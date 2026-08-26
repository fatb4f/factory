# Factory daily dispatcher

This directory contains the actuator procedure and append-only execution evidence. It is not repository, schedule, task, or admission authority. Canonical dispatcher authority is `contracts/factory/dispatcher/`; admitted task references come from root `registry.cue`.

Only consume a CI-produced due-plan archive when its `plan.admission` value is literally `true`, its repository revision is the checked-out revision, and its recomputed `planDigest` matches. A due plan is not a lease: recompute current tick and ledger admission before every claim or disposition. Process dispatch items independently in listed order. Invoke a task-owned adapter only when `claim` reports `created`; `already_claimed` is non-actionable. Commit the claim and wait for qualification on that exact revision before task execution.

Task adapters return a task-completion reference to an immutable sealed local run bundle, not a dispatcher state claim. The mutable `latest.json` pointer is never durable result evidence. The registered task adapter contract validates the sealed evidence and projects the common result. A failure before task-local evidence admission leaves the attempt incomplete and retryable after its stale boundary.

Never modify an existing claim, result, disposition, or sealed task publication. An invalid root, registry, ledger, transition, plan, or digest stops the tick. A task-local admitted failure is recorded and does not stop later dispatch items.
