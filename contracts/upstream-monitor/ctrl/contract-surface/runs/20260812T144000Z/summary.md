# ctrl upstream monitor summary

## Run identity

- Run: `20260812T144000Z`
- Profile: `ctrl`
- Terminal state: `terminal_success`
- Mode: Astral Rust profile-extension baseline

## Decision

- Critical / blocking-gate: **0**
- High / contract-update: **1**
- Notes: **1**

## High

**Admit Astral Rust machinery as the static Python evidence plane.**

The profile now models Ruff/ty's shared Rust substrate—database/index, parser, AST, Ruff semantic analysis, ty module resolution, type core, semantic analysis, and IDE projection—and correlates it with CPython AST, symtable, importlib, compiler/runtime evidence and local probes.

CPython retains semantic precedence for CPython behavior; Astral observations cannot override contradictory compiler/runtime evidence.

## Note

`astral-sh/ruff@main` is forecast evidence. Concrete analyzer qualification must bind the Ruff/ty artifacts actually selected by `ctrl`'s committed `uv.lock` to their source/release provenance.

## Execution graph delta

Added operations:

- `AcquireAstralAnalysis`
- `CorrelateStaticDynamic`

Added correlation probes:

- `astral-cpython-ast`
- `astral-cpython-bindings`
- `astral-cpython-imports`

## Validation

CUE, CPython regrtest, and executable Astral/CPython correlation probes were not executed by the GitHub App actuator. No such execution is claimed.
