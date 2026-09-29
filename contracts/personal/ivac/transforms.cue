package ivac

import state "github.com/fatb4f/factory/contracts/state"

#TransformID: string & !=""
#IndexID: string & !=""

#ProjectionRelationID:
	"evidenceArtifacts" |
	"findings" |
	"findingEvidence" |
	"observations" |
	"observationEvidence" |
	"episodes" |
	"episodeObservations" |
	"episodeEvidence" |
	"capacities" |
	"capacityEvidence" |
	"capacitySupport" |
	"interventions" |
	"interventionEvidence" |
	"clinicalRelations" |
	"relationEvidence" |
	"subjectProfiles" |
	"profileObservations" |
	"profileEpisodes" |
	"profileCapacities" |
	"profileInterventions" |
	"profileRelations" |
	"graphEdges" |
	"graphIndices"

#GraphEdgeBinding: close({
	sourceRelation: #ProjectionRelationID
	edgeClass:      #GraphEdgeClass

	subjectKindField?: string & !=""
	subjectKindValue?: string & !=""
	subjectIDField:    string & !=""

	predicateField?: string & !=""
	predicateValue?: string & !=""

	objectKindField?: string & !=""
	objectKindValue?: string & !=""
	objectIDField:    string & !=""

	assertionModeField?: string & !=""
	attributedByField?: string & !=""
	temporalStatusField?: string & !=""
	temporalStartField?:  string & !=""
	temporalEndField?:    string & !=""
})

graphEdgeBindings: close({
	clinicalRelations: #GraphEdgeBinding & {
		sourceRelation:        "clinicalRelations"
		edgeClass:             "clinical"
		subjectKindField:      "subjectKind"
		subjectIDField:        "subjectID"
		predicateField:        "predicate"
		objectKindField:       "objectKind"
		objectIDField:         "objectID"
		assertionModeField:    "assertionMode"
		attributedByField:     "attributedByID"
		temporalStatusField:   "temporalStatus"
		temporalStartField:    "temporalStart"
		temporalEndField:      "temporalEnd"
	}
	episodeObservations: #GraphEdgeBinding & {
		sourceRelation:   "episodeObservations"
		edgeClass:        "membership"
		subjectKindValue: "episode"
		subjectIDField:   "episodeID"
		predicateValue:   "contains-observation"
		objectKindValue:  "observation"
		objectIDField:    "observationID"
	}
	observationEvidence: #GraphEdgeBinding & {
		sourceRelation:   "observationEvidence"
		edgeClass:        "evidence"
		subjectKindValue: "observation"
		subjectIDField:   "observationID"
		predicateValue:   "supported-by"
		objectKindValue:  "evidence-artifact"
		objectIDField:    "evidenceID"
	}
	episodeEvidence: #GraphEdgeBinding & {
		sourceRelation:   "episodeEvidence"
		edgeClass:        "evidence"
		subjectKindValue: "episode"
		subjectIDField:   "episodeID"
		predicateValue:   "supported-by"
		objectKindValue:  "evidence-artifact"
		objectIDField:    "evidenceID"
	}
	capacityEvidence: #GraphEdgeBinding & {
		sourceRelation:   "capacityEvidence"
		edgeClass:        "evidence"
		subjectKindValue: "capacity"
		subjectIDField:   "capacityID"
		predicateValue:   "supported-by"
		objectKindValue:  "evidence-artifact"
		objectIDField:    "evidenceID"
	}
	interventionEvidence: #GraphEdgeBinding & {
		sourceRelation:   "interventionEvidence"
		edgeClass:        "evidence"
		subjectKindValue: "intervention"
		subjectIDField:   "interventionID"
		predicateValue:   "supported-by"
		objectKindValue:  "evidence-artifact"
		objectIDField:    "evidenceID"
	}
	relationEvidence: #GraphEdgeBinding & {
		sourceRelation:   "relationEvidence"
		edgeClass:        "evidence"
		subjectKindValue: "clinical-relation"
		subjectIDField:   "relationID"
		predicateValue:   "supported-by"
		objectKindValue:  "evidence-artifact"
		objectIDField:    "evidenceID"
	}
	capacitySupport: #GraphEdgeBinding & {
		sourceRelation:   "capacitySupport"
		edgeClass:        "support"
		subjectKindValue: "capacity"
		subjectIDField:   "capacityID"
		predicateValue:   "requires-support"
		objectKindValue:  "intervention"
		objectIDField:    "interventionID"
	}
	findingEvidence: #GraphEdgeBinding & {
		sourceRelation:   "findingEvidence"
		edgeClass:        "review"
		subjectKindValue: "finding"
		subjectIDField:   "findingID"
		predicateValue:   "supported-by"
		objectKindValue:  "evidence-artifact"
		objectIDField:    "evidenceID"
	}
})

