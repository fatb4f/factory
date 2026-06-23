package pluginbundle

pluginBundleFormatReport: close({
	schema:  "factory.plugin-bundle-format.report.v0"
	status:  "admitted"
	package: "pluginbundle"
	path:    "contracts/factory/plugin-bundle"
	slice:   "codex-plugin-bundle-format-v0"

	authority: {
		owns: [
			"generic plugin bundle schema",
			"bundle import schema",
			"component graph schema",
			"projection graph schema",
			"materialization admission schema",
			"bundle lockfile schema",
			"Codex adapter runtime schema",
			"valid and invalid bundle fixtures",
			"public eval/check exports for the format",
		]
		doesNotOwn: [
			"actual .codex runtime execution",
			"semagrams repo import",
			"Git/VCS mutation",
			"shell materializer implementation",
			"Codex CLI behavior",
			"agent-context-resolver contract semantics outside the bundle reference boundary",
		]
	}

	rootQuestion: {
		id:   "N0.contract-question"
		text: "What CUE authority must exist so a Codex plugin bundle can be represented, imported, projected, materialized, locked, and checked without making .codex runtime files authority?"
	}

	primitives: [
		"#PluginBundle",
		"#BundleImport",
		"#Component",
		"#Projection",
		"#Materialization",
		"#Gate",
		"#BundleLock",
		"#CodexRuntime",
	]

	surfaces: {
		admissible: [
			"#PluginBundle",
			"#BundleImport",
			"#Component",
			"#Projection",
			"#Materialization",
			"#Gate",
			"#BundleLock",
			"#CodexRuntime",
		]
		observed: [
			"#ObservedBundleFile",
			"#ObservedMaterializedFile",
		]
		candidates: [
			"#AdmissiblePluginBundle",
			"#AdmissibleCodexRuntime",
		]
		fixtures: [
			"validFixtures.codexAgentRuntime",
			"negativeFixtures.codexAsAuthority",
			"negativeFixtures.generatedAsAuthority",
			"negativeFixtures.materializationWithoutProjection",
			"negativeFixtures.unboundedHook",
		]
		checks: [
			"_negativeBottomChecks",
		]
		publicExports: [
			"validBaselineBundle",
			"codexAgentRuntimeSurface",
			"pluginBundleFormatReport",
		]
	}

	acceptanceCriteria: {
		cueAuthorityBoundaryExplicit: true
		implementationIsNotVocabularyOnly: true
		publicEvalSurfaces: [
			"validBaselineBundle",
			"codexAgentRuntimeSurface",
			"pluginBundleFormatReport",
		]
		negativeBottomChecks: [
			"codexAsAuthority",
			"generatedAsAuthority",
			"materializationWithoutProjection",
			"unboundedHook",
		]
		codexRuntimeAdapterOnly: true
		bundleImportRequiresLockEvidence: true
		materializationRequiresProjectionAndProvenance: true
		codexHookRequiresBoundedIO: true
	}

	control: {
		action: "admit"
		reason: "Codex Plugin Bundle Format v0 is represented as contract authority before semagrams import/materialization work proceeds."
		evidence: [
			"public eval exports",
			"negative bottom checks",
		]
		nextState: "stable plugin bundle schema and Codex runtime adapter schema exist under contracts/factory/plugin-bundle"
	}
})
