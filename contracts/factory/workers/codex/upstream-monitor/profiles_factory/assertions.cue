package factoryprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

forbiddenAttractors: [
	"ChatGPT output treated as authority",
	"GitHub adapter output treated as authority",
	"openai/codex treated as authority",
	"latest-alpha-cli evidence assigned to main",
	"main evidence assigned to latest-alpha-cli",
	"unresolved ref populated from inference",
	"run artifacts split across report and evidence directories",
	"run artifact written outside its runs/<run_id>/ bundle",
	"bundle manifest published before required artifacts",
	"mutable latest report or evidence copy",
	"legacy report or evidence path present",
	"legacy report or evidence path used for a new write",
	"issue update without publication target",
	"claimant-supplied admission boolean",
]

validationAssertions: close({
	acceptedSignalExact:             true
	mainRefExact:                    true
	alphaRefExact:                   true
	channelsDistinct:                true
	upstreamEvidenceOnly:            true
	chatgptIsActuatorNotAuthority:   true
	runArtifactsCoLocated:           true
	bundleExportUnitIsDirectory:     true
	bundleManifestSealsArtifacts:    true
	latestIsPointerOnly:             true
	legacyPathsAbsent:               true
	legacyWritesForbidden:           true
	undeclaredIssueUpdatesForbidden: true
	unresolvedEvidencePreserved:     true
	workflowClosed:                  true
})

negativeFixtures: {
	collapseChannels:         close({main: "latest-alpha-cli", alpha: "latest-alpha-cli"})
	promoteUpstreamAuthority: close({authority: "openai/codex"})
	inferUnresolvedHead:      close({status: "unresolved", inferred_head: core.#CommitSHA})
	scatteredRunArtifacts:    close({reportDirectory: core.#NonEmptyString, evidenceDirectory: core.#NonEmptyString, sameDirectory: false})
	unbundledRunArtifact:     close({path: string & !~"^contracts/upstream-monitor/codex/contract-surface/runs/[^/]+/"})
	manifestBeforeArtifacts:  close({manifestWritten: true, requiredArtifactsComplete: false})
	mutableLatestCopy:        close({path: string & =~"^contracts/upstream-monitor/codex/contract-surface/(reports|evidence)/latest"})
	legacyPathPresent:        close({path: "contracts/upstream-monitor/codex/contract-surface/reports" | "contracts/upstream-monitor/codex/contract-surface/evidence", present: true})
	legacyWrite:              close({path: "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md" | "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json", write: true})
	undeclaredIssueMutation:  close({target: int & >0, declared: false})
}

validationPlan: close({
	commands: [
		"cue fmt --check contract.cue profiles_factory/*.cue",
		"cue vet -c=false ./...",
		"cue export ./profiles_factory -e publicContract --out json",
	]
	adapterLimitation: "The GitHub App actuator cannot execute these commands; repository CI or a checked local environment performs executable validation."
})
