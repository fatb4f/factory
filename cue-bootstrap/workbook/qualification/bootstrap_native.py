from __future__ import annotations

import hashlib
import json
import subprocess
from pathlib import Path
from typing import Any

CUE = (
    "https://github.com/cue-lang/cue",
    "806821e40fae070318600a264d311517e596353b",
)
CUE_PY = (
    "https://github.com/cue-lang/cue-py",
    "81e6fb15247ed7050e5bd987db032f757e06c8f0",
)
LIBCUE = (
    "https://github.com/cue-lang/libcue",
    "96d0572450429fa28d7a2345c04a8c47c85b47e4",
)
TARGET_CUE_MODULE_VERSION = "v0.18.0"
UPSTREAM_LIBCUE_MODULE_VERSION = "v0.15.3"


def run(*args: str, cwd: Path | None = None) -> None:
    subprocess.run(args, cwd=cwd, check=True)


def checkout(target: Path, repository: str, commit: str) -> None:
    if not target.exists():
        run("git", "clone", "--filter=blob:none", "--no-checkout", repository, str(target))
    run("git", "fetch", "--depth", "1", "origin", commit, cwd=target)
    run("git", "checkout", "--detach", commit, cwd=target)
    observed = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=target, text=True
    ).strip()
    if observed != commit:
        raise RuntimeError(f"checkout identity mismatch for {target}: {observed}")


def digest(path: Path) -> str:
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


def go_mod_json(root: Path) -> dict[str, Any]:
    raw = subprocess.check_output(
        ["go", "mod", "edit", "-json"], cwd=root, text=True
    )
    return json.loads(raw)


def required_version(document: dict[str, Any], module: str) -> str | None:
    for requirement in document.get("Require", []):
        if requirement.get("Path") == module:
            return requirement.get("Version")
    return None


def replacement_path(document: dict[str, Any], module: str) -> str | None:
    for replacement in document.get("Replace", []):
        if replacement.get("Old", {}).get("Path") == module:
            return replacement.get("New", {}).get("Path")
    return None


def rebind_libcue_engine(libcue: Path, cue_source: Path) -> None:
    before = go_mod_json(libcue)
    observed_upstream = required_version(before, "cuelang.org/go")
    if observed_upstream != UPSTREAM_LIBCUE_MODULE_VERSION:
        raise RuntimeError(
            "unexpected upstream libcue engine: "
            f"expected {UPSTREAM_LIBCUE_MODULE_VERSION}, observed {observed_upstream}"
        )

    run(
        "go",
        "mod",
        "edit",
        f"-require=cuelang.org/go@{TARGET_CUE_MODULE_VERSION}",
        cwd=libcue,
    )
    run(
        "go",
        "mod",
        "edit",
        f"-replace=cuelang.org/go={cue_source.resolve()}",
        cwd=libcue,
    )
    run("go", "mod", "tidy", cwd=libcue)

    after = go_mod_json(libcue)
    if required_version(after, "cuelang.org/go") != TARGET_CUE_MODULE_VERSION:
        raise RuntimeError("libcue target engine version was not applied")
    rebound = replacement_path(after, "cuelang.org/go")
    if rebound is None or Path(rebound).resolve() != cue_source.resolve():
        raise RuntimeError("libcue target engine checkout was not applied")


def main() -> int:
    workbook = Path(__file__).resolve().parents[1]
    deps = workbook / ".deps"
    deps.mkdir(exist_ok=True)

    cue_source = deps / "cue"
    cue_py = deps / "cue-py"
    libcue = deps / "libcue"

    checkout(cue_source, *CUE)
    checkout(cue_py, *CUE_PY)
    checkout(libcue, *LIBCUE)
    rebind_libcue_engine(libcue, cue_source)

    system = __import__("platform").system()
    library = {"Darwin": "libcue.dylib", "Windows": "cue.dll"}.get(
        system, "libcue.so"
    )
    run("go", "build", "-o", library, "-buildmode=c-shared", cwd=libcue)

    manifest = {
        "cue_target": {
            "repository": CUE[0],
            "commit": CUE[1],
            "module_version": TARGET_CUE_MODULE_VERSION,
            "release_line": "v0.18",
        },
        "cue_py": {"repository": CUE_PY[0], "commit": CUE_PY[1]},
        "libcue": {
            "repository": LIBCUE[0],
            "commit": LIBCUE[1],
            "library": library,
            "digest": digest(libcue / library),
            "upstream_cue_module_version": UPSTREAM_LIBCUE_MODULE_VERSION,
            "target_cue_module_version": TARGET_CUE_MODULE_VERSION,
            "target_cue_commit": CUE[1],
            "engine_rebound": True,
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
