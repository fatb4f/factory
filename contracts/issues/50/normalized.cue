package issue50

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
	previousIssue: validBaseline.previousIssue
	encodedSequence: validBaseline.encodedSequence
	title: validBaseline.title
	schemaSync: validBaseline.schemaSync
	primitives: primitiveInventory
	surfaceInventory: _surfaceInventory
	surfaces: surfaceSet
	fixtures: negativeFixtures
	validation: validationPlan
	completion: completionReportContract
})
