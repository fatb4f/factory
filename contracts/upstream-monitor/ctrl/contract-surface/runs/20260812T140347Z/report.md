# ctrl upstream impact report

## Run identity

- Run ID: `20260812T140347Z`
- Terminal state: `terminal_success`
- Factory authority revision: `cbb224d491e0a792b96bffb10ba70e3173fe6106`
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Bootstrap baseline: `true`

This is the first `ctrl` run. It establishes source/channel revisions, graph bindings, and implementation priorities; it does not invent a historical delta.

## Subject context

`fatb4f/ctrl@main` is a Python 3.14 qualification-prototype monorepo. `spec/` remains its sole qualification semantic authority. Factory-local CUE and AGENTS files remain the authority for this monitor loop. The profile reads the qualification spec, qualification workflow, PPF, runtime-promptgen, TDD agent skills, and OpenAI integration as subject context only.

## Source state

| Source | Channel | Mode | State | Revision |
|---|---|---|---|---|
| Codex | `main` | active baseline | resolved | `eb752e43d9b7bd7dc5965ea20642bcf7f1a492d8` |
| Codex | `latest-alpha-cli` | forecast | resolved | `9392c3fa5bcda342b5b96a1a04d67b2f781617c2` |
| CPython | `3.14` | active baseline | resolved | `b842ab829fa265df7c00a9034d007f4bbfd95577` |
| CPython | `main` | forecast | resolved | `b11e749f7590e9a0907db908fa3e7e76c772c28f` |
| CUE | pinned | pinned external semantics | resolved | `806821e40fae070318600a264d311517e596353b` |
| CUE | `master` | forecast | resolved | `f356f8f46cedb8e853ed200fb46ab49a68bfe357` |
| uv | `main` | release watch | resolved | `c2681564218e41a73e99cc448ba0b25459920444` |
| Jujutsu | `main` | release watch | resolved | `3a81f836030b00bea85e66c4070d054c555af8b2` |

Codex alpha and CPython main remain forecast evidence. Neither can substitute for the active Codex main / CPython 3.14 baselines. The CUE master head cannot substitute for ctrl's explicitly declared CUE revision.

## Codex projection graph

The baseline confirms a useful qualification chain:

```text
Rust protocol
    |
    v
exported JSON/config schemas
    |
    v
Python openai-codex generated models
    |
    +------------------> live app-server/runtime
                              |
                              v
                     rollout raw evidence
                              |
                              v
                     deterministic reduction
```

The Python SDK is not merely a wrapper. `sdk/python/scripts/update_sdk_artifacts.py` identifies an aggregate `codex_app_server_protocol.v2.schemas.json` bundle emitted by the pinned runtime binary, and `sdk/python/src/openai_codex/generated/v2_all.py` declares that same bundle as its generation input. This makes protocol -> schema -> Python SDK a qualification-worthy projection chain.

Codex rollout tracing separately documents an observe-first path: ordered raw events and payloads are stored locally, then a deterministic reducer produces a semantic graph while retaining raw payload references. `ctrl` should qualify raw/runtime versus reconstructed/reduced observations as related but non-identical evidence.

The current `PreToolUse` request/outcome model includes session and turn identity, permission mode, tool identity/input, tool-use identity, transcript path, blocking decisions, updated input, and additional context. This establishes the current hook boundary as a future `blocking-gate` comparison surface; the bootstrap itself does not report a break.

## CPython operational graph

The CPython 3.14 baseline supports an explicit dependency spine:

```text
parser
  -> AST
  -> symtable
  -> compiler
  -> code object
  -> instruction/bytecode model
  -> evaluation
       |-> frames
       `-> monitoring

