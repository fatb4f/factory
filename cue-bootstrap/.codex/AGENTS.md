# cue-bootstrap agent contract

Issue #109 is the requirements authority for this temporary bootstrap root.
Pinned CUE sources define language semantics. The workbook orchestrates and
records observations; it is not semantic authority.

## Environment

All Python and MCP entrypoints use the project at `workbook/`.

```text
allowed:
  uv run --project workbook --locked ...
  uv lock --check --project workbook

forbidden:
  system python
  pip install
  requirements.txt
  PEP 723 inline dependencies
  another venv
```

A missing or stale `uv.lock` is a blocker. Do not bypass `--locked`.

## Session classes

Declare exactly one class at session start.

### authority

May update `.codex/authority/cue/**` and pilot traceability. May not change the
pattern, fixtures, probes, runner, worker, or expected assertions.

### pattern

May update `pattern/bounded-int/pattern.cue` and its traceability. May run format,
vet, and CUE-LSP diagnostics. May not design fixtures or modify backends.

### fixture-design

May update registered fixture sources and manifest entries. May not alter the
pattern, kernel, expected outcome after execution, or backend code.

### probe

May update `probe/**` and protocol-compatible assertion declarations. May not
alter the subject, fixtures, or runner to obtain a passing result.

### runner

May update `runner/**` only. Must use gopls MCP diagnostics. Runner output is
facts only.

### harness

May update `workbook/qualification/**`, `workbook/cue_workbook.py`, project
metadata, and MCP adapters. It may not change pattern semantics or fixtures.

### execution

Read-only. Runs registered assertions and records workbook state.

### diagnosis

Read-only. Classifies a failure as authority, pattern, kernel, fixture, probe,
cue-py, Go runner, MCP, protocol, or workbook.

### correction

Applies one accepted diagnosis to one surface. Full replay occurs in a new
execution session.

## Required loop

```text
design -> implement -> execute -> diagnose -> select correction
       -> correct one surface -> execute in a new session
```

Never combine fixture design, subject correction, and judging execution in one
session.

## Native isolation

Accepted cue-py evaluations run in a child Python process. Native contexts,
values, CFFI objects, and resource handles never enter the Marimo process.
The Go runner is independent and must not import cue-py normalization code.
