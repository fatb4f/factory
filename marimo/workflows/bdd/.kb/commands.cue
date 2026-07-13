package bdd

#CommandStep: close({
	id:           #NonEmptyString
	workflowNode: #NonEmptyString
	boundary:     "operator" | "cue" | "marimo-python"
	argv: [...#NonEmptyString] & [_, ...]
	environment?: [#NonEmptyString]: #NonEmptyString
	consumes: [...#NonEmptyString]
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
	interface: close({
		defaultTarget:         "unit.admit"
		incrementalInvocation: "just validate-bdd-bootstrap node=<workflow-node>"
		executionIDArgument:   "--execution-id"
		nodeArgument:          "--node"
	})
	evidenceBoundary: close({
		base:       "${XDG_RUNTIME_DIR:-/tmp}/factory-bdd"
		allocation: "operator-allocated-unique-execution-id-required"
		cleanup:    "required"
	})
	steps: [
		#CommandStep & {
			id:           "requirements.verify"
			workflowNode: "requirements.verify"
			boundary:     "cue"
			argv: ["cue", "vet", "./marimo/workflows/bdd/.kb", "$evidence_root/requirements-source.json"]
			consumes: []
			produces: ["requirements-source"]
		},
		#CommandStep & {
			id:           "workbook-identity.verify"
			workflowNode: "workbook-identity.verify"
			boundary:     "cue"
			argv: ["cue", "export", "./marimo/workflows/bdd/.kb", "-e", "workbookIdentityAdmission", "--out", "json"]
			consumes: ["requirements-source"]
			produces: ["workbook-identity"]
		},
		#CommandStep & {
			id:           "project-lock.verify"
			workflowNode: "project-lock.verify"
			boundary:     "marimo-python"
			environment: {UV_PROJECT_ENVIRONMENT: "$temporary_directory/venv"}
			argv: [
				"uv", "run", "--project", "$factory_provider_root", "--locked", "--exact", "--",
				"python", "$factory_provider_root/marimo/workflows/bdd/validate_implementation_unit.py",
				"--provider-root", "$factory_provider_root",
				"--repo-root", "$consumer_root",
				"--evidence-root", "$evidence_root",
				"--execution-id", "$execution_id",
				"--node", "project-lock.verify",
				"--command-manifest", "$evidence_root/command-manifest.json",
				"--command-manifest-digest", "$command_manifest_digest",
				"--scenario-manifest", "$evidence_root/scenario-manifest.json",
				"--scenario-manifest-digest", "$scenario_manifest_digest",
			]
			consumes: ["workbook-identity"]
			produces: ["locked-environment-identity"]
		},
		#CommandStep & {
			id:           "contracts.vet"
			workflowNode: "contracts.vet"
			boundary:     "cue"
			argv: ["cue", "vet", "-c", "./marimo/workflows/bdd/.kb"]
			consumes: ["requirements-source", "workbook-identity"]
			produces: ["bootstrap-contract-validation"]
		},
		#CommandStep & {
			id:           "fixtures.execute"
			workflowNode: "fixtures.execute"
			boundary:     "marimo-python"
			environment: {UV_PROJECT_ENVIRONMENT: "$temporary_directory/venv"}
			argv: [
				"uv", "run", "--project", "$factory_provider_root", "--locked", "--exact", "--",
				"python", "$factory_provider_root/marimo/workflows/bdd/validate_implementation_unit.py",
				"--provider-root", "$factory_provider_root",
				"--repo-root", "$consumer_root",
				"--evidence-root", "$evidence_root",
				"--execution-id", "$execution_id",
				"--node", "fixtures.execute",
				"--command-manifest", "$evidence_root/command-manifest.json",
				"--command-manifest-digest", "$command_manifest_digest",
				"--scenario-manifest", "$evidence_root/scenario-manifest.json",
				"--scenario-manifest-digest", "$scenario_manifest_digest",
			]
			consumes: ["locked-environment-identity", "bootstrap-contract-validation"]
			produces: ["positive-fixture-results", "negative-fixture-results"]
		},
		#CommandStep & {
			id:           "workflow.verify"
			workflowNode: "workflow.verify"
			boundary:     "cue"
			argv: ["cue", "vet", "./marimo/workflows/bdd/.kb", "$evidence_root/observations.json"]
			consumes: ["positive-fixture-results", "negative-fixture-results"]
			produces: ["workflow-refinement-result", "scenario-coverage-result"]
		},
		#CommandStep & {
			id:           "provisional.compute"
			workflowNode: "provisional.compute"
			boundary:     "cue"
			argv: ["cue", "export", "./marimo/workflows/bdd/.kb", "$evidence_root/observations.json", "-e", "boundedProvisionalAdmission", "--out", "json"]
			consumes: ["workflow-refinement-result", "scenario-coverage-result"]
			produces: ["bounded-provisional-admission"]
		},
		#CommandStep & {
			id:           "self-conformance.execute"
			workflowNode: "self-conformance.execute"
			boundary:     "marimo-python"
			environment: {UV_PROJECT_ENVIRONMENT: "$temporary_directory/venv"}
			argv: [
				"uv", "run", "--project", "$factory_provider_root", "--locked", "--exact", "--",
				"python", "$factory_provider_root/marimo/workflows/bdd/validate_implementation_unit.py",
				"--provider-root", "$factory_provider_root",
				"--repo-root", "$consumer_root",
				"--evidence-root", "$evidence_root",
				"--execution-id", "$execution_id",
				"--node", "self-conformance.execute",
				"--command-manifest", "$evidence_root/command-manifest.json",
				"--command-manifest-digest", "$command_manifest_digest",
				"--scenario-manifest", "$evidence_root/scenario-manifest.json",
				"--scenario-manifest-digest", "$scenario_manifest_digest",
			]
			consumes: ["bounded-provisional-admission"]
			produces: ["self-conformance-result"]
		},
		#CommandStep & {
			id:           "self-conformance.admit"
			workflowNode: "self-conformance.admit"
			boundary:     "cue"
			argv: ["cue", "export", "./marimo/workflows/bdd/.kb", "$evidence_root/observations.json", "-e", "selfConformanceAdmission", "--out", "json"]
			consumes: ["self-conformance-result"]
			produces: ["self-conformance-admission"]
		},
		#CommandStep & {
			id:           "provisional.retire"
			workflowNode: "provisional.retire"
			boundary:     "cue"
			argv: ["cue", "export", "./marimo/workflows/bdd/.kb", "$evidence_root/observations.json", "-e", "provisionalRetirement", "--out", "json"]
			consumes: ["self-conformance-admission"]
			produces: ["provisional-retirement-result"]
		},
		#CommandStep & {
			id:           "unit.admit"
			workflowNode: "unit.admit"
			boundary:     "cue"
			argv: ["cue", "export", "./marimo/workflows/bdd/.kb", "$evidence_root/observations.json", "-e", "implementationUnitAdmission", "--out", "json"]
			consumes: ["provisional-retirement-result"]
			produces: ["implementation-unit-admission"]
		},
	]
	literalTrueGate: close({
		expression:               "implementationUnitAdmission"
		requiredJSONValue:        "true"
		shellExitAloneSufficient: false
	})
	manifestExports: close({
		command: ["cue", "export", "./marimo/workflows/bdd/.kb", "-e", "workbookCommandManifest", "--out", "json"]
		scenario: ["cue", "export", "./marimo/workflows/bdd/.kb", "-e", "workbookScenarioManifest", "--out", "json"]
	})
})

workbookCommandManifest: close({
	schema: "factory.bdd-workbook-command-manifest.v1"
	nodes: {
		for _, step in commandProjection.steps if step.boundary == "marimo-python" {
			(step.workflowNode): close({
				consumes: step.consumes
				produces: step.produces
			})
		}
	}
})

validationTargets: close({
	"workbook.protocol": close({
		nodes: ["project-lock.verify"]
		assertions: [
			"closed CLI",
			"external evidence-root ownership",
			"manifest-bound dispatch",
			"raw observation closure",
			"claimant field rejection",
		]
	})
	"fixtures.protocol": close({nodes: ["fixtures.execute"]})
	full: close({terminalNode: "unit.admit"})
})
