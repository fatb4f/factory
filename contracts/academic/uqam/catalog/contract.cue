package uqamcatalog

import state "github.com/fatb4f/factory/contracts/state"

#TaskID:   "academic.uqam.catalog"
#SchemaID: "uqam-catalog/v1"
#ScopeID:  "uqam-student-community-academic-catalog"

#RequiredSourceID:
	"uqam-student-services" |
	"uqam-student-life" |
	"uqam-student-associations" |
	"uqam-student-groups" |
	"uqam-student-cafes" |
	"uqam-student-media"

#GroupCategoryID:
	"community" |
	"entrepreneurship-management" |
	"student-media" |
	"multicultural" |
	"science-technology" |
	"sports" |
	"cultural"

#CompleteAcquisitionCoverage: close({
	complete: true
	observed_sources: [
		"uqam-student-services",
		"uqam-student-life",
		"uqam-student-associations",
		"uqam-student-groups",
		"uqam-student-cafes",
		"uqam-student-media",
	]
	traversed_group_categories: [
		"community",
		"entrepreneurship-management",
		"student-media",
		"multicultural",
		"science-technology",
		"sports",
		"cultural",
	]
	gaps: []
})

#IncompleteAcquisitionCoverage: close({
	complete: false
	observed_sources:           [...#RequiredSourceID]
	traversed_group_categories: [...#GroupCategoryID]
	gaps:                       [...#NonEmptyString] & [_, ...]
})

#AcquisitionCoverage:
	#CompleteAcquisitionCoverage |
	#IncompleteAcquisitionCoverage

#CatalogRunReference: state.#RunReference & {
	task:   #TaskID
	scope:  #ScopeID
	schema: #SchemaID
}

#CatalogBaselinePointer: state.#BaselinePointer & {
	task:   #TaskID
	scope:  #ScopeID
	schema: #SchemaID
	baseline: {run: #CatalogRunReference}
}

#EntityChangeKind:
	"identity" |
	"status" |
	"category" |
	"details" |
	"location" |
	"audience" |
	"evidence"

#RelationChangeKind: "topology" | "details" | "evidence"

#ChangedEntity: close({
	id:      #EntityID
	changes: [...#EntityChangeKind] & [_, ...]
})

#ChangedRelation: close({
	id:      #RelationID
	changes: [...#RelationChangeKind] & [_, ...]
})

#Delta: close({
	added_entity_ids:     [...#EntityID]
	changed_entities:     [...#ChangedEntity]
	removed_entity_ids:   [...#EntityID]
	added_relation_ids:   [...#RelationID]
	changed_relations:    [...#ChangedRelation]
	removed_relation_ids: [...#RelationID]
})

#NoChangeDelta: #Delta & {
	added_entity_ids:     []
	changed_entities:     []
	removed_entity_ids:   []
	added_relation_ids:   []
	changed_relations:    []
	removed_relation_ids: []
}

#AddedEntityDelta: #Delta & {added_entity_ids: [...#EntityID] & [_, ...]}
#ChangedEntityDelta: #Delta & {changed_entities: [...#ChangedEntity] & [_, ...]}
#RemovedEntityDelta: #Delta & {removed_entity_ids: [...#EntityID] & [_, ...]}
#AddedRelationDelta: #Delta & {added_relation_ids: [...#RelationID] & [_, ...]}
#ChangedRelationDelta: #Delta & {changed_relations: [...#ChangedRelation] & [_, ...]}
#RemovedRelationDelta: #Delta & {removed_relation_ids: [...#RelationID] & [_, ...]}

#ChangedDelta:
	#AddedEntityDelta |
	#ChangedEntityDelta |
	#RemovedEntityDelta |
	#AddedRelationDelta |
	#ChangedRelationDelta |
	#RemovedRelationDelta

#Outcome:
	"baseline_established" |
	"no_change" |
	"catalog_changed" |
	"source_gap" |
	"comparison_gap" |
	"state_conflict"

#Decision: close({
	outcome:              #Outcome
	baseline_action:      "advance" | "hold"
	changed_entity_ids:   [...#EntityID]
	changed_relation_ids: [...#RelationID]
	reason:               #NonEmptyString
})

#PointerAdvance: close({
	action: "advance"
	transition: state.#BaselineAdvance & {
		task:   #TaskID
		scope:  #ScopeID
		schema: #SchemaID
		next:   #CatalogBaselinePointer
	}
	_generationInvariant: transition.next.generation & (transition.expected_generation + 1)
})

