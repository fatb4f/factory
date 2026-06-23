package factory

#NegativeBottomChecks: {
	vocabularyWithoutGateProof:
		negativeFixtures.vocabularyWithoutGateProof.input & #RootPromotionCandidate

	sidePackageSchemaSprawl:
		negativeFixtures.sidePackageSchemaSprawl.input & #RootPromotionCandidate

	prematureClosureClaim:
		negativeFixtures.prematureClosureClaim.input & #RootPromotionCandidate

	syntheticEvidenceOrProvenance:
		negativeFixtures.syntheticEvidenceOrProvenance.input & #RootPromotionCandidate

	fakeProvenance:
		negativeFixtures.fakeProvenance.input & #RootPromotionCandidate

	nonDerivedPath:
		negativeFixtures.nonDerivedPath.input & #RootPromotionCandidate

}

_negativeBottomChecks: #NegativeBottomChecks
