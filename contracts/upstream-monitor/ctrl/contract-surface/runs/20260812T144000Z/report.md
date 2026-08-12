# ctrl upstream impact report

## Run identity

- Run ID: `20260812T144000Z`
- Profile: `ctrl`
- Terminal state: `terminal_success`
- Factory authority revision: `0f5bc48c5e2d3156352079f8a498a49803dd1c24`
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Run mode: profile-extension baseline

## Source state

- `astral-python/main`: `a9663e243a571b4aed032ee243da25189d2bc95b` — required forecast evidence.
- `cpython/3.14`: `b842ab829fa265df7c00a9034d007f4bbfd95577` — active compiler/runtime evidence baseline.
- `cpython/main`: `b11e749f7590e9a0907db908fa3e7e76c772c28f` — forecast only.
- Codex, CUE, uv, and Jujutsu source identities remain resolved as recorded in `evidence.json`.

## High — Astral Rust static-analysis plane

Decision: `contract-update`.

The `astral-sh/ruff` workspace already contains the Rust machinery needed for the static half of the Python control plane: Ruff database/index infrastructure, parser, AST and static semantic crates, plus ty's module resolver, Python type core, semantic engine and IDE projections.

`ty_python_semantic` explicitly depends on `ruff_db`, Salsa-backed `ruff_index`, `ruff_python_ast`, `ruff_python_parser`, `ty_module_resolver`, `ty_site_packages`, `ty_python_core`, and `ty_static`. `ruff_python_semantic` separately consumes the Ruff parser/AST/index family. The profile therefore models Ruff static semantics and ty type semantics as distinct observations over shared machinery.

Local impact: the future CPython-control/python-intel layer should consume Astral observations instead of reimplementing parser/index/resolution/type infrastructure. Static observations are correlated with CPython AST, `symtable`, `importlib`, compiler and runtime probes. They never override contradictory CPython evidence.

New graph nodes include:

- `astral-db-index`
- `astral-parser`
- `astral-ast`
- `astral-ruff-semantic`
- `astral-module-resolver`
- `astral-ty-core`
- `astral-ty-semantic`
- `astral-ide`
- `astral-cpython-correlation`

New correlation probes cover AST/source-range agreement, lexical binding agreement, and module/import identity.

## Note — baseline identity

`astral-sh/ruff@main` is forecast evidence, not the realized analyzer baseline. Concrete qualification must separately bind the Ruff/ty artifacts selected by `fatb4f/ctrl`'s committed `uv.lock` to their Astral source/release provenance.

This prevents current `main` behavior from being silently attributed to the versions actually used by a qualified ctrl revision.

## Operational model

The CPython execution graph now includes `AcquireAstralAnalysis` and `CorrelateStaticDynamic`:

```text
ResolveRevision
→ ResolveBuild
→ MapChangedPaths
→ AcquireAstralAnalysis
→ ResolveSubsystemClosure
→ SelectRegrtests / SelectProbes
→ RunRegrtests / RunProbes
→ CorrelateStaticDynamic
→ NormalizeEvidence
→ CorrelateEvidence
→ Qualify
```

CUE remains graph authority. Pydantic is transport. The executor and Marimo remain replaceable/non-authoritative projections.

## Validation

- Factory/profile authority read: yes.
- ctrl context read: yes.
- Astral source identity resolved: yes.
- Analyzer/CPython authority separation encoded: yes.
- CUE execution: not available to GitHub App actuator.
- CPython regrtest execution: not executed in this baseline run.
- CPython/Astral correlation probes: not executed in this baseline run.
- Cross-repository writes: none.
