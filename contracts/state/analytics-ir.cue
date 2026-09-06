package state

#AnalyticsIRSchema: "factory.analytics-ir/v1"

#AnalyticalAdmissibility: close({
	state:     "admitted"
	authority: #NonEmptyString
	basis:     [#NonEmptyString, ...#NonEmptyString]
})

#AnalyticalSourceRef: close({
	id:            #NonEmptyString
	snapshotDigest: #SHA256
	semanticRef?:  #SemanticRef
	provenance:    [#NonEmptyString, ...#NonEmptyString]
	admissibility: #AnalyticalAdmissibility
})

#AnalyticalGrain: close({
	keys: [#NonEmptyString, ...#NonEmptyString]
	unit: #NonEmptyString
})

#OperationKind:
	"project" |
	"filter" |
	"join" |
	"group" |
	"aggregate" |
	"grain-change" |
	"order" |
	"window" |
	"derive"

#ProjectOperation: close({
	kind:   "project"
	fields: [#NonEmptyString, ...#NonEmptyString]
})

#FilterOperation: close({
	kind:      "filter"
	predicate: #NonEmptyString
	basis:     [#NonEmptyString, ...#NonEmptyString]
})

#JoinKey: close({
	left:  #NonEmptyString
	right: #NonEmptyString
})

#JoinOperation: close({
	kind:     "join"
	joinType: "inner" | "left" | "right" | "full"
	right:    #AnalyticalSourceRef
	on:       [#JoinKey, ...#JoinKey]
})

#GroupOperation: close({
	kind: "group"
	keys: [#NonEmptyString, ...#NonEmptyString]
})

#AggregateMeasure: close({
	id:    #NonEmptyString
	op:    "count" | "sum" | "min" | "max" | "mean"
	field?: #NonEmptyString
})

#AggregateOperation: close({
	kind:     "aggregate"
	measures: [#AggregateMeasure, ...#AggregateMeasure]
})

#GrainChangeOperation: close({
	kind:   "grain-change"
	output: #AnalyticalGrain
})

#OrderKey: close({
	field:     #NonEmptyString
	direction: "asc" | "desc"
})

#OrderOperation: close({
	kind: "order"
	by:   [#OrderKey, ...#OrderKey]
})

#WindowFunction: close({
	id:       #NonEmptyString
	function: #NonEmptyString
	field?:   #NonEmptyString
})

#WindowOperation: close({
	kind:        "window"
	partitionBy: [...#NonEmptyString]
	orderBy:    [#OrderKey, ...#OrderKey]
	functions:  [#WindowFunction, ...#WindowFunction]
})

#DerivedExpression: close({
	id:         #NonEmptyString
	expression: #NonEmptyString
	basis:      [#NonEmptyString, ...#NonEmptyString]
})

#DeriveOperation: close({
	kind:        "derive"
	expressions: [#DerivedExpression, ...#DerivedExpression]
})

#RelationalOperation:
	#ProjectOperation |
	#FilterOperation |
	#JoinOperation |
	#GroupOperation |
	#AggregateOperation |
	#GrainChangeOperation |
	#OrderOperation |
	#WindowOperation |
	#DeriveOperation

#AnalyticalRequest: close({
	apiVersion: #AnalyticsIRSchema
	kind:       "AnalyticalRequest"
	id:         #NonEmptyString
	source:     #AnalyticalSourceRef
	grain:      #AnalyticalGrain
	operations: [#RelationalOperation, ...#RelationalOperation]
})

#PlanProvenance: close({
	authority: #NonEmptyString
	basis:     [#NonEmptyString, ...#NonEmptyString]
})

#RelationalPlan: close({
	apiVersion: #AnalyticsIRSchema
	kind:       "RelationalPlan"
	id:         #NonEmptyString
	request:    #AnalyticalRequest
	steps:      [#RelationalOperation, ...#RelationalOperation]
	outputGrain: #AnalyticalGrain
	provenance:  #PlanProvenance
})

#ExecutionTargetCapability: close({
	id:                  #NonEmptyString
	capabilityVersion:   #NonEmptyString
	transport:           "logical-plan" | "dataframe" | "sql"
	supportedOperations: [#OperationKind, ...#OperationKind]
})

#AnalyticsCapabilityGap: close({
	kind:      "capability-gap"
	request:   #NonEmptyString
	target:    #NonEmptyString
	operation: #OperationKind
	reason:    #NonEmptyString
})
