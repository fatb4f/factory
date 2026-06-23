package issue52

primitiveInventory: [for primitive in _primitives {primitive.out}]

surfaceSet: _surfaces.out

validationPlan: _validation.out

completionReportContract: _completion.out

publicContract: close({
	kind: "issue-constructor-manifest"
	issue: validBaseline.issue
	repository: validBaseline.repository
	module: validBaseline.module
	constructorLibrary: validBaseline.constructorLibrary
	manifestPath: validBaseline.manifestPath
	normalizedPath: validBaseline.normalizedPath
	constructorCallsOnly: validBaseline.constructorCallsOnly
	inlineConstructorDefinitions: validBaseline.inlineConstructorDefinitions
	stringifiedCUEExpressions: validBaseline.stringifiedCUEExpressions
	goWrapperRequiredNow: validBaseline.goWrapperRequiredNow
	generatedArtifactsAreAuthority: validBaseline.generatedArtifactsAreAuthority
	primitives: primitiveInventory
	surfaces: surfaceSet
	fixtures: negativeFixtures
	validation: validationPlan
	completion: completionReportContract
})
