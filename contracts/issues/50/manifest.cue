package issue50

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue50Manifest: close({
	issue: 50
	sequenceOrder: 3
	previousIssue: 49
	encodedSequence: [48, 49, 50, 46, 47, 51]
	title: "Generated/imported schema and Rust runtime surface sync slice"
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	manifestPath: "contracts/issues/50/manifest.cue"
	normalizedPath: "contracts/issues/50/normalized.cue"
	constructorLibrary: "contracts/meta/impl"
	constructorCallsOnly: true
	generatedArtifactsAreAuthority: false
	schemaSync: {
		generatedSchemaAuthority: false
		importedSchemaAuthority: false
		cueAuthority: "contracts/agent-runtime"
		rustRuntimeSurface: "runtime-adapter-schema-sync"
		requiredDirections: ["cue-to-generated-schema", "cue-to-rust-runtime"]
	}
})

validBaseline: #Issue50Manifest

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#RustRuntimeSchemaSyncManifest"
			role: "closed generated/imported schema and Rust runtime sync surface"
			requiredFields: ["issue", "schemaSync"]
			constraints: [
				"CUE remains the schema authority",
				"generated and imported schemas are synchronization products",
			]
		}
	},
]

_observedSurface: impl.#MakeObservedSurface & {
	in: {
		name: "#ObservedRustRuntimeSchemaSyncManifest"
		role: "broad observed generated/imported schema and Rust runtime sync payload"
		factFields: ["issue", "sequenceOrder", "previousIssue", "schemaSync"]
		constraints: ["may represent generated schema authority and wrong-sequence invalid states"]
	}
}

_admissibleSurface: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#RustRuntimeSchemaSyncCandidate"
		role: "admissible schema sync manifest with CUE-owned authority"
		observedSurface: _observedSurface.out.name
		requiredFields: ["issue", "sequenceOrder", "previousIssue", "schemaSync"]
		rejectedFields: ["generatedSchemaAuthority", "importedSchemaAuthority"]
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#RustRuntimeSchemaSyncPredicates"
		role: "derive schema sync rejection predicates from observed fields"
		inputSurface: _observedSurface.out.name
		derivedPredicates: ["generatedSchemaAsAuthority", "wrongSequenceOrder"]
		operatorSupplied: false
	}
}

_promotionCandidate: impl.#MakePromotionCandidate & {
	in: {
		name: "#RustRuntimeSchemaSyncPromotionCandidate"
		role: "closed promotion candidate for runtime schema sync manifests"
		observedSurface: _observedSurface.out.name
		admissibleSurface: _admissibleSurface.out.name
		predicateSet: _predicates.out.name
		controlPredicates: _predicates.out.derivedPredicates
		closed: true
	}
}

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: [_admissibleSurface.out.name, "#Issue50Manifest"]
		observed: [_observedSurface.out.name, "validBaseline"]
		candidates: [_promotionCandidate.out.name, "_primitives", "_surfaces", "_negativeFixtures", "_validation", "_completion"]
		fixtures: ["negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["publicContract", "validationPlan", "completionReportContract"]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "generatedSchemaAsAuthority"
			violates: "schema authority boundary"
			refusal: "generated schema cannot supersede CUE authority"
			input: {
				issue: 50
				sequenceOrder: 3
				previousIssue: 49
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Generated/imported schema and Rust runtime surface sync slice"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/50/manifest.cue"
				normalizedPath: "contracts/issues/50/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				schemaSync: {
					generatedSchemaAuthority: true
					importedSchemaAuthority: false
					cueAuthority: "contracts/agent-runtime"
					rustRuntimeSurface: "runtime-adapter-schema-sync"
					requiredDirections: ["cue-to-generated-schema", "cue-to-rust-runtime"]
				}
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "wrongSequenceOrder"
			violates: "encoded sequence order"
			refusal: "issue 50 must follow the alpha lock slice"
			input: {
				issue: 50
				sequenceOrder: 4
				previousIssue: 49
				encodedSequence: [48, 49, 50, 46, 47, 51]
				title: "Generated/imported schema and Rust runtime surface sync slice"
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				manifestPath: "contracts/issues/50/manifest.cue"
				normalizedPath: "contracts/issues/50/normalized.cue"
				constructorLibrary: "contracts/meta/impl"
				constructorCallsOnly: true
				generatedArtifactsAreAuthority: false
				schemaSync: validBaseline.schemaSync
			}
		}
	},
]

negativeFixtures: {
	generatedSchemaAsAuthority: _negativeFixtures[0].out
	wrongSequenceOrder:         _negativeFixtures[1].out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/50"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: ["generatedSchemaAsAuthority", "wrongSequenceOrder"]
		checkFile: "./contracts/issues/50/checks"
		forbiddenPattern: _issueForbiddenPattern
	}
}

_issueForbiddenPattern: "\(bottomWord)\(checkWord)\(surfaceWord)|\(expressionWord):|\(invalidWord): true"
bottomWord: "bottom"
checkWord: "Check"
surfaceWord: "Surface"
expressionWord: "expression"
invalidWord: "isInvalid"

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: [
			_observedSurface.out.name,
			_admissibleSurface.out.name,
			_predicates.out.name,
			_promotionCandidate.out.name,
			"publicContract",
			"validationPlan",
			"completionReportContract",
		]
		fixtures: [negativeFixtures.generatedSchemaAsAuthority.id, negativeFixtures.wrongSequenceOrder.id]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
	}
}
