# /// script
# requires-python = ">=3.11"
# dependencies = ["hypothesis", "marimo", "pydantic"]
# ///

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path
from typing import Any, Literal

import marimo

__generated_with = "0.19.0"
app = marimo.App(width="full")


@app.cell
def _():
    import json
    import subprocess
    from pathlib import Path
    from typing import Any

    from hypothesis import given, settings, strategies as st
    from pydantic import BaseModel, ConfigDict, Field, ValidationError, model_validator

    import marimo as mo

    class Budget(BaseModel):
        model_config = ConfigDict(extra="forbid")

        maxFragments: int = Field(ge=1, le=32)
        maxSteps: int = Field(ge=1, le=32)
        maxNodes: int = Field(ge=4, le=128)
        maxTokens: int = Field(ge=256, le=20_000)

    class WorkbookRequest(BaseModel):
        model_config = ConfigDict(extra="forbid")

        schema_: Literal["factory.context-request.v0"] = Field(alias="schema")
        event: str = Field(min_length=1)
        prompt: str = Field(min_length=1)
        repo_root: str = Field(min_length=1)
        budget: Budget

    class SourceRef(BaseModel):
        model_config = ConfigDict(extra="forbid")

        path: str = Field(min_length=1)
        symbol: str | None = None

        def resolve_under(self, root: Path) -> Path:
            candidate = (root / self.path).resolve()
            candidate.relative_to(root.resolve())
            return candidate

    class GraphProjection(BaseModel):
        model_config = ConfigDict(extra="allow")

        valid: Literal[True]
        resources: dict[str, dict[str, Any]]
        topology: dict[str, dict[str, Literal[True]]]

    class BoundaryExport(BaseModel):
        model_config = ConfigDict(extra="allow")

        context: GraphProjection
        workflow: GraphProjection

    class CheckResult(BaseModel):
        model_config = ConfigDict(extra="allow")

        id: str = Field(min_length=1)
        status: Literal["pending", "pass", "fail", "blocked"]

    class GateResult(BaseModel):
        model_config = ConfigDict(extra="allow")

        id: str = Field(min_length=1)
        satisfied: bool

    class ContextPacket(BaseModel):
        model_config = ConfigDict(extra="allow")

        schema_: Literal["factory.context-packet.v0"] = Field(alias="schema")
        authority: Literal[False]
        generated: Literal[True]
        transient: Literal[True]
        admitted: bool
        request: WorkbookRequest
        selected_fragments: list[dict[str, Any]]
        checks: list[CheckResult]
        gates: list[GateResult]

        @model_validator(mode="after")
        def admitted_packets_have_satisfied_gates(self) -> "ContextPacket":
            if self.admitted and (
                not self.selected_fragments
                or not self.gates
                or any(not gate.satisfied for gate in self.gates)
                or any(check.status in {"fail", "blocked"} for check in self.checks)
            ):
                raise ValueError("admitted packet violates check or gate admission")
            return self

    def cue_output(module: Path) -> dict[str, Any]:
        completed = subprocess.run(
            ["cue", "export", ".", "-e", "output", "--out", "json"],
            cwd=module,
            check=True,
            capture_output=True,
            text=True,
            timeout=15,
        )
        value = json.loads(completed.stdout)
        if not isinstance(value, dict):
            raise TypeError(f"{module}: CUE output must be an object")
        return value

    def validate_cue_modules(repo_root: Path) -> list[dict[str, str]]:
        modules = (
            "marimo/profiles/context-resolver/.kb",
            "marimo/profiles/code-intel/python/.kb",
            "marimo/profiles/code-intel/cue/.kb",
        )
        results: list[dict[str, str]] = []
        for relative in modules:
            module = repo_root / relative
            try:
                subprocess.run(
                    ["cue", "vet", "."],
                    cwd=module,
                    check=True,
                    capture_output=True,
                    text=True,
                    timeout=15,
                )
                output = cue_output(module)
                export = BoundaryExport.model_validate(output)
                for resource in export.context.resources.values():
                    source = resource.get("source")
                    if isinstance(source, dict):
                        source_ref = SourceRef.model_validate(source)
                        candidate = (module / source_ref.path).resolve()
                        candidate.relative_to(repo_root.resolve())
                results.append({"module": relative, "status": "pass"})
            except Exception as exc:
                results.append({"module": relative, "status": "fail", "reason": str(exc)})
        return results

    def run_properties() -> dict[str, Any]:
        counters = {"examples": 0}

        @settings(derandomize=True, deadline=None, max_examples=32)
        @given(st.text(min_size=1, max_size=80))
        def paths_do_not_escape_repository(path: str) -> None:
            counters["examples"] += 1
            root = Path("/repo")
            try:
                resolved = SourceRef(path=path).resolve_under(root)
            except ValueError:
                return
            assert resolved.is_relative_to(root)

        @settings(derandomize=True, deadline=None, max_examples=32)
        @given(
            max_fragments=st.integers(min_value=-10, max_value=50),
            max_steps=st.integers(min_value=-10, max_value=50),
            max_nodes=st.integers(min_value=-10, max_value=150),
            max_tokens=st.integers(min_value=-10, max_value=21_000),
        )
        def invalid_budgets_are_rejected(
            max_fragments: int,
            max_steps: int,
            max_nodes: int,
            max_tokens: int,
        ) -> None:
            counters["examples"] += 1
            payload = {
                "schema": "factory.context-request.v0",
                "event": "operator",
                "prompt": "validate",
                "repo_root": "/repo",
                "budget": {
                    "maxFragments": max_fragments,
                    "maxSteps": max_steps,
                    "maxNodes": max_nodes,
                    "maxTokens": max_tokens,
                },
            }
            valid = (
                1 <= max_fragments <= 32
                and 1 <= max_steps <= 32
                and 4 <= max_nodes <= 128
                and 256 <= max_tokens <= 20_000
            )
            if valid:
                WorkbookRequest.model_validate(payload)
            else:
                try:
                    WorkbookRequest.model_validate(payload)
                except ValidationError:
                    return
                raise AssertionError("out-of-range budget was accepted")

        paths_do_not_escape_repository()
        invalid_budgets_are_rejected()
        return {"status": "pass", "examples": counters["examples"]}

    return mo, run_properties, validate_cue_modules


