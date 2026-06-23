package impl

#ConstructorID:
	"#MakePrimitive" |
	"#MakeObservedSurface" |
	"#MakeAdmissibleSurface" |
	"#MakePredicateSet" |
	"#MakePromotionCandidate" |
	"#MakeSurfaceSet" |
	"#MakeNegativeFixture" |
	"#MakeBottomCheckPlan" |
	"#MakeBottomCheckProof" |
	"#MakeValidationPlan" |
	"#MakeCompletionReport"

#ConstructorCatalogEntry: close({
	id: #ConstructorID
	file: string & =~"^contracts/meta/impl/.+\\.cue$"
	purpose: string & !=""
})

#ConstructorCatalog: close({
	kind: "constructor-catalog"
	package: "impl"
	root: "contracts/meta/impl"
	constructors: [...#ConstructorCatalogEntry] & [_, ...]
	invariants: [...string & !=""] & [_, ...]
})

constructorCatalog: #ConstructorCatalog & {
	kind: "constructor-catalog"
	package: "impl"
	root: "contracts/meta/impl"
	constructors: [
		{
			id: "#MakePrimitive"
			file: "contracts/meta/impl/primitive.cue"
			purpose: "Compress repeated primitive descriptions into a known metadata shape."
		},
		{
			id: "#MakeObservedSurface"
			file: "contracts/meta/impl/surface.cue"
			purpose: "Describe broad observed fact substrates that can carry valid and invalid states."
		},
		{
			id: "#MakeAdmissibleSurface"
			file: "contracts/meta/impl/surface.cue"
			purpose: "Describe narrow admissible surfaces that reject invalid structure."
		},
		{
			id: "#MakePredicateSet"
			file: "contracts/meta/impl/predicate.cue"
			purpose: "Describe predicates derived from observed structure."
		},
		{
			id: "#MakePromotionCandidate"
			file: "contracts/meta/impl/promotion.cue"
			purpose: "Describe closed promotion candidates wired to predicate control."
		},
		{
			id: "#MakeSurfaceSet"
			file: "contracts/meta/impl/surface.cue"
			purpose: "Declare expected admissible, observed, candidate, fixture, check, and export surfaces."
		},
		{
			id: "#MakeNegativeFixture"
			file: "contracts/meta/impl/fixture.cue"
			purpose: "Make rejection cases first-class fixtures."
		},
		{
			id: "#MakeBottomCheckPlan"
			file: "contracts/meta/impl/bottom.cue"
			purpose: "Declare intended negative checks in manifests without executable proof targets."
		},
		{
			id: "#MakeBottomCheckProof"
			file: "contracts/meta/impl/bottom.cue"
			purpose: "Generate executable CUE intersections from check packages with adapter-bound targets."
		},
		{
			id: "#MakeValidationPlan"
			file: "contracts/meta/impl/validation.cue"
			purpose: "Generate deterministic validation command lists."
		},
		{
			id: "#MakeCompletionReport"
			file: "contracts/meta/impl/completion.cue"
			purpose: "Constrain completion reports into deterministic review evidence."
		},
	]
	invariants: [
		"Constructor definitions live in the repo-local impl package.",
		"Issue manifests carry constructor calls, not constructor bodies.",
		"CUE expressions remain CUE values, not stringified expression metadata.",
		"Negative checks are generated as intersections, not invalidity flags.",
		"Manifest packages carry bottom-check plans; check packages carry executable proof objects.",
		"Go wrappers are deferred to transport and materialization."
	]
}
