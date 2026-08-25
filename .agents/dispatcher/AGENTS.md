# Factory daily dispatcher

This directory contains the actuator procedure and append-only execution evidence. It is not repository, schedule, task, or admission authority. Canonical dispatcher authority is `contracts/factory/dispatcher/`; admitted task references come from root `registry.cue`.

Only consume a CI-produced due-plan archive when its `plan.admission` value is literally `true`, its repository revision is the checked-out revision, and its recomputed `planDigest` matches. Process dispatch items independently in listed order. Create and validate an append-only claim before invoking the task-owned adapter, then validate and append exactly one result.

Never modify an existing claim, result, disposition, or sealed task publication. An invalid root, registry, ledger, plan, or digest stops the tick. A task-local failure is recorded and does not stop later dispatch items.
