package state

#IntrospectionSchema: "factory.introspection/v1"

#IntrospectionSpace:
	"cue" |
	"python" |
	"analytics" |
	"render"

#ModelSourceRef: close({
	path:      #NonEmptyString
	lineStart: int & >=1
	lineEnd:   int & >=lineStart
	digest:    #SHA256
})

#LogicalModelNodeKind:
	"package" |
	"import" |
	"definition" |
	"field" |
	"external-definition"

#LogicalModelNode: close({
	id:            #NonEmptyString
	space:         "cue"
	kind:          #LogicalModelNodeKind
	name:          #NonEmptyString
	qualifiedName: #NonEmptyString
	required?:     bool
	expressions?:  [...#NonEmptyString]
	sources:       [...#ModelSourceRef]
})

#LogicalModelEdgeRelation:
	"contains" |
	"imports" |
	"references" |
	"conjoins"

#LogicalModelEdge: close({
	id:       #NonEmptyString
	relation: #LogicalModelEdgeRelation
	source:   #NonEmptyString
	target:   #NonEmptyString
	basis:    [#ModelSourceRef, ...#ModelSourceRef]
})

#LogicalModelFile: close({
	path:    #NonEmptyString
	package: #NonEmptyString
	digest:  #SHA256
})

#LogicalModelProjection: close({
	apiVersion: #IntrospectionSchema
	kind:       "LogicalModelProjection"
	repository: #NonEmptyString
	revision:   #NonEmptyString
	packages:   [#NonEmptyString, ...#NonEmptyString]
	files:      [#LogicalModelFile, ...#LogicalModelFile]
	nodes:      [#LogicalModelNode, ...#LogicalModelNode]
	edges:      [...#LogicalModelEdge]
	digest:     #SHA256
})
