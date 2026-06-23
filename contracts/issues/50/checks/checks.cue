package issue50checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

import issue50 "github.com/fatb4f/contract.cuemod/contracts/issues/50:issue50"

_generatedSchemaAsAuthority: impl.#MakeBottomCheckProof & {
	in: {
		name: "generatedSchemaAsAuthority"
		input: {
			evidence: "negative fixture input"
			value:    issue50.negativeFixtures.generatedSchemaAsAuthority.input
		}
		target: {
			name: "#Issue50Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue50.#Issue50Manifest
			}
		}
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheckProof & {
	in: {
		name: "wrongSequenceOrder"
		input: {
			evidence: "negative fixture input"
			value:    issue50.negativeFixtures.wrongSequenceOrder.input
		}
		target: {
			name: "#Issue50Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue50.#Issue50Manifest
			}
		}
	}
}

_negativeBottomChecks: {
	generatedSchemaAsAuthority: _generatedSchemaAsAuthority.out.generatedSchemaAsAuthority
	wrongSequenceOrder:         _wrongSequenceOrder.out.wrongSequenceOrder
}
