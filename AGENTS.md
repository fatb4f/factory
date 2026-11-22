# Factory repository instructions

## Engineering issue tracking

Factory engineering work that persists across conversations, runs, graph realizations, substrate work, or project phases must use the repository's GitHub Issues operating model.

Before creating, updating, closing, reopening, or correlating a Factory engineering issue, read in order:

1. `contracts/state/tracker.cue` — shared executable tracker schema;
2. `.github/ISSUES/AGENTS.md` — GitHub Issues projection and reconciliation procedure;
3. the narrow domain/profile/project contract that owns the issue semantics.

GitHub Issues is operational state, not semantic authority.

Keep `engineering-intent` separate from `evidence-derived` issues. A planned Factory change does not establish an external fact, and an observed external event does not become engineering work until explicitly admitted and projected.

Track one primary entity per issue (`graph`, `substrate`, `project`, `worker`, `profile`, `contract`, `adapter`, or `runtime`) and use explicit issue dependencies rather than inferring coupling from repository paths or names.

Correlate by `factory-issue-key`, never by title or GitHub issue number.

## Existing authority model

Continue to place normative semantics at the narrowest CUE authority. Repository procedures, agents, generated projections, execution environments, external tools, GitHub state, and model conclusions remain downstream unless a contract explicitly admits them.

## Git task isolation

Keep the primary `main` checkout clean and synchronized with `origin/main`. Do not
implement durable work directly on `main`. Correlate the work to its stable
`factory-issue-key`, then create one task branch and one worktree with
`scripts/create-task-worktree.sh` or the Codex app's Worktree action.

Branch names use `<type>/<issue-number>-<slug>`, where `type` is `feat`, `fix`,
`docs`, `chore`, `contracts`, or `test`. Integrate through a pull request after
the relevant CUE and implementation validations pass. Never reset or delete an
unmerged task to resolve worktree contention; use Codex Handoff or switch the
other worktree away from the branch. See
[`docs/development/codex-github-workflow.md`](docs/development/codex-github-workflow.md).

## IVAC project dispatch

For IVAC regulatory, evidence, case-snapshot or analytical work, start with
[`personal/ivac/AGENTS.md`](personal/ivac/AGENTS.md). That dispatcher routes to the
existing CUE authorities, verified adapters and documentation. Private case facts
remain in source-anchored private snapshots, outside this repository.
