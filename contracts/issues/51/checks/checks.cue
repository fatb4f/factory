package issue51checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"
import issue51 "github.com/fatb4f/contract.cuemod/contracts/issues/51"

_projectMutationAuthority: impl.#MakeBottomCheck & {
	in: {
		name: "projectMutationAuthority"
		input: issue51.negativeFixtures.projectMutationAuthority.input
		target: issue51.#Issue51Manifest
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheck & {
	in: {
		name: "wrongSequenceOrder"
		input: issue51.negativeFixtures.wrongSequenceOrder.input
		target: issue51.#Issue51Manifest
	}
}

_negativeBottomChecks: {
	projectMutationAuthority: _projectMutationAuthority.out.projectMutationAuthority
	wrongSequenceOrder:       _wrongSequenceOrder.out.wrongSequenceOrder
}
