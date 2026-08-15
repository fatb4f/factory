package epistemicplantprofile

epistemicPlantCorrelationContract: close({
	kind: "content-addressed-epistemic-lineage"
	stableIdentities: [
		"source_document_sha256",
		"graphql_query_sha256",
		"graph_generation_digest",
		"candidate_digest",
		"evaluation_digest",
		"admission_receipt_digest",
		"transition_receipt_digest",
		"epistemic_observation_derivation_digest",
	]
	joinChain: [
		"SourceDocument.digest",
		"GraphGeneration.sourceDigests",
		"GraphGeneration.digest",
		"ObservedRelationship.graphGeneration",
		"AdmissionDecision.candidateDigest",
		"AdmissionReceipt.candidateDigest",
		"AdmissionReceipt.evidenceSourceDigests",
		"AdmissionReceipt.supportingSourceDigests",
		"AdmissionReceipt.transitionReceipt",
		"EpistemicObservation.admittedRelationships",
		"EpistemicObservation.transitionReceipt",
	]
	volatileExclusions: [
		"GUAC internal IDs",
		"GraphQL result ordering",
		"runtime timestamps",
		"backend-local identifiers",
		"process IDs and listen ports",
	]
	semanticPrecedence: [
		"pinned_source_declaration",
		"cue_qualified_admission",
		"guac_observation",
		"guac_provenance_witness",
		"backend_realization",
	]
	conflictPolicy: close({
		guacVsPinnedSource: "pinned_source_wins; unsupported resolved candidate is REJECTED"
		conflictingPinnedSources: "INCONCLUSIVE"
		insufficientCoordinateResolution: "INCONCLUSIVE"
		operationalFailure: "INCONCLUSIVE"
	})
})
