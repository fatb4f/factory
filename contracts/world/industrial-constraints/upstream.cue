package industrialconstraints

// Industrial constraint qualification is downstream of admitted industrial
// signal state. The source domain remains independent semantic authority.
#IndustrialSignalsSnapshotRef: close({
	domain:          "world.industrial-signals"
	snapshotID:      string
	digest:          #Digest
	observedThrough: #Timestamp
})

#RelationalConstraintInput: close({
	industrialSignals: #IndustrialSignalsSnapshotRef
})

#IndustrialSignalsInputContract: close({
	sourceDomain: "world.industrial-signals"
	admission:    "snapshot-qualified"
	schema:       "#RelationalConstraintInput"
})
