package eval

import "list"

#Coverage: close({
	requiredKernelInvariants: [...string] & [_, ...]
	requiredCandidates: [...string] & [_, ...]
	requiredFamilies: [...string] & [_, ...]
	requiredEvaluators: [...string] & [_, ...]
	requiredFixtures: [...string] & [_, ...]
	coveredKernelInvariants: [...string]
	coveredCandidates: [...string]
	coveredFamilies: [...string]
	coveredEvaluators: [...string]
	coveredFixtures: [...string]

	_kernel:     list.SortStrings(requiredKernelInvariants) == list.SortStrings(coveredKernelInvariants)
	_candidates: list.SortStrings(requiredCandidates) == list.SortStrings(coveredCandidates)
	_families:   list.SortStrings(requiredFamilies) == list.SortStrings(coveredFamilies)
	_evaluators: list.SortStrings(requiredEvaluators) == list.SortStrings(coveredEvaluators)
	_fixtures:   list.SortStrings(requiredFixtures) == list.SortStrings(coveredFixtures)
	complete:    _kernel && _candidates && _families && _evaluators && _fixtures
})
