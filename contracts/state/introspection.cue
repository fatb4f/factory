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

#PythonModelNodeKind:
	"type" |
	"field"

#PythonModelNode: close({
	id:            #NonEmptyString
	space:         "python"
	kind:          #PythonModelNodeKind
	name:          #NonEmptyString
	qualifiedName: #NonEmptyString
	source:        #NonEmptyString
	cueNode?:      #NonEmptyString
	semanticSpace?: #NonEmptyString
	annotation?:   #NonEmptyString
	required?:     bool
})

#PythonModelEdgeRelation:
	"projects-from" |
	"contains" |
	"relates-to"

#PythonModelEdge: close({
	id:          #NonEmptyString
	relation:    #PythonModelEdgeRelation
	label?:      #NonEmptyString
	source:      #NonEmptyString
	target:      #NonEmptyString
	cardinality?: "one" | "many"
	basis:       [#NonEmptyString, ...#NonEmptyString]
})

#PythonModelProjection: close({
	apiVersion:     #IntrospectionSchema
	kind:           "PythonModelProjection"
	sourceCueNodes: [#NonEmptyString, ...#NonEmptyString]
	nodes:          [#PythonModelNode, ...#PythonModelNode]
	edges:          [...#PythonModelEdge]
	digest:         #SHA256
})
