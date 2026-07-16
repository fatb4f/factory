package upstreammonitor

forbiddenAttractors: [
	"ChatGPT output treated as authority",
	"GitHub adapter output treated as authority",
	"openai/codex treated as authority",
	"latest-alpha-cli evidence assigned to main",
	"main evidence assigned to latest-alpha-cli",
	"unresolved ref populated from inference",
	"report path outside reports/",
	"evidence path outside evidence/",
	"issue update without publication target",
	"claimant-supplied admission boolean",
]

validationAssertions: close({
	acceptedSignalExact: true
	mainRefExact: true
	alphaRefExact: true
	channelsDistinct: true
	upstreamEvidenceOnly: true
	chatgptIsActuatorNotAuthority: true
	reportPathsBounded: true
	evidencePathsBounded: true
	undeclaredIssueUpdatesForbidden: true
	unresolvedEvidencePreserved: true
	workflowClosed: true
})

negativeFixtures: {
	collapseChannels: close({main: "latest-alpha-cli", alpha: "latest-alpha-cli"})
	promoteUpstreamAuthority: close({authority: "openai/codex"})
	inferUnresolvedHead: close({status: "unresolved", inferred_head: #CommitSHA})
	unboundedReportPath: close({path: string & !~"^contracts/upstream-monitor/codex/contract-surface/reports/"})
	unboundedEvidencePath: close({path: string & !~"^contracts/upstream-monitor/codex/contract-surface/evidence/"})
	undeclaredIssueMutation: close({target: int & >0, declared: false})
}

validationPlan: close({
	commands: [
		"cue fmt --check --files *.cue",
		"cue vet -c ./...",
		"cue export -e publicContract --out json",
	]
	adapterLimitation: "The GitHub App actuator cannot execute these commands; repository CI or a checked local environment performs executable validation."
})
