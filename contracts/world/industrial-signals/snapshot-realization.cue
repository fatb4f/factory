package industrialsignals

import state "github.com/fatb4f/factory/contracts/state"

#IndustrialGraphSnapshotRealization: close({
	apiVersion: "industrial-signals.graph-snapshot/v1"
	kind:       "IndustrialGraphSnapshotRealization"
	execution:  #IndustrialGraphExecution

	analyticalPlan: state.#RelationalPlan
	storage: state.#StorageSnapshot & {
		sourceSnapshot: analyticalPlan.request.source.snapshotDigest
	}

	projection: close({
		canonicalization: "json-sort-keys-compact"
		version:          string & != ""
	})

	snapshot: #IndustrialGraphSnapshot
})
