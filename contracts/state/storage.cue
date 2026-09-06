package state

#StorageSchema: "factory.storage/v1"

#DatasetStorageIdentity: close({
	id:               #NonEmptyString
	analyticalSource: #AnalyticalSourceRef
	grain:            #AnalyticalGrain
})

#StorageRequirement: close({
	apiVersion: #StorageSchema
	kind:       "StorageRequirement"
	dataset:    #DatasetStorageIdentity
	required: close({
		columnar:        bool
		immutableSnapshot: bool
		catalogOptional: bool
	})
})

#StorageFormatCapability: close({
	id:              #NonEmptyString
	version:         #NonEmptyString
	columnar:        bool
	openTable:       bool
	immutableFiles:  bool
})

#StorageCatalogCapability: close({
	id:                 #NonEmptyString
	version:            #NonEmptyString
	managed:            bool
	snapshotReferences: bool
})

#StorageLocation: close({
	scheme: "file" | "object" | "warehouse"
	uri:    #NonEmptyString
})

#StorageSnapshot: close({
	apiVersion:       #StorageSchema
	kind:             "StorageSnapshot"
	dataset:          #DatasetStorageIdentity
	version:          #NonEmptyString
	digest:           #SHA256
	sourceSnapshot:   #SHA256
	location:         #StorageLocation
	format:           #StorageFormatCapability
	catalog?:         #StorageCatalogCapability
})

#StorageRealization: close({
	id:          #NonEmptyString
	requirement: #StorageRequirement
	snapshot:    #StorageSnapshot
	capabilities: close({
		formats:  [#StorageFormatCapability, ...#StorageFormatCapability]
		catalogs: [...#StorageCatalogCapability]
	})
})

#StorageCoverageGap: close({
	kind:        "storage-capability-gap"
	dataset:     #NonEmptyString
	capability:  #NonEmptyString
	description: #NonEmptyString
})
