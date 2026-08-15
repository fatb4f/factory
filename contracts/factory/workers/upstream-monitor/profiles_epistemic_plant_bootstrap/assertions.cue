package epistemicplantprofile

epistemicPlantForbiddenAttractors: [
	"fatb4f/epistemic-plant-bootstrap repository state treated as factory monitor authority",
	"upstream repository state treated as factory authority",
	"GUAC candidate treated as an admitted fact before source closure",
	"GUAC justification, origin, collector, or documentRef treated as the admission oracle",
	"GUAC backend identity or result ordering treated as stable semantic identity",
	"GUAC main forecast treated as the pinned v1.1.0 experiment baseline",
	"Gemara main treated as the pinned v1.4.1 evidence vocabulary",
	"CUE master treated as the pinned v0.17.1 evaluator semantics",
	"current CycloneDX master treated as rewriting digest-pinned fixture meaning",
	"Python admission proposal treated as qualified without CUE validation",
	"operational source, build, readiness, ingestion, or query failure treated as semantic rejection",
	"just qualify pass interpreted as a supported POC hypothesis",
	"graph generation compared with volatile GUAC IDs, ordering, timestamps, or ports",
	"admission emitted without source document digest lineage",
	"epistemic observation emitted without admitted receipt lineage",
	"terminal_success interpreted as executable qualification success without qualification_state",
	"subject evidence/ directory copied into factory authority",
	"run artifact written outside contract-surface/runs/<run_id>/",
	"manifest published before report, summary, and evidence",
	"latest pointer updated before manifest seal",
	"publication_revision interpreted as latest-pointer self-reference",
	"cross-repository write",
]

epistemicPlantValidationAssertions: close({
	acceptedSignalExact: true
	profileIDExact: true
	contextRepositoryExact: true
	subjectSemanticAuthorityPreserved: true
	sourceQualifiedEvidenceRequired: true
	guacPinnedAndForecastDistinct: true
	guacObservationOnly: true
	gemaraPinAndForecastDistinct: true
	cuePinAndForecastDistinct: true
	cycloneDXForecastEvidenceOnly: true
	pinnedSourceRequiredForAdmission: true
	cueQualificationAuthorityExplicit: true
	pythonProposalDistinctFromCueQualification: true
	operationalFailureInconclusive: true
	stableIdentityExclusionsExplicit: true
	graphGenerationLineageExplicit: true
	admissionReceiptLineageExplicit: true
	epistemicObservationLineageExplicit: true
	freshRunDeterminismExplicit: true
	monitorAndQualificationStateDistinct: true
	authorityRevisionExplicit: true
	publicationRevisionMeansManifestSeal: true
	factoryRunArtifactsCoLocated: true
	bundleManifestSealsArtifacts: true
	latestPointerOnly: true
	subjectEvidenceNotAuthority: true
	crossRepositoryWritesForbidden: true
	issueUpdatesForbidden: true
	workflowClosed: true
})

epistemicPlantValidationPlan: close({
	commands: [
		"cue fmt --check contract.cue profiles_epistemic_plant_bootstrap/*.cue",
		"cue vet -c=false ./...",
		"cue export ./profiles_epistemic_plant_bootstrap -e publicContract --out json",
	]
	subjectCommands: [
		"just bootstrap-check",
		"just check",
		"just vet",
		"just eval",
		"just qualify",
	]
	adapterLimitation: "The GitHub App actuator cannot execute CUE or subject-local bootstrap/experiment probes. Executable validation belongs to repository CI or a checked local environment; the monitor must preserve this as qualification_state rather than inferring success."
})
