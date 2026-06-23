package issue51checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

import issue51 "github.com/fatb4f/contract.cuemod/contracts/issues/51:issue51"

_projectMutationAuthority: impl.#MakeBottomCheckProof & {
	in: {
		name: "projectMutationAuthority"
		input: {
			evidence: "negative fixture input"
			value:    issue51.negativeFixtures.projectMutationAuthority.input
		}
		target: {
			name: "#Issue51Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue51.#Issue51Manifest
			}
		}
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheckProof & {
	in: {
		name: "wrongSequenceOrder"
		input: {
			evidence: "negative fixture input"
			value:    issue51.negativeFixtures.wrongSequenceOrder.input
		}
		target: {
			name: "#Issue51Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue51.#Issue51Manifest
			}
		}
	}
}

_negativeBottomChecks: {
	projectMutationAuthority: _projectMutationAuthority.out.projectMutationAuthority
	wrongSequenceOrder:       _wrongSequenceOrder.out.wrongSequenceOrder
}
