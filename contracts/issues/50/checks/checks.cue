package issue50checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue50 "github.com/fatb4f/contract.cuemod/contracts/issues/50"

_generatedSchemaAsAuthority: impl.#MakeBottomCheck & {
	in: {
		name: "generatedSchemaAsAuthority"
		input: issue50.negativeFixtures.generatedSchemaAsAuthority.input
		target: issue50.#Issue50Manifest
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheck & {
	in: {
		name: "wrongSequenceOrder"
		input: issue50.negativeFixtures.wrongSequenceOrder.input
		target: issue50.#Issue50Manifest
	}
}

_negativeBottomChecks: {
	generatedSchemaAsAuthority: _generatedSchemaAsAuthority.out.generatedSchemaAsAuthority
	wrongSequenceOrder:         _wrongSequenceOrder.out.wrongSequenceOrder
}
