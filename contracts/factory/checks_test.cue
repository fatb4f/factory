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

	hookTemplate: {
		generatedAuthority:
			hookTemplateNegativeFixtures.generatedAuthority.input & #ImplementationSliceIssue

		stringifiedBottomCheck:
			hookTemplateNegativeFixtures.stringifiedBottomCheck.input & #EvalPlan

		shellSemanticAuthority:
			hookTemplateNegativeFixtures.shellSemanticAuthority.input & #EvalPlan

		emptyEvalCommand:
			hookTemplateNegativeFixtures.emptyEvalCommand.input & #EvalObligation
	}

	hookRunner: {
		generatedProjectionAuthority:
			hookRunnerNegativeFixtures.generatedProjectionAuthority.input & #GeneratedHookProjection

		shellSemanticAuthority:
			hookRunnerNegativeFixtures.shellSemanticAuthority.input & #EvalRunnerPlan

		emptyRunnerCommand:
			hookRunnerNegativeFixtures.emptyRunnerCommand.input & #RunnerCommand

		undeclaredRunnerCommand:
			hookRunnerNegativeFixtures.undeclaredRunnerCommand.input & #EvalRunnerPlan
	}
}

_negativeBottomChecks: #NegativeBottomChecks
