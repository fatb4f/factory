from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

CUE = (
    "https://github.com/cue-lang/cue",
    "806821e40fae070318600a264d311517e596353b",
)
GOPY = (
    "https://github.com/go-python/gopy",
    "72557f647208599c726c14dc9721a6c850d2e6d9",
)
TARGET_CUE_MODULE_VERSION = "v0.18.0"
GOIMPORTS_VERSION = "v0.38.0"
BINDING_PACKAGE = "github.com/fatb4f/cue-bootstrap/runner/bindings"


def run(
    *args: str,
    cwd: Path | None = None,
    env: dict[str, str] | None = None,
) -> None:
    merged = os.environ.copy()
    if env:
        merged.update(env)
    subprocess.run(args, cwd=cwd, env=merged, check=True)


def output(*args: str, cwd: Path | None = None) -> str:
    return subprocess.check_output(args, cwd=cwd, text=True).strip()


def checkout(target: Path, repository: str, commit: str) -> None:
    if not target.exists():
        run("git", "clone", "--filter=blob:none", "--no-checkout", repository, str(target))
    run("git", "fetch", "--depth", "1", "origin", commit, cwd=target)
    run("git", "checkout", "--detach", commit, cwd=target)
    observed = output("git", "rev-parse", "HEAD", cwd=target)
    if observed != commit:
        raise RuntimeError(f"checkout identity mismatch for {target}: {observed}")


def digest(path: Path) -> str:
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


def combined_digest(paths: list[Path]) -> str:
    hasher = hashlib.sha256()
    for path in sorted(paths):
        hasher.update(str(path.name).encode("utf-8"))
        hasher.update(path.read_bytes())
    return "sha256:" + hasher.hexdigest()


def go_mod_json(root: Path) -> dict[str, Any]:
    return json.loads(output("go", "mod", "edit", "-json", cwd=root))


def replacement_path(document: dict[str, Any], module: str) -> str | None:
    for replacement in document.get("Replace", []):
        if replacement.get("Old", {}).get("Path") == module:
            return replacement.get("New", {}).get("Path")
    return None


def require_target_checkout(runner: Path, cue_source: Path) -> None:
    document = go_mod_json(runner)
    replacement = replacement_path(document, "cuelang.org/go")
    if replacement is None:
        raise RuntimeError("runner/go.mod does not replace cuelang.org/go")
    resolved = (runner / replacement).resolve()
    if resolved != cue_source.resolve():
        raise RuntimeError(
            f"runner CUE replacement mismatch: {resolved} != {cue_source.resolve()}"
        )


def install_gopy(gopy_source: Path, tools: Path) -> Path:
    tools.mkdir(parents=True, exist_ok=True)
    env = {"GOBIN": str(tools)}
    run("go", "install", ".", cwd=gopy_source, env=env)
    run(
        "go",
        "install",
        f"golang.org/x/tools/cmd/goimports@{GOIMPORTS_VERSION}",
        cwd=gopy_source,
        env=env,
    )
    binary = tools / ("gopy.exe" if os.name == "nt" else "gopy")
    if not binary.exists():
        raise RuntimeError(f"gopy binary was not created: {binary}")
    return binary


def build_extension(gopy_binary: Path, runner: Path, workbook: Path, tools: Path) -> Path:
    destination = workbook / "cue_native"
    if destination.exists():
        shutil.rmtree(destination)
    env = {"PATH": str(tools) + os.pathsep + os.environ.get("PATH", "")}
    run(
        str(gopy_binary),
        "build",
        f"-vm={sys.executable}",
        "-name=cue_native",
        f"-output={destination}",
        BINDING_PACKAGE,
        cwd=runner,
        env=env,
    )
    return destination


def verify_extension(workbook: Path) -> dict[str, Any]:
    script = """
import json
from cue_native import bindings
print(bindings.IdentityJSON())
""".strip()
    raw = output(sys.executable, "-c", script, cwd=workbook)
    identity = json.loads(raw)
    if identity.get("cue_revision") != CUE[1]:
        raise RuntimeError(f"extension CUE revision mismatch: {identity}")
    if identity.get("cue_module_version") != TARGET_CUE_MODULE_VERSION:
        raise RuntimeError(f"extension target module mismatch: {identity}")
    if identity.get("observed_cue_module_version") != TARGET_CUE_MODULE_VERSION:
        raise RuntimeError(f"extension compiled module mismatch: {identity}")
    return identity


def build_runner(runner: Path) -> Path:
    binary = runner / "bin" / ("cueprobe.exe" if os.name == "nt" else "cueprobe")
    binary.parent.mkdir(parents=True, exist_ok=True)
    run("go", "build", "-o", str(binary), "./cmd/cueprobe", cwd=runner)
    return binary


def main() -> int:
    workbook = Path(__file__).resolve().parents[1]
    root = workbook.parent
    runner = root / "runner"
    deps = workbook / ".deps"
    deps.mkdir(exist_ok=True)

    cue_source = deps / "cue"
    gopy_source = deps / "gopy"
    tools = deps / "bin"

    checkout(cue_source, *CUE)
    checkout(gopy_source, *GOPY)
    require_target_checkout(runner, cue_source)
    run("go", "mod", "tidy", cwd=runner)

    gopy_binary = install_gopy(gopy_source, tools)
    extension = build_extension(gopy_binary, runner, workbook, tools)
    identity = verify_extension(workbook)
    cueprobe = build_runner(runner)

    extension_files = [
        path
        for path in extension.rglob("*")
        if path.is_file() and path.suffix in {".so", ".dylib", ".dll", ".pyd"}
    ]
    if not extension_files:
        raise RuntimeError(f"no native extension artifact found under {extension}")

    manifest = {
        "cue_target": {
            "repository": CUE[0],
            "commit": CUE[1],
            "module_version": TARGET_CUE_MODULE_VERSION,
            "release_line": "v0.18",
        },
        "gopy": {
            "repository": GOPY[0],
            "commit": GOPY[1],
            "binary": str(gopy_binary),
        },
        "python": {
            "executable": sys.executable,
            "abi": getattr(sys.implementation, "cache_tag", None),
            "version": sys.version,
        },
        "gopy_extension": {
            "directory": str(extension),
            "files": [
                {"path": str(path), "digest": digest(path)} for path in extension_files
            ],
            "combined_digest": combined_digest(extension_files),
            "identity": identity,
        },
        "cueprobe": {
            "path": str(cueprobe),
            "digest": digest(cueprobe),
        },
        "go": {
            "version": output("go", "version"),
            "goimports_version": GOIMPORTS_VERSION,
        },
    }
    (deps / "manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
