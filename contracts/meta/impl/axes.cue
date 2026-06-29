package impl

#ConstructorOrderEntry: close({
	order:         int & >=1
	id:            #ConstructorID
	instantiateAt: string & !=""
})

#ConstructorAxis: close({
	kind:      "constructor-axis"
	pipeline:  [...#ConstructorOrderEntry] & [_, ...]
	invariant: string & !=""
})

_constructorAxis: #ConstructorAxis & {
	kind: "constructor-axis"
	pipeline: [
		{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
		{order: 2, id: "#MakeObservedSurface", instantiateAt: "_observed"},
		{order: 3, id: "#MakeAdmissibleSurface", instantiateAt: "_admissible"},
		{order: 4, id: "#MakePredicateSet", instantiateAt: "_predicates"},
		{order: 5, id: "#MakePromotionCandidate", instantiateAt: "_promotion"},
		{order: 6, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
		{order: 7, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
		{order: 8, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
		{order: 9, id: "#MakeBottomCheckProof", instantiateAt: "checks/_negativeBottomChecks"},
		{order: 10, id: "#MakeValidationPlan", instantiateAt: "_validation"},
		{order: 11, id: "#MakeCompletionReport", instantiateAt: "_completion"},
	]
	invariant: "Constructor order defines instantiation sequence only; it does not define artifact authority."
}

constructorAxis: _constructorAxis

#AuthorityStratumID:
	"contract" |
	"assertions" |
	"fixtures" |
	"checks" |
	"evals"

#AuthorityStratumEntry: close({
	order:     int & >=1
	id:        #AuthorityStratumID
	role:      string & !=""
	authority: string & !=""
	accepts:   *[] | [...string & !=""]
	rejects:   *[] | [...string & !=""]
})

#AuthorityAxis: close({
	kind:      "authority-axis"
	order:     [...#AuthorityStratumID] & [_, ...]
	strata:    [...#AuthorityStratumEntry] & [_, ...]
	invariant: string & !=""
})

_authorityAxis: #AuthorityAxis & {
	kind:  "authority-axis"
	order: ["contract", "assertions", "fixtures", "checks", "evals"]
	strata: [
		{
			order:     1
			id:        "contract"
			role:      "Owns constructor signatures, descriptor shapes, invariants, and admissible boundaries."
			authority: "source-of-truth"
			accepts:   ["constructor definitions", "descriptor contracts", "admissible surface definitions", "invariants"]
			rejects:   ["generated artifacts as authority", "adapter outputs as contract definitions"]
		},
		{
			order:     2
			id:        "assertions"
			role:      "Binds expected properties over concrete contract instances."
			authority: "derived-from-contract"
			accepts:   ["expected invariants", "instance-level obligations"]
			rejects:   ["new constructor bodies", "schema drift"]
		},
		{
			order:     3
			id:        "fixtures"
			role:      "Provides positive and negative examples that probe contract boundaries."
			authority: "test-input"
			accepts:   ["admissible examples", "inadmissible examples", "negative fixtures"]
			rejects:   ["proof results", "authority promotion"]
		},
		{
			order:     4
			id:        "checks"
			role:      "Executes proof obligations against fixtures and adapter-bound targets."
			authority: "evidence-generator"
			accepts:   ["bottom-check plans", "bottom-check proofs", "validation commands"]
			rejects:   ["hand-written bottom sentinels as authority", "fixtures collapsing to top"]
		},
		{
			order:     5
			id:        "evals"
			role:      "Summarizes evidence from checks without becoming a source of truth."
			authority: "evidence-summary"
			accepts:   ["completion reports", "review evidence", "publication summaries"]
			rejects:   ["contract mutation", "schema authority"]
		},
	]
	invariant: "Authority rank is independent from constructor instantiation order."
}

authorityAxis: _authorityAxis

#DualAxisShape: close({
	kind:            "meta-dual-axis-shape"
	constructorAxis: #ConstructorAxis
	authorityAxis:   #AuthorityAxis
	invariants:      [...string & !=""] & [_, ...]
})

metaDualAxisShape: #DualAxisShape & {
	kind:            "meta-dual-axis-shape"
	constructorAxis: _constructorAxis
	authorityAxis:   _authorityAxis
	invariants: [
		"Constructor order and authority strata are separate axes.",
		"Constructor calls use impl.#MakeX & { in: {...} } according to constructor-specific signatures.",
		"String references bind constructor instances unless an impl signature explicitly requires an embedded value.",
		"Checks generate proof artifacts from fixtures intersected with adapter-bound admissible targets.",
		"Evaluations and completion reports summarize validated evidence only.",
	]
}
