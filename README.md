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

## Validation

```bash
just check
```
