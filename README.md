# factory

This repository is the dedicated reflective transition factory authority.

Seeded from `fatb4f/contract.cuemod` branch
`factory/reflective-transition-factory` through the admitted extraction
transition packet for issue #68.

## Authority

`contracts/factory/` is the active factory authority root.

Bounded input snapshots:

- `contracts/agent-runtime/`
- `contracts/agent-context-resolver/`

Factory issue tracking and scheduled upstream-monitor output belong in this
repository after migration handoff.

`contracts/upstream-monitor/` owns the scheduled review surface for future
factory follow-up.

## Codex Resolver Hook

`.codex/hooks.json` installs a repo-local `UserPromptSubmit` hook at
`.codex/skills/resolve-agent-context/scripts/agent-context-resolver-hook`.
The hook consumes the operator's copied issue packet text and emits a bounded
agent route controller packet for Codex prompt context.

The resolver hook is an adapter/runtime ingress only. It references
`contracts/agent-context-resolver/generated/**` as resolver projection input and
does not make `contracts/agent-context-resolver/**` factory authority. Factory
contract authority remains under `contracts/factory/**`.

Hook smoke validation is rooted in `contracts/factory/reflection.cue`, which
materializes admitted assertion instances under
`contracts/factory/assertions/generated/**`, fixture projections under
`generated/fixtures/**`, executable projections under `generated/checks/**`, and
evidence under `generated/evidence/**`.

`contracts/factory/control.cue` models the validation/materialization control
loop as contract authority. `contracts/factory/introspection.cue` owns
adapter-visible exposure. Loop-stage exports are bounded, non-authoritative
evidence under `generated/evidence/control-loop/**`.

Issue packet workflow:

```bash
gh issue view <n> --json title,body --jq '"# " + .title + "\n\n" + .body' | wl-copy
```

Paste the copied packet into Codex. The hook classifies that supplied prompt and
must not perform raw GitHub or repository firehose acquisition by default.

## Validation

```bash
just generate-validation
just export-validation-loop
just check
```

Hook smoke validation is also available directly:

```bash
just hook-smoke
```
