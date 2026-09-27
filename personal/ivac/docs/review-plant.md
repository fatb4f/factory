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
