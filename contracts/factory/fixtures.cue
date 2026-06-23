package factory

baselineObservedPatch: #ObservedPatch & {
	id: *"baseline.valid-root-only-observed-patch" | string

	files: *[
		{
			path:    "contracts/factory/root.cue"
			package: "factory"
			role:    "root"
		},
		{
			path:    "contracts/factory/issue_28.cue"
			package: "factory"
			role:    "branch"
		},
		{
			path:    "contracts/factory/fixtures.cue"
			package: "factory"
			role:    "branch"
		},
	] | [...#ObservedFile]

	rootModel: {
		baseVocabularyDeclared:  *true | bool
		rootPackageDiscoverable: *true | bool
		singlePackage:           *true | bool
	}

	paths: (*{
		agentContextHookCheck: #DerivedPath & {
			kind: "check"
			name: "agent-context-hook"
		}
	} | {[string]: #DerivedPath})

	evidence: (*{
		vcs: []
	} | {
		vcs?: [...#ObservedVCSEvidence]
	})

	closureClaim: {
		decision:              "blocked"
		declaresPass:          false
		declaresClosurePassed: false
	}

	empiricalGate: {
		requiredChecksDeclared: *true | bool
		requiredChecksPass:     *true | bool
		negativeFixturesTyped:  *true | bool
		refusalEvalsDeclared:   *true | bool
		everyInvariantCovered:  *true | bool
		closureProven:          false
	}
}

negativeFixtures: {
	vocabularyWithoutGateProof: #NegativeFixture & {
		id:              "negative.vocabulary-without-gate-proof"
		violates:        "predicates.vocabularyWithoutGateProof"
		expectedRefusal: "vocabulary alone is insufficient; gate checks, typed negative fixtures, refusal evals, and invariant coverage are required"
		expectedBottom:  true

		input: {
			id: "bad.vocabulary-without-gate-proof"

			files:    baselineObservedPatch.files
			paths:    baselineObservedPatch.paths
			evidence: baselineObservedPatch.evidence

			closureClaim: baselineObservedPatch.closureClaim

			rootModel: baselineObservedPatch.rootModel

			empiricalGate: {
				requiredChecksDeclared: false
				requiredChecksPass:     false
				negativeFixturesTyped:  false
				refusalEvalsDeclared:   false
				everyInvariantCovered:  false
				closureProven:          false
			}
		}
	}

	sidePackageSchemaSprawl: #NegativeFixture & {
		id:              "negative.side-package-schema-sprawl"
		violates:        "predicates.sidePackageSchemaSprawl"
		expectedRefusal: "root contract must be discoverable as one package factory before side packages are admissible"
		expectedBottom:  true

		input: {
			id: "bad.side-package-schema-sprawl"

			paths:    baselineObservedPatch.paths
			evidence: baselineObservedPatch.evidence

			closureClaim:  baselineObservedPatch.closureClaim
			empiricalGate: baselineObservedPatch.empiricalGate

			files: [
				{
					path:    "contracts/factory/artifacts/schema.cue"
					package: "artifacts"
					role:    "branch"
				},
			]

			rootModel: {
				baseVocabularyDeclared:  true
				rootPackageDiscoverable: false
				singlePackage:           false
			}
		}
	}

	prematureClosureClaim: #NegativeFixture & {
		id:              "negative.premature-closure-claim"
		violates:        "predicates.prematureClosureClaim"
		expectedRefusal: "candidate cannot claim admission, promotion, pass, or closure before empirical proof"
		expectedBottom:  true

		input: {
			id: "bad.premature-closure-claim"

			files:    baselineObservedPatch.files
			paths:    baselineObservedPatch.paths
			evidence: baselineObservedPatch.evidence

			rootModel:    baselineObservedPatch.rootModel
			closureClaim: baselineObservedPatch.closureClaim

			empiricalGate: {
				requiredChecksDeclared: true
				requiredChecksPass:     true
				negativeFixturesTyped:  true
				refusalEvalsDeclared:   true
				everyInvariantCovered:  true
				closureProven:          true
			}
		}
	}

	placeholderEvidenceOrProvenance: #NegativeFixture & {
		id:              "negative.placeholder-evidence-or-provenance"
		violates:        "predicates.placeholderEvidenceOrProvenance"
		expectedRefusal: "placeholder evidence, placeholder provenance, adapter-declared HEAD, and fake digest defaults are inadmissible"
		expectedBottom:  true

		input: {
			id: "bad.placeholder-evidence-or-provenance"

			files: baselineObservedPatch.files
			paths: baselineObservedPatch.paths

			rootModel:     baselineObservedPatch.rootModel
			closureClaim:  baselineObservedPatch.closureClaim
			empiricalGate: baselineObservedPatch.empiricalGate

			evidence: {
				vcs: [{
					before: {head: "declared-by-adapter"}
					after: {head: "declared-by-adapter"}
					result: "applied"
				}]
			}
		}
	}

	nonDerivedPath: #NegativeFixture & {
		id:              "negative.non-derived-path"
		violates:        "predicates.nonDerivedPath"
		expectedRefusal: "artifact paths must be derived from root policy, not supplied directly or accepted by regex"
		expectedBottom:  true

		input: {
			id: "bad.non-derived-path"

			files:    baselineObservedPatch.files
			evidence: baselineObservedPatch.evidence

			rootModel:     baselineObservedPatch.rootModel
			closureClaim:  baselineObservedPatch.closureClaim
			empiricalGate: baselineObservedPatch.empiricalGate

			paths: {
				agentContextHookCheck: {
					owner: {
						path: "contracts/factory"
					}
					pathPolicy: {
						segments: {
							check:      "reflection/projections/checks"
							report:     "reports"
							fixture:    "fixtures"
							projection: "reflection/projections"
							operation:  "operations"
							evidence:   "evidence"
						}
					}
					kind:  "check"
					name:  "agent-context-hook"
					value: "contracts/factory/reflection/projections/checks/manual-invalid"
				}
			}
		}
	}
}
