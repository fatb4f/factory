from __future__ import annotations

import argparse
import json
import subprocess
import sys
import threading
import time
from pathlib import Path
from queue import Empty, Queue
from typing import Any


class LspClient:
    def __init__(self, command: list[str], root: Path):
        self.command = command
        self.root = root
        self.proc: subprocess.Popen[bytes] | None = None
        self.next_id = 1
        self.responses: Queue[dict[str, Any]] = Queue()
        self.notifications: Queue[dict[str, Any]] = Queue()

    def start(self) -> None:
        if self.proc and self.proc.poll() is None:
            return
        self.proc = subprocess.Popen(
            self.command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=sys.stderr.buffer,
            cwd=self.root,
        )
        threading.Thread(target=self._reader, daemon=True).start()
        self.request(
            "initialize",
            {
                "processId": None,
                "rootUri": self.root.as_uri(),
                "capabilities": {"textDocument": {"publishDiagnostics": {}}},
            },
        )
        self.notify("initialized", {})

    def _reader(self) -> None:
        assert self.proc and self.proc.stdout
        stream = self.proc.stdout
        while True:
            headers: dict[str, str] = {}
            while True:
                line = stream.readline()
                if not line:
                    return
                if line in {b"\r\n", b"\n"}:
                    break
                key, _, value = line.decode("ascii").partition(":")
                headers[key.lower()] = value.strip()
            size = int(headers.get("content-length", "0"))
            if size <= 0:
                continue
            message = json.loads(stream.read(size))
            if "id" in message:
                self.responses.put(message)
            else:
                self.notifications.put(message)

    def _write(self, message: dict[str, Any]) -> None:
        assert self.proc and self.proc.stdin
        body = json.dumps(message, separators=(",", ":")).encode()
        self.proc.stdin.write(f"Content-Length: {len(body)}\r\n\r\n".encode() + body)
        self.proc.stdin.flush()

    def request(self, method: str, params: dict[str, Any]) -> Any:
        self.start()
        request_id = self.next_id
        self.next_id += 1
        self._write({"jsonrpc": "2.0", "id": request_id, "method": method, "params": params})
        while True:
            response = self.responses.get(timeout=30)
            if response.get("id") == request_id:
                if "error" in response:
                    raise RuntimeError(response["error"])
                return response.get("result")

    def notify(self, method: str, params: dict[str, Any]) -> None:
        self._write({"jsonrpc": "2.0", "method": method, "params": params})

    def open_document(self, path: Path, language: str) -> str:
        uri = path.resolve().as_uri()
        self.notify(
            "textDocument/didOpen",
            {
                "textDocument": {
                    "uri": uri,
                    "languageId": language,
                    "version": 1,
                    "text": path.read_text(encoding="utf-8"),
                }
            },
        )
        return uri

    def diagnostics(self, path: Path, language: str, timeout: float = 2.0) -> list[Any]:
        uri = self.open_document(path, language)
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            try:
                note = self.notifications.get(timeout=max(0.01, deadline - time.monotonic()))
            except Empty:
                break
            if (
                note.get("method") == "textDocument/publishDiagnostics"
                and note.get("params", {}).get("uri") == uri
            ):
                return note["params"].get("diagnostics", [])
        return []


def write_message(message: dict[str, Any]) -> None:
    sys.stdout.write(json.dumps(message, separators=(",", ":")) + "\n")
    sys.stdout.flush()


def tools() -> list[dict[str, Any]]:
    position_schema = {
        "type": "object",
        "properties": {
            "path": {"type": "string"},
            "line": {"type": "integer", "minimum": 0},
            "character": {"type": "integer", "minimum": 0},
        },
        "required": ["path"],
        "additionalProperties": False,
    }
    path_schema = {
        "type": "object",
        "properties": {"path": {"type": "string"}},
        "required": ["path"],
        "additionalProperties": False,
    }
    return [
        {
            "name": "diagnostics",
            "description": "Open a document and return published diagnostics.",
            "inputSchema": path_schema,
        },
        {"name": "hover", "description": "Return hover information.", "inputSchema": position_schema},
        {
            "name": "definition",
            "description": "Return definitions.",
            "inputSchema": position_schema,
        },
        {
            "name": "references",
            "description": "Return references.",
            "inputSchema": position_schema,
        },
        {
            "name": "document_symbols",
            "description": "Return document symbols.",
            "inputSchema": path_schema,
        },
    ]


def serve(language: str, server_command: list[str]) -> int:
    root = Path.cwd().resolve()
    client = LspClient(server_command, root)
    for raw in sys.stdin:
        message: dict[str, Any] = {}
        try:
            message = json.loads(raw)
            method = message.get("method")
            request_id = message.get("id")
            if method == "initialize":
                result = {
                    "protocolVersion": "2025-06-18",
                    "capabilities": {"tools": {}},
                    "serverInfo": {"name": f"{language}-lsp-mcp", "version": "0.1.0"},
                }
            elif method == "tools/list":
                result = {"tools": tools()}
            elif method == "tools/call":
                params = message["params"]
                name = params["name"]
                args = params.get("arguments", {})
                path = (root / args["path"]).resolve()
                if root not in path.parents and path != root:
                    raise ValueError("path escapes configured workspace root")
                if name == "diagnostics":
                    result_value = client.diagnostics(path, language)
                else:
                    uri = client.open_document(path, language)
                    position = {
                        "line": args.get("line", 0),
                        "character": args.get("character", 0),
                    }
                    methods = {
                        "hover": "textDocument/hover",
                        "definition": "textDocument/definition",
                        "references": "textDocument/references",
                        "document_symbols": "textDocument/documentSymbol",
                    }
                    lsp_params: dict[str, Any] = {"textDocument": {"uri": uri}}
                    if name != "document_symbols":
                        lsp_params["position"] = position
                    if name == "references":
                        lsp_params["context"] = {"includeDeclaration": True}
                    result_value = client.request(methods[name], lsp_params)
                result = {
                    "content": [{"type": "text", "text": json.dumps(result_value, indent=2)}],
                    "structuredContent": {"result": result_value},
                }
            elif method and method.startswith("notifications/"):
                continue
            else:
                raise ValueError(f"unsupported MCP method: {method}")
            if request_id is not None:
                write_message({"jsonrpc": "2.0", "id": request_id, "result": result})
        except Exception as exc:
            if isinstance(message, dict) and message.get("id") is not None:
                write_message(
                    {
                        "jsonrpc": "2.0",
                        "id": message["id"],
                        "error": {"code": -32603, "message": str(exc)},
                    }
                )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--language", choices=("cue", "go"), required=True)
    parser.add_argument("server", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.server[1:] if args.server and args.server[0] == "--" else args.server
    if not command:
        parser.error("missing language-server command after --")
    return serve(args.language, command)


if __name__ == "__main__":
    raise SystemExit(main())
