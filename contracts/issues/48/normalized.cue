package issue48

primitiveInventory: [for primitive in _primitives {primitive.out}]
_surfaceInventory: {
	observed: _observedSurface.out
	admissible: _admissibleSurface.out
	predicates: _predicates.out
	promotion: _promotionCandidate.out
}
surfaceSet: _surfaces.out
validationPlan: _validation.out
completionReportContract: _completion.out

publicContract: close({
	kind: "encoded-issue-surface"
	issue: validBaseline.issue
	sequenceOrder: validBaseline.sequenceOrder
	encodedSequence: validBaseline.encodedSequence
	title: validBaseline.title
	childGraph: validBaseline.childGraph
	codexAdapterSprintControl: validBaseline.codexAdapterSprintControl
	primitives: primitiveInventory
	surfaceInventory: _surfaceInventory
	surfaces: surfaceSet
	fixtures: negativeFixtures
	validation: validationPlan
	completion: completionReportContract
})
