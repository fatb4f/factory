package patterns

// Positive witnesses remain evaluable in the package. Expected-bottom inputs
// are exported as raw fixtures and are conjoined with their selected schemas by
// the admitted observation boundary.
positiveFixtures: close({
	attributes: #PositiveFixture & {patternID: "attributes", value: #TaggedSelector & {selector: "#ClosedObligationState", path: "kernel/kernel.cue"}}
	bounds: #PositiveFixture & {patternID: "bounds", value: #KebabIdentifier & "authority-file"}
	closedness: #PositiveFixture & {patternID: "closedness", value: #ClosedResource & {id: "authority-file", path: "authority.cue", role: "authority", visibility: "internal"}}
	comprehensions: #PositiveFixture & {patternID: "comprehensions", value: (#MakeResources & {in: {authority: {path: "authority.cue", role: "authority"}}}).out}
	constructors: #PositiveFixture & {patternID: "constructors", value: (#MakeResource & {in: {id: "authority", path: "authority.cue", role: "authority"}}).out}
	defaults: #PositiveFixture & {patternID: "defaults", value: #GatePolicy & {id: "cue-vet", description: "validate package"}}
	disjunctions: #PositiveFixture & {patternID: "disjunctions", value: #OperationIntent & {kind: "generate", creates: {output: true}}}
	"hidden-and-let": #PositiveFixture & {patternID: "hidden-and-let", value: (#CreateProof & {createdID: "output", operation: {creates: {output: true}}, resources: {output: {role: "generated-output"}}}).proof}
	lists: #PositiveFixture & {patternID: "lists", value: #NonEmptyKeyList & ["authority-file"]}
	projections: #PositiveFixture & {patternID: "projections", value: (#PublicResourceProjection & {resources: {authority: {id: "authority", path: "authority.cue", role: "authority", visibility: "public"}}}).out}
	unification: #PositiveFixture & {patternID: "unification", value: #Resource & {id: "authority", path: "authority.cue", role: "authority"}}
})

negativeFixtures: close({
	closedness: #NegativeFixture & {patternID: "closedness", value: {id: "authority", path: "authority.cue", role: "authority", extra: true}}
	defaults: #NegativeFixture & {patternID: "defaults", value: {id: "cue-vet", description: "validate package", required: "true"}}
	definitions: #NegativeFixture & {patternID: "definitions", value: {id: "authority", path: "authority.cue", role: "authority", extra: true}}
	disjunctions: #NegativeFixture & {patternID: "disjunctions", value: {kind: "generate", reads: {authority: true}}}
})

directionalFixtures: close({
	subsumption: #DirectionalSubsumption & {
		general: {id: string, path: string, role: "authority" | "generated-output"}
		specific: {id: "authority", path: "authority.cue", role: "authority"}
	}
	preservation: #ProjectionPreservation & {
		general: {id: string, path: string}
		specific: {id: "authority", path: "authority.cue"}
	}
})

// Valid fixed points and recursive definitions are kept separate from the
// arithmetic and structural cycle inputs that the observation boundary rejects.
#RecursiveList: {head: _, tail: null | #RecursiveList}
cycleFixtures: close({
	positive: {
		fixedPoint: {a: {x: 1, y: 2}, b: {x: 1, y: 2}}
		recursiveDefinition: #RecursiveList
	}
	negative: {
		arithmetic: {kind: "arithmetic", expression: "x: x + 1"}
		structural: {kind: "structural", expression: "a: b: a"}
	}
})

patternSatisfaction: catalogComplete &&
	positiveFixtures.constructors.value.visibility == "internal" &&
	positiveFixtures["hidden-and-let"].value.created == true &&
	positiveFixtures["hidden-and-let"].value.role == "generated-output" &&
	positiveFixtures.projections.value == [{id: "authority", path: "authority.cue"}]
