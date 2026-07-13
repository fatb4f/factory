# CUE bootstrap laboratory

This directory is the implementation branch for factory issue #109. It is a
self-contained, temporary repository root intended for later extraction.

The bootstrap proves one bounded CUE pattern end-to-end before the current CUE
skill is cleaned up or extended:

```text
pinned CUE v0.18 authority
  -> bounded-int pattern
  -> minimum kernel projection
  -> registered fixtures
  -> reusable probe request
  -> isolated cue-py/libcue worker
  -> independent Go reference runner
  -> Marimo comparison workbook
```

## Engine identity

The semantic target is the CUE v0.18 development line, pinned to exact commit:

```text
cue-lang/cue@806821e40fae070318600a264d311517e596353b
language/module version: v0.18.0
```

The pinned upstream `libcue` source still declares `cuelang.org/go v0.15.3`.
That version is provenance, not the bootstrap target. `qualification.bootstrap_native`
verifies the upstream declaration and then explicitly rebinds libcue to the exact
v0.18 CUE checkout before building the shared library. The Go reference runner
uses the same local checkout through its `go.mod` replacement.

A run is comparable only when both backends report:

```text
cue_module_version: v0.18.0
engine_revision: 806821e40fae070318600a264d311517e596353b
```

## Implemented slice

- repository and session isolation policy;
- project-local Codex MCP declarations routed through `workbook/`;
- pinned CUE v0.18, cue-py, and libcue source identities;
- explicit libcue engine rebind onto the target CUE checkout;
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

The v0.18 runner `go.sum` is also not fabricated. It must be generated only
after `workbook/.deps/cue` is checked out at the pinned target commit.

The first follow-up actions are:

```bash
cd cue-bootstrap/workbook
uv lock
uv lock --check

uv run --project . --locked \
  python -m qualification.bootstrap_native

cd ../runner
go mod tidy
go build -o bin/cueprobe ./cmd/cueprobe
```

CUE v0.18 currently requires Go 1.25 or newer. Do not hand-author or copy a
lockfile or `go.sum` from another engine version.

## Commands

```bash
# Protocol and subprocess-classification tests; no cue-py/libcue required.
uv run --project workbook python -m qualification.selftest

# Acquire exact CUE/cue-py/libcue sources, rebind libcue, and build the library.
uv run --project workbook --locked \
  python -m qualification.bootstrap_native

# Build the independent Go reference runner against the same CUE checkout.
(cd runner && go mod tidy && go build -o bin/cueprobe ./cmd/cueprobe)

# Open the executable iteration record.
uv run --project workbook --locked \
  marimo edit workbook/cue_workbook.py
```

## Boundaries

- Do not import `.codex/skills/cue/**` from the parent repository.
- Do not create another virtual environment or dependency file.
- Do not place native CUE values or CFFI handles in Marimo cells.
- Do not send expected results to either backend.
- Do not compare observations with different engine revisions.
- Do not use free-form workbook input to satisfy qualification assertions.
- One session class may mutate one declared surface only.
