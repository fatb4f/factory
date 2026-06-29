package agentcontextresolver

#ObservedHookEvent: close({
	source: "claude" | "codex" | "git" | "githubActions" | "manual"
	event:  "preToolUse" | "postToolUse" | "preCommit" | "pullRequest" | "manual"

	cwd: string & !=""

	changedFiles?: [...{
		path:      string & !=""
		operation: "create" | "update" | "delete" | "rename" | "unknown"
	}]

	tool?: {
		name:      string & !=""
		input?:    _
		response?: _
	}
})
