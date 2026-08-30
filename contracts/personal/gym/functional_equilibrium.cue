package gym

#ContributionDistributionID: string
#ContributionDistributionRef: close({id: #ContributionDistributionID})

#ContributionAllocationEntry: close({
	contributor:  #ContributorRef
	contribution?: #MechanicalContributionRef
	effect?:      #DerivedScalar
	allocation?:  number
})

// Allocation is tracked independently from task success. Two states may have
// equivalent demand residuals while using materially different contributors.
#ContributionDistribution: close({
	id:        #ContributionDistributionID
	movement:  #MovementPatternRef
	phase:     #PatternPhaseRef
	demand:    #MechanicalDemandRef
	entries:   [...#ContributionAllocationEntry] & [_, ...]
	evidence:  [...#EvidenceLink] & [_, ...]
	uncertainty?: #Uncertainty
	projectionVersion: string
})

#DemandResidual: close({
	demand:   #MechanicalDemandRef
	required?: #DerivedScalar
	observed?: #DerivedScalar
	residual: #DerivedScalar
})

#DistributionResidual: close({
	current:   #ContributionDistributionRef
	reference: #ContributionDistributionRef
	difference?: #DerivedScalar
	method:    string
})

// Functional equilibrium is a derived projection, never an authoritative
// observation. Demand satisfaction and contribution allocation remain separate.
#EquilibriumProjection: close({
	program?:   #ProgramRef
	movement:   #MovementPatternRef
	phase:      #PatternPhaseRef
	demandResiduals: [...#DemandResidual] & [_, ...]
	contributionDistribution?: #ContributionDistributionRef
	distributionResidual?:      #DistributionResidual
	compensation?:              #CompensationProjectionRef
	uncertainty?:               #Uncertainty
	evidence:                   [...#EvidenceLink] & [_, ...]
	projectionVersion:          string
})
