# IVAC medico-legal review companion — contract-first checkpoint

Tracked by Factory Issue #227; implemented as a **separate, additive workstream**
alongside draft PR #223. Source acquisition and Annex I normalization are still
Milestone 2 responsibilities under Issue #222.

## Authority and execution

```text
CUE IVAC evidence world + verified regulatory citations
                     |
          five specialist model lenses
      clinical | legal | claimant | opposing | audit
                     |
         paired candidate explanations
            favorable / restrictive
                     |
       source references + coverage gaps
                     |
       optional external professional link
        existing finding / review ground
                     |
        independent credential/mandate,
        source, privilege and disclosure
        checks OUTSIDE the model
```

The roles are analytical perspectives, not `#ActorKind` values. A model is not
represented as a physician, lawyer, legal representative or adjudicator.
`#MedicoLegalReviewDraft` has fixed `professionalStatus: not-reviewed`,
`disclosure: not-authorized`, `submission: not-authorized` and
`adjudication: not-determined`. Every question retains paired favorable and
restrictive theories, distinct evidence/clinical source refs, a confidence
classification and explicit coverage gaps where needed.

The companion's case references are checked against the existing
`#ValidatedCasePlant`. A legal citation is *structurally* typed, but must still
be checked against pinned source bytes through the existing source verifier.
Neither the model nor CUE type checking can prove legal applicability, assess
professional credibility or establish official current-law coverage.

`#MedicoLegalClinicalReviewLink` accepts only a matching finding already in
the case, authored by a medical expert or treating clinician, on the same claim
axis. `#MedicoLegalLegalReviewLink` accepts only a matching existing review
ground authored by a legal representative on the same axis. These links do not
create or endorse a finding, legal ground, decision or submission. External
professional identity, credential, actual endorsement, mandate, source
verification, disclosure/privilege and informed consent remain mandatory
operational gates. Do not use a link as evidence those checks happened.

The source/model distinction is maintained: `source-observed` is not an
independent medical conclusion; `arguable` is not a statutory qualification.
Clinical causal attribution and procedural applicability remain entirely
external to the model draft. No role automatically chooses the most favorable
result.

## Interfaces

- CUE: `contracts/personal/ivac/evaluations/medico_legal_review.cue`.
- Existing clinical/review/evaluation state remains unchanged.
- Typed inputs: de-identified synthetic test cases or private locally bound case
  records. Never commit identifiable patient records.
- Run: `bash scripts/validate-ivac-regulatory.sh`.
- Synthetic test: `python3 scripts/test_ivac_medico_legal.py`.

## Future work

1. Independent regulatory citation verification and applicable-version choice,
   after Issue #222 admits a reviewed compendium.
2. Professional verification receipt/signature mechanism and purpose-specific
   disclosure controls; case-bound links alone are insufficient.
3. Generate JSON Schema and Pydantic v2 from CUE without authoring a competing
   canonical model; run CUE round-trip tests and record constraint loss.
4. Lower query and adversarial comparison projections through
   `factory.analytics-ir/v1` to Ibis/DuckDB. No query engine may confer
   clinical or legal authority.
5. Implement execution orchestration that prevents an AI-generated role result
   from being submitted or promoted without explicit external gates.

This checkpoint is a wired schema and offline regression harness, **not** an
operational licensed legal/medical representation service.
