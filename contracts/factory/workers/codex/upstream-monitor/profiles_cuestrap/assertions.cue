package cuestrapprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

cuestrapForbiddenAttractors: [
	"fatb4f/cuestrap repository state treated as monitor authority",
	"openai/codex treated as authority",
	"ChatGPT output treated as authority",
	"GitHub adapter output treated as authority",
	"latest-alpha-cli evidence assigned to main",
	"main evidence assigned to latest-alpha-cli",
	"unresolved ref populated from inference",
	"factory report path outside cuestrap profile reports/",
	"factory evidence path outside cuestrap profile evidence/",
	"evidence artifact written to fatb4f/cuestrap",
	"CUE or AGENTS plumbing written to fatb4f/cuestrap",
	"cuestrap report copy differs from factory report",
	"issue update without publication target",
	"claimant-supplied admission boolean",
]

cuestrapValidationAssertions: close({
	acceptedSignalExact:             true
	profileIDExact:                  true
	contextRepositoryExact:          true
	currentContextRequired:          true
	mainRefExact:                    true
	alphaRefExact:                   true
	channelsDistinct:                true
	upstreamEvidenceOnly:            true
	cuestrapContextNotAuthority:      true
	chatgptIsActuatorNotAuthority:    true
	factoryReportPathsBounded:        true
	factoryEvidencePathsBounded:      true
	cuestrapMirrorPathsBounded:       true
	cuestrapEvidenceForbidden:        true
	cuestrapPlumbingForbidden:        true
	mirrorContentEqualityRequired:    true
	undeclaredIssueUpdatesForbidden:  true
	unresolvedEvidencePreserved:      true
	purposeAssignmentRequired:        true
	workflowClosed:                   true
})

cuestrapNegativeFixtures: {
	collapseChannels: close({main: "latest-alpha-cli", alpha: "latest-alpha-cli"})
	promoteUpstreamAuthority: close({authority: "openai/codex"})
	promoteContextAuthority: close({authority: "fatb4f/cuestrap"})
	inferUnresolvedHead: close({status: "unresolved", inferred_head: core.#CommitSHA})
	unboundedFactoryReportPath: close({path: string & !~"^contracts/upstream-monitor/codex/cuestrap-contract-surface/reports/"})
	unboundedFactoryEvidencePath: close({path: string & !~"^contracts/upstream-monitor/codex/cuestrap-contract-surface/evidence/"})
	unboundedMirrorPath: close({path: string & !~"^reports/upstream-monitor/codex/"})
	cuestrapEvidenceWrite: close({repository: "fatb4f/cuestrap", kind: "evidence"})
	cuestrapPlumbingWrite: close({repository: "fatb4f/cuestrap", kind: "authority" | "instruction" | "actuator"})
	mismatchedMirror: close({factoryDigest: core.#NonEmptyString, mirrorDigest: core.#NonEmptyString, equal: false})
	undeclaredIssueMutation: close({target: int & >0, declared: false})
}

cuestrapValidationPlan: close({
	commands: [
		"cue fmt --check contract.cue profiles_cuestrap/*.cue",
		"cue vet -c ./profiles_cuestrap",
		"cue export ./profiles_cuestrap -e publicContract --out json",
	]
	adapterLimitation: "The GitHub App actuator cannot execute these commands; repository CI or a checked local environment performs executable validation."
})
