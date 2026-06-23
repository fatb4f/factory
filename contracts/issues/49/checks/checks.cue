package issue49checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue49 "github.com/fatb4f/contract.cuemod/contracts/issues/49"

_floatingAlphaResolution: impl.#MakeBottomCheck & {
	in: {
		name: "floatingAlphaResolution"
		input: issue49.negativeFixtures.floatingAlphaResolution.input
		target: issue49.#Issue49Manifest
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheck & {
	in: {
		name: "wrongSequenceOrder"
		input: issue49.negativeFixtures.wrongSequenceOrder.input
		target: issue49.#Issue49Manifest
	}
}

_negativeBottomChecks: {
	floatingAlphaResolution: _floatingAlphaResolution.out.floatingAlphaResolution
	wrongSequenceOrder:      _wrongSequenceOrder.out.wrongSequenceOrder
}
