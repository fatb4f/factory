# IVAC review plant

Status: executable review-control model with normalized subject/evidence extension.

## Control surface

The review plant is modeled as:

```text
recognized decision
      ↓ preserve
review-open state
      ↓ commission
independent expert mandate
      ↓ opine
medical findings
      ↓ legal qualification / binding
review submission
      ↓ adjudicate
recognized review decision
      ↓
accept | escalate
```

The principal separation is:

```text
clinical authority      -> findings
legal authority         -> grounds + submission
adjudicative authority  -> recognized decision
```

No actor may skip an authority boundary.

## Normalized subject/evidence plant

The review state machine is intentionally separate from the normalized clinical evidence world that feeds expert and treating-clinician evaluations:

```text
source evidence artifacts
        ↓
normalized observations
        ↓
episodes + capacities + interventions
        ↓
typed clinical relations
        ↓
normalized subject profile
        ↓
evaluation-specific selector + relation transforms
        ↓
clinical assessment / finding candidate
        ↓
review-control plant
```

The canonical subject layer consists of:

- `#EvidenceWorld` — admitted references to evidence artifacts plus normalized observations, episodes, capacities, interventions, and relations;
- `#NormalizedSubjectProfile` — a deterministic read model over one evidence world;
- `#ClinicalRelation` — typed graph edges with explicit assertion mode and provenance;
- `relationTransforms` — deterministic projection-only graph selections/closures reused by evaluation contracts;
- `contracts/personal/ivac/evaluations/` — independent permanent-sequela, GP-addendum, neuroscience-expertise, and legal-review contracts.

The profile is not semantic authority. It is disposable and reproducible from the admitted evidence world. Evaluation outputs never write themselves back into the evidence world as facts.

## Causal boundary

Temporal order, recurrence, or association does not manufacture medical causation. Relations with causal predicates such as `impairs`, `resulted-in`, or `triggered-by` require `clinician-attributed` mode and a qualified clinical actor.

Patient-reported or derived longitudinal relationships may remain admitted as observations/associations while still being unavailable to causal-only evaluation transforms.

## Evaluation boundary

Evaluation contracts consume the same normalized profile while retaining different authority:

```text
permanent-sequela / GP / neuroscience
    -> clinical assessments, finding candidates, coverage gaps

legal review
    -> legal-ground candidates, coverage gaps
```

Legal evaluation cannot manufacture clinical findings. Clinical evaluation cannot manufacture legal grounds or adjudicative outcomes.

Evaluation-owned cutoffs, selected relation transforms, questions, and report wording do not alter canonical subject history.

## Cross-forum portability

The IVAC review plant is the first consumer of the normalized legal-medical evidence layer, not its semantic boundary.

The reusable path is:

```text
master legal-medical corpus
        ↓ preserve source authority
artifact portability envelopes
        ↓ forum + purpose qualification
reuse consumer profile
        ↓ explicit disclosure gates
purpose-bound artifact selection
        ↓
derived downstream package
```

`contracts/personal/ivac/portability.cue` distinguishes four artifact layers:

- source records;
- clinical expert opinions;
- filed legal material;
- privileged legal work product.

The distinction is intentionally asymmetric. A source record may be a direct or supporting candidate in another forum. An expert report may require a new mandate, forum-specific qualification, or a statutory assessment. Filed legal material may be reusable as supporting material. Legal work product is withheld by default pending explicit protection review.

No portability profile determines admissibility, privilege, waiver, entitlement, criminal responsibility, capacity, damages, or any other forum-specific outcome. Those remain downstream qualifications owned by the competent legal/adjudicative authority.

The current consumer profiles seed:

- criminal defence;
- civil litigation;
- administrative/benefits proceedings;
- insurance/disability proceedings;
- capacity/protective proceedings;
- employment/human-rights proceedings;
- family proceedings.

Every derivative package is a `purpose-bound-subset`. The master corpus is never inferred to be an appropriate disclosure package.

`contracts/personal/ivac/portability_seed.cue` contains only de-identified structural reuse seeds. It demonstrates explicit inclusion of selected source/expert material and explicit exclusion of legal work product. It does not encode actual claimant facts or provider identities.

## Runtime bindings

Concrete providers are runtime bindings to semantic roles:

```text
legal-representative <- selected counsel
medical-expert       <- selected independent psychiatrist / specialist
treating-clinician   <- selected treating clinician
adjudicator          <- IVAC administrative review authority
```

Changing a provider does not change plant semantics.

## Transition grants

A transition attempt is not success. Successful transition decisions emit grants. Downstream transitions consume those grants.

This prevents:

- an expert appointment from being treated as an expert opinion;
- an expert report from being treated as a legal ground without qualification;
- a filed submission from being treated as a favorable decision;
- a lawyer or expert from manufacturing an adjudicative outcome.

## Public fixtures

`contracts/personal/ivac/mock.cue` provides the de-identified procedural trace.

`contracts/personal/ivac/clinical_mock.cue` provides a de-identified evidence-world/profile fixture. It contains only structural mock facts and never real claimant medical history or provider bindings.

The review fixture includes one recognized primary axis and three independent supplemental hypothesis axes. Supplemental axes intentionally remain hypotheses until their own evidence gates are satisfied.

## Relational projection

`contracts/personal/ivac/projections.cue` exposes row qualification targets for both graphs:

- review-control actors, authorities, axes, evidence, findings, mandates, grounds, submissions, decisions, snapshots, transitions, dependencies, decisions, and grants;
- evidence-world observations, episodes, capacities, interventions, clinical relations, profiles, and profile membership tables.

Those rows are downstream projections. CUE canonical graph/evidence-world state remains semantic authority.
