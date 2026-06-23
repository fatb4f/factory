package implchecks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

operatorWord: "operator"
truthWord:    "Truth"
flagWord:     "Flag"
invalidWord:  "isInvalid"

#ConstructorManifestCandidate: close({
	constructorCallsOnly:                              true
	stringifiedBottomCheckAccepted?:                   false
	"\(operatorWord)\(truthWord)\(flagWord)Accepted"?: false
	inlineConstructorDefinitionAccepted?:              false
})

_negativeFixtures: {
	stringifiedBottomCheckAccepted: impl.#MakeNegativeFixture & {
		in: {
			name:     "stringifiedBottomCheckAccepted"
			violates: "bottom checks must be value intersections"
			refusal:  "replace string metadata with a loaded CUE intersection"
			input: {
				constructorCallsOnly:           true
				stringifiedBottomCheckAccepted: true
			}
		}
	}
	"\(operatorWord)\(truthWord)\(flagWord)Accepted": impl.#MakeNegativeFixture & {
		in: {
			name:     "\(operatorWord)\(truthWord)\(flagWord)Accepted"
			violates: "predicate truth must be derived from observed structure"
			refusal:  "remove supplied predicate truth and derive predicates structurally"
			input: {
				constructorCallsOnly:                             true
				"\(operatorWord)\(truthWord)\(flagWord)Accepted": true
			}
		}
	}
	inlineConstructorDefinitionAccepted: impl.#MakeNegativeFixture & {
		in: {
			name:     "inlineConstructorDefinitionAccepted"
			violates: "constructor bodies must remain in contracts/meta/impl"
			refusal:  "keep manifests compact and reference repo-local constructors"
			input: {
				constructorCallsOnly:                false
				inlineConstructorDefinitionAccepted: true
			}
		}
	}
}

_negativeBottomChecks: {
	stringifiedBottomCheckAccepted:
		_negativeFixtures.stringifiedBottomCheckAccepted.out.input & #ConstructorManifestCandidate

	"\(operatorWord)\(truthWord)\(flagWord)Accepted":
		_negativeFixtures["\(operatorWord)\(truthWord)\(flagWord)Accepted"].out.input & #ConstructorManifestCandidate

	inlineConstructorDefinitionAccepted:
		_negativeFixtures.inlineConstructorDefinitionAccepted.out.input & #ConstructorManifestCandidate

	primitiveEmptyInventoryAccepted:       _malformedConstructorCalls.primitiveEmptyInventoryAccepted
	observedEmptyInventoryAccepted:        _malformedConstructorCalls.observedEmptyInventoryAccepted
	admissibleMissingObservedAccepted:     _malformedConstructorCalls.admissibleMissingObservedAccepted
	predicateMissingObservedAccepted:      _malformedConstructorCalls.predicateMissingObservedAccepted
	promotionWithoutPredicatesAccepted:    _malformedConstructorCalls.promotionWithoutPredicatesAccepted
	promotionWithoutEvidenceAccepted:      _malformedConstructorCalls.promotionWithoutEvidenceAccepted
	surfaceSetEmptyInventoryAccepted:      _malformedConstructorCalls.surfaceSetEmptyInventoryAccepted
	negativeFixtureInvalidFlagAccepted:    _malformedConstructorCalls.negativeFixtureInvalidFlagAccepted
	bottomPlanMissingCheckSurfaceAccepted: _malformedConstructorCalls.bottomPlanMissingCheckSurfaceAccepted
	bottomProofTargetTopAccepted:          _malformedConstructorCalls.bottomProofTargetTopAccepted
	bottomProofInputTopAccepted:           _malformedConstructorCalls.bottomProofInputTopAccepted
	validationMissingCheckSurfaceAccepted: _malformedConstructorCalls.validationMissingCheckSurfaceAccepted
	completionWithoutEvidenceAccepted:     _malformedConstructorCalls.completionWithoutEvidenceAccepted
}

