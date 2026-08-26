package epistemicplantprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/upstream-monitor:upstreammonitor"

#EpistemicPlantAcceptedSignal: close({
	signal_id: "loop_bootstrap_request"
	profile_id: "epistemic-plant-bootstrap"
	target_repo: "fatb4f/factory"
	context_repo: "fatb4f/epistemic-plant-bootstrap"
	entrypoint: "contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/AGENTS.md"
	adapter: "github_app"
})

epistemicPlantAcceptedSignal: #EpistemicPlantAcceptedSignal

epistemicPlantContext: close({
	repository: "fatb4f/epistemic-plant-bootstrap"
	branch: "main"
	role: "subject_context_not_monitor_authority"
	semanticAuthority: [
		"BOOTSTRAP_SPEC.md",
		"HYPOTHESIS_PROBLEM_STATEMENT.md",
		"spec/schema.cue",
		"spec/poc.cue",
		"fixtures/corpus/",
	]
	requiredContextReads: [
		"README.md",
		"AGENTS.md",
		"BOOTSTRAP_SPEC.md",
		"HYPOTHESIS_PROBLEM_STATEMENT.md",
		"pyproject.toml",
		"uv.lock",
		"cue.mod/module.cue",
		"justfile",
		".github/workflows/ci.yml",
		"queries/dependencies.graphql",
		"spec/schema.cue",
		"spec/poc.cue",
		"src/epistemic_plant/constants.py",
		"src/epistemic_plant/source.py",
		"src/epistemic_plant/guac.py",
		"src/epistemic_plant/admission.py",
		"src/epistemic_plant/qualification.py",
		"src/epistemic_plant/experiment.py",
	]
})

epistemicPlantAuthorityModel: close({
	authority: [
		"contracts/factory/workers/upstream-monitor/contract.cue",
		"contracts/factory/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/*.cue",
		"contracts/factory/workers/upstream-monitor/AGENTS.md",
		"contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/AGENTS.md",
		"contracts/upstream-monitor/epistemic-plant-bootstrap/contract-surface/output/report-template.md",
	]
	subjectContext: ["fatb4f/epistemic-plant-bootstrap@main repository state"]
	subjectSemanticAuthority: [
		"pinned fixture bytes and their SHA-256 digests",
		"BOOTSTRAP_SPEC.md authority and realization boundaries",
		"HYPOTHESIS_PROBLEM_STATEMENT.md decision rule",
		"spec/schema.cue admission and qualification constraints",
		"spec/poc.cue experiment contract",
	]
	evidenceOnly: [
		"guacsec/guac",
		"CycloneDX/specification",
		"golang/go",
		"astral-sh/uv",
		"GitHub adapter responses",
		"ChatGPT observations",
		"generated run bundles",
		"subject repository evidence/ outputs",
	]
	pinnedExternalSemantics: [
		"gemaraproj/gemara@v1.4.1",
		"cue-lang/cue@v0.17.1",
	]
})

epistemicPlantWorkflow: close({
	initial: "authority_read"
	states: [
		"authority_read",
		"input_admission",
		"context_acquisition",
		"source_acquisition",
		"graph_projection",
		"test_probe_binding",
		"semantic_classification",
		"subject_bootstrap_validation",
		"subject_qualification",
		"report_render",
		"summary_render",
		"publication_admission",
		"bundle_publication",
		"manifest_seal",
		"latest_pointer_update",
	]
	terminal: "terminal_success"
	failureStates: ["terminal_abort", "terminal_deferred", "coverage_gap"]
})

epistemicPlantControlInvariants: close({
	guacCandidatesAreObservations: true
	guacProvenanceNeverDecidesAdmission: true
	pinnedSourceDeclarationRequiredForAdmission: true
	cueQualificationIsSemanticAuthority: true
	gemaraProvidesEvidenceVocabulary: true
	operationalFailureIsInconclusive: true
	backendIdentityExcludedFromStableRelationshipIdentity: true
	freshRunDeterminismRequired: true
	monitorEvidenceCannotOverrideSubjectAuthority: true
})

chatgptActuator: core.ChatGPTActuator
epistemicPlantOperational: true
