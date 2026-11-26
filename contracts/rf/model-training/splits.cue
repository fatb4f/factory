package modeltraining

import "list"

#Text: string & =~"[^[:space:]]"
#Recording: {
	id:      #Text
	session: #Text
	group:   #Text
}

#SplitManifest: {
	dataset:             #Text
	datasetVersion:      #Text
	generalizationClaim: #Text
	groupingUnit:        #Text
	splits: {
		train: [#Recording, ...#Recording]
		validation: [#Recording, ...#Recording]
		test: [#Recording, ...#Recording]
	}

	_recordingIDs: [for _, rows in splits for r in rows {r.id}] & list.UniqueItems()
	// Repeated keys unify, so related recordings must agree.
	_groupForSession: {for _, rows in splits for r in rows {(r.session): r.group}}
	_splitForGroup: {for role, rows in splits for r in rows {(r.group): role}}
}
