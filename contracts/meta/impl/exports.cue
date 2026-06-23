package impl

publicContract: close({
	kind: "constructor-library"
	catalog: constructorCatalog
	specs: close({
		primitive: #PrimitiveSpec
		surfaceSet: #SurfaceSetSpec
		negativeFixture: #NegativeFixtureSpec
		bottomCheck: #BottomCheckSpec
		validationPlan: #ValidationPlanSpec
		completionReport: #CompletionReportSpec
	})
	outputs: close({
		primitive: #PrimitiveDescriptor
		surfaceSet: #SurfaceSetDescriptor
		negativeFixture: #NegativeFixtureDescriptor
		validationPlan: #ValidationPlan
		completionReport: #CompletionReportContract
	})
})
