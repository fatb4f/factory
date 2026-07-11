# /// script
# requires-python = ">=3.11"
# dependencies = ["marimo"]
# ///

from __future__ import annotations

import argparse
import importlib.util
import json
import sys
from pathlib import Path
from typing import Any


_ALLOWED_FIELDS = {
    "agent_id",
    "agent_type",
    "cwd",
    "hook_event_name",
    "model",
    "permission_mode",
    "prompt",
    "session_id",
    "transcript_path",
    "turn_id",
}


def read_event() -> dict[str, Any]:
    value = json.load(sys.stdin)
    if not isinstance(value, dict):
        raise ValueError("hook input must be an object")
    if set(value) - _ALLOWED_FIELDS:
        raise ValueError("hook input contains unknown fields")
    if value.get("hook_event_name") != "UserPromptSubmit":
        raise ValueError("unsupported hook event")
    prompt = value.get("prompt")
    if not isinstance(prompt, str) or not prompt.strip():
        raise ValueError("prompt must be a non-empty string")
    return value


def load_app(workbook: Path):
    spec = importlib.util.spec_from_file_location(
        "factory_context_resolver",
        workbook,
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load workbook: {workbook}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.app


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", required=True, type=Path)
    args = parser.parse_args()

    repo_root = args.repo_root.resolve()
    event = read_event()
    workbook = repo_root / "marimo/profiles/context-resolver/context_resolver.py"

    request = {
        "schema": "factory.context-request.v0",
        "event": "UserPromptSubmit",
        "prompt": event["prompt"],
        "repo_root": str(repo_root),
        "budget": {
            "maxFragments": 12,
            "maxSteps": 8,
            "maxNodes": 48,
            "maxTokens": 6000,
        },
    }

    _outputs, definitions = load_app(workbook).run(
        defs={"workbook_request": request}
    )
    result = definitions.get("workbook_result")
    if not isinstance(result, dict):
        raise RuntimeError("workbook did not define workbook_result")
    if not result.get("admitted"):
        raise RuntimeError("workbook context packet was not admitted")

    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": json.dumps(
                    result,
                    ensure_ascii=False,
                    separators=(",", ":"),
                ),
            }
        },
        sys.stdout,
        ensure_ascii=False,
        separators=(",", ":"),
    )
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"factory context hook: {exc}", file=sys.stderr)
        raise SystemExit(2) from exc
