package eval

import (
	"list"
	"github.com/fatb4f/factory/cue-skill/gate"
)

#SuiteEvaluation: close({
	candidates: [...#CandidateEvaluation] & [_, ...]
	coverage:     #Coverage
	packageGates: gate.#PackageGates

	semanticSatisfied: !list.Contains([for candidate in candidates {candidate.satisfied}], false) && coverage.complete
	structuralSatisfied: packageGates.structuralComplete && packageGates.allSucceeded
	satisfied:           semanticSatisfied && structuralSatisfied
})
