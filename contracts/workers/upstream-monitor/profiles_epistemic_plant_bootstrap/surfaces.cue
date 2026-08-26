package epistemicplantprofile

import core "github.com/fatb4f/factory/contracts/workers/upstream-monitor:upstreammonitor"

#EpistemicPlantSurface: close({
	id: core.#NonEmptyString
	source: core.#NonEmptyString
	terms: [...core.#NonEmptyString] & [_, ...]
	impactFloor: core.#ImpactDecision
	localContractHint: core.#NonEmptyString
	localPaths: [...core.#NonEmptyString] & [_, ...]
})

epistemicPlantSurfaceCatalogue: [
	{
		id: "guac-graphql-isdependency"
		source: "guac"
		terms: ["IsDependency", "package", "dependencyPackage", "dependencyType", "justification", "origin", "collector", "documentRef"]
		impactFloor: "blocking-gate"
		localContractHint: "checked-in GraphQL query shape and exact dependency candidate extraction"
		localPaths: ["queries/dependencies.graphql", "src/epistemic_plant/guac.py", "tests/test_guac.py"]
	},
	{
		id: "guac-coordinate-normalization"
		source: "guac"
		terms: ["purl", "namespace", "name", "version", "qualifiers", "subpath", "exact_purl", "reconstructed", "insufficient"]
		impactFloor: "blocking-gate"
		localContractHint: "stable package-coordinate identity and source-closure join key"
		localPaths: ["src/epistemic_plant/guac.py", "src/epistemic_plant/model.py", "spec/schema.cue"]
	},
	{
		id: "guac-ingest-runtime"
		source: "guac"
		terms: ["guacgql", "guacone", "collect files", "gql-backend", "keyvalue", "GraphQL readiness"]
		impactFloor: "contract-update"
		localContractHint: "fresh disposable graph-generation realization and operational failure classification"
		localPaths: ["src/epistemic_plant/guac.py", "scripts/bootstrap_check.py", "scripts/evaluate.py"]
	},
	{
		id: "guac-provenance-witnesses"
		source: "guac"
		terms: ["justification", "origin", "collector", "documentRef", "provenance"]
		impactFloor: "contract-update"
		localContractHint: "retained witness fields that must never become the admission oracle"
		localPaths: ["BOOTSTRAP_SPEC.md", "HYPOTHESIS_PROBLEM_STATEMENT.md", "src/epistemic_plant/model.py", "spec/schema.cue"]
	},
	{
		id: "gemara-evidence-vocabulary"
		source: "gemara"
		terms: ["#Evidence", "#Result", "#Datetime", "Passed", "Failed", "Needs Review", "collected-at", "requirement"]
		impactFloor: "blocking-gate"
		localContractHint: "imported evidence/evaluation vocabulary used by CUE-qualified admission decisions"
		localPaths: ["cue.mod/module.cue", "spec/schema.cue", "src/epistemic_plant/model.py"]
	},
	{
		id: "cue-admission-closure"
		source: "cue"
		terms: ["unification", "comprehension", "if", "cue vet", "schema", "closedness", "reference resolution"]
		impactFloor: "blocking-gate"
		localContractHint: "independent source-declaration closure and admission qualification semantics"
		localPaths: ["spec/schema.cue", "spec/poc.cue", "src/epistemic_plant/qualification.py", "justfile"]
	},
	{
		id: "cyclonedx-dependency-closure"
		source: "cyclonedx"
		terms: ["CycloneDX", "bom-ref", "purl", "dependencies", "dependsOn", "metadata", "timestamp", "serialNumber"]
		impactFloor: "contract-update"
		localContractHint: "independent extraction of canonical dependency pairs from digest-pinned source documents"
		localPaths: ["fixtures/corpus/", "src/epistemic_plant/source.py", "HYPOTHESIS_PROBLEM_STATEMENT.md"]
	},
	{
		id: "go-guac-build"
		source: "golang"
		terms: ["go install", "go version -m", "module version", "GOBIN", "Go 1.25.0"]
		impactFloor: "contract-update"
		localContractHint: "reproducible construction and verification of pinned GUAC binaries"
		localPaths: ["src/epistemic_plant/guac.py", "src/epistemic_plant/constants.py", ".github/workflows/ci.yml"]
	},
	{
		id: "uv-frozen-environment"
		source: "uv"
		terms: ["--frozen", "--no-sync", "uv sync --locked", "uv.lock", "uv_build"]
		impactFloor: "note"
		localContractHint: "reproducible Python tool environment used before experiment qualification"
		localPaths: ["uv.lock", "pyproject.toml", "justfile", ".github/workflows/ci.yml"]
	},
]

epistemicPlantClassificationPolicy: close({
	requireSurfaceMatch: true
	requireLocalImpactForReport: true
	requireSourceQualifiedEvidence: true
	requireAuthoritySeparation: true
	requireAdmissionInvariantAnalysisForGuacChanges: true
	requirePinnedSemanticVersionAnalysisForCueAndGemara: true
	upstreamRole: "evidence_only_unless_explicitly_pinned_external_semantics"
	allowedDecisions: ["none", "note", "contract-update", "blocking-gate"]
	severityMap: {
		none: "none"
		note: "note"
		"contract-update": "high"
		"blocking-gate": "critical"
	}
})
