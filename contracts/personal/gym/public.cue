package gym

public: close({
	contract:          gymContract
	body:              bodyRegions
	chains:            chains
	relations:         chainRelations
	metrics:           metrics
	metricLineage:     metricLineage
	protocols:         protocols
	exercises:         exerciseProfiles
	mappings:          exerciseMappings
	programs:          programs
	programTargets:    ankleKneePelvisTargets
	compositeTargets:  ankleKneePelvisCompositeTargets
	dataRequirements:  ankleKneePelvisDataRequirements
	projections:       projectionRelations
	policies: close({
		recovery: defaultRecoveryPolicy
		sessionAdmission: defaultSessionAdmissionPolicy
	})
})
