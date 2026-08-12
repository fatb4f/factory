# ctrl upstream impact report

## Run identity

- Run ID: `<run_id>`
- Terminal state: `<terminal_state>`
- Factory authority revision: `<factory_revision>`
- ctrl context revision: `<ctrl_revision>`
- Bootstrap baseline: `<true|false>`

## Subject context

Summarize the current `fatb4f/ctrl@main` authority boundary and components read. `spec/` remains ctrl's qualification semantic authority; the monitor contract remains factory-local authority for this loop.

## Source state

List every declared source/channel separately with exact resolved commit or explicit unresolved state. Never collapse same-named channels across sources.

## Codex projection graph

Project evidence through the declared chain:

```text
Rust protocol -> exported JSON/config schemas -> Python openai_codex SDK
      |                                             |
      +-----------------> live runtime <------------+
                              |
                              v
                    rollout persistence
                              |
                              v
                    rollout reconstruction
```

Record projection inconsistencies separately from ordinary upstream changes.

## CPython operational graph

Summarize affected CPython DAG nodes, selected upstream regrtest bindings, selected local probe bindings, and the operationalization state of the typed execution graph. Distinguish source evidence, upstream test evidence, local probe evidence, correlation, and qualification.

## Critical

Render critical `blocking-gate` items from `evidence.json` only.

## High

Render high `contract-update` items from `evidence.json` only.

## Notes

Render note items from `evidence.json` only.

## No local action

Render `none` items from `evidence.json` only.

## Publication

- Bundle: `<bundle_path>`
- Manifest: `<manifest_path>`
- Latest pointer: `<latest_pointer_path>`
- Export unit: directory

## Validation notes

Disclose authority/context reads, source resolution, graph/model reads, report/summary projection status, CUE execution availability, CPython regrtest execution status, and local probe execution status.
