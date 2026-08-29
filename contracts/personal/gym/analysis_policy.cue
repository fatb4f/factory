package gym

#RecoveryPolicy: close({
	highEnergyDrop:             int & >=1 & <=4
	highCognitiveDrop:          int & >=1 & <=4
	highDoms:                   int & >=1 & <=5
	exceededMovementHours:      number & >0
	exceededRecoveryHours:      number & >0
})

defaultRecoveryPolicy: #RecoveryPolicy & {
	highEnergyDrop:        2
	highCognitiveDrop:     2
	highDoms:              4
	exceededMovementHours: 48
	exceededRecoveryHours: 72
}

#SessionAdmissionPolicy: close({
	mechanicalExceeded: "reduce"
	recoveryExceeded:   "reduce"
	mechanicalMarginal: "hold"
	recoveryHigh:       "hold"
	cleanWithinBudget:  "eligible"
	incompleteRecovery: "provisional"
})

defaultSessionAdmissionPolicy: #SessionAdmissionPolicy & {
	mechanicalExceeded: "reduce"
	recoveryExceeded:   "reduce"
	mechanicalMarginal: "hold"
	recoveryHigh:       "hold"
	cleanWithinBudget:  "eligible"
	incompleteRecovery: "provisional"
}
