# Factory Daily Dispatcher

Status: proposed, non-authoritative design plan

This document records an implementation proposal. It does not amend the
requirement graph, define repository authority, admit an implementation unit,
or replace vetted CUE declarations.

The repository-wide unit and registry migration is defined separately in
[`factory-unit-registry-refactor.md`](factory-unit-registry-refactor.md). This
dispatcher consumes admitted task references from that model; it does not own
the repository hierarchy or any unit's domain semantics.

## Summary

Introduce a CUE-admitted dispatcher overlay for the existing `ctrl` and
`epistemic-plant-bootstrap` monitors without relocating their authorities.
The single recurring ChatGPT task owns only the daily clock. The Factory
dispatcher owns the schedule registry, due-task admission, invocation
orchestration, dispatcher attempt state, and dispatcher result admission. Each
unit owns its domain authority, execution semantics, qualification, evidence,
publication, and adapter normalization.

The intended control flow is:

```text
ChatGPT daily clock
        |
        v
Factory dispatcher preflight
        |
        v
CUE-admitted due occurrences
        |
        v
task-owned adapter and unit-local execution
        |
        v
admitted result / no change / deferred / coverage gap / failure
        |
        v
append-only dispatcher execution ledger
```

Canonical scheduling and admission contracts remain outside `.agents`. Root
`contract.cue` and `registry.cue` disclose admitted task references, while
`.agents/dispatcher/` contains only the ChatGPT procedure and non-authoritative
execution records. UQAM and industrial-constraint work remain independent
domain implementation units.

## Authority and implementation ordering

1. Implement and validate the root unit vocabulary and empty registry without
   relocating existing authorities.
2. Admit canonical unit-local contracts and task references before dispatcher
   registration.
3. Define a dispatcher requirement family covering:
   - a canonical dispatcher registry;
   - epoch, cadence, window, and deterministic-occurrence semantics;
   - common invocation and result contracts;
   - append-only execution state and retry safety;
   - CUE-computed due admission and task isolation;
   - compatibility migration for existing scheduled monitors.
4. Implement the dispatcher only after its registry projection,
   resolved-snapshot, runtime binding, and task-local adapter dependencies are
   explicit and validated.
5. Implement the dispatcher through root-disclosed CUE authority, a thin
   ChatGPT entrypoint, a CI preflight binding, and task-owned adapters.

The planned repository surfaces are:

```text
<repo>/contract.cue
    shared repository and registry invariants

<repo>/registry.cue
    admitted unit identities and task references

contracts/factory/dispatcher/
    canonical dispatcher schemas, registry, admission, and fixtures

.agents/dispatcher/
    AGENTS.md
    chatgpt-task-prompt.md
    executions/<task>/<occurrence>/<attempt>/

.github/workflows/
    dispatcher CUE preflight and validation binding

projects|academic|world/<unit>/
    task-local authority and dispatcher adapters

contracts/compatibility/
    temporary legacy invocation surfaces
```

The append-only execution tree is runtime state and evidence. It is never
repository, schedule, domain, or admission authority.

The control planes remain mechanically distinct:

```text
declarative authority
    contract.cue / registry.cue / unit-local contracts

        |
        v

derived control state
    projected task references / dispatcher registrations / due plans /
    resolved snapshots

        |
        v

observed runtime state
    attempts / task results / reports / execution ledger
```

Derived control state and runtime observations never become authority merely
because the dispatcher produced or consumed them.

## Dispatcher contracts

### Task registration

`#TaskRegistration` binds an admitted root-registry task reference to
**dispatcher-only** configuration:

- stable task reference;
- enabled state and effective activation date;
- explicit IANA timezone;
- schedule and task-declared misfire policy; and
- a six-hour stale-attempt timeout.

Conceptually:

```cue
#TaskRegistration: close({
    task: #TaskRef

    enabled: bool
    activationDate: #CivilDate
    timezone: #IANAZone
    schedule: #Schedule
    misfire: #MisfirePolicy
    staleAttemptAfter: #Duration
})
```

The root registry remains the identity/reference graph. Dispatcher registration
must not independently redefine task authority, adapter path, publication
contract, or domain identity. Any such values required at runtime are
mechanically projected from the admitted task reference.

```text
root registry task reference
        |
        v
mechanical dispatcher projection
        +
dispatcher-only schedule configuration
```

This prevents the dispatcher registry from becoming a second task registry or
a competing semantic authority.

The first candidate registrations are:

```text
projects.ctrl.upstream-monitor
projects.epistemic-plant-bootstrap.upstream-monitor
```

They resolve through admitted root-registry task references. Compatibility
adapters may retain their current invocation and publication paths during
cutover. Both use the epoch `2026-08-24`, a three-day cadence,
`America/Toronto`, a full civil-day window, and `coalesce_latest`. Registration
activation starts at cutover, so pre-cutover occurrences do not create
artificial backlog.

No disabled UQAM or industrial placeholder registration is added in this unit.

### Schedule and occurrence

`#Schedule` uses an exclusive cadence shape:

```cue
cadence: close({
    unit:  "days" | "weeks"
    every: int & >0
})
```

It also carries an ISO civil-date epoch, optional weekday qualification, and a
local `notBefore`/`notAfter` execution window. Dates and windows are evaluated
in the registration's IANA timezone.

An occurrence is derived from schedule topology rather than execution history.
Its canonical ID is:

```text
<task-id>/<scheduled-civil-date>
```

The occurrence also retains its epoch index, registry digest, scheduled civil
date, timezone, and resolved UTC window. V1 permits at most one occurrence per
task per civil date.

### Misfire policy

Every registration chooses one policy:

