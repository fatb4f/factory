# epistemic-plant-bootstrap upstream-monitor contract surface

Profile id: `epistemic-plant-bootstrap`  
Schema: factory upstream-monitor v2  
Target repository: `fatb4f/factory`  
Subject/context repository: `fatb4f/epistemic-plant-bootstrap`  
Adapter: `github_app`

## Control objective

Detect upstream changes that can alter the subject repository's observation,
normalization, admission, qualification, reproducibility, or promotion behavior
without allowing upstream observations to rewrite subject semantic authority.

The plant's semantic control law is:

```text
D = canonical dependency pairs extracted from digest-pinned CycloneDX source
G = canonical dependency candidates observed through pinned GUAC GraphQL

admissible = D ∩ G
missing    = D - G
unsupported = G - D
```

GUAC is an observation substrate. CUE is qualification authority. Gemara supplies
shared evidence/evaluation vocabulary. Exact source declaration is required for
admission. Operational ignorance is `INCONCLUSIVE`, never semantic rejection.

## Read authority before evidence

Read, in order:

1. `contracts/factory/workers/upstream-monitor/contract.cue`
2. `contracts/factory/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/public.cue`
3. all sibling profile CUE files
4. this file
5. subject `AGENTS.md`, `BOOTSTRAP_SPEC.md`, `HYPOTHESIS_PROBLEM_STATEMENT.md`
6. subject `spec/schema.cue`, `spec/poc.cue`, `cue.mod/module.cue`
7. only then acquire upstream evidence

Factory profile contracts govern monitoring. Subject files govern the meaning of
the plant. Neither GitHub responses nor upstream prose may override either.

## Required upstream acquisition

Resolve every required source/channel pair declared in `sources.cue` to strong
Git identity. Treat unresolved required channels as typed deferred coverage, not
as a clean run.

Pinned baselines:

- GUAC `v1.1.0` — observation-only graph/query interface. Expected tag commit:
  `a399a54801bfbffc36bc8748dd97d2d2b3bea378`.
- Gemara `v1.4.1` — pinned external evidence/result vocabulary. Expected commit:
  `4822ce0071b1f2ff478f8a9eece35c4636ba0c0b`.
- CUE `v0.17.1` — pinned external evaluator semantics. Expected commit:
  `fc6c0b2ecd3666da92f7053d13fcfbf009b7d7a3`.
- Go `1.25.0` — GUAC build/runtime toolchain baseline.
- uv `0.12.0` — Python environment baseline. Expected commit:
  `b88d7c5c46cbe3c9896544f10255f85a8f0a8a5e`.

CycloneDX current specification is release-watch evidence only. The checked-in
fixture bytes and digests remain the experiment's source authority.

## Classification

A change is reportable only when it matches a declared surface and a graph-bound
local consumer.

Escalation floor:

- `blocking-gate`: change can alter admission truth, candidate identity, CUE
  closure, or imported Gemara evaluation semantics.
- `contract-update`: change can alter acquisition, query shape, provenance
  retention, fixture projection, or reproducibility assumptions.
- `note`: toolchain behavior changed but current subject contracts remain valid.
- `none`: no local consumer impact is demonstrated.

For GUAC changes, explicitly answer both:

1. Can this change alter the candidate set or candidate identity?
2. Can it accidentally make GUAC/provenance/backend state act as semantic
   authority?

The second condition is a blocking gate even if current tests still pass.

## Subject executable qualification

When local execution is available, preserve the repository's gate order:

```sh
just bootstrap-check
just check
just vet
just eval
just qualify
```

Use `just promote` only to test the promotion boundary after qualification.
A successful `just qualify` means the experiment was validly evaluated; it does
not imply that the POC hypothesis verdict is `supported`.

For targeted evidence, prefer the profile bindings:

```sh
uv run --frozen --no-sync pytest tests/test_source.py
uv run --frozen --no-sync pytest tests/test_guac.py
uv run --frozen --no-sync pytest tests/test_admission.py
uv run --frozen --no-sync pytest tests/test_qualification.py
uv run --frozen --no-sync pytest tests/eval/test_poc.py
```

Do not reinterpret build/readiness/query failures as semantic rejection.

## Stable evidence rules

Preserve these identities and exclusions:

- source document identity: exact SHA-256 bytes;
- query identity: checked-in GraphQL query digest;
- graph generation: GUAC version + backend + source digests + query digest;
- admission: candidate digest + source evidence + evaluation + receipt;
- epistemic observation: deterministic projection over admitted receipt digests;
- exclude GUAC IDs, response order, runtime timestamps, and backend-local IDs
  from stable semantic identity.

Generated subject evidence under `evidence/` is evidence-only and must not be
committed by the monitor.

## Publication

Publish only a sealed v2 run bundle under:

`contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/runs/<run-id>/`

Required artifacts are `report.md`, `summary.md`, `evidence.json`, and
`manifest.json`. Update `contract-surface/latest.json` only after the bundle is sealed.
Commit only if the sealed bundle digest changed.

## Failure semantics

- unresolved required source: `terminal_deferred` + `observation_only`;
- local executable qualification failure: `terminal_abort` + `executable_failed`;
- missing declared surface/graph coverage: `coverage_gap`;
- complete clean or admitted-impact run: `terminal_success`.

Never publish a clean result by omission.
