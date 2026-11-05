#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
helper="$script_dir/create-task-worktree.sh"
test_root="$(mktemp -d)"

cleanup() {
  case "$test_root" in
    /tmp/*) rm -rf -- "$test_root" ;;
    *) echo "refusing to remove unexpected test path: $test_root" >&2 ;;
  esac
}
trap cleanup EXIT

fail() {
  echo "test-create-task-worktree: $*" >&2
  exit 1
}

expect_failure() {
  if "$@" >"$test_root/expected-failure.log" 2>&1; then
    fail "command unexpectedly succeeded: $*"
  fi
}

remote="$test_root/origin.git"
seed="$test_root/seed"
canonical="$test_root/factory"
worktrees="$test_root/worktrees"

git init --bare --initial-branch=main "$remote" >/dev/null
git init -b main "$seed" >/dev/null
git -C "$seed" config user.name "Factory workflow test"
git -C "$seed" config user.email "workflow-test@example.invalid"
mkdir -p "$seed/contracts/state"
printf '%s\n' "seed" >"$seed/README.md"
printf '%s\n' "package state" >"$seed/contracts/state/tracker.cue"
git -C "$seed" add README.md contracts/state/tracker.cue
git -C "$seed" commit -m "seed" >/dev/null
git -C "$seed" remote add origin "$remote"
git -C "$seed" push -u origin main >/dev/null
git -C "$remote" symbolic-ref HEAD refs/heads/main
git clone "$remote" "$canonical" >/dev/null

(
  cd "$canonical"
  FACTORY_WORKTREE_ROOT="$worktrees" bash "$helper" feat 42 example-task
) >/dev/null

first_worktree="$worktrees/feat-42-example-task"
[[ "$(git -C "$first_worktree" branch --show-current)" == "feat/42-example-task" ]] || fail "unexpected task branch"
[[ "$(git -C "$first_worktree" rev-parse HEAD)" == "$(git -C "$canonical" rev-parse origin/main)" ]] || fail "task did not start at origin/main"
[[ -z "$(git -C "$canonical" status --porcelain)" ]] || fail "canonical main became dirty"

(
  cd "$canonical"
  expect_failure env FACTORY_WORKTREE_ROOT="$worktrees" bash "$helper" feat 42 example-task
  expect_failure env FACTORY_WORKTREE_ROOT="$worktrees" bash "$helper" feat 43 Not-Kebab-Case
)

printf '%s\n' "dirty" >>"$canonical/README.md"
(
  cd "$canonical"
  expect_failure env FACTORY_WORKTREE_ROOT="$worktrees" bash "$helper" fix 44 dirty-main
)
git -C "$canonical" restore README.md

printf '%s\n' "second" >>"$seed/README.md"
git -C "$seed" add README.md
git -C "$seed" commit -m "advance main" >/dev/null
git -C "$seed" push origin main >/dev/null

(
  cd "$canonical"
  FACTORY_WORKTREE_ROOT="$worktrees" bash "$helper" docs 45 refreshed-main
) >/dev/null

second_worktree="$worktrees/docs-45-refreshed-main"
[[ "$(git -C "$canonical" rev-parse main)" == "$(git -C "$seed" rev-parse main)" ]] || fail "canonical main was not fast-forwarded"
[[ "$(git -C "$second_worktree" rev-parse HEAD)" == "$(git -C "$seed" rev-parse main)" ]] || fail "second task used a stale base"

echo "create-task-worktree tests passed"