- `catch_up_all`: dispatch every overdue unterminal occurrence;
- `coalesce_latest`: dispatch the newest occurrence and classify older
  unterminal occurrences as coalesced;
- `expire`: classify closed occurrences as expired without task execution.

Coalesced and expired occurrences are dispatcher dispositions, not fabricated
task results.

### Invocation, attempt, and result

`#TaskInvocation` binds:

- task, occurrence, and attempt IDs;
- scheduled and invoked times;
- the admitted due-plan digest;
- the resolved repository snapshot and registry digest.

`#TaskResult` has exactly these terminal states:

```text
success
no_change
deferred
coverage_gap
failed
```

All five states are terminal for the occurrence. Only an attempt that never
produced a valid result may retry after its six-hour stale-attempt boundary.
Attempt ordinals are contiguous, and no attempt may begin after a terminal
result or dispatcher disposition.

Task results provide publication references and digests. They never provide an
`admitted` or `due` claim. CUE validates the referenced task-local evidence and
computes dispatcher result admission.

Task-local adapters own result normalization. For the two existing monitors:

- `terminal_abort` maps to `failed`;
- `terminal_deferred` maps to `deferred`;
- `coverage_gap` maps to `coverage_gap`;
- `terminal_success` maps to `success` or `no_change` from the validated local
  report content.

Task-specific qualification state remains orthogonal and is not reinterpreted
by the dispatcher.

### Compatibility adapters

Compatibility adapters are invocation and result-shape translators only. They
may reference canonical task authority and preserve a legacy invocation or
publication surface during migration, but they must not define:

- task identity;
- schedule semantics;
- domain qualification semantics; or
- publication admission.

Compatibility therefore flows toward canonical authority rather than creating
a second authoritative path:

```text
legacy invocation
        |
        v
compatibility adapter
        |
        v
canonical task authority
```

## Daily execution

The daily ChatGPT task is configured for `12:05 America/Toronto` and follows
this sequence:

1. Submit the observed tick and repository revision to the dispatcher preflight
   workflow.
2. Have CI obtain its own current-time observation, validate the resolved root,
   registry, ledger, toolchain, and tick, then run CUE.
3. Publish a transient due-plan archive bound to the repository revision,
   registry digest, workflow digest, CUE identity, tick, and plan digest.
4. Consume only a due plan whose CUE admission export is literally `true`.
5. Commit append-only attempt claims for admitted due occurrences and wait for
   claim validation.
6. Resolve each admitted task through its root-registry reference and invoke it
   independently through its task-owned adapter. Unit-local execution remains
   governed by the unit's own contract.
7. Validate and append each result before proceeding to the next independent
   occurrence.
8. Return a compact dispatcher summary.

The ChatGPT environment's bundled CUE may be used for independent verification,
but it does not replace the CI-produced admission artifact unless a later
runtime-binding requirement explicitly admits that transition.

A malformed root, registry, ledger, or due plan stops the entire dispatcher
tick because task selection cannot be trusted. Once the due plan is admitted,
a task-local failure is recorded and does not suppress unrelated occurrences.

Existing task bundles gain optional dispatcher occurrence and attempt identity.
This preserves legacy direct signals while allowing a stale retry to discover
already-published work and close its dispatcher result without duplicating
domain publication.

## Validation

The implementation unit must cover:

- CUE formatting, independent package vetting, closed-schema export, and
  literal-true due-plan and result admission;
- exact schedule dates `2026-08-24`, `2026-08-27`, and `2026-08-30`, plus the
  non-due date `2026-08-25`;
- weekly weekday qualification and `America/Toronto` daylight-saving
  boundaries;
- rejection of mixed cadence units, invalid zones, dates, or windows, path
  escapes, disabled or pre-activation tasks, mismatched IDs or digests,
  duplicate terminal results, and claimant-supplied due/admission booleans;
- catch-up, coalescing, and expiry behavior;
- duplicate ticks, stale incomplete attempts, already-published task output,
  and terminal no-rerun behavior;
- unchanged legacy direct monitor invocations and existing run bundles;
- one failed task not preventing another admitted task from completing;
- rejection of dispatcher registrations that independently redefine canonical
  task authority, adapter, publication, or domain identity;
- rejection of compatibility adapters that claim schedule, qualification, or
  publication-admission authority; and
- end-to-end tick submission, due-plan archive retrieval, claim validation,
  task execution, append-only completion, and summary rendering.

The implementation is admitted only through a canonical repository workflow
that validates the root registry, dispatcher contracts, runtime binding, and
task-local evidence. Any CUE-computed admission export must be literally
`true`.

## Rollout and rollback

1. Admit both unit-local task contracts and their root-registry references.
2. Merge the dispatcher contracts and adapters with both registrations
   disabled.
3. Configure the daily ChatGPT clock and prove a no-op preflight against the
   admitted registry.
4. Enable the two registrations and disable the existing combined upstream
   monitor scheduled task before the next three-day occurrence.
5. Verify the first admitted due plan, both independent task outcomes, and the
   append-only dispatcher ledger.
6. Roll back, if necessary, by disabling the registrations and re-enabling the
   previous scheduled task. Preserve execution history.

The existing UQAM and industrial scheduled jobs remain unchanged. Each moves
under the dispatcher only after its unit-local authority, evidence flow,
adapter, scenarios, publication contract, and root-registry task reference are
independently admitted.

## Assumptions

- The ChatGPT automation can trigger and inspect GitHub Actions and retrieve
  the due-plan archive. This capability must be proven before cutover.
- Schedule authority, execution history, and domain state remain separate.
- Generated due plans, attempts, summaries, reports, and execution ledgers are
  non-authoritative observations.
- The dispatcher never learns domain semantics beyond the common invocation,
  result, publication-reference, and task-adapter interfaces.
