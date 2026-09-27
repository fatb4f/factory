# personal.ivac agent instructions

Canonical IVAC semantics live under:

```text
contracts/personal/ivac/
```

This unit models both administrative-review control state and a normalized subject/evidence layer for reusable clinical/legal evaluations. It does not store personally identifying medical records or case facts in the public repository.

Rules:

1. Treat source documents, clinicians, experts, lawyers, and administrative bodies as typed actors/evidence providers with bounded authority.
2. Never infer a successful transition from the existence of a document; consume an explicit transition grant.
3. Medical findings must originate from clinical authority.
4. Legal qualification and submission may consume medical findings but may not manufacture them.
5. Only adjudication may change recognized-decision state.
6. Provider names are runtime bindings, not semantic role identities.
7. Normalize source-supported observations, episodes, capacities, interventions, and relations into `#EvidenceWorld`; do not copy evaluation conclusions backward into that world.
8. Treat `#NormalizedSubjectProfile` as a deterministic read model, not independent authority.
9. Do not promote temporal sequence or reported association into causal predicates; causal predicates require qualified clinical attribution.
10. Keep evaluation-owned cutoffs, selectors, relation transforms, questions, and report wording outside canonical subject history.
11. Keep public fixtures de-identified and free of real claimant medical facts.
12. Relational/JSON/Python outputs are disposable projections of CUE authority.
