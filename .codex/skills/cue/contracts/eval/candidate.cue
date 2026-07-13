package eval

import "list"

#CandidateEvaluation: close({
	candidate:     string
	subjectDigest: string
	requiredFamilies: [...string] & [_, ...]
	families: [...#FamilyEvaluation] & [_, ...]

	_familyIDs: [for family in families {family.family}]
	_scoped: !list.Contains([for family in families {
		family.candidate == candidate && family.subjectDigest == subjectDigest
	}], false)
	_exactFamilies: list.SortStrings(_familyIDs) == list.SortStrings(requiredFamilies) && len(_familyIDs) == len(requiredFamilies)
	_allSatisfied: !list.Contains([for family in families {family.satisfied}], false)

	satisfied: _scoped && _exactFamilies && _allSatisfied
})
