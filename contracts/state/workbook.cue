package state

#WorkbookSchema: "factory.workbook/v1"

#DirectoryOccurrence: close({
	repository: #NonEmptyString
	revision:   #NonEmptyString
	path:       #RepositoryScopePath
})

#DirectoryBinding: close({
	id:        #NonEmptyString
	directory: #DirectoryOccurrence
	subjects:  [...#SemanticRef]
})

#WorkbookScope: close({
	binding:  #DirectoryBinding
	primary:  #SemanticRef
	includes: [...#SemanticRef]
	snapshot: #SHA256
})

#IntrospectionBinding: close({
	id:         #NonEmptyString
	subject:    #SemanticRef
	projection: #SHA256
	roots:      [#NonEmptyString, ...#NonEmptyString]
})

#PresentationKind: "topology" | "table" | "chart" | "timeline" | "property-graph" | "inspection"

#BoundedNavigationViewSource: close({
	kind:     "bounded-navigation"
	root:     #SemanticRef
	plane:    #ContextPlane
	maxDepth: int & >=1 & <=32
})

#AnalyticalViewSource: close({
	kind:    "analytical"
	request: #AnalyticalRequest
})

#IntrospectionViewSource: close({
	kind:    "introspection"
	binding: #NonEmptyString
	request: #InspectionRequest
})

#ViewSource: #BoundedNavigationViewSource | #AnalyticalViewSource | #IntrospectionViewSource

#ViewSpec: close({
	id:           #NonEmptyString
	presentation: #PresentationKind
	source:       #ViewSource
})

#SemanticProjectionNode: close({
	space:      "semantic"
	id:         #NonEmptyString
	semantic:   #SemanticRef
	provenance: [#NonEmptyString, ...#NonEmptyString]
})

#ContextProjectionNode: close({
	space:      "context"
	id:         #NonEmptyString
	artifact:   #ContextArtifactRef
	plane:      #ContextOnlyPlane
	provenance: [#NonEmptyString, ...#NonEmptyString]
})

#ProjectionNode: #SemanticProjectionNode | #ContextProjectionNode

#ProjectionEdge: close({
	id:         #NonEmptyString
	plane:      #ContextPlane
	relation:   #NonEmptyString
	source:     #NonEmptyString
	target:     #NonEmptyString
	basis:      [#NonEmptyString, ...#NonEmptyString]
	provenance: [#NonEmptyString, ...#NonEmptyString]

	// Semantic navigation preserves the owning relation authority and admitted
	// domain snapshot so downstream adapters never infer relation authority from
	// endpoint identity. Context-plane edges do not require these fields.
	relationAuthority?: #SemanticAuthorityRef
	admittedSnapshot?:  #AdmittedDomainSnapshotRef
})

#ProjectionValue: string | number | bool | null

#ProjectionCell: close({
	field: #NonEmptyString
	value: #ProjectionValue
})

#ProjectionRow: close({
	id:    #NonEmptyString
	cells: [#ProjectionCell, ...#ProjectionCell]
})

#ProjectionPoint: close({
	series:     #NonEmptyString
	x:          #ProjectionValue
	y:          #ProjectionValue
	provenance: [#NonEmptyString, ...#NonEmptyString]
})

#ProjectionResult: close({
	apiVersion:   #WorkbookSchema
	kind:         "ProjectionResult"
	viewID:       #NonEmptyString
	presentation: #PresentationKind
	snapshot:     #SHA256
	subject:      #SemanticRef
	nodes:        [...#ProjectionNode]
	edges:        [...#ProjectionEdge]
	rows:         [...#ProjectionRow]
	points:       [...#ProjectionPoint]
	provenance:   [#NonEmptyString, ...#NonEmptyString]
})

#InspectionViewResult: close({
	apiVersion:   #WorkbookSchema
	kind:         "InspectionViewResult"
	viewID:       #NonEmptyString
	presentation: "inspection"
	snapshot:     #SHA256
	subject:      #SemanticRef
	binding:      #NonEmptyString
	inspection:   #InspectionResult
	provenance:   [#NonEmptyString, ...#NonEmptyString]
})

#WorkbookViewResult: #ProjectionResult | #InspectionViewResult

#WorkbookCapabilityGap: close({
	kind:         "workbook-capability-gap"
	viewID:       #NonEmptyString
	presentation: #PresentationKind
	description:  #NonEmptyString
})
