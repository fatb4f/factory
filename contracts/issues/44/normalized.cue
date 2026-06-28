package issue44

import resolver "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/agent-context-resolver/src:agentcontextresolver"

implementationSliceConstructorInventory: _constructorInventory
primitiveInventory: [for _, primitive in _primitives {primitive.out}]

publicContract: close({
	kind: "implementation-slice-issue-materializer"
	issue: validBaseline.issue
	title: validBaseline.title
	tracking: validBaseline.tracking
	template: validBaseline.template
	instantiation: validBaseline.instantiation
	constructorInventory: implementationSliceConstructorInventory
	primitives: primitiveInventory
	observed: _observed.out
	admissible: _admissible.out
	predicates: _predicates.out
	promotion: _promotion.out
	surfaces: _surfaces.out
	negativeFixtures: negativeFixtureExports
	bottomCheckPlans: _bottomCheckPlans
	resolverExports: {
		implementationSliceIssueBaseline: resolver.implementationSliceIssueBaseline
		implementationSliceMaterializationReport: resolver.implementationSliceMaterializationReport
		implementationSliceEvalPlan: resolver.implementationSliceEvalPlan
		implementationSliceRunnerPlan: resolver.implementationSliceRunnerPlan
		implementationSliceFeedbackShape: resolver.implementationSliceFeedbackShape
	}
})

validationPlan: _validation.out
completionReportContract: _completion.out
