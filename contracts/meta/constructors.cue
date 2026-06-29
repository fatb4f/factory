package meta

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
	"#MakeCompletionReport" |
	"#ContractGenerator" |
	"#ContractValidator" |
	"#GeneratedContractCompliance"

#ConstructorCatalogEntry: close({
	id:      #ConstructorID
	file:    string & =~"^contracts/meta/.+\\.cue$"
	purpose: string & !=""
})

#ConstructorCatalog: close({
	kind:    "constructor-catalog"
	package: "meta"
	root:    "contracts/meta"
	axes: close({
		constructorOrder: "constructorAxis"
		authorityStrata:  "authorityAxis"
		shape:            "metaDualAxisShape"
	})
	constructors: [...#ConstructorCatalogEntry] & [_, ...]
	invariants: [...string & !=""] & [_, ...]
})

constructorCatalog: #ConstructorCatalog & {
	kind:    "constructor-catalog"
	package: "meta"
	root:    "contracts/meta"
	axes: {
		constructorOrder: "constructorAxis"
		authorityStrata:  "authorityAxis"
		shape:            "metaDualAxisShape"
	}
	constructors: [
		{
			id:      "#MakePrimitive"
			file:    "contracts/meta/primitive.cue"
			purpose: "Compress repeated primitive descriptions into a known metadata shape."
		},
		{
			id:      "#MakeObservedSurface"
			file:    "contracts/meta/surface.cue"
			purpose: "Describe broad observed fact substrates that can carry valid and invalid states."
		},
		{
			id:      "#MakeAdmissibleSurface"
			file:    "contracts/meta/surface.cue"
			purpose: "Describe narrow admissible surfaces that reject invalid structure."
		},
		{
			id:      "#MakePredicateSet"
			file:    "contracts/meta/predicate.cue"
			purpose: "Describe predicates derived from observed structure."
		},
		{
			id:      "#MakePromotionCandidate"
			file:    "contracts/meta/promotion.cue"
			purpose: "Describe closed promotion candidates wired to predicate control."
		},
		{
			id:      "#MakeSurfaceSet"
			file:    "contracts/meta/surface.cue"
			purpose: "Declare expected admissible, observed, candidate, fixture, check, and export surfaces."
		},
		{
			id:      "#MakeNegativeFixture"
			file:    "contracts/meta/fixture.cue"
			purpose: "Make rejection cases first-class fixtures."
		},
		{
			id:      "#MakeBottomCheckPlan"
			file:    "contracts/meta/bottom.cue"
			purpose: "Declare intended negative checks in manifests without executable proof targets."
		},
		{
			id:      "#MakeBottomCheckProof"
			file:    "contracts/meta/bottom.cue"
			purpose: "Generate executable CUE intersections from check packages with adapter-bound targets."
		},
		{
			id:      "#MakeValidationPlan"
			file:    "contracts/meta/validation.cue"
			purpose: "Generate deterministic validation command lists."
		},
		{
			id:      "#MakeCompletionReport"
			file:    "contracts/meta/completion.cue"
			purpose: "Constrain completion reports into deterministic review evidence."
		},
		{
			id:      "#ContractGenerator"
			file:    "contracts/meta/scaffold.cue"
			purpose: "Declare next-layer scaffold generation contracts without making generated files authoritative."
		},
		{
			id:      "#ContractValidator"
			file:    "contracts/meta/scaffold.cue"
			purpose: "Declare parent-authority validation contracts for generated scaffold candidates."
		},
		{
			id:      "#GeneratedContractCompliance"
			file:    "contracts/meta/scaffold.cue"
			purpose: "Bind one generator and one validator to required exports, constructor use, bottom checks, and evidence-only boundaries."
		},
	]
	invariants: [
		"Constructor definitions live in the repo-local meta package.",
		"Issue manifests carry constructor calls, not constructor bodies.",
		"CUE expressions remain CUE values, not stringified expression metadata.",
		"Negative checks are generated as intersections, not invalidity flags.",
		"Manifest packages carry bottom-check plans; check packages carry executable proof objects.",
		"Constructor order and authority strata are separate axes.",
		"Constructor catalog entries identify available constructors; constructorAxis orders their instantiation.",
		"AuthorityAxis ranks contract, assertions, fixtures, checks, and evals independently of constructor order.",
		"Go wrappers are deferred to transport and materialization.",
		"Generator contracts create candidates; validator contracts prove parent-authority compliance.",
		"Generated artifacts remain evidence only until admitted by repo-local CUE validation.",
	]
}
