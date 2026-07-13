package bdd

#CommandStep: close({
	id:       #NonEmptyString
	boundary: "operator" | "cue" | "uv" | "marimo-python"
	argv: [...#NonEmptyString] & [_, ...]
	environment?: [#NonEmptyString]: #NonEmptyString
	produces: [...#NonEmptyString]
})

validationCommand: #ValidationCommand & {
	id:                 "factory.validate-bdd-bootstrap.v1"
	operatorEntrypoint: "just validate-bdd-bootstrap"
	providerRoot:       "absolute-required"
	consumerRoot:       "absolute-required"
	evidenceRoot:       "absolute-required"
	projectMode:        "locked-exact"
	offlineMode:        "separate-explicit-scenario"
}

commandProjection: close({
	id:                 validationCommand.id
	operatorEntrypoint: validationCommand.operatorEntrypoint
	evidenceBoundary: close({
		base:       "${XDG_RUNTIME_DIR:-/tmp}/factory-bdd"
		allocation: "unique-execution-id-required"
		cleanup:    "required"
	})
	steps: [
		#CommandStep & {id: "lock.check", boundary: "uv", argv: ["uv", "lock", "--check"], produces: []},
		#CommandStep & {id: "contracts.vet", boundary: "cue", argv: ["cue", "vet", "./marimo/workflows/bdd/.kb"], produces: ["bootstrap-contract-validation"]},
		#CommandStep & {
			id:       "workbook.execute"
			boundary: "marimo-python"
			environment: {UV_PROJECT_ENVIRONMENT: "$temporary_directory/venv"}
			argv: [
				"uv", "run", "--project", "$factory_provider_root", "--locked", "--exact", "--",
				"python", "$factory_provider_root/marimo/workflows/bdd/validate_implementation_unit.py",
				"--provider-root", "$factory_provider_root",
				"--repo-root", "$consumer_root",
				"--evidence-root", "$evidence_root",
			]
			produces: ["locked-environment-identity", "positive-fixture-results", "negative-fixture-results"]
		},
		#CommandStep & {id: "evidence.vet", boundary: "cue", argv: ["cue", "vet", "./marimo/workflows/bdd/.kb/evidence.cue", "$evidence_root/*.json"], produces: ["workflow-refinement-result", "scenario-coverage-result"]},
		#CommandStep & {id: "admission.verify", boundary: "cue", argv: ["cue", "export", "./marimo/workflows/bdd/.kb", "-e", "selfConformanceAdmission"], produces: ["self-conformance-result"]},
		#CommandStep & {id: "retirement.verify", boundary: "cue", argv: ["cue", "export", "./marimo/workflows/bdd/.kb", "-e", "provisionalRetirement"], produces: ["provisional-retirement-result"]},
	]
	literalTrueGate: close({
		expression:               "selfConformanceAdmission"
		requiredJSONValue:        "true"
		shellExitAloneSufficient: false
	})
})
