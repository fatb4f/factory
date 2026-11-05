#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: $0 <type> <issue-number> <slug>" >&2
  echo "types: feat fix docs chore contracts test" >&2
}

die() {
  echo "create-task-worktree: $*" >&2
  exit 1
}

[[ $# -eq 3 ]] || {
  usage
  exit 2
}

task_type="$1"
issue_number="$2"
task_slug="$3"

case "$task_type" in
  feat|fix|docs|chore|contracts|test) ;;
  *) die "unsupported type: $task_type" ;;
esac

[[ "$issue_number" =~ ^[1-9][0-9]*$ ]] || die "issue number must be a positive integer"
[[ "$task_slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "slug must be lowercase kebab-case"

repository_root="$(git rev-parse --show-toplevel 2>/dev/null)" || die "run from a Factory checkout"
[[ -f "$repository_root/contracts/state/tracker.cue" ]] || die "run from a Factory checkout"
git -C "$repository_root" remote get-url origin >/dev/null 2>&1 || die "origin remote is required"

canonical_worktree="$({
  git -C "$repository_root" worktree list --porcelain
} | awk '
  /^worktree / { path = substr($0, 10) }
  /^branch refs\/heads\/main$/ { print path; exit }
')"

[[ -n "$canonical_worktree" ]] || die "no worktree has local main checked out"
[[ -z "$(git -C "$canonical_worktree" status --porcelain)" ]] || die "primary main worktree is not clean: $canonical_worktree"

git -C "$canonical_worktree" fetch --no-tags origin refs/heads/main:refs/remotes/origin/main
git -C "$canonical_worktree" merge --ff-only origin/main

local_main="$(git -C "$canonical_worktree" rev-parse refs/heads/main)"
remote_main="$(git -C "$canonical_worktree" rev-parse refs/remotes/origin/main)"
[[ "$local_main" == "$remote_main" ]] || die "local main is not identical to origin/main"

branch_name="$task_type/$issue_number-$task_slug"
worktree_name="$task_type-$issue_number-$task_slug"
worktree_root="${FACTORY_WORKTREE_ROOT:-$(dirname "$canonical_worktree")/factory-worktrees}"
worktree_path="$worktree_root/$worktree_name"

git -C "$canonical_worktree" show-ref --verify --quiet "refs/heads/$branch_name" && die "local branch already exists: $branch_name"

set +e
git -C "$canonical_worktree" ls-remote --exit-code --heads origin "refs/heads/$branch_name" >/dev/null 2>&1
remote_branch_status=$?
set -e
case "$remote_branch_status" in
  0) die "remote branch already exists: $branch_name" ;;
  2) ;;
  *) die "could not verify remote branch availability" ;;
esac

[[ ! -e "$worktree_path" ]] || die "worktree path already exists: $worktree_path"
mkdir -p "$worktree_root"

git -C "$canonical_worktree" worktree add --no-track -b "$branch_name" "$worktree_path" origin/main

echo "branch: $branch_name"
echo "worktree: $worktree_path"