importlib -> inspect/source identity
```

`Python/compile.c` itself documents compiler passes from AST through symbol-table construction, instruction generation, control-flow graph optimization, assembly, and `PyCodeObject` output. The profile therefore binds CPython source changes to graph nodes before selecting regrtest slices or local probes.

The operational target is:

```text
ResolveRevision
-> ResolveBuild
-> MapChangedPaths
-> ResolveSubsystemClosure
-> SelectRegrtests + SelectProbes
-> RunRegrtests + RunProbes
-> NormalizeEvidence
-> CorrelateEvidence
-> Qualify
```

CUE owns this operation graph. Pydantic is the transport projection. `pydantic-graph` is an initial replaceable executor candidate. Marimo is an interactive operator/diagnosis projection and is explicitly not authority.

CPython regrtest is upstream behavioral evidence, not a local verdict. `Lib/test/regrtest.py` delegates to `test.libregrtest`, while `libregrtest` contains specialized runner/result machinery. The admitted ctrl boundary is therefore the checked-out interpreter process (`./python -m test ...`), with internal `test.libregrtest` code observed but not imported as a stable ctrl dependency.

`Python/instrumentation.c` also confirms that monitoring is inseparable from code objects, bytecode/opcodes, frames/interpreter frames, optimizer state, and runtime mode, including free-threaded paths. A useful local monitoring probe must preserve those correlations rather than emit an untyped callback log.

## Critical

None in this bootstrap baseline.

## High

### Qualify Codex protocol -> schema -> Python SDK projection

**Decision:** `contract-update`

Add projection qualification to ctrl's OpenAI integration and future Python-native controller adapter. A protocol/schema/SDK inconsistency should be distinguishable from an ordinary upstream change.

### Treat rollout bundles and reduced graphs as correlated runtime evidence

**Decision:** `contract-update`

Define rollout bundle identity, raw payload references, reduction/reconstruction correlation, lineage, and sensitive-evidence handling.

### Use CPython's compiler pipeline as an executable dependency DAG

**Decision:** `contract-update`

Implement the declared DAG in ctrl and use changed-path classification plus reverse dependency closure to select affected upstream tests and local probes.

### Operationalize CPython regrtest behind a process adapter

**Decision:** `contract-update`

Implement typed revision/build/test operations and normalize `./python -m test` process evidence. Keep local probes as a separate evidence family.

### Bind sys.monitoring probes to interpreter instrumentation and frame/code state

**Decision:** `contract-update`

Implement normalized monitoring-event and frame-source probes with explicit build/runtime identity, including free-threaded mode.

## Notes

### Establish hook/tool interception as a future blocking boundary

Current hook semantics are explicit enough to establish an exact baseline. Future incompatible changes to the hook/tool/config interception surface should classify at `blocking-gate` for ctrl.

### Keep pinned CUE evaluator semantics distinct from master forecast

ctrl's declared evaluator revision is `806821e40fae070318600a264d311517e596353b`; current master is `f356f8f46cedb8e853ed200fb46ab49a68bfe357`. The profile records this as intentional pin-versus-forecast separation. An explicit root toolchain identity contract remains desirable so executable qualification can verify the pin rather than only checking that `cue` exists.

## No local action

No separate report item. uv and Jujutsu were resolved as release-watch satellites and did not produce a local-impact finding in the bootstrap acquisition.

## Publication

- Bundle: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260812T140347Z/`
- Manifest: `contracts/upstream-monitor/ctrl/contract-surface/runs/20260812T140347Z/manifest.json`
- Latest pointer: `contracts/upstream-monitor/ctrl/contract-surface/latest.json`
- Export unit: `directory`

## Validation notes

- Factory worker/profile authority read: yes.
- Current ctrl context read: yes.
- Required source/channel identities resolved: yes.
- Source identities kept distinct from channel identities: yes.
- Codex projection graph read and bound: yes.
- CPython dependency/test/probe graph read and bound: yes.
- Report and summary are projections from `evidence.json`: yes.
- CUE execution: `not_available_to_github_app`.
- CPython regrtest execution: `not_executed_bootstrap`.
- Local CPython probe execution: `not_executed_bootstrap`.
- Cross-repository writes: none.
- Issue updates: none declared.
