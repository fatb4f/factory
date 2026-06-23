package agentcontextresolver

#ImplementationSliceIssue: close({
	kind: "cueImplementationSlice"

	contract: {
		path:    string & !=""
		package: string & !=""
		slice:   string & !=""

		authority: {
			owns:       [...string & !=""]
			doesNotOwn: [...string & !=""]
		}

		boundaries?: {
			adapters: {
				authority: false
				role:      "observe/project/execute declared behavior only"
			}
			generated: {
				authority: false
				role:      "downstream projection or materialized evidence only"
			}
			runtime: {
				authority: false
				role:      "external substrate, not contract truth"
			}
		}
	}

	rootQuestion?: {
		id:   "N0.contract-question"
		text: "What CUE authority must exist so this state, transition, or projection is representable and checkable?"
	}

	primitives?: [...{
		name:           string & !=""
		role:           string & !=""
		requiredFields: [...string & !=""]
		constraints:    [...string & !=""]
	}]

	surfaces: {
		admissible?:    [...string & !=""]
		observed?:      [...string & !=""]
		candidates?:    [...string & !=""]
		fixtures?:      [...string & !=""]
		checks:         [...string & !=""]
		publicExports:  [...string & !=""]
	}

	constraints?: {
		noVocabularyOnlyPatch:          true
		noDiagnosticBooleanAuthority:   true
		noReviewMetadataAsProof:        true
		noStringifiedEvalExpressions:   true
		noGeneratedArtifactAsAuthority: true
		noAdapterLocalPolicyAuthority:  true
		noShellOnlySemanticValidation:  true
		noSidePackageSprawl:            true
	}

	dag?: {
		nodes: _
		allowedEdges: [...string & !=""]
		forbiddenEdges: [...string & !=""]
	}

	acceptanceCriteria?: {
		rootQuestionAnsweredBeforeImplementation: true
		authorityBoundaryDeclared:                true
		primitiveModelDeclared:                   true
		admissibleSurfaceDeclared:                true
		validFixtureExports:                      true
		publicEvalSurfaceExports:                 true
		negativeFixturesBottomIfPresent:          true
		forbiddenAttractorSearchPasses:           true
		validationCommandsReported:               true
	}
})
