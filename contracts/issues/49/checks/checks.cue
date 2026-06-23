package issue49checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue49 "github.com/fatb4f/contract.cuemod/contracts/issues/49:issue49"

_floatingAlphaResolution: impl.#MakeBottomCheckProof & {
	in: {
		name: "floatingAlphaResolution"
		input: {
			value: issue49.negativeFixtures.floatingAlphaResolution.input
		}
		target: {
			name: "#Issue49Manifest"
			contract: issue49.#Issue49Manifest
		}
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheckProof & {
	in: {
		name: "wrongSequenceOrder"
		input: {
			value: issue49.negativeFixtures.wrongSequenceOrder.input
		}
		target: {
			name: "#Issue49Manifest"
			contract: issue49.#Issue49Manifest
		}
	}
}

_negativeBottomChecks: {
	floatingAlphaResolution: _floatingAlphaResolution.out.floatingAlphaResolution
	wrongSequenceOrder:      _wrongSequenceOrder.out.wrongSequenceOrder
}
