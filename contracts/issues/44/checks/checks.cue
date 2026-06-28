package issue44checks

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

import issue44 "github.com/fatb4f/contract.cuemod/contracts/issues/44:issue44"
import resolver "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/agent-context-resolver/src:agentcontextresolver"

_routeOnlyPacket: impl.#MakeBottomCheckProof & {
	in: {
		name: "routeOnlyPacket"
		input: {
			evidence: "negative fixture"
			value: issue44.negativeFixtures.routeOnlyPacket.input
		}
		target: {
			name: "#IssueMaterializationCandidate"
			contract: {
				evidence: "resolver materialization candidate"
				value: resolver.#IssueMaterializationCandidate
			}
		}
	}
}

_missingContractPath: impl.#MakeBottomCheckProof & {
	in: {
		name: "missingContractPath"
		input: {
			evidence: "negative fixture"
			value: issue44.negativeFixtures.missingContractPath.input.parsedIssue.contract
		}
		target: {
			name: "#ParsedImplementationSliceIssue.contract"
			contract: {
				evidence: "parsed issue contract path requirement"
				value: resolver.#ParsedImplementationSliceIssue.contract
			}
		}
	}
}

_staticEvalPlan: impl.#MakeBottomCheckProof & {
	in: {
		name: "staticEvalPlan"
		input: {
			evidence: "negative fixture"
			value: issue44.negativeFixtures.staticEvalPlan.input
		}
		target: {
			name: "#IssueMaterializationCandidate"
			contract: {
				evidence: "derived eval plan predicate"
				value: resolver.#IssueMaterializationCandidate
			}
		}
	}
}

_missingNegativeCheckExpression: impl.#MakeBottomCheckProof & {
	in: {
		name: "missingNegativeCheckExpression"
		input: {
			evidence: "negative fixture"
			value: issue44.negativeFixtures.missingNegativeCheckExpression.input
		}
		target: {
			name: "#IssueMaterializationCandidate"
			contract: {
				evidence: "negative selector predicate"
				value: resolver.#IssueMaterializationCandidate
			}
		}
	}
}

_anyNonzeroAsPass: impl.#MakeBottomCheckProof & {
	in: {
		name: "anyNonzeroAsPass"
		input: {
			evidence: "negative fixture"
			value: issue44.negativeFixtures.anyNonzeroAsPass.input
		}
		target: {
			name: "#IssueMaterializationCandidate"
			contract: {
				evidence: "classified failure predicate"
				value: resolver.#IssueMaterializationCandidate
			}
		}
	}
}

_negativeBottomChecks: {
	routeOnlyPacket: _routeOnlyPacket.out.routeOnlyPacket
	missingContractPath: _missingContractPath.out.missingContractPath
	staticEvalPlan: _staticEvalPlan.out.staticEvalPlan
	missingNegativeCheckExpression: _missingNegativeCheckExpression.out.missingNegativeCheckExpression
	anyNonzeroAsPass: _anyNonzeroAsPass.out.anyNonzeroAsPass
}
