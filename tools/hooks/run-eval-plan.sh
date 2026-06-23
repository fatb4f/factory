#!/usr/bin/env bash
set -u -o pipefail

usage() {
	printf 'usage: %s [eval-runner-plan.json]\n' "$0" >&2
	printf '       cue export ./contracts/factory -e hookEvalRunnerPlan | %s\n' "$0" >&2
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
	usage
	exit 0
fi

if [ "$#" -gt 1 ]; then
	usage
	exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
	printf 'run-eval-plan: jq is required\n' >&2
	exit 2
fi

plan_file="${1:-}"
if [ -n "$plan_file" ] && [ ! -r "$plan_file" ]; then
	printf 'run-eval-plan: cannot read plan file: %s\n' "$plan_file" >&2
	exit 2
fi

plan="$(mktemp)"
command_output="$(mktemp)"
trap 'rm -f "$plan" "$command_output"' EXIT

if [ -n "$plan_file" ]; then
	cp "$plan_file" "$plan"
else
	cat >"$plan"
fi

if ! jq -e '
	(.schema == "factory.eval-runner-plan.v1" or .schema == "agent-context-resolver.eval-runner-plan.v1")
	and (.commands | type == "array" and length > 0)
	and all(.commands[]; (.id | type == "string" and length > 0)
		and (.command | type == "array" and length > 0)
		and all(.command[]; type == "string" and length > 0)
		and (.expect == "pass" or .expect == "fail"))
' "$plan" >/dev/null; then
	printf 'run-eval-plan: invalid eval runner plan\n' >&2
	exit 2
fi

failures=0
count="$(jq '.commands | length' "$plan")"

i=0
while [ "$i" -lt "$count" ]; do
	id="$(jq -r --argjson i "$i" '.commands[$i].id' "$plan")"
	expect="$(jq -r --argjson i "$i" '.commands[$i].expect' "$plan")"

	mapfile -t argv < <(jq -r --argjson i "$i" '.commands[$i].command[]' "$plan")

	printf 'run-eval-plan: %s\n' "$id" >&2

	"${argv[@]}" >"$command_output" 2>&1
	status="$?"

	case "$expect:$status" in
		pass:0 | fail:[1-9]*)
			;;
		*)
			printf 'run-eval-plan: expectation mismatch for %s: expect=%s status=%s\n' "$id" "$expect" "$status" >&2
			cat "$command_output" >&2
			failures=$((failures + 1))
			;;
	esac

	i=$((i + 1))
done

if [ "$failures" -ne 0 ]; then
	printf 'run-eval-plan: %s command expectation(s) failed\n' "$failures" >&2
	exit 1
fi

exit 0