#PointerHold: close({
	action:              "hold"
	reason:              "source_gap" | "comparison_gap"
	expected_generation: int & >=0
})

#StateConflictHold: close({
	action:              "hold"
	reason:              "cas_conflict"
	expected_generation: int & >=0
	observed_generation: int & >=1
	_generationsDiffer:  (observed_generation != expected_generation) & true
})

#RunManifest: close({
	apiVersion:        "factory.uqam-catalog.run-bundle/v1"
	kind:              "UQAMCatalogRunBundle"
	run_id:            state.#RunID
	task_id:           #TaskID
	schema:            #SchemaID
	observed_at:       #NonEmptyString
	normalized_digest: state.#SHA256
	decision_digest:   state.#SHA256
	export_unit:       "directory"
	normalized_path:   #NonEmptyString
	decision_path:     #NonEmptyString
})

#BootstrapDecisionArtifact: close({
	currentRun:  #CatalogRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: close({
		comparison_state: state.#BootstrapComparisonState & {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
	})
	decision: #Decision & {
		outcome:              "baseline_established"
		baseline_action:      "advance"
		changed_entity_ids:   []
		changed_relation_ids: []
	}
	pointer: #PointerAdvance & {
		transition: {
			expected_generation: 0
			next: {baseline: {run: currentRun}}
		}
	}
})

#ComparableNoChangeDecisionArtifact: close({
	currentRun:  #CatalogRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: close({
		comparison_state: state.#ComparableComparisonState & {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
		delta: #NoChangeDelta
	})
	decision: #Decision & {
		outcome:              "no_change"
		baseline_action:      "advance"
		changed_entity_ids:   []
		changed_relation_ids: []
	}
	pointer: #PointerAdvance & {
		transition: {
			expected_generation: int & >=1
			next: {baseline: {run: currentRun}}
		}
	}
})

#ComparableChangedDecisionArtifact: close({
	currentRun:  #CatalogRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: close({
		comparison_state: state.#ComparableComparisonState & {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
		delta: #ChangedDelta
	})
	decision: #Decision & {
		outcome:         "catalog_changed"
		baseline_action: "advance"
	}
	pointer: #PointerAdvance & {
		transition: {
			expected_generation: int & >=1
			next: {baseline: {run: currentRun}}
		}
	}
})

#SourceGapDecisionArtifact: close({
	currentRun:  #CatalogRunReference
	acquisition: #IncompleteAcquisitionCoverage
	decision: #Decision & {
		outcome:              "source_gap"
		baseline_action:      "hold"
		changed_entity_ids:   []
		changed_relation_ids: []
	}
	pointer: #PointerHold & {reason: "source_gap"}
})

#ComparisonGapDecisionArtifact: close({
	currentRun:  #CatalogRunReference
	acquisition: #CompleteAcquisitionCoverage
	comparison: close({
		comparison_state: state.#InvalidatedComparisonState & {
			task:    #TaskID
			scope:   #ScopeID
			schema:  #SchemaID
			current: currentRun
		}
	})
	decision: #Decision & {
		outcome:              "comparison_gap"
		baseline_action:      "hold"
		changed_entity_ids:   []
		changed_relation_ids: []
	}
	pointer: #PointerHold & {reason: "comparison_gap"}
})

