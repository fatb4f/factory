# CUE bootstrap laboratory

This directory is the implementation branch for factory issue #109. It is a
self-contained, temporary repository root intended for later extraction.

The bootstrap proves one bounded CUE pattern end-to-end before the current CUE
skill is cleaned up or extended:

```text
pinned authority
  -> bounded-int pattern
  -> minimum kernel projection
  -> registered fixtures
  -> reusable probe request
  -> isolated cue-py/libcue worker
  -> independent Go reference runner
  -> Marimo comparison workbook
```

## Implemented slice

- repository and session isolation policy;
- project-local Codex MCP declarations routed through `workbook/`;
- pinned CUE, cue-py, and libcue source identities;
- one `bounded-int` pilot pattern and minimum kernel;
- positive, negative, and directional fixtures;
- strict request/response models with facts-only backend output;
- one-request-per-process cue-py worker;
- independent Go reference runner source;
- Marimo workbook skeleton and qualification table;
- protocol/self-test suite that does not require native CUE dependencies.

## Deliberately incomplete

`workbook/uv.lock` is not committed by this initial slice. The project file is
complete, but the execution environment used to author this branch had no
network access and no package cache from which a truthful lock could be
resolved. `.codex/config.toml` uses `--locked`, so MCP launch fails closed until
the lock is generated and reviewed.

The first follow-up action is:

```bash
cd cue-bootstrap/workbook
uv lock
uv lock --check
```

Do not hand-author or copy a lockfile from another project.

## Commands

```bash
# Protocol and subprocess-classification tests; no cue-py/libcue required.
uv run --project workbook python -m qualification.selftest

# Acquire exact cue-py/libcue sources and build the shared library.
uv run --project workbook --locked \
  python -m qualification.bootstrap_native

# Build the independent Go reference runner.
(cd runner && go build -o bin/cueprobe ./cmd/cueprobe)

# Open the executable iteration record.
uv run --project workbook --locked \
  marimo edit workbook/cue_workbook.py
```

## Boundaries

- Do not import `.codex/skills/cue/**` from the parent repository.
- Do not create another virtual environment or dependency file.
- Do not place native CUE values or CFFI handles in Marimo cells.
- Do not send expected results to either backend.
- Do not use free-form workbook input to satisfy qualification assertions.
- One session class may mutate one declared surface only.
