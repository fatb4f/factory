from __future__ import annotations

import importlib
import json
from dataclasses import dataclass
from pathlib import Path
from types import ModuleType
from typing import Any


class NativeBindingUnavailable(RuntimeError):
    """Raised when the generated gopy extension is not available."""


def import_bindings() -> ModuleType:
    """Import the generated binding package built for this interpreter."""
    errors: list[BaseException] = []
    for name in ("cue_native.bindings", "bindings"):
        try:
            return importlib.import_module(name)
        except (ImportError, OSError) as exc:
            errors.append(exc)
    detail = "; ".join(str(error) for error in errors)
    raise NativeBindingUnavailable(
        "gopy CUE extension is unavailable; run "
        "`python -m qualification.bootstrap_native`: " + detail
    )


def binding_identity(bindings: ModuleType | None = None) -> dict[str, Any]:
    bindings = bindings or import_bindings()
    return json.loads(bindings.IdentityJSON())


def build_manifest() -> dict[str, Any] | None:
    path = Path(__file__).resolve().parents[1] / ".deps" / "manifest.json"
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


@dataclass
class DirectSession:
    """Interactive, in-process access to live Go-backed CUE proxy objects.

    This mode is intentionally not accepted qualification evidence. A fatal
    native failure would terminate the Marimo kernel.
    """

    bindings: ModuleType
    context: Any

    @classmethod
    def open(cls) -> "DirectSession":
        bindings = import_bindings()
        return cls(bindings=bindings, context=bindings.NewContext())

    @property
    def identity(self) -> dict[str, Any]:
        return binding_identity(self.bindings)

    def compile(self, source: str, filename: str = "interactive.cue") -> Any:
        return self.context.CompileString(source, filename)

    def open_loader(self, root: str) -> Any:
        return self.context.OpenLoader(root)


def summarize_value(value: Any) -> dict[str, Any]:
    """Return a native-free summary while leaving the live proxy available."""
    diagnostics = json.loads(value.DiagnosticsJSON())
    return {
        "exists": bool(value.Exists()),
        "bottom": bool(value.IsBottom()),
        "error": value.Error() or None,
        "kind": value.Kind(),
        "incomplete_kind": value.IncompleteKind(),
        "diagnostics": diagnostics,
    }