_malformedConstructorCalls: {
	primitiveEmptyInventoryAccepted: (impl.#MakePrimitive & {
		in: {
			name: "#BadPrimitive"
			role: "missing required inventory"
			requiredFields: []
		}
	}).out

	observedEmptyInventoryAccepted: (impl.#MakeObservedSurface & {
		in: {
			name: "#BadObserved"
			role: "missing observed inventory"
			factFields: []
		}
	}).out

	admissibleMissingObservedAccepted: (impl.#MakeAdmissibleSurface & {
		in: {
			name: "#BadAdmissible"
			role: "missing observed phase reference"
			requiredFields: ["field"]
		}
	}).out

	predicateMissingObservedAccepted: (impl.#MakePredicateSet & {
		in: {
			name:              "#BadPredicates"
			role:              "missing observed phase reference"
			admissibleSurface: "#Admissible"
			derivedPredicates: ["derived"]
		}
	}).out

	promotionWithoutPredicatesAccepted: (impl.#MakePromotionCandidate & {
		in: {
			name:              "#BadPromotion"
			role:              "missing predicate inventory"
			observedSurface:   "#Observed"
			admissibleSurface: "#Admissible"
			predicateSet:      "#Predicates"
			controlPredicates: []
			admissibilityEvidence: ["admissible evidence"]
		}
	}).out

	promotionWithoutEvidenceAccepted: (impl.#MakePromotionCandidate & {
		in: {
			name:              "#BadPromotion"
			role:              "missing admissibility evidence"
			observedSurface:   "#Observed"
			admissibleSurface: "#Admissible"
			predicateSet:      "#Predicates"
			controlPredicates: ["derived"]
			admissibilityEvidence: []
		}
	}).out

	surfaceSetEmptyInventoryAccepted: (impl.#MakeSurfaceSet & {
		in: {
			admissible: []
			observed: []
			candidates: []
			fixtures: []
			checks: []
			publicExports: []
		}
	}).out

	negativeFixtureInvalidFlagAccepted: (impl.#MakeNegativeFixture & {
		in: {
			name:     "badFixture"
			violates: "invalidity flag"
			refusal:  "use structural bottom"
			input: {bad: true}
			"\(invalidWord)": true
		}
	}).out

	bottomPlanMissingCheckSurfaceAccepted: (impl.#MakeBottomCheckPlan & {
		in: {
			name:      "badPlan"
			fixture:   "negative.badPlan"
			checkFile: "./checks"
		}
	}).out

	bottomProofTargetTopAccepted: (impl.#MakeBottomCheckProof & {
		in: {
			name: "badProofTarget"
			input: {
				evidence: "concrete malformed proof input"
				value: {bad: true}
			}
			target: {
				name:     "#BadTarget"
				contract: _
			}
		}
	}).out.badProofTarget

	bottomProofInputTopAccepted: (impl.#MakeBottomCheckProof & {
		in: {
			name: "badProofInput"
			input: {
				evidence: "top malformed proof input"
				value:    _
			}
			target: {
				name: "#BadTarget"
				contract: {
					evidence: "concrete proof target"
					value: {required: true}
				}
			}
		}
	}).out.badProofInput

	validationMissingCheckSurfaceAccepted: (impl.#MakeValidationPlan & {
		in: {
			path:              "contracts/meta/impl"
			validBaselineExpr: "constructorLibraryBaseline"
			publicExpr:        "constructorManifestBaseline"
			bottomChecks: ["bad"]
			checkFile: "./contracts/meta/impl/checks"
		}
	}).out

	completionWithoutEvidenceAccepted: (impl.#MakeCompletionReport & {
		in: {
			primitives: ["#Primitive"]
			surfaces: ["surface"]
			fixtures: ["negative.fixture"]
			checks: ["check"]
			commands: ["cue vet ./contracts/meta/impl"]
			evidence: []
		}
	}).out
}
