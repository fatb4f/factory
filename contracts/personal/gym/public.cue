package gym

// Convenience export namespace. Domain registries and contracts own their own
// closure; recursively closing this composed index makes referenced registry
// fields illegal under CUE 0.16.x.
public: {
	contract:          gymContract
	body:              bodyRegions
	chains:            chains
	relations:         chainRelations
	metrics:           metrics
	metricLineage:     metricLineage
	equilibriumMetrics: equilibriumMetrics
	protocols:         protocols
	exercises:         exerciseProfiles
	mappings:          exerciseMappings
	programs:          programs
	programTargets:    ankleKneePelvisTargets
	compositeTargets:  ankleKneePelvisCompositeTargets
	programEquilibrium: ankleKneePelvisEquilibrium
	dataRequirements:  ankleKneePelvisDataRequirements
	projections:       projectionRelations
	projectionPolicy:  projectionPolicy
	policies: close({
		recovery: defaultRecoveryPolicy
		sessionAdmission: defaultSessionAdmissionPolicy
	})
}
