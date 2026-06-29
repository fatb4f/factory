package metachecks

import (
	impl "github.com/fatb4f/factory/contracts/meta"
)

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

#EvalReportCandidate: close({
	authority?: false
	evidence: [...string & !=""] & [_, ...]
})

#ContractAssertion: close({
	id:            string & !=""
	claim:         string & !=""
	negativeCheck: string & !=""
	proofKey:      string & !=""
	refusal:       string & !=""
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
			violates: "constructor bodies must remain in contracts/meta"
			refusal:  "keep manifests compact and reference repo-local constructors"
			input: {
				constructorCallsOnly:                false
				inlineConstructorDefinitionAccepted: true
			}
		}
	}
}

contractAssertions: {
	stringifiedBottomCheckAccepted: #ContractAssertion & {
		id:            "meta.manifest.bottom-checks-are-cue-values"
		claim:         "bottom checks are generated from loaded CUE value intersections, not strings"
		negativeCheck: "stringifiedBottomCheckAccepted"
		proofKey:      "stringifiedBottomCheckAccepted"
		refusal:       "string metadata cannot satisfy bottom-check proof authority"
	}
	"\(operatorWord)\(truthWord)\(flagWord)Accepted": #ContractAssertion & {
		id:            "meta.predicates.derive-truth-from-structure"
		claim:         "predicate truth is derived from observed structure, not operator flags"
		negativeCheck: "\(operatorWord)\(truthWord)\(flagWord)Accepted"
		proofKey:      "\(operatorWord)\(truthWord)\(flagWord)Accepted"
		refusal:       "operator-supplied truth cannot satisfy predicate authority"
	}
	inlineConstructorDefinitionAccepted: #ContractAssertion & {
		id:            "meta.manifest.no-inline-constructor-bodies"
		claim:         "contract slice manifests reference repo-local constructors and do not embed constructor bodies"
		negativeCheck: "inlineConstructorDefinitionAccepted"
		proofKey:      "inlineConstructorDefinitionAccepted"
		refusal:       "constructor bodies remain under contracts/meta"
	}
	primitiveEmptyInventoryAccepted: #ContractAssertion & {
		id:            "meta.primitive.requires-nonempty-field-inventory"
		claim:         "primitive constructors require non-empty requiredFields"
		negativeCheck: "primitiveEmptyInventoryAccepted"
		proofKey:      "primitiveEmptyInventoryAccepted"
		refusal:       "empty primitive inventory is inadmissible"
	}
	observedEmptyInventoryAccepted: #ContractAssertion & {
		id:            "meta.observed.requires-nonempty-fact-inventory"
		claim:         "observed-surface constructors require non-empty factFields"
		negativeCheck: "observedEmptyInventoryAccepted"
		proofKey:      "observedEmptyInventoryAccepted"
		refusal:       "empty observed inventory is inadmissible"
	}
	admissibleMissingObservedAccepted: #ContractAssertion & {
		id:            "meta.admissible.requires-observed-surface-reference"
		claim:         "admissible surfaces must bind an observed surface"
		negativeCheck: "admissibleMissingObservedAccepted"
		proofKey:      "admissibleMissingObservedAccepted"
		refusal:       "missing observed surface reference is inadmissible"
	}
	predicateMissingObservedAccepted: #ContractAssertion & {
		id:            "meta.predicate.requires-observed-surface-reference"
		claim:         "predicate sets must bind observed and admissible surfaces"
		negativeCheck: "predicateMissingObservedAccepted"
		proofKey:      "predicateMissingObservedAccepted"
		refusal:       "missing observed surface reference is inadmissible"
	}
	promotionWithoutPredicatesAccepted: #ContractAssertion & {
		id:            "meta.promotion.requires-control-predicates"
		claim:         "promotion candidates require non-empty control predicates"
		negativeCheck: "promotionWithoutPredicatesAccepted"
		proofKey:      "promotionWithoutPredicatesAccepted"
		refusal:       "promotion without predicates is inadmissible"
	}
	promotionWithoutEvidenceAccepted: #ContractAssertion & {
		id:            "meta.promotion.requires-admissibility-evidence"
		claim:         "promotion candidates require non-empty admissibility evidence"
		negativeCheck: "promotionWithoutEvidenceAccepted"
		proofKey:      "promotionWithoutEvidenceAccepted"
		refusal:       "promotion without evidence is inadmissible"
	}
	surfaceSetEmptyInventoryAccepted: #ContractAssertion & {
		id:            "meta.surface-set.requires-nonempty-inventories"
		claim:         "surface sets require non-empty admissible, observed, candidate, fixture, check, and export inventories"
		negativeCheck: "surfaceSetEmptyInventoryAccepted"
		proofKey:      "surfaceSetEmptyInventoryAccepted"
		refusal:       "empty surface set inventory is inadmissible"
	}
	negativeFixtureInvalidFlagAccepted: #ContractAssertion & {
		id:            "meta.negative-fixture.rejects-invalidity-flags"
		claim:         "negative fixtures use structural bottom, not invalidity flags"
		negativeCheck: "negativeFixtureInvalidFlagAccepted"
		proofKey:      "negativeFixtureInvalidFlagAccepted"
		refusal:       "invalidity flag cannot substitute for structural conflict"
	}
	bottomPlanMissingCheckSurfaceAccepted: #ContractAssertion & {
		id:            "meta.bottom-plan.requires-check-surface"
		claim:         "bottom-check plans bind an explicit check surface"
		negativeCheck: "bottomPlanMissingCheckSurfaceAccepted"
		proofKey:      "bottomPlanMissingCheckSurfaceAccepted"
		refusal:       "missing check surface is inadmissible"
	}
	bottomProofTargetTopAccepted: #ContractAssertion & {
		id:            "meta.bottom-proof.rejects-top-targets"
		claim:         "bottom-check proofs require concrete adapter-bound targets"
		negativeCheck: "bottomProofTargetTopAccepted"
		proofKey:      "bottomProofTargetTopAccepted"
		refusal:       "top target cannot prove bottom"
	}
	bottomProofInputTopAccepted: #ContractAssertion & {
		id:            "meta.bottom-proof.rejects-top-inputs"
		claim:         "bottom-check proofs require concrete proof inputs"
		negativeCheck: "bottomProofInputTopAccepted"
		proofKey:      "bottomProofInputTopAccepted"
		refusal:       "top input cannot prove bottom"
	}
	validationMissingCheckSurfaceAccepted: #ContractAssertion & {
		id:            "meta.validation-plan.requires-check-surface"
		claim:         "validation plans bind an explicit check surface"
		negativeCheck: "validationMissingCheckSurfaceAccepted"
		proofKey:      "validationMissingCheckSurfaceAccepted"
		refusal:       "validation without a check surface is inadmissible"
	}
	completionWithoutEvidenceAccepted: #ContractAssertion & {
		id:            "meta.completion-report.requires-evidence"
		claim:         "completion reports require evidence"
		negativeCheck: "completionWithoutEvidenceAccepted"
		proofKey:      "completionWithoutEvidenceAccepted"
		refusal:       "completion without evidence is inadmissible"
	}
	generatedAuthorityAccepted: #ContractAssertion & {
		id:            "meta.observed.generated-artifacts-are-evidence-only"
		claim:         "generated artifacts remain evidence and cannot become observed authority"
		negativeCheck: "generatedAuthorityAccepted"
		proofKey:      "generatedAuthorityAccepted"
		refusal:       "generated authority is inadmissible"
	}
	manifestExecutableProofObjectAccepted: #ContractAssertion & {
		id:            "meta.manifest.executable-proofs-live-in-check-packages"
		claim:         "manifest packages carry plans; executable proof objects live in check packages"
		negativeCheck: "manifestExecutableProofObjectAccepted"
		proofKey:      "manifestExecutableProofObjectAccepted"
		refusal:       "manifest executable proof object is inadmissible"
	}
	evalAuthorityAccepted: #ContractAssertion & {
		id:            "meta.eval.evidence-summary-not-authority"
		claim:         "eval reports summarize evidence and do not become authority"
		negativeCheck: "evalAuthorityAccepted"
		proofKey:      "evalAuthorityAccepted"
		refusal:       "eval authority is inadmissible"
	}
	contractGeneratorMissingOutputAccepted: #ContractAssertion & {
		id:            "meta.generator.requires-output-inventory"
		claim:         "contract generators declare generated output paths"
		negativeCheck: "contractGeneratorMissingOutputAccepted"
		proofKey:      "contractGeneratorMissingOutputAccepted"
		refusal:       "generator without output inventory is inadmissible"
	}
	contractValidatorAbsoluteTargetAccepted: #ContractAssertion & {
		id:            "meta.validator.rejects-absolute-targets"
		claim:         "contract validators use repo-relative targets"
		negativeCheck: "contractValidatorAbsoluteTargetAccepted"
		proofKey:      "contractValidatorAbsoluteTargetAccepted"
		refusal:       "absolute target is inadmissible"
	}
	contractValidatorParentTraversalCommandAccepted: #ContractAssertion & {
		id:            "meta.validator.rejects-parent-traversal-commands"
		claim:         "contract validator commands cannot escape by parent traversal"
		negativeCheck: "contractValidatorParentTraversalCommandAccepted"
		proofKey:      "contractValidatorParentTraversalCommandAccepted"
		refusal:       "parent traversal command is inadmissible"
	}
	contractValidatorExternalLookupCommandAccepted: #ContractAssertion & {
		id:            "meta.validator.rejects-external-lookup-authority"
		claim:         "contract validator commands cannot encode external lookup authority"
		negativeCheck: "contractValidatorExternalLookupCommandAccepted"
		proofKey:      "contractValidatorExternalLookupCommandAccepted"
		refusal:       "external lookup authority is inadmissible"
	}
	contractValidatorStaleLocalCheckAccepted: #ContractAssertion & {
		id:            "meta.validator.rejects-stale-local-checks"
		claim:         "contract validators cannot reference stale local check paths"
		negativeCheck: "contractValidatorStaleLocalCheckAccepted"
		proofKey:      "contractValidatorStaleLocalCheckAccepted"
		refusal:       "stale local check reference is inadmissible"
	}
	generatedComplianceAuthorityAccepted: #ContractAssertion & {
		id:            "meta.generated-compliance.evidence-only"
		claim:         "generated compliance artifacts remain evidence only"
		negativeCheck: "generatedComplianceAuthorityAccepted"
		proofKey:      "generatedComplianceAuthorityAccepted"
		refusal:       "generated compliance authority is inadmissible"
	}
}

