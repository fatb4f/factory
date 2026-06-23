#!/usr/bin/env bash
set -u -o pipefail

usage() {
	printf 'usage: %s [eval-runner-plan.json]\n' "$0" >&2
	printf '       cue export ./contracts/agent-context-resolver -e resolverHookEvalRunnerPlan | %s\n' "$0" >&2
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
results_jsonl="$(mktemp)"
trap 'rm -f "$plan" "$command_output" "$results_jsonl"' EXIT

if [ -n "$plan_file" ]; then
	cp "$plan_file" "$plan"
else
	cat >"$plan"
fi

if ! jq -e '
	# The factory schema is accepted only as adapter compatibility for older exported
	# plans; semantic authority lives in the CUE package that produced the plan.
	(.schema == "factory.eval-runner-plan.v1" or .schema == "agent-context-resolver.eval-runner-plan.v1" or .schema == "agent-context-resolver.implementation-slice-runner-plan.v1")
	and (.commands | type == "array" and length > 0)
	and all(.commands[]; (.id | type == "string" and length > 0)
		and (.sourceEvalID | type == "string" and length > 0)
		and (.command | type == "array" and length > 0)
		and all(.command[]; type == "string" and length > 0)
		and (.expect == "pass" or .expect == "fail")
		and (if .expect == "fail" then (.reasonClass == "structural_bottom") else true end))
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
	expected_reason="$(jq -r --argjson i "$i" '.commands[$i].reasonClass // "none"' "$plan")"

	mapfile -t argv < <(jq -r --argjson i "$i" '.commands[$i].command[]' "$plan")

	printf 'run-eval-plan: %s\n' "$id" >&2

	"${argv[@]}" >"$command_output" 2>&1
	status="$?"

	actual_reason="none"
	if [ "$status" -ne 0 ]; then
		if grep -Eq 'reference .* not found|undefined field|field not allowed|cannot reference optional field' "$command_output"; then
			actual_reason="missing_selector"
		elif grep -Eq 'cannot find package|cannot load|no such file|unknown file extension' "$command_output"; then
			actual_reason="load_error"
		elif grep -Eq 'expected|illegal|invalid character|syntax' "$command_output"; then
			actual_reason="syntax_error"
		elif grep -Eq '_\\|_|conflicting values|incomplete value' "$command_output"; then
			actual_reason="structural_bottom"
		else
			actual_reason="tool_failure"
		fi
	fi

	if [ "$expect" = "pass" ] && [ "$status" -eq 0 ]; then
		result_status="pass"
	elif [ "$expect" = "fail" ] && [ "$status" -ne 0 ] && [ "$actual_reason" = "$expected_reason" ]; then
		result_status="pass"
	else
		result_status="fail"
		printf 'run-eval-plan: expectation mismatch for %s: expect=%s status=%s expectedReason=%s actualReason=%s\n' "$id" "$expect" "$status" "$expected_reason" "$actual_reason" >&2
		cat "$command_output" >&2
		failures=$((failures + 1))
	fi

	jq -cn \
		--arg commandID "$id" \
		--arg status "$result_status" \
		--arg expected "$expect" \
		--argjson exitCode "$status" \
		--arg reasonClass "$actual_reason" \
		'{commandID: $commandID, status: $status, expected: $expected, actual: {exitCode: $exitCode}, reasonClass: $reasonClass}' \
		>>"$results_jsonl"

	i=$((i + 1))
done

if [ -n "$plan_file" ]; then
	plan_dir="$(dirname "$plan_file")"
	issue_id="$(jq -r '.issueID // "unknown"' "$plan")"
	jq -s --arg issueID "$issue_id" '{schema: "agent-context-resolver.runner-result.v1", issueID: $issueID, results: .}' "$results_jsonl" >"$plan_dir/runner-result.json"
	jq -s --arg issueID "$issue_id" '{schema: "agent-context-resolver.implementation-slice-feedback.v1", issueID: $issueID, results: .}' "$results_jsonl" >"$plan_dir/feedback.json"
fi

if [ "$failures" -ne 0 ]; then
	printf 'run-eval-plan: %s command expectation(s) failed\n' "$failures" >&2
	exit 1
fi

exit 0
