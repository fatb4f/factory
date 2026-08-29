package gym

public: close({
	contract:    gymContract
	exercises:   exerciseProfiles
	projections: projectionRelations
	policies: close({
		recovery: defaultRecoveryPolicy
		sessionAdmission: defaultSessionAdmissionPolicy
	})
})