@app.cell
def _(mo):
    run_validation = mo.ui.run_button(label="Run architecture validation")
    mo.vstack([mo.md("# Architecture validation"), run_validation])
    return (run_validation,)


@app.cell
def _(run_properties, run_validation, validate_cue_modules):
    if not run_validation.value:
        report = {"status": "pending", "reason": "run validation on demand"}
    else:
        repo_root = Path.cwd()
        cue_results = validate_cue_modules(repo_root)
        properties = run_properties()
        report = {
            "status": "pass"
            if all(result["status"] == "pass" for result in cue_results)
            and properties["status"] == "pass"
            else "fail",
            "cue": cue_results,
            "hypothesis": properties,
        }
    return (report,)


@app.cell
def _(mo, report):
    mo.json(report)
    return


def _run_operator_validation(repo_root: Path) -> int:
    _outputs, definitions = app.run()
    cue_results = definitions["validate_cue_modules"](repo_root.resolve())
    properties = definitions["run_properties"]()
    report = {
        "status": "pass"
        if all(result["status"] == "pass" for result in cue_results)
        and properties["status"] == "pass"
        else "fail",
        "cue": cue_results,
        "hypothesis": properties,
    }
    print(json.dumps(report, separators=(",", ":")))
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--validate", action="store_true")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    args, marimo_args = parser.parse_known_args()
    if args.validate:
        raise SystemExit(_run_operator_validation(args.repo_root))
    import sys

    sys.argv = [sys.argv[0], *marimo_args]
    app.run()
