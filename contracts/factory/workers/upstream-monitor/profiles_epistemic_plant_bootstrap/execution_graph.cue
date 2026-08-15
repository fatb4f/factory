package epistemicplantprofile

epistemicPlantExecutionGraphContract: close({
	kind: "epistemic-plant-execution-graph"
	stages: [
		"pinned_source_load",
		"guac_build_and_readiness",
		"corpus_ingestion",
		"isdependency_query",
		"coordinate_normalization",
		"graph_generation_receipt",
		"python_admission_proposal",
		"cue_source_closure_qualification",
		"admission_receipt_projection",
		"epistemic_observation_projection",
		"fresh_run_comparison",
		"experiment_evaluation",
		"promotion_gate",
	]
	controlLoops: close({
		bootstrap: ["module_pin", "module_resolution", "schema_closure", "fixture_digest", "specialization_compile"]
		semantic: ["source_declaration", "guac_candidate", "admission_proposal", "cue_qualification", "admitted_relationship"]
		determinism: ["graph_generation_run_1_2", "admission_run_1_2", "observation_run_1_2"]
		promotion: ["qualified_execution", "supported_verdict", "interfaces_recorded", "limitations_recorded"]
	})
	failureRouting: close({
		sourceUnavailable: "INCONCLUSIVE"
		guacOperationalFailure: "INCONCLUSIVE"
		identityInsufficient: "INCONCLUSIVE"
		sourceConflict: "INCONCLUSIVE"
		resolvedUnsupportedCandidate: "REJECTED"
		resolvedSourceClosedCandidate: "ADMITTED"
	})
	executorBoundary: close({
		pythonProposes: true
		cueQualifies: true
		guacObserves: true
		backendDefinesMeaning: false
		provenanceWordingDefinesMeaning: false
	})
})