#StateConflictDecisionArtifact: close({
	currentRun:  #CatalogRunReference
	acquisition: #CompleteAcquisitionCoverage
	decision: #Decision & {
		outcome:              "state_conflict"
		baseline_action:      "hold"
		changed_entity_ids:   []
		changed_relation_ids: []
	}
	pointer: #StateConflictHold
})

#DecisionArtifact:
	#BootstrapDecisionArtifact |
	#ComparableNoChangeDecisionArtifact |
	#ComparableChangedDecisionArtifact |
	#SourceGapDecisionArtifact |
	#ComparisonGapDecisionArtifact |
	#StateConflictDecisionArtifact

#AuthorityBoundary: close({
	semantic:        "contracts/academic/uqam/catalog"
	procedure:       "academic/uqam/.agents/catalog"
	runs:            "academic/uqam/catalog/runs"
	baselinePointer: "academic/uqam/catalog/state/admitted-baseline.json"
})

#Contract: close({
	id:     #TaskID
	kind:   "academic-institution-catalog"
	schema: #SchemaID
	scope:  #ScopeID

	authority: #AuthorityBoundary

	identity: close({
		entity:   "source-defined-id-else-canonical-kind-and-name"
		relation: "explicit-source-qualified-edge"
	})

	sources: close({
		required: [
			"uqam-student-services",
			"uqam-student-life",
			"uqam-student-associations",
			"uqam-student-groups",
			"uqam-student-cafes",
			"uqam-student-media",
		]
		requiredGroupCategories: [
			"community",
			"entrepreneurship-management",
			"student-media",
			"multicultural",
			"science-technology",
			"sports",
			"cultural",
		]
		priorityOptionalClasses: [
			"uqam-academic-unit",
			"uqam-student-success-service",
			"uqam-digital-platform",
			"uqam-library",
			"uqam-sport",
			"uqam-funding",
			"uqam-accessibility",
			"uqam-group-category",
		]
	})

	graph: close({
		relations: [
			"part-of",
			"operated-by",
			"supported-by",
			"represents",
			"offers",
			"serves",
			"located-at",
			"publishes",
			"organizes",
			"discoverable-at",
		]
		requireExplicitEvidence: true
		noNameBasedInference:    true
	})

	publication: close({
		immutableRuns: true
		pointerUpdate: "compare-and-swap"
	})
})

contract: #Contract & {
	id:     "academic.uqam.catalog"
	kind:   "academic-institution-catalog"
	schema: "uqam-catalog/v1"
	scope:  "uqam-student-community-academic-catalog"
	authority: {
		semantic:        "contracts/academic/uqam/catalog"
		procedure:       "academic/uqam/.agents/catalog"
		runs:            "academic/uqam/catalog/runs"
		baselinePointer: "academic/uqam/catalog/state/admitted-baseline.json"
	}
	identity: {
		entity:   "source-defined-id-else-canonical-kind-and-name"
		relation: "explicit-source-qualified-edge"
	}
	sources: {
		required: [
			"uqam-student-services",
			"uqam-student-life",
			"uqam-student-associations",
			"uqam-student-groups",
			"uqam-student-cafes",
			"uqam-student-media",
		]
		requiredGroupCategories: [
			"community",
			"entrepreneurship-management",
			"student-media",
			"multicultural",
			"science-technology",
			"sports",
			"cultural",
		]
		priorityOptionalClasses: [
			"uqam-academic-unit",
			"uqam-student-success-service",
			"uqam-digital-platform",
			"uqam-library",
			"uqam-sport",
			"uqam-funding",
			"uqam-accessibility",
			"uqam-group-category",
		]
	}
	graph: {
		relations: [
			"part-of",
			"operated-by",
			"supported-by",
			"represents",
			"offers",
			"serves",
			"located-at",
			"publishes",
			"organizes",
			"discoverable-at",
		]
		requireExplicitEvidence: true
		noNameBasedInference:    true
	}
	publication: {
		immutableRuns: true
		pointerUpdate: "compare-and-swap"
	}
}
