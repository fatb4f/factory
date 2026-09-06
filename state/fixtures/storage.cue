package statefixtures

import state "github.com/fatb4f/factory/contracts/state"

storageDataset: state.#DatasetStorageIdentity & {
	id:               "industrial-project-trajectories"
	analyticalSource: analyticsSource
	grain: {
		keys: ["project_id", "stage", "observed_at"]
		unit: "funding-stage-observation"
	}
}

storageRequirement: state.#StorageRequirement & {
	apiVersion: "factory.storage/v1"
	kind:       "StorageRequirement"
	dataset:    storageDataset
	required: {
		columnar:          true
		immutableSnapshot: true
		catalogOptional:   true
	}
}

parquetFormat: state.#StorageFormatCapability & {
	id:             "parquet"
	version:        "fixture-v1"
	columnar:       true
	openTable:      false
	immutableFiles: true
}

icebergFormat: state.#StorageFormatCapability & {
	id:             "iceberg"
	version:        "fixture-v1"
	columnar:       true
	openTable:      true
	immutableFiles: false
}

warehouseFormat: state.#StorageFormatCapability & {
	id:             "managed-columnar-table"
	version:        "fixture-v1"
	columnar:       true
	openTable:      false
	immutableFiles: false
}

filesystemCatalog: state.#StorageCatalogCapability & {
	id:                 "filesystem-manifest"
	version:            "fixture-v1"
	managed:            false
	snapshotReferences: true
}

managedCatalog: state.#StorageCatalogCapability & {
	id:                 "managed-warehouse-catalog"
	version:            "fixture-v1"
	managed:            true
	snapshotReferences: true
}

localStorage: state.#StorageRealization & {
	id:          "local-columnar"
	requirement: storageRequirement
	snapshot: {
		apiVersion:     "factory.storage/v1"
		kind:           "StorageSnapshot"
		dataset:        storageDataset
		version:        "local-v1"
		digest:         "sha256:1111111111111111111111111111111111111111111111111111111111111111"
		sourceSnapshot: analyticsSource.snapshotDigest
		location: {scheme: "file", uri: "state/storage/industrial-project-trajectories/local-v1.parquet"}
		format: parquetFormat
		catalog: filesystemCatalog
	}
	capabilities: {
		formats:  [parquetFormat, icebergFormat]
		catalogs: [filesystemCatalog]
	}
}

managedStorage: state.#StorageRealization & {
	id:          "managed-remote"
	requirement: storageRequirement
	snapshot: {
		apiVersion:     "factory.storage/v1"
		kind:           "StorageSnapshot"
		dataset:        storageDataset
		version:        "managed-v1"
		digest:         "sha256:2222222222222222222222222222222222222222222222222222222222222222"
		sourceSnapshot: analyticsSource.snapshotDigest
		location: {scheme: "warehouse", uri: "warehouse://factory/industrial-project-trajectories@managed-v1"}
		format: warehouseFormat
		catalog: managedCatalog
	}
	capabilities: {
		formats:  [warehouseFormat, icebergFormat]
		catalogs: [managedCatalog]
	}
}

storageGap: state.#StorageCoverageGap & {
	kind:        "storage-capability-gap"
	dataset:     storageDataset.id
	capability:  "cross-catalog-transaction"
	description: "No cross-catalog transactional guarantee is required by the current storage contract."
}
