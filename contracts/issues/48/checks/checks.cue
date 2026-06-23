package issue48checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue48 "github.com/fatb4f/contract.cuemod/contracts/issues/48:issue48"

_generatedAsAuthority: impl.#MakeBottomCheckProof & {
	in: {
		name: "generatedAsAuthority"
		input: {
			value: issue48.negativeFixtures.generatedAsAuthority.input
		}
		target: {
			name: "#Issue48Manifest"
			contract: issue48.#Issue48Manifest
		}
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheckProof & {
	in: {
		name: "wrongSequenceOrder"
		input: {
			value: issue48.negativeFixtures.wrongSequenceOrder.input
		}
		target: {
			name: "#Issue48Manifest"
			contract: issue48.#Issue48Manifest
		}
	}
}

_negativeBottomChecks: {
	generatedAsAuthority: _generatedAsAuthority.out.generatedAsAuthority
	wrongSequenceOrder:   _wrongSequenceOrder.out.wrongSequenceOrder
}
