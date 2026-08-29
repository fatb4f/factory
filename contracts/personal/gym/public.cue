package gym

public: close({
	contract:    gymContract
	body:        bodyRegions
	chains:      chains
	relations:   chainRelations
	metrics:     metrics
	protocols:   protocols
	exercises:   exerciseProfiles
	mappings:    exerciseMappings
	programs:    programs
	projections: projectionRelations
	policies: close({
		recovery: defaultRecoveryPolicy
		sessionAdmission: defaultSessionAdmissionPolicy
	})
})
