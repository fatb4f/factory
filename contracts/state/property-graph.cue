package state

#PropertyGraphSchema: "factory.property-graph/v1"

#PropertyGraphSemanticNode: close({
	id:         #NonEmptyString
	class:      "semantic"
	snapshot:   #SHA256
	semantic:   #SemanticRef
	authority:  #SemanticAuthorityRef
	provenance: [#NonEmptyString, ...#NonEmptyString]
})

#PropertyGraphContextNode: close({
	id:         #NonEmptyString
	class:      "context"
	snapshot:   #SHA256
	artifact:   #ContextArtifactRef
	plane:      #ContextOnlyPlane
	provenance: [#NonEmptyString, ...#NonEmptyString]
})

#PropertyGraphNode: #PropertyGraphSemanticNode | #PropertyGraphContextNode

#PropertyGraphEdge: close({
	id:         #NonEmptyString
	snapshot:   #SHA256
	plane:      #ContextPlane
	relation:   #NonEmptyString
	source:     #NonEmptyString
	target:     #NonEmptyString
	basis:      [#NonEmptyString, ...#NonEmptyString]
	provenance: [#NonEmptyString, ...#NonEmptyString]

	// Present only when the admitted workbook edge preserved authority-owned
	// semantic relation metadata. The property-graph adapter may not infer it
	// from endpoint identity.
	relationAuthority?: #SemanticAuthorityRef
	admittedSnapshot?:  #AdmittedDomainSnapshotRef
})

#PropertyGraphProjection: close({
	apiVersion:         #PropertyGraphSchema
	kind:               "PropertyGraphProjection"
	sourceViewID:       #NonEmptyString
	sourcePresentation: #PresentationKind
	snapshot:           #SHA256
	subject:            #SemanticRef
	direction:          "factory-to-backend"
	reverseAdmission:   false
	nodes:              [...#PropertyGraphNode]
	edges:              [...#PropertyGraphEdge]
	provenance:         [#NonEmptyString, ...#NonEmptyString]
})

#PropertyGraphBackendTarget: close({
	id:        #NonEmptyString
	version:   #NonEmptyString
	transport: "record-batch"
})

#PropertyGraphLoadBundle: close({
	apiVersion:       #PropertyGraphSchema
	kind:             "PropertyGraphLoadBundle"
	target:           #PropertyGraphBackendTarget
	direction:        "factory-to-backend"
	reverseAdmission: false
	source: close({
		viewID:   #NonEmptyString
		snapshot: #SHA256
	})
	nodes: [...#PropertyGraphNode]
	edges: [...#PropertyGraphEdge]
})