#IbisLoweringContract: close({
	target:             "ibis"
	ir:                 "factory.analytics-ir/v1"
	materialization:    "lazy"
	physicalIndex:      false
	requiredOperations: [state.#OperationKind, ...state.#OperationKind]
})

#TransformParameter: close({
	name:     string & !=""
	type:     "string" | "int" | "timestamp" | "duration" | "predicate" | "node-kind"
	required: bool
})

#EdgeTransformPrimitive:
	"select" |
	"reverse" |
	"compose" |
	"bounded-expand" |
	"deduplicate"

#EdgeSelector: close({
	edgeClasses?:     [#GraphEdgeClass, ...#GraphEdgeClass]
	predicates?:      [string & !="", ...(string & !="")]
	subjectKinds?:    [string & !="", ...(string & !="")]
	objectKinds?:     [string & !="", ...(string & !="")]
	assertionModes?:  [#RelationAssertionMode, ...#RelationAssertionMode]
})

#EdgeTransform: close({
	id:        #TransformID
	primitive: #EdgeTransformPrimitive
	input:     "graphEdges"
	output:    string & !=""
	selector?: #EdgeSelector
	parameters?: [...#TransformParameter]
	maxDepth?: int & >=1 & <=8
	lowering: #IbisLoweringContract
})

#EdgeTransformRef: close({id: #TransformID})

#IndexTransformPrimitive:
	"build" |
	"probe" |
	"union" |
	"intersect" |
	"difference"

#IndexKeySpec: close({
	name:   string & !=""
	fields: [string & !="", ...(string & !="")]
})

#IndexMemberSpec: close({
	kindField?: string & !=""
	kindValue?: string & !=""
	idField:    string & !=""
	edgeIDField?: string & !=""
})

#IndexTransform: close({
	id:        #IndexID
	primitive: #IndexTransformPrimitive
	inputs:    [string & !="", ...(string & !="")]
	output:    string & !=""
	key?:      #IndexKeySpec
	member?:   #IndexMemberSpec
	parameters?: [...#TransformParameter]
	lowering: #IbisLoweringContract
})

#IndexTransformRef: close({id: #IndexID})

#IndexSnapshotRef: close({
	index: #IndexTransformRef
	digest: string & =~"^sha256:[0-9a-f]{64}$"
})

edgeTransforms: close({
	"temporal-window": #EdgeTransform & {
		id:        "temporal-window"
		primitive: "select"
		input:     "graphEdges"
		output:    "graphEdges.temporal-window"
		parameters: [
			{name: "start", type: "timestamp", required: false},
			{name: "end", type: "timestamp", required: false},
		]
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "project"]
		}
	}
	"episode-membership": #EdgeTransform & {
		id:        "episode-membership"
		primitive: "select"
		input:     "graphEdges"
		output:    "graphEdges.episode-membership"
		selector: {edgeClasses: ["membership"]}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "project"]
		}
	}
	"capacity-impact": #EdgeTransform & {
		id:        "capacity-impact"
		primitive: "select"
		input:     "graphEdges"
		output:    "graphEdges.capacity-impact"
		selector: {predicates: ["impairs", "requires-support-for", "requires-support"]}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "project", "distinct"]
		}
	}
	"contradiction-surface": #EdgeTransform & {
		id:        "contradiction-surface"
		primitive: "select"
		input:     "graphEdges"
		output:    "graphEdges.contradictions"
		selector: {predicates: ["contradicts", "refines"]}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "project", "distinct"]
		}
	}
	"causal-attribution-only": #EdgeTransform & {
		id:        "causal-attribution-only"
		primitive: "select"
		input:     "graphEdges"
		output:    "graphEdges.causal-attributed"
		selector: {
			predicates: ["impairs", "resulted-in", "triggered-by"]
			assertionModes: ["clinician-attributed"]
		}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "project", "distinct"]
		}
	}
	"evidence-neighborhood": #EdgeTransform & {
		id:        "evidence-neighborhood"
		primitive: "bounded-expand"
		input:     "graphEdges"
		output:    "graphEdges.evidence-neighborhood"
		selector: {edgeClasses: ["clinical", "membership", "evidence", "support"]}
		parameters: [{name: "roots", type: "string", required: true}]
		maxDepth: 4
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "join", "union", "distinct", "project"]
		}
	}
	"assessment-input-surface": #EdgeTransform & {
		id:        "assessment-input-surface"
		primitive: "bounded-expand"
		input:     "graphEdges"
		output:    "graphEdges.assessment-input"
		selector: {edgeClasses: ["clinical", "membership", "evidence", "support", "review"]}
		parameters: [{name: "roots", type: "string", required: true}]
		maxDepth: 4
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "join", "union", "distinct", "project"]
		}
	}
	"assessment-evidence-links": #EdgeTransform & {
		id:        "assessment-evidence-links"
		primitive: "select"
		input:     "graphEdges"
		output:    "graphEdges.assessment-evidence"
		selector: {
			edgeClasses: ["evidence", "review"]
			objectKinds: ["evidence-artifact"]
		}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "project", "distinct"]
		}
	}

})

