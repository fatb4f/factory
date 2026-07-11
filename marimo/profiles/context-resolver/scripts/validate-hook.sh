#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

hook=marimo/profiles/context-resolver/hooks/codex/user-prompt-submit
payload='{"hook_event_name":"UserPromptSubmit","prompt":"inspect the CUE and Python code-intel context profiles"}'
output=$(printf '%s\n' "$payload" | sh "$hook")

printf '%s\n' "$output" | jq -e '
  .hookSpecificOutput.hookEventName == "UserPromptSubmit"
  and (.hookSpecificOutput.additionalContext | fromjson
    | .schema == "factory.context-packet.v0"
    and .admitted == true
    and (.selected_fragments | length > 0)
    and (.implementation_plan | length > 0)
    and (.context_graph.nodes | length > 0))
' >/dev/null
