# Factory Daily Dispatcher

Status: proposed, non-authoritative design plan  
Architectural authority: [factory#103](https://github.com/fatb4f/factory/issues/103)  
Current BDD bootstrap authority: [factory#104](https://github.com/fatb4f/factory/issues/104)

This document records an implementation proposal. It does not amend the
requirement graph, define repository authority, admit an implementation unit,
or replace vetted CUE declarations.

## Summary

Introduce a CUE-admitted dispatcher overlay for the existing `ctrl` and
`epistemic-plant-bootstrap` monitors without relocating their authorities.
The single recurring ChatGPT task owns only the daily clock. Factory owns the
schedule registry, due-task admission, task invocation, task-local execution,
and result admission.

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
task-local authority and execution
        |
        v
admitted result / no change / deferred / coverage gap / failure
        |
        v
append-only dispatcher execution ledger
```

Canonical scheduling and admission contracts remain outside `.agents`. Root
`.kb` discloses them, while `.agents/dispatcher/` contains only the ChatGPT
procedure and non-authoritative execution records. UQAM, industrial-constraint,
and directory-relocation work remain separate later implementation units.

## Authority and implementation ordering

1. Finish issue #104 against its pinned issue #103 revision before changing the
   parent requirement graph.
2. Amend issue #103 with a dispatcher requirement family covering:
   - a canonical dispatcher registry;
   - epoch, cadence, window, and deterministic-occurrence semantics;
   - common invocation and result contracts;
   - append-only execution state and retry safety;
   - CUE-computed due admission and task isolation;
   - compatibility migration for existing scheduled monitors.
3. Create an ordinary post-bootstrap implementation issue with a complete
   dependency closure. It depends on the admitted BDD contract, root `.kb`,
   resolved-snapshot, registry, and runtime-binding requirements.
4. Capture applicable architectural decisions as candidate KG records and
   admit them through the architecture-KG workflow when that substrate exists.
5. Implement the dispatcher through root-disclosed CUE authority, a thin
   ChatGPT entrypoint, a CI preflight binding, and task-owned adapters.

The planned repository surfaces are:

```text
<repo>/.kb
    thin dispatcher descriptor and admitted references

contracts/factory/dispatcher/
    canonical dispatcher schemas, registry, admission, and fixtures

.agents/dispatcher/
    AGENTS.md
    chatgpt-task-prompt.md
    executions/<task>/<occurrence>/<attempt>/

.github/workflows/
    dispatcher CUE preflight and validation binding

existing task profile packages
    task-owned dispatcher adapters
```

The append-only execution tree is runtime state and evidence. It is never
repository, schedule, domain, or admission authority.

## Dispatcher contracts

### Task registration

`#TaskRegistration` contains:

- stable task ID;
- task authority and adapter references;
- enabled state and effective activation date;
- explicit IANA timezone;
- schedule and task-declared misfire policy;
- a six-hour stale-attempt timeout.

The initial registrations are:

```text
projects.ctrl.upstream-monitor
projects.epistemic-plant-bootstrap.upstream-monitor
```

They retain their current authority and publication paths. Both use the epoch
`2026-08-24`, a three-day cadence, `America/Toronto`, a full civil-day window,
and `coalesce_latest`. Registration activation starts at cutover, so
pre-cutover occurrences do not create artificial backlog.

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
6. Resolve and execute each task independently through its task-owned adapter.
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
- end-to-end tick submission, due-plan archive retrieval, claim validation,
  task execution, append-only completion, and summary rendering.

The implementation is admitted only through the canonical BDD workflow when
its CUE-exported implementation-unit admission is literally `true`.

## Rollout and rollback

1. Merge the dispatcher contracts and adapters with both registrations
   disabled.
2. Configure the daily ChatGPT clock and prove a no-op preflight against the
   admitted registry.
3. Enable the two registrations and disable the existing combined upstream
   monitor scheduled task before the next three-day occurrence.
4. Verify the first admitted due plan, both independent task outcomes, and the
   append-only dispatcher ledger.
5. Roll back, if necessary, by disabling the registrations and re-enabling the
   previous scheduled task. Preserve execution history.

The existing UQAM and industrial scheduled jobs remain unchanged. Each moves
under the dispatcher only after its task-local authority, adapter, scenarios,
and registration are independently admitted. Relocating authorities into
`projects/`, `academic/`, or `world/` is also a separate migration.

## Assumptions

- The ChatGPT automation can trigger and inspect GitHub Actions and retrieve
  the due-plan archive. This capability must be proven before cutover.
- Schedule authority, execution history, and domain state remain separate.
- Generated due plans, attempts, summaries, reports, and execution ledgers are
  non-authoritative observations.
- The dispatcher never learns domain semantics beyond the common invocation,
  result, publication-reference, and task-adapter interfaces.