assertionGeneratedCheckManifest: close({
	kind: "assertion-generated-check-manifest"
	checks: [
		for _, assertion in contractAssertions {
			assertionID:   assertion.id
			negativeCheck: assertion.negativeCheck
			proofKey:      assertion.proofKey
			refusal:       assertion.refusal
			expected:      "bottom"
		},
	]
})

_negativeBottomChecks: {
	for _, assertion in contractAssertions {
		"\(assertion.negativeCheck)": _assertionProofs[assertion.proofKey]
	}
}

_assertionProofs: {
	stringifiedBottomCheckAccepted:
		_negativeFixtures.stringifiedBottomCheckAccepted.out.input & #ConstructorManifestCandidate

	"\(operatorWord)\(truthWord)\(flagWord)Accepted":
		_negativeFixtures["\(operatorWord)\(truthWord)\(flagWord)Accepted"].out.input & #ConstructorManifestCandidate

	inlineConstructorDefinitionAccepted:
		_negativeFixtures.inlineConstructorDefinitionAccepted.out.input & #ConstructorManifestCandidate

	primitiveEmptyInventoryAccepted:                 _malformedConstructorCalls.primitiveEmptyInventoryAccepted
	observedEmptyInventoryAccepted:                  _malformedConstructorCalls.observedEmptyInventoryAccepted
	admissibleMissingObservedAccepted:               _malformedConstructorCalls.admissibleMissingObservedAccepted
	predicateMissingObservedAccepted:                _malformedConstructorCalls.predicateMissingObservedAccepted
	promotionWithoutPredicatesAccepted:              _malformedConstructorCalls.promotionWithoutPredicatesAccepted
	promotionWithoutEvidenceAccepted:                _malformedConstructorCalls.promotionWithoutEvidenceAccepted
	surfaceSetEmptyInventoryAccepted:                _malformedConstructorCalls.surfaceSetEmptyInventoryAccepted
	negativeFixtureInvalidFlagAccepted:              _malformedConstructorCalls.negativeFixtureInvalidFlagAccepted
	bottomPlanMissingCheckSurfaceAccepted:           _malformedConstructorCalls.bottomPlanMissingCheckSurfaceAccepted
	bottomProofTargetTopAccepted:                    _malformedConstructorCalls.bottomProofTargetTopAccepted
	bottomProofInputTopAccepted:                     _malformedConstructorCalls.bottomProofInputTopAccepted
	validationMissingCheckSurfaceAccepted:           _malformedConstructorCalls.validationMissingCheckSurfaceAccepted
	completionWithoutEvidenceAccepted:               _malformedConstructorCalls.completionWithoutEvidenceAccepted
	generatedAuthorityAccepted:                      _malformedConstructorCalls.generatedAuthorityAccepted
	manifestExecutableProofObjectAccepted:           _malformedConstructorCalls.manifestExecutableProofObjectAccepted
	evalAuthorityAccepted:                           _malformedConstructorCalls.evalAuthorityAccepted
	contractGeneratorMissingOutputAccepted:          _malformedConstructorCalls.contractGeneratorMissingOutputAccepted
	contractValidatorAbsoluteTargetAccepted:         _malformedConstructorCalls.contractValidatorAbsoluteTargetAccepted
	contractValidatorParentTraversalCommandAccepted: _malformedConstructorCalls.contractValidatorParentTraversalCommandAccepted
	contractValidatorExternalLookupCommandAccepted:  _malformedConstructorCalls.contractValidatorExternalLookupCommandAccepted
	contractValidatorStaleLocalCheckAccepted:        _malformedConstructorCalls.contractValidatorStaleLocalCheckAccepted
	generatedComplianceAuthorityAccepted:            _malformedConstructorCalls.generatedComplianceAuthorityAccepted
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
			path:              "contracts/meta"
			validBaselineExpr: "constructorLibraryBaseline"
			publicExpr:        "constructorManifestBaseline"
			bottomChecks: ["bad"]
			checkFile: "./contracts/meta/checks"
		}
	}).out

	completionWithoutEvidenceAccepted: (impl.#MakeCompletionReport & {
		in: {
			primitives: ["#Primitive"]
			surfaces: ["surface"]
			fixtures: ["negative.fixture"]
			checks: ["check"]
			commands: ["cue vet ./contracts/meta"]
			evidence: []
		}
	}).out

	generatedAuthorityAccepted: (impl.#MakeObservedSurface & {
		in: {
			name: "BadGeneratedAuthority"
			role: "generated output promoted to contract authority"
			factFields: ["generated"]
			generatedArtifactsAreAuthority: true
		}
	}).out

	manifestExecutableProofObjectAccepted: (impl.#MakeSurfaceSet & {
		in: {
			admissible: ["Admissible"]
			observed: ["Observed"]
			candidates: ["Candidate"]
			fixtures: ["negative.fixture"]
			checks: ["_negativeBottomChecks.fixture"]
			publicExports: ["publicContract"]
			manifestExecutableProofObject: true
		}
	}).out

	evalAuthorityAccepted: {
		authority: true
		evidence: ["check evidence"]
	} & #EvalReportCandidate

	contractGeneratorMissingOutputAccepted: (impl.#ContractGenerator & {
		kind:    "contract-generator"
		id:      "badGenerator"
		name:    "badGenerator"
		command: "just scaffold-contract-slice"
		inputs: ["slice-id"]
		outputs: []
		invariants: ["bad generator omits required outputs"]
	})

	contractValidatorAbsoluteTargetAccepted: (impl.#ContractValidator & {
		kind:       "contract-validator"
		id:         "badValidator"
		name:       "badValidator"
		target:     "/contracts/slices/example"
		targetPath: "/contracts/slices/example"
		commands: ["cue vet ./contracts/slices/example"]
		negativeChecks: ["bad"]
		forbiddenPattern: impl._defaultForbiddenPattern
		rejects: ["bad absolute target path"]
	})

	contractValidatorParentTraversalCommandAccepted: (impl.#ContractValidator & {
		kind:       "contract-validator"
		id:         "badValidator"
		name:       "badValidator"
		target:     "contracts/plugin-bundle/template"
		targetPath: "contracts/plugin-bundle/template"
		commands: ["cue vet ./../outside"]
		negativeChecks: ["bad"]
		forbiddenPattern: impl._defaultForbiddenPattern
		rejects: ["bad parent traversal command path"]
	})

	contractValidatorExternalLookupCommandAccepted: (impl.#ContractValidator & {
		kind:       "contract-validator"
		id:         "badValidator"
		name:       "badValidator"
		target:     "contracts/plugin-bundle/template"
		targetPath: "contracts/plugin-bundle/template"
		commands: ["cue export ./contracts/plugin-bundle/template -e external lookup authority"]
		negativeChecks: ["bad"]
		forbiddenPattern: impl._defaultForbiddenPattern
		rejects: ["bad external lookup authority command"]
	})

	contractValidatorStaleLocalCheckAccepted: (impl.#ContractValidator & {
		kind:       "contract-validator"
		id:         "badValidator"
		name:       "badValidator"
		target:     "contracts/plugin-bundle/template"
		targetPath: "contracts/plugin-bundle/template"
		commands: ["cue export ./contracts/slices/stale/checks -e _negativeBottomChecks.bad"]
		negativeChecks: ["bad"]
		forbiddenPattern: impl._defaultForbiddenPattern
		rejects: ["bad stale local check reference"]
		staleLocalChecks: true
	})

	generatedComplianceAuthorityAccepted: (impl.#GeneratedContractCompliance & {
		kind:      "generated-contract-compliance"
		generator: impl.contractScaffoldGenerator
		validator: impl.contractScaffoldValidator
		requiredExports: ["normalizedIssueManifest"]
		requiredConstructors: ["#MakePrimitive", "#MakeBottomCheckProof"]
		mustUseConstructors:            true
		mustUseMakeBottomCheckProof:    true
		requiresBottomCheckProof:       true
		generatedArtifactsAreAuthority: true
		evidenceOnlyGeneratedArtifacts: true
		bindings: {
			generatorName:   "contractScaffoldGenerator"
			validatorName:   "contractScaffoldValidator"
			parentAuthority: "contracts/meta"
		}
	})
}
