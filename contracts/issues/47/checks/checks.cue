package issue47checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue47 "github.com/fatb4f/contract.cuemod/contracts/issues/47"

_fallbackAuthority: impl.#MakeBottomCheck & {
	in: {
		name: "fallbackAuthority"
		input: issue47.negativeFixtures.fallbackAuthority.input
		target: issue47.#Issue47Manifest
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheck & {
	in: {
		name: "wrongSequenceOrder"
		input: issue47.negativeFixtures.wrongSequenceOrder.input
		target: issue47.#Issue47Manifest
	}
}

_negativeBottomChecks: {
	fallbackAuthority: _fallbackAuthority.out.fallbackAuthority
	wrongSequenceOrder: _wrongSequenceOrder.out.wrongSequenceOrder
}
