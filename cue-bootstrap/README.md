# CUE bootstrap laboratory

This directory implements factory issue #109 as a self-contained, temporary
repository root intended for later extraction.

The bootstrap proves one bounded CUE pattern end-to-end before the current CUE
skill is cleaned up or extended:

```text
pinned CUE v0.18 authority
  -> bounded-int pattern
  -> minimum kernel projection
  -> registered fixtures
  -> reusable probe request
  -> purpose-built Go binding façade
  -> gopy CPython extension
       -> direct Marimo interaction with live Go-backed values
       -> isolated Python worker qualification
  -> independent cueprobe Go executable
  -> Marimo comparison workbook
```

## Engine and binding identity

The semantic target is the CUE v0.18 development line at the exact commit:

```text
cue-lang/cue@806821e40fae070318600a264d311517e596353b
language/module version: v0.18.0
```

The Go binding package and `cueprobe` executable both compile against that exact
checkout through `runner/go.mod`. There is no cue-py or libcue compatibility
layer in the admitted execution path.

The Python bridge is generated with pinned gopy source:

```text
go-python/gopy@72557f647208599c726c14dc9721a6c850d2e6d9
```

A qualification run is comparable only when the gopy worker and `cueprobe`
report the same CUE engine revision and module target.

## Runtime modes

### Interactive mode

```text
Marimo kernel
  -> generated CPython extension
  -> gopy int64 object handles
  -> live Go Context, Loader, and Value objects
  -> CUE v0.18
```

Interactive cells may retain live proxy objects for exploration. This mode is
not qualification evidence because a fatal native failure would terminate the
Marimo kernel.

### Qualified mode

```text
Marimo kernel
  -> one-request Python worker process
  -> same generated gopy extension
  -> CUE v0.18
  -> immutable typed observation
```

The independent `cueprobe` executable evaluates the same registered request as
a second process surface. Expected facts are never sent to either backend.

## Implemented slice

- repository and session isolation policy;
- project-local Codex MCP declarations routed through `workbook/`;
- pinned CUE v0.18 and gopy source identities;
- a narrow Go façade exposing `Context`, `Loader`, `Value`, diagnostics, engine
  identity, unification, validation, subsumption, and projection;
- direct Python access to live Go-backed values;
- one-request-per-process gopy qualification worker;
- independent `cueprobe` Go executable;
- one `bounded-int` pilot pattern and minimum kernel;
- positive, negative, and directional fixtures;
- strict request/response models with facts-only qualification output;
- Marimo workbook with separate interactive and qualified surfaces;
- protocol, timeout, output-boundary, and missing-extension self-tests.

## Deliberately incomplete

`workbook/uv.lock` is not committed by this initial slice. Generate it from the
project metadata and review it; do not hand-author or copy a lockfile.

The generated CPython extension and `runner/go.sum` are also not fabricated.
They must be produced from the exact CUE and gopy checkouts using Go 1.25 or
newer and the Python interpreter selected by the locked `uv` environment.

## Build

```bash
cd cue-bootstrap/workbook
uv lock
uv lock --check

uv run --project . --locked \
  python -m qualification.bootstrap_native
```

The bootstrap command:

1. checks out the exact CUE and gopy commits;
2. verifies `runner/go.mod` resolves CUE to that checkout;
3. builds gopy and pinned `goimports` tooling;
4. generates `workbook/cue_native/` against `sys.executable`;
5. verifies the extension-reported CUE identity;
6. generates `runner/go.sum` and builds `runner/bin/cueprobe`;
7. records source, ABI, toolchain, and binary digests in
   `workbook/.deps/manifest.json`.

## Commands

```bash
# Protocol and subprocess classification; native extension may be absent.
uv run --project workbook python -m qualification.selftest

# Build the exact native binding and Go reference executable.
uv run --project workbook --locked \
  python -m qualification.bootstrap_native

# Open the executable iteration record.
uv run --project workbook --locked \
  marimo edit workbook/cue_workbook.py
```

## Boundaries

- Do not import `.codex/skills/cue/**` from the parent repository.
- Do not create another virtual environment or dependency file.
- Direct mode may hold gopy proxy objects; qualified observations must never
  contain native handles or Go-backed values.
- Do not send expected results to either backend.
- Do not compare observations from different CUE engine revisions.
- Do not use free-form workbook input to satisfy qualification assertions.
- One session class may mutate one declared surface only.
