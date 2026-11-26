"""Exercise the installed Core wheel with the actual synthetic M1 domain adapter."""

from importlib.metadata import distribution
from pathlib import Path
import sys
import unittest

from runtime import transform_execution


def main():
    package = distribution("factory-domain-core")
    installed_executor = package.locate_file("runtime/transform_execution.py").resolve()
    if Path(transform_execution.__file__).resolve() != installed_executor:
        raise RuntimeError("run with python -I and install the candidate wheel first")
    if not (transform_execution.CUE_ROOT / "cue.mod/module.cue").is_file():
        raise RuntimeError("installed Core wheel lacks its CUE module")
    scripts = Path(__file__).resolve().parent
    # Only the domain adapter and synthetic fixture come from this checkout.
    # Python has already bound the shared runtime package to the installed wheel.
    sys.path.extend((str(scripts), str(scripts.parent)))
    suite = unittest.defaultTestLoader.loadTestsFromNames(("test_ivac_legal_units", "test_ivac_review_desk"))
    return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
