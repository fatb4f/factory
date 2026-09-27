# personal.ivac agent instructions

Canonical IVAC review semantics live under:

```text
contracts/personal/ivac/
```

This unit models administrative-review state and evidence/legal/adjudicative transitions. It does not store personally identifying medical records or case facts in the public repository.

Rules:

1. Treat source documents, clinicians, experts, lawyers, and administrative bodies as typed actors/evidence providers with bounded authority.
2. Never infer a successful transition from the existence of a document; consume an explicit transition grant.
3. Medical findings must originate from clinical authority.
4. Legal qualification and submission may consume medical findings but may not manufacture them.
5. Only adjudication may change recognized-decision state.
6. Provider names are runtime bindings, not semantic role identities.
7. Keep public fixtures de-identified.
8. Relational/JSON/Python outputs are disposable projections of CUE authority.
