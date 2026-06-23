package impl

publicContract: close({
	kind: "constructor-library"
	catalog: constructorCatalog
	specs: [
		{
			name: "#PrimitiveSpec"
			constructor: "#MakePrimitive"
			file: "contracts/meta/impl/primitive.cue"
		},
		{
			name: "#SurfaceSetSpec"
			constructor: "#MakeSurfaceSet"
			file: "contracts/meta/impl/surface.cue"
		},
		{
			name: "#NegativeFixtureSpec"
			constructor: "#MakeNegativeFixture"
			file: "contracts/meta/impl/fixture.cue"
		},
		{
			name: "#BottomCheckSpec"
			constructor: "#MakeBottomCheck"
			file: "contracts/meta/impl/bottom.cue"
		},
		{
			name: "#ValidationPlanSpec"
			constructor: "#MakeValidationPlan"
			file: "contracts/meta/impl/validation.cue"
		},
		{
			name: "#CompletionReportSpec"
			constructor: "#MakeCompletionReport"
			file: "contracts/meta/impl/completion.cue"
		},
	]
	exports: [
		"constructorCatalog",
		"publicContract",
	]
})
