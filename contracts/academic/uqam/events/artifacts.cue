package uqamevents

#NormalizedSnapshot: close({
	task_id:          #TaskID
	schema:           #SchemaID
	observed_at:      #NonEmptyString
	catalog_context?: #CatalogContext
	events:           [...#NormalizedEvent]
})

#SourceGapDecisionArtifact: close({
	currentRun: #EventRunReference
	acquisition: #IncompleteAcquisitionCoverage
	decision: #SourceGapDecision
	pointer: #PointerHold & {reason: "source_gap"}
})

#BootstrapDecisionArtifact: close({
	currentRun: #EventRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: #BootstrapComparisonResult & {comparison_state: {current: currentRun}}
	decision: #BaselineEstablishedDecision
	pointer: #PointerAdvance & {transition: {expected_generation: 0, next: {baseline: {run: currentRun}}}}
})

#ComparableNoChangeDecisionArtifact: close({
	currentRun: #EventRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: #ComparableComparisonResult & {comparison_state: {current: currentRun}, delta: #NoReportableDelta}
	decision: #NoChangeDecision
	pointer: #PointerAdvance & {transition: {expected_generation: int & >=1, next: {baseline: {run: currentRun}}}}
})

#ComparableNewMatchesDecisionArtifact: close({
	currentRun: #EventRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: #ComparableComparisonResult & {comparison_state: {current: currentRun}, delta: #ReportableDelta}
	decision: #NewMatchesDecision
	pointer: #PointerAdvance & {transition: {expected_generation: int & >=1, next: {baseline: {run: currentRun}}}}
})

#ComparisonGapDecisionArtifact: close({
	currentRun: #EventRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: #InvalidatedComparisonResult & {comparison_state: {current: currentRun}}
	decision: #ComparisonGapDecision
	pointer: #PointerHold & {reason: "comparison_gap"}
})

#StateConflictDecisionArtifact: close({
	currentRun: #EventRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: (#BootstrapComparisonResult | #ComparableComparisonResult) & {comparison_state: {current: currentRun}}
	decision: #StateConflictDecision
	pointer: #StateConflictHold
})

#DecisionArtifact: #SourceGapDecisionArtifact | #BootstrapDecisionArtifact | #ComparableNoChangeDecisionArtifact | #ComparableNewMatchesDecisionArtifact | #ComparisonGapDecisionArtifact | #StateConflictDecisionArtifact
