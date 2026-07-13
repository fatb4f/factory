from __future__ import annotations

import hashlib
import json
import subprocess
from pathlib import Path

CUE_PY = ("https://github.com/cue-lang/cue-py", "81e6fb15247ed7050e5bd987db032f757e06c8f0")
LIBCUE = ("https://github.com/cue-lang/libcue", "96d0572450429fa28d7a2345c04a8c47c85b47e4")


def run(*args: str, cwd: Path | None = None) -> None:
    subprocess.run(args, cwd=cwd, check=True)


def checkout(target: Path, repository: str, commit: str) -> None:
    if not target.exists():
        run("git", "clone", "--filter=blob:none", "--no-checkout", repository, str(target))
    run("git", "fetch", "--depth", "1", "origin", commit, cwd=target)
    run("git", "checkout", "--detach", commit, cwd=target)
    observed = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=target, text=True).strip()
    if observed != commit:
        raise RuntimeError(f"checkout identity mismatch for {target}: {observed}")


def digest(path: Path) -> str:
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    workbook = Path(__file__).resolve().parents[1]
    deps = workbook / ".deps"
    deps.mkdir(exist_ok=True)
    cue_py = deps / "cue-py"
    libcue = deps / "libcue"
    checkout(cue_py, *CUE_PY)
    checkout(libcue, *LIBCUE)

    system = __import__("platform").system()
    library = {"Darwin": "libcue.dylib", "Windows": "cue.dll"}.get(system, "libcue.so")
    run("go", "build", "-o", library, "-buildmode=c-shared", cwd=libcue)

    manifest = {
        "cue_py": {"repository": CUE_PY[0], "commit": CUE_PY[1]},
        "libcue": {
            "repository": LIBCUE[0],
            "commit": LIBCUE[1],
            "library": library,
            "digest": digest(libcue / library),
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
