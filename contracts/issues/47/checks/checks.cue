package issue47checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

import issue47 "github.com/fatb4f/contract.cuemod/contracts/issues/47:issue47"

_fallbackAuthority: impl.#MakeBottomCheckProof & {
	in: {
		name: "fallbackAuthority"
		input: {
			evidence: "negative fixture input"
			value:    issue47.negativeFixtures.fallbackAuthority.input
		}
		target: {
			name: "#Issue47Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue47.#Issue47Manifest
			}
		}
	}
}

_wrongSequenceOrder: impl.#MakeBottomCheckProof & {
	in: {
		name: "wrongSequenceOrder"
		input: {
			evidence: "negative fixture input"
			value:    issue47.negativeFixtures.wrongSequenceOrder.input
		}
		target: {
			name: "#Issue47Manifest"
			contract: {
				evidence: "issue-local proof target"
				value:    issue47.#Issue47Manifest
			}
		}
	}
}

_negativeBottomChecks: {
	fallbackAuthority:  _fallbackAuthority.out.fallbackAuthority
	wrongSequenceOrder: _wrongSequenceOrder.out.wrongSequenceOrder
}
