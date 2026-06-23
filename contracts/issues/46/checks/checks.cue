package issue46checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue46 "github.com/fatb4f/contract.cuemod/contracts/issues/46"

_inlineConstructorDefinitions: impl.#MakeBottomCheck & {
	in: {
		name: "inlineConstructorDefinitions"
		input: issue46.negativeFixtures.inlineConstructorDefinitions.input
		target: issue46.#Issue46Manifest
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheck & {
	in: {
		name: "wrongSequenceOrder"
		input: issue46.negativeFixtures.wrongSequenceOrder.input
		target: issue46.#Issue46Manifest
	}
}

_negativeBottomChecks: {
	inlineConstructorDefinitions: _inlineConstructorDefinitions.out.inlineConstructorDefinitions
	wrongSequenceOrder:           _wrongSequenceOrder.out.wrongSequenceOrder
}
