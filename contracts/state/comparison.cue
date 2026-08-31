package state

import unit "github.com/fatb4f/factory/contracts:unit"

#NonEmptyString: string & != ""
#RunID:          string & =~"^[0-9]{8}T[0-9]{6}Z$"
#SHA256:         string & =~"^sha256:[0-9a-f]{64}$"

#ComparisonStatus: "bootstrap" | "comparable" | "invalidated"

#RunReference: close({
	task:              unit.#TaskID
	scope:             #NonEmptyString
	schema:            #NonEmptyString
	run_id:            #RunID
	observed_at:       #NonEmptyString
	normalized_digest: #SHA256
	bundle_path:       unit.#RepositoryPath
})

#BaselineReference: close({
	run:         #RunReference
	admitted_at: #NonEmptyString
})

#BootstrapComparisonState: close({
	task:    unit.#TaskID
	scope:   #NonEmptyString
	schema:  #NonEmptyString
	current: #RunReference
	status:  "bootstrap"
})

#ComparableComparisonState: close({
	task:     unit.#TaskID
	scope:    #NonEmptyString
	schema:   #NonEmptyString
	current:  #RunReference
	status:   "comparable"
	baseline: #BaselineReference
})

#InvalidatedComparisonState: close({
	task:                unit.#TaskID
	scope:               #NonEmptyString
	schema:              #NonEmptyString
	current:             #RunReference
	status:              "invalidated"
	baseline:            #BaselineReference
	invalidation_reason: #NonEmptyString
})

#ComparisonState:
	#BootstrapComparisonState |
	#ComparableComparisonState |
	#InvalidatedComparisonState

#BaselinePointer: close({
	apiVersion: "factory.comparison-state.baseline/v1"
	kind:       "AdmittedComparisonBaseline"
	task:       unit.#TaskID
	scope:      #NonEmptyString
	schema:     #NonEmptyString
	generation: int & >=1
	baseline:   #BaselineReference
})

#BaselineAdvance: close({
	task:                unit.#TaskID
	scope:               #NonEmptyString
	schema:              #NonEmptyString
	expected_generation: int & >=0
	expected_digest?:    #SHA256
	next:                #BaselinePointer
})

storeProtocol: close({
	backend:        "git-repository"
	immutableRuns:  true
	mutablePointer: true
	updateMode:     "compare-and-swap"
	casInputs: [
		"expected-pointer-generation",
		"expected-pointer-file-revision",
	]
})
