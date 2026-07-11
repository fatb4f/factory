#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

payload='{"hook_event_name":"UserPromptSubmit","prompt":"inspect the CUE and Python code-intel context profiles"}'
output=$(printf '%s\n' "$payload" | sh .kg/hooks/codex/user-prompt-submit)

printf '%s\n' "$output" | jq -e '
  .hookSpecificOutput.hookEventName == "UserPromptSubmit"
  and (.hookSpecificOutput.additionalContext | fromjson
    | .schema == "factory.context-packet.v0"
    and .admitted == true
    and (.selected_fragments | length > 0)
    and (.implementation_plan | length > 0)
    and (.context_graph.nodes | length > 0))
' >/dev/null
