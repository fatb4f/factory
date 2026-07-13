package eval

import "list"

#Policy: close({
	permitted: {[#Verdict]: true}
	requiredAny: [...#Verdict]
	requiredEach: [...#Verdict]
})

#FamilyEvaluation: close({
	candidate:     string
	family:        string
	subjectDigest: string
	requiredProbeIDs: [...string] & [_, ...]
	policy: #Policy
	results: [...#ProbeEvaluationShape] & [_, ...]

	_ids: [for result in results {result.probeID}]
	_scoped: !list.Contains([for result in results {
		result.candidate == candidate && result.family == family
	}], false)
	_exactIDs: list.SortStrings(_ids) == list.SortStrings(requiredProbeIDs) && len(_ids) == len(requiredProbeIDs)
	_allPermitted: !list.Contains([for result in results {policy.permitted[result.verdict] == true}], false)
	_requiredAny: len(policy.requiredAny) == 0 || list.Contains([for result in results {list.Contains(policy.requiredAny, result.verdict)}], true)
	_requiredEach: !list.Contains([for required in policy.requiredEach {
		list.Contains([for result in results {result.verdict}], required)
	}], false)

	satisfied: _scoped && _exactIDs && _allPermitted && _requiredAny && _requiredEach
})
