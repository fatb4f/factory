# Factory Daily Dispatcher

Status: proposed, non-authoritative design plan

Implementation note (2026-08-25): commit `26a3be4` landed the foundation,
unit mappings, dispatcher, and registrations in one change before the staged
migration gates were satisfied. The registrations are therefore kept disabled
with no activation date while authority, evidence projection, retry admission,
and automatic qualification are corrected. This note records the exception;
it does not retroactively treat the combined landing as an admitted cutover.

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
    activationDate?: #CivilDate // required exactly when enabled
    timezone: #IANAZone
    schedule: #Schedule
    misfire: #MisfirePolicy
    staleAttemptAfter: #Duration
})
```

The root registry remains the identity/reference graph. A generic task
reference contains only identity and domain authority. Project mappings import
that authority and expose dispatcher-specific adapter contract and procedure
metadata; dispatcher registration projects those values rather than placing an
invocation adapter in the shared unit vocabulary. Registration must not
independently redefine task authority, publication contract, or domain
identity.

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

Task adapters return a common task-completion reference containing immutable
sealed evidence, manifest, and publication paths with exact digests. Mutable
`latest.json` pointers are operational discovery state, not durable result
evidence.
They do not supply dispatcher state, reportable-item counts, `admitted`, or
`due`. The registered task adapter contract validates the profile-specific
documents, binds their dispatcher context to the claim, and projects the
common result. The generic dispatcher stores only that projected result and
revalidates it whenever the ledger is read.

Task-local adapter contracts own result projection. For the two existing monitors:

- `terminal_abort` maps to `failed`;
- `terminal_deferred` maps to `deferred`;
- `coverage_gap` maps to `coverage_gap`;
- `terminal_success` maps to `success` when the validated local evidence has a
  decision other than `none`, and to `no_change` otherwise. The evidence item
  list remains the semantic source for report rendering.

An actuator failure before sealed task-local evidence exists does not fabricate
a terminal `failed` result. The claimed attempt remains incomplete and becomes
retryable only after its stale boundary.

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
5. Recompute the current tick, ledger, and due projection under an
   task-scoped transition lock. Append a claim only if the archived item
   remains the exact current dispatch item; then commit it and wait for
   qualification on that exact revision.
6. Resolve each admitted task through its root-registry reference and invoke it
   independently through its task-owned adapter. Unit-local execution remains
   governed by the unit's own contract.
7. Validate and append each result before proceeding to the next independent
   occurrence.
8. Return a compact dispatcher summary.

The ChatGPT environment's bundled CUE may be used for independent verification,
but it does not replace the CI-produced admission artifact unless a later
runtime-binding requirement explicitly admits that transition.

A due plan is a bound decision artifact, not a durable lease. Claims and
dispositions are re-admitted immediately before each append, and dispositions
are recomputed one at a time. A terminal result, existing disposition, newer
attempt, or later coalescing occurrence invalidates a stale archived action.

A malformed root, registry, ledger, transition, or due plan stops the entire dispatcher
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
that runs automatically for pull requests and pushes to `main`, validating the
root registry, dispatcher contracts, Python scenarios, both worker modules,
runtime ledger, and task-local evidence projection. Manual dispatch additionally
produces the due-plan artifact. Any CUE-computed admission export must be
literally `true`.

## Rollout and rollback

1. Admit both unit-local task contracts and their root-registry references.
2. Merge the dispatcher contracts and adapters with both registrations
   disabled and with `activationDate` absent.
3. Configure the daily ChatGPT clock and prove a no-op preflight against the
   admitted registry.
4. In a separately approved, cadence-aligned cutover, add the actual future
   `activationDate`, enable the two registrations, and disable the existing
   combined upstream monitor scheduled task before that occurrence.
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
