# Factory GitHub Issues operating model

## Authority

GitHub Issues is an operational tracker projection. It is not semantic authority.

The shared tracker schema is:

```text
contracts/state/tracker.cue
```

Read that contract before creating, updating, resolving, reopening, or correlating Factory issues.

Project/profile/domain CUE remains authoritative for domain meaning. This file defines the procedural projection into GitHub Issues.

## Why this exists

Factory now contains multiple independent graphs, substrates, workers, profiles, and projects whose engineering state cannot be reliably carried in chat context or inferred from repository paths.

Use issues as durable control state for work that persists across conversations, runs, or implementation phases.

The reusable state pattern is:

```text
intent / admitted observation
        ↓
normalized typed state
        ↓
derived assessment
        ↓
stable issue identity
        ↓
tracker projection
        ↓
reconciliation
```

This pattern is shared with the Gym adaptation tracker only at the control/state level. Gym semantics do not generalize into Factory engineering semantics.

## Two issue origins

### `engineering-intent`

Use for Factory's own engineering work.

Examples:

- realize a graph;
- define a shared substrate;
- introduce an analytical IR;
- implement a projection or adapter;
- qualify a runtime;
- migrate a project onto a new contract.

An engineering-intent issue records a desired change and its acceptance criteria. It is not evidence that an external fact is true.

### `evidence-derived`

Use only when an authoritative project/profile admits a continuing concern from runs and evidence.

Examples may include a profile-defined qualification regression, coverage gap, or industrial constraint issue.

The generic tracker does not define universal evidence-derived issue classes. Their meaning remains with the narrow project/profile authority.

## Tracked entity boundary

Every issue must identify one primary tracked entity:

```text
graph
substrate
project
worker
profile
contract
adapter
runtime
```

Do not create a single issue that silently owns several independent semantic authorities.

Use explicit dependencies between issues when work crosses boundaries.

Examples:

```text
industrial-signals graph
    depends-on → canonical identity contract
    projects-to → relational substrate

resource-allocation project
    consumes → admitted graph snapshots

analytics IR substrate
    implements → projections to Ibis/Substrait
```

Names, path similarity, and conversation proximity do not establish dependencies.

## Stable identity

Never correlate Factory issues by title or GitHub issue number.

The semantic tracker key is projected by `contracts/state/tracker.cue`.

Engineering key shape:

```text
engineering:<entity-kind>:<entity-id>:<work-class>:<slug>
```

Evidence-derived key shape:

```text
evidence:<entity-kind>:<entity-id>:<issue-class>:<slug>
```

Before creating an issue, search existing open and closed issues for its exact `factory-issue-key` marker.

If the key already exists, reconcile that issue instead of creating a duplicate.

## Required GitHub issue marker

Every Factory-managed issue body must contain this block near the end:

```text
factory-schema: factory.tracker/v1
factory-issue-key: <stable key>
factory-origin: <engineering-intent|evidence-derived>
factory-entity-kind: <kind>
factory-entity-id: <id>
```

These markers are machine state. Do not casually edit them.

## Engineering issue body

Use this shape for `engineering-intent` issues:

```markdown
## Contract

Primary entity, authoritative path(s), and authority boundary.

## Objective

One bounded engineering outcome.

## Scope

What this issue owns and explicitly does not own.

## Dependencies

Explicit tracker-key relationships only. Use `None` when empty.

## Acceptance

- [ ] Mechanically or observably checkable exit condition.
- [ ] Additional exit condition where required.

## References

Relevant architecture documents, contracts, commits, or upstream specifications.

---
factory-schema: factory.tracker/v1
factory-issue-key: ...
factory-origin: engineering-intent
factory-entity-kind: ...
factory-entity-id: ...
```

Acceptance criteria should describe terminal state, not implementation activity.

Prefer:

```text
A closed RelationalPlan contract projects deterministically to two replaceable adapters.
```

over:

```text
Work on Ibis integration.
```

## Evidence-derived issue body

Evidence-derived issues must additionally preserve:

- admitted run references;
- evidence references;
- the authority that admitted the issue;
- the admission decision or claim;
- project-specific resolution semantics.

An issue must never upgrade an observation into a fact merely by being opened.

## Lifecycle

The shared operational states are:

```text
backlog
ready
in-progress
blocked
done
suppressed
```

GitHub's open/closed state is only the external UI projection.

Close an engineering issue only when its acceptance conditions are satisfied or explicitly waived by the relevant authority.

Close an evidence-derived issue only according to its project/profile resolution semantics. Absence of another observation is not automatically resolution.

## Work decomposition

Create a separate issue when any of the following is true:

1. the work has a different semantic authority;
2. the primary tracked entity changes;
3. it can reach a terminal state independently;
4. it has different prerequisites;
5. combining it would make acceptance non-mechanical.

Do not create issues for transient conversational steps, implementation trivia, or observations that have not crossed their admission boundary.

## Graphs versus substrates versus projects

Keep these distinct.

```text
graph
    owns domain topology and admitted graph state

substrate
    supplies reusable execution/storage/modeling/projection capability

project
    owns Factory decisions or bounded outcomes that consume graphs/substrates
```

A substrate must not acquire graph semantics merely because it executes graph queries.

A project must not reconstruct an upstream graph to avoid declaring a dependency.

A graph issue must not silently own generic infrastructure.

## ChatGPT procedure

When asked to plan or track Factory engineering work:

1. inspect current `main`;
2. read `contracts/state/tracker.cue`;
3. read this file;
4. classify the primary tracked entity and authority;
5. search GitHub Issues by exact stable key or marker fragments;
6. update an existing issue when identity matches;
7. create a new issue only when the concern has a distinct stable identity;
8. preserve explicit dependencies and acceptance criteria;
9. never infer semantic relationships from names;
10. report the created/updated issue numbers and any coverage gaps.

For evidence-derived issues, also read the relevant project/profile tracker/admission contract before mutation.
