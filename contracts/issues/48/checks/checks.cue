package issue48checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue48 "github.com/fatb4f/contract.cuemod/contracts/issues/48"

_generatedAsAuthority: impl.#MakeBottomCheck & {
	in: {
		name: "generatedAsAuthority"
		input: issue48.negativeFixtures.generatedAsAuthority.input
		target: issue48.#Issue48Manifest
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheck & {
	in: {
		name: "wrongSequenceOrder"
		input: issue48.negativeFixtures.wrongSequenceOrder.input
		target: issue48.#Issue48Manifest
	}
}

_negativeBottomChecks: {
	generatedAsAuthority: _generatedAsAuthority.out.generatedAsAuthority
	wrongSequenceOrder:   _wrongSequenceOrder.out.wrongSequenceOrder
}
