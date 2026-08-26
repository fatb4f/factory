# Dispatcher execution ledger

This tree is append-only runtime evidence, not CUE or repository authority. Records use:

```text
<task-id>/<scheduled-civil-date>/
├── disposition.json
└── attempt-<ordinal>/
    ├── claim.json
    └── result.json
```

An occurrence has either one dispatcher disposition or one or more contiguous attempts. Exactly one attempt may have a terminal result. A result is valid only when it equals the registered task adapter's projection of sealed task-local evidence. Existing records are never edited; corrections and stale retries append a later attempt where fresh CUE transition admission permits it. Once a later attempt is claimed, a late result for an earlier attempt is rejected.
