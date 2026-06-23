package issue52

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

#Issue52Manifest: close({
	issue: 52
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	constructorLibrary: "contracts/meta/impl"
	manifestPath: "contracts/issues/52/manifest.cue"
	normalizedPath: "contracts/issues/52/normalized.cue"
	constructorCallsOnly: true
	inlineConstructorDefinitions: false
	stringifiedCUEExpressions: false
	goWrapperRequiredNow: false
	generatedArtifactsAreAuthority: false
})

validBaseline: #Issue52Manifest & {
	issue: 52
	repository: "fatb4f/factory"
	module: "github.com/fatb4f/contract.cuemod"
	constructorLibrary: "contracts/meta/impl"
	manifestPath: "contracts/issues/52/manifest.cue"
	normalizedPath: "contracts/issues/52/normalized.cue"
	constructorCallsOnly: true
	inlineConstructorDefinitions: false
	stringifiedCUEExpressions: false
	goWrapperRequiredNow: false
	generatedArtifactsAreAuthority: false
}

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#PrimitiveSpec"
			role: "closed input contract for primitive constructor calls"
			requiredFields: ["name", "role"]
			constraints: [
				"requiredFields defaults to empty list",
				"constraints defaults to empty list",
				"closed defaults to true",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#SurfaceSetSpec"
			role: "closed input contract for declared CUE surface inventories"
			requiredFields: []
			constraints: [
				"all surface lists default to empty lists",
				"surface names remain concrete strings",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#NegativeFixtureSpec"
			role: "closed rejection fixture constructor input"
			requiredFields: ["name", "violates", "refusal", "input"]
			constraints: [
				"negative fixtures carry observed invalid input",
				"fixtures do not replace structural bottom checks",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#BottomCheckSpec"
			role: "real CUE intersection check constructor input"
			requiredFields: ["name", "input", "target"]
			constraints: [
				"checks intersect input and target directly",
				"checks do not encode CUE expressions as strings",
			]
			closed: true
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#Issue52Manifest"]
		observed: ["validBaseline"]
		candidates: ["_primitives", "_surfaces", "_negativeFixtures", "_validation", "_completion"]
		fixtures: ["negativeFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: ["publicContract", "validationPlan", "completionReportContract"]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "inlineConstructorDefinitions"
			violates: "constructor manifest compactness boundary"
			refusal: "issue manifests must carry constructor calls, not constructor bodies"
			input: {
				issue: 52
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				constructorLibrary: "contracts/meta/impl"
				manifestPath: "contracts/issues/52/manifest.cue"
				normalizedPath: "contracts/issues/52/normalized.cue"
				constructorCallsOnly: false
				inlineConstructorDefinitions: true
				stringifiedCUEExpressions: false
				goWrapperRequiredNow: false
				generatedArtifactsAreAuthority: false
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "stringifiedCueExpression"
			violates: "real CUE bottom check boundary"
			refusal: "CUE expressions must remain value intersections, not expression strings"
			input: {
				issue: 52
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				constructorLibrary: "contracts/meta/impl"
				manifestPath: "contracts/issues/52/manifest.cue"
				normalizedPath: "contracts/issues/52/normalized.cue"
				constructorCallsOnly: true
				inlineConstructorDefinitions: false
				stringifiedCUEExpressions: true
				goWrapperRequiredNow: false
				generatedArtifactsAreAuthority: false
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "goWrapperRequiredNow"
			violates: "pure CUE first implementation boundary"
			refusal: "Go is deferred to transport and materialization, not required for constructor shape authority"
			input: {
				issue: 52
				repository: "fatb4f/factory"
				module: "github.com/fatb4f/contract.cuemod"
				constructorLibrary: "contracts/meta/impl"
				manifestPath: "contracts/issues/52/manifest.cue"
				normalizedPath: "contracts/issues/52/normalized.cue"
				constructorCallsOnly: true
				inlineConstructorDefinitions: false
				stringifiedCUEExpressions: false
				goWrapperRequiredNow: true
				generatedArtifactsAreAuthority: false
			}
		}
	},
]

negativeFixtures: {
	inlineConstructorDefinitions: _negativeFixtures[0].out
	stringifiedCueExpression: _negativeFixtures[1].out
	goWrapperRequiredNow: _negativeFixtures[2].out
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/52"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: [
			"inlineConstructorDefinitions",
			"stringifiedCueExpression",
			"goWrapperRequiredNow",
		]
		forbiddenPattern: "bottomCheckSurface|expression:|isInvalid: true"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [
			negativeFixtures.inlineConstructorDefinitions.id,
			negativeFixtures.stringifiedCueExpression.id,
			negativeFixtures.goWrapperRequiredNow.id,
		]
		checks: _validation.in.bottomChecks
		commands: _validation.out.commands
	}
}
