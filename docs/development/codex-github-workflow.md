# Codex and GitHub workflow

This procedure keeps Codex tasks independent without creating a second source
of truth.

## Authority and ownership

- CUE owns Factory semantics at the narrowest applicable contract.
- GitHub `fatb4f/factory` owns canonical committed history, pull requests, and
  CI results.
- The primary local `main` checkout is a clean integration mirror of
  `origin/main`; it is not a task workspace.
- Each durable task owns one issue, one branch, and one worktree. The stable
  `factory-issue-key` remains the task identity; issue and branch numbers are
  operational projections.
- A Codex conversation owns context, not repository state. Durable decisions
  belong in CUE, repository documentation, commits, or the correlated issue.

Conversation synchronization does not copy a repository. A Codex-managed
worktree remains on its host and may be removed when its task is archived.
Commit and push work that must survive cleanup.

## Start a task

1. Fetch current GitHub state and inspect `main`, open pull requests, registered
   worktrees, and the working tree.
2. Read `AGENTS.md`, then the narrow contract and procedure that own the work.
3. For durable work, reconcile an existing `factory-issue-key` or create a
   tracker-compliant issue before branching.
4. Start from `origin/main` in one of two ways:
   - In the Codex app, select **Worktree**, base it on `main`, and use **Create
     branch here** when the change is ready to retain.
   - From a checkout, run:

     ```text
     bash scripts/create-task-worktree.sh <type> <issue-number> <slug>
     ```

The helper refuses a dirty or divergent primary `main`, existing local or
remote branches, invalid names, and worktree path collisions. Its default root
is a `factory-worktrees` directory beside the primary checkout. Override it for
a different local location with `FACTORY_WORKTREE_ROOT`.

Do not copy private IVAC evidence, credentials, or machine-local state into a
worktree. If `.worktreeinclude` is introduced later, list only reviewed ignored
files that are safe and required for local setup.

## Branch names

Use `<type>/<issue-number>-<slug>`:

| Type | Use |
| --- | --- |
| `feat` | Product or runtime capability |
| `fix` | Defect correction |
| `contracts` | CUE authority or schema change |
| `docs` | Documentation-only change |
| `test` | Test-only change |
| `chore` | Repository procedure or maintenance |

Use a lowercase hyphenated slug. Do not reuse a branch for a second issue or
use one issue to hide independent authorities.

## Validate and integrate

Run the smallest relevant validation while developing. Before marking a pull
request ready:

1. run the changed domain's CUE and implementation gates;
2. run `bash scripts/test-create-task-worktree.sh` when this repository workflow
   changes;
3. run `bash scripts/validate-contracts.sh` for cross-cutting contract changes;
4. record exact commands and any pre-existing or environment-specific failures
   in the pull request;
5. push the task branch and open a pull request to `main` with the stable issue
   key and closing issue reference.

`repository-policy` is the stable required check for branch protection. The
full contract workflow remains visible on every pull request; promote it to a
required check only when its current cross-platform IVAC source-conversion
baseline is green. A failing required check is never bypassed by resetting or
rewriting another task.

Prefer a squash merge for one-purpose tasks. Preserve a merge commit when the
individual commits carry useful review or provenance boundaries. GitHub may
delete a merged branch automatically; that does not delete the pull request or
committed history.

## Handoff and cleanup

Git permits a branch to be checked out in only one worktree. Use Codex
**Handoff** to move a task between Worktree and Local. Do not force another
checkout of the same branch.

Archive a Codex task only after one of these terminal states is verified:

- its pull request is merged;
- its retained work is committed and pushed on an explicitly named branch; or
- it made no repository changes and its final result is already summarized.

Keep tasks with uncommitted or unpushed work visible and label their title as
WIP. Do not delete conversations as cleanup. Archiving is reversible, and
Codex saves a snapshot before automatically removing a managed worktree, but a
pushed branch is the durable recovery point.

After merge, refresh the primary checkout with a fast-forward-only update and
remove a manual worktree only after verifying its branch is merged or retained
remotely. Never use a destructive reset as a synchronization mechanism.