indexTransforms: close({
	"edge-by-subject": #IndexTransform & {
		id:        "edge-by-subject"
		primitive: "build"
		inputs:    ["graphEdges"]
		output:    "graphIndices.edge-by-subject"
		key:       {name: "subject", fields: ["subjectKind", "subjectID"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["project", "distinct"]
		}
	}
	"edge-by-object": #IndexTransform & {
		id:        "edge-by-object"
		primitive: "build"
		inputs:    ["graphEdges"]
		output:    "graphIndices.edge-by-object"
		key:       {name: "object", fields: ["objectKind", "objectID"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["project", "distinct"]
		}
	}
	"edge-by-predicate": #IndexTransform & {
		id:        "edge-by-predicate"
		primitive: "build"
		inputs:    ["graphEdges"]
		output:    "graphIndices.edge-by-predicate"
		key:       {name: "predicate", fields: ["predicate"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["project", "distinct"]
		}
	}
	"edge-by-evidence": #IndexTransform & {
		id:        "edge-by-evidence"
		primitive: "build"
		inputs:    ["graphEdges"]
		output:    "graphIndices.edge-by-evidence"
		key:       {name: "evidence", fields: ["objectID"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		parameters: [{name: "edgeClass", type: "string", required: true}]
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["filter", "project", "distinct"]
		}
	}
	"assessment-by-subject": #IndexTransform & {
		id:        "assessment-by-subject"
		primitive: "build"
		inputs:    ["graphEdges.assessment-input"]
		output:    "graphIndices.assessment-by-subject"
		key:       {name: "subject", fields: ["subjectKind", "subjectID"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["project", "distinct"]
		}
	}
	"assessment-by-object": #IndexTransform & {
		id:        "assessment-by-object"
		primitive: "build"
		inputs:    ["graphEdges.assessment-input"]
		output:    "graphIndices.assessment-by-object"
		key:       {name: "object", fields: ["objectKind", "objectID"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["project", "distinct"]
		}
	}
	"assessment-by-predicate": #IndexTransform & {
		id:        "assessment-by-predicate"
		primitive: "build"
		inputs:    ["graphEdges.assessment-input"]
		output:    "graphIndices.assessment-by-predicate"
		key:       {name: "predicate", fields: ["predicate"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["project", "distinct"]
		}
	}
	"assessment-by-evidence": #IndexTransform & {
		id:        "assessment-by-evidence"
		primitive: "build"
		inputs:    ["graphEdges.assessment-evidence"]
		output:    "graphIndices.assessment-by-evidence"
		key:       {name: "evidence", fields: ["objectID"]}
		member:    {kindValue: "edge", idField: "edgeID", edgeIDField: "edgeID"}
		lowering: {
			target: "ibis"
			ir: "factory.analytics-ir/v1"
			materialization: "lazy"
			physicalIndex: false
			requiredOperations: ["project", "distinct"]
		}
	}

})
