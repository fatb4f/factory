package issue46checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

import issue46 "github.com/fatb4f/contract.cuemod/contracts/issues/46:issue46"

_inlineConstructorDefinitions: impl.#MakeBottomCheckProof & {
	in: {
		name: "inlineConstructorDefinitions"
		input: {
			evidence: "negative fixture input"
			value:    issue46.negativeFixtures.inlineConstructorDefinitions.input
		}
		target: {
			name: "#Issue46Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue46.#Issue46Manifest
			}
		}
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheckProof & {
	in: {
		name: "wrongSequenceOrder"
		input: {
			evidence: "negative fixture input"
			value:    issue46.negativeFixtures.wrongSequenceOrder.input
		}
		target: {
			name: "#Issue46Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue46.#Issue46Manifest
			}
		}
	}
}

_negativeBottomChecks: {
	inlineConstructorDefinitions: _inlineConstructorDefinitions.out.inlineConstructorDefinitions
	wrongSequenceOrder:           _wrongSequenceOrder.out.wrongSequenceOrder
}
