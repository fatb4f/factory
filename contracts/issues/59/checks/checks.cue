package issue59checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

import issue59 "github.com/fatb4f/contract.cuemod/contracts/issues/59:issue59"

#Issue59InvocationCandidate: close({
	constructor: string & !=""
	phase:       "admissible"
	evidence: [...string & !=""] & [_, ...]
	targetTopAccepted?:                             false
	inputTopAccepted?:                              false
	emptySurfaceInventoryAccepted?:                 false
	missingPhaseReferenceAccepted?:                 false
	promotionWithoutPredicatesAccepted?:            false
	promotionWithoutAdmissibilityEvidenceAccepted?: false
	predicateWithoutObservedSurfaceAccepted?:       false
	predicateWithoutAdmissibleSurfaceAccepted?:     false
	validationWithoutCheckFileAccepted?:            false
	validationWithoutCheckSurfaceAccepted?:         false
	completionWithoutCommandsAccepted?:             false
	completionWithoutEvidenceAccepted?:             false
	stringifiedCueExpressionAccepted?:              false
	invalidityFlagAccepted?:                        false
	inlineConstructorDefinitionAccepted?:           false
	generatedAuthorityAccepted?:                    false
	manifestExecutableProofObjectAccepted?:         false
})

#MakeIssue59BottomCheckProof: {
	in: {
		name: string & !=""
		fixture: {
			input: {...}
		}
	}

	_name:         in.name
	_fixtureInput: in.fixture.input

	_constructor: impl.#MakeBottomCheckProof & {
		in: {
			name: _name
			input: {
				evidence: "negative fixture input"
				value:    _fixtureInput
			}
			target: {
				name: "#Issue59InvocationCandidate"
				contract: {
					evidence: "issue-local proof target"
					value:    #Issue59InvocationCandidate
				}
			}
		}
	}

	out: _constructor.out
}

_negativeBottomChecks: {
	targetTopAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "targetTopAccepted", fixture: issue59.negativeFixtureInputSet[0]}}).out.targetTopAccepted
	inputTopAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "inputTopAccepted", fixture: issue59.negativeFixtureInputSet[1]}}).out.inputTopAccepted
	emptySurfaceInventoryAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "emptySurfaceInventoryAccepted", fixture: issue59.negativeFixtureInputSet[2]}}).out.emptySurfaceInventoryAccepted
	missingPhaseReferenceAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "missingPhaseReferenceAccepted", fixture: issue59.negativeFixtureInputSet[3]}}).out.missingPhaseReferenceAccepted
	promotionWithoutPredicatesAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "promotionWithoutPredicatesAccepted", fixture: issue59.negativeFixtureInputSet[4]}}).out.promotionWithoutPredicatesAccepted
	promotionWithoutAdmissibilityEvidenceAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "promotionWithoutAdmissibilityEvidenceAccepted", fixture: issue59.negativeFixtureInputSet[5]}}).out.promotionWithoutAdmissibilityEvidenceAccepted
	predicateWithoutObservedSurfaceAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "predicateWithoutObservedSurfaceAccepted", fixture: issue59.negativeFixtureInputSet[6]}}).out.predicateWithoutObservedSurfaceAccepted
	predicateWithoutAdmissibleSurfaceAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "predicateWithoutAdmissibleSurfaceAccepted", fixture: issue59.negativeFixtureInputSet[7]}}).out.predicateWithoutAdmissibleSurfaceAccepted
	validationWithoutCheckFileAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "validationWithoutCheckFileAccepted", fixture: issue59.negativeFixtureInputSet[8]}}).out.validationWithoutCheckFileAccepted
	validationWithoutCheckSurfaceAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "validationWithoutCheckSurfaceAccepted", fixture: issue59.negativeFixtureInputSet[9]}}).out.validationWithoutCheckSurfaceAccepted
	completionWithoutCommandsAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "completionWithoutCommandsAccepted", fixture: issue59.negativeFixtureInputSet[10]}}).out.completionWithoutCommandsAccepted
	completionWithoutEvidenceAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "completionWithoutEvidenceAccepted", fixture: issue59.negativeFixtureInputSet[11]}}).out.completionWithoutEvidenceAccepted
	stringifiedCueExpressionAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "stringifiedCueExpressionAccepted", fixture: issue59.negativeFixtureInputSet[12]}}).out.stringifiedCueExpressionAccepted
	invalidityFlagAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "invalidityFlagAccepted", fixture: issue59.negativeFixtureInputSet[13]}}).out.invalidityFlagAccepted
	inlineConstructorDefinitionAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "inlineConstructorDefinitionAccepted", fixture: issue59.negativeFixtureInputSet[14]}}).out.inlineConstructorDefinitionAccepted
	generatedAuthorityAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "generatedAuthorityAccepted", fixture: issue59.negativeFixtureInputSet[15]}}).out.generatedAuthorityAccepted
	manifestExecutableProofObjectAccepted: (#MakeIssue59BottomCheckProof & {in: {name: "manifestExecutableProofObjectAccepted", fixture: issue59.negativeFixtureInputSet[16]}}).out.manifestExecutableProofObjectAccepted
}
