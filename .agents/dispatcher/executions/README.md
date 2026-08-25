# Dispatcher execution ledger

This tree is append-only runtime evidence, not CUE or repository authority. Records use:

```text
<task-id>/<scheduled-civil-date>/
├── disposition.json
└── attempt-<ordinal>/
    ├── claim.json
    └── result.json
```

An occurrence has either one dispatcher disposition or one or more contiguous attempts. Exactly one attempt may have a terminal result. Existing records are never edited; corrections and stale retries append a later attempt where CUE admission permits it.
