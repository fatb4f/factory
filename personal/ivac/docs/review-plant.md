# IVAC review plant

Status: initial executable model.

## Control surface

The plant is modeled as:

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

## Runtime bindings

Concrete providers are runtime bindings to semantic roles:

```text
legal-representative <- selected counsel
medical-expert       <- selected independent psychiatrist / specialist
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

## Mock trace

`contracts/personal/ivac/mock.cue` provides a de-identified trace:

```text
s0 --preserve--> s1
s1 --commission--> s2
s2 --opine--> s3
s3 --submit--> s4
s4 --adjudicate--> s5
```

The fixture includes one recognized primary axis and three independent supplemental hypothesis axes. Supplemental axes intentionally remain hypotheses until their own evidence gates are satisfied.

## Relational projection

`contracts/personal/ivac/projections.cue` exposes row qualification targets for actors, authorities, axes, evidence, findings, mandates, grounds, submissions, decisions, snapshots, transitions, dependencies, decisions, and grants.

Those rows are downstream projections. The CUE graph remains semantic authority.
