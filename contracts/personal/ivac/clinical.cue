package ivac

#TemporalPrecision:
	"exact" |
	"minute" |
	"hour" |
	"day" |
	"month" |
	"year" |
	"approximate" |
	"unknown"

#TemporalPosition: close({
	value:     string & !=""
	precision: #TemporalPrecision
})

#TemporalExtentStatus: "instant" | "bounded" | "ongoing" | "unknown"

#TemporalExtent: close({
	status: #TemporalExtentStatus
	start?: #TemporalPosition
	end?:   #TemporalPosition

	if status == "instant" {
		start: #TemporalPosition
	}
	if status == "bounded" {
		start: #TemporalPosition
		end:   #TemporalPosition
	}
	if status == "ongoing" {
		start: #TemporalPosition
	}
})

#TemporalSelector: close({
	mode: "all" | "as-of" | "window"
	asOf?: #TemporalPosition
	window?: close({
		start?: #TemporalPosition
		end?:   #TemporalPosition
	})

	if mode == "as-of" {
		asOf: #TemporalPosition
	}
	if mode == "window" {
		window: close({
			start?: #TemporalPosition
			end?:   #TemporalPosition
		})
	}
})

#EvidenceWorldID: #ID
#ObservationID: #ID
#EpisodeID: #ID
#CapacityID: #ID
#InterventionID: #ID
#ClinicalRelationID: #ID
#SubjectProfileID: #ID

#EvidenceWorldRef: close({id: #EvidenceWorldID})
#ObservationRef: close({id: #ObservationID})
#EpisodeRef: close({id: #EpisodeID})
#CapacityRef: close({id: #CapacityID})
#InterventionRef: close({id: #InterventionID})
#ClinicalRelationRef: close({id: #ClinicalRelationID})
#SubjectProfileRef: close({id: #SubjectProfileID})

#AssertionBasis:
	"source-documented" |
	"clinician-assessment" |
	"retrospective-clinician-history" |
	"patient-reported" |
	"derived-longitudinal-inference"

#ClinicalProvenance: close({
	basis:       #AssertionBasis
	evidence:    [#EvidenceArtifactRef, ...#EvidenceArtifactRef]
	assertedBy?: #ActorRef
	note?:       string
})

#EvidenceWorld: close({
	id:      #EvidenceWorldID
	subject: #ActorRef
	evidence: [#EvidenceArtifactRef, ...#EvidenceArtifactRef]
	observations:  [string]: #ClinicalObservation
	episodes:      [string]: #ClinicalEpisode
	capacities:    [string]: #CapacityAssessment
	interventions: [string]: #ClinicalIntervention
	relations:     [string]: #ClinicalRelation
})

#ObservationKind:
	"diagnosis" |
	"symptom" |
	"functional-state" |
	"functional-failure" |
	"behavior" |
	"substance-use" |
	"sleep" |
	"treatment-response" |
	"objective-test" |
	"risk-event" |
	"support-dependency" |
	"context" |
	"other"

#ClinicalValue:
	close({
		kind:  "boolean"
		value: bool
	}) |
	close({
		kind:  "number"
		value: number
		unit?: string
	}) |
	close({
		kind:  "categorical"
		value: string & !=""
	}) |
	close({
		kind:  "text"
		value: string & !=""
	})

#ClinicalObservation: close({
	id:              #ObservationID
	kind:            "clinical-observation"
	observationKind: #ObservationKind
	subject:         #ActorRef
	concept:         string & !=""
	value:           #ClinicalValue
	temporal:        #TemporalExtent
	provenance:      #ClinicalProvenance
})

#EpisodeKind:
	"trauma-reactivation" |
	"dissociative" |
	"substance-relapse" |
	"sleep-disruption" |
	"academic-failure" |
	"occupational-failure" |
	"treatment-failure" |
	"medical-event" |
	"administrative-failure" |
	"mixed" |
	"other"

#ClinicalEpisode: close({
	id:          #EpisodeID
	kind:        "clinical-episode"
	episodeKind: #EpisodeKind
	subject:     #ActorRef
	label:       string & !=""
	temporal:    #TemporalExtent
	members:     [#ObservationRef, ...#ObservationRef]
	provenance:  #ClinicalProvenance
})

#CapacityDomain:
	"basic-needs" |
	"self-care" |
	"administrative" |
	"treatment-management" |
	"education" |
	"occupation" |
	"community-obligation" |
	"judgment" |
	"safety" |
	"substance-regulation" |
	"sleep-regulation" |
	"interpersonal" |
	"cognitive" |
	"motor" |
	"other"

#CapacityState: "preserved" | "impaired" | "unreliable" | "not-demonstrated" | "unknown"

#CapacityAssessment: close({
	id:         #CapacityID
	kind:       "capacity-assessment"
	subject:    #ActorRef
	domain:     #CapacityDomain
	label:      string & !=""
	state:      #CapacityState
	temporal:   #TemporalExtent
	support?:   [...#InterventionRef]
	provenance: #ClinicalProvenance
})

#InterventionKind:
	"psychotherapy" |
	"occupational-therapy" |
	"addiction-treatment" |
	"medical-treatment" |
	"medication" |
	"hospitalization" |
	"accommodation" |
	"human-support" |
	"harm-reduction" |
	"self-management" |
	"other"

#InterventionState: "planned" | "active" | "completed" | "interrupted" | "failed" | "unknown"

#ClinicalIntervention: close({
	id:               #InterventionID
	kind:             "clinical-intervention"
	interventionKind: #InterventionKind
	subject:          #ActorRef
	label:            string & !=""
	state:            #InterventionState
	provider?:        #ActorRef
	temporal:         #TemporalExtent
	provenance:       #ClinicalProvenance
})

#ClinicalNodeKind:
	"evidence-artifact" |
	"finding" |
	"claim-axis" |
	"observation" |
	"episode" |
	"capacity" |
	"intervention" |
	"subject-profile"

#ClinicalNodeRef: close({
	kind: #ClinicalNodeKind
	id:   #ID
})

#ClinicalPredicate:
	"documents" |
	"member-of" |
	"precedes" |
	"overlaps" |
	"associated-with" |
	"corroborates" |
	"contradicts" |
	"refines" |
	"treated-by" |
	"supports-finding" |
	"requires-support-for" |
	"impairs" |
	"resulted-in" |
	"triggered-by"

#RelationAssertionMode:
	"source-documented" |
	"reported" |
	"derived" |
	"clinician-attributed"

#ClinicalRelation: close({
	id:            #ClinicalRelationID
	kind:          "clinical-relation"
	subject:       #ClinicalNodeRef
	predicate:     #ClinicalPredicate
	object:        #ClinicalNodeRef
	assertionMode: #RelationAssertionMode
	temporal?:     #TemporalExtent
	attributedBy?: #ActorRef
	provenance:    #ClinicalProvenance
})

#RelationTransformID:
	"temporal-window" |
	"evidence-closure" |
	"episode-membership" |
	"capacity-impact" |
	"contradiction-surface" |
	"causal-attribution-only"

#RelationTransformKind: "filter" | "closure" | "partition" | "join"

#RelationTransform: close({
	id:               #RelationTransformID
	kind:             #RelationTransformKind
	inputPredicates?: [...#ClinicalPredicate]
	inputNodeKinds?:  [...#ClinicalNodeKind]
	output:           "node-selection" | "relation-selection" | "evidence-closure"
	deterministic:    true
	authority:        "projection-only"
	description:      string & !=""
})

relationTransforms: close({
	"temporal-window": #RelationTransform & {
		id:            "temporal-window"
		kind:          "filter"
		output:        "relation-selection"
		deterministic: true
		authority:     "projection-only"
		description:   "Select records and relations admitted by an evaluation-owned temporal selector."
	}
	"evidence-closure": #RelationTransform & {
		id:              "evidence-closure"
		kind:            "closure"
		inputPredicates: ["documents", "corroborates", "contradicts", "refines", "supports-finding"]
		output:          "evidence-closure"
		deterministic:   true
		authority:       "projection-only"
		description:     "Traverse evidentiary links without changing the admission or authority state of the source records."
	}
	"episode-membership": #RelationTransform & {
		id:              "episode-membership"
		kind:            "closure"
		inputPredicates: ["member-of"]
		output:          "node-selection"
		deterministic:   true
		authority:       "projection-only"
		description:     "Expand an episode to its admitted observation members."
	}
	"capacity-impact": #RelationTransform & {
		id:              "capacity-impact"
		kind:            "filter"
		inputPredicates: ["impairs", "requires-support-for"]
		output:          "relation-selection"
		deterministic:   true
		authority:       "projection-only"
		description:     "Select admitted relations that connect observed states or episodes to functional capacity."
	}
	"contradiction-surface": #RelationTransform & {
		id:              "contradiction-surface"
		kind:            "filter"
		inputPredicates: ["contradicts", "refines"]
		output:          "relation-selection"
		deterministic:   true
		authority:       "projection-only"
		description:     "Expose conflicting or refining records for explicit evaluator reconciliation."
	}
	"causal-attribution-only": #RelationTransform & {
		id:              "causal-attribution-only"
		kind:            "filter"
		inputPredicates: ["impairs", "resulted-in", "triggered-by"]
		output:          "relation-selection"
		deterministic:   true
		authority:       "projection-only"
		description:     "Select only relations whose causal semantics require qualified clinical attribution."
	}
})

#RelationTransformRef: close({id: #RelationTransformID})

#ProfilePartition:
	"conditions" |
	"symptoms" |
	"functional-events" |
	"substance-use" |
	"sleep" |
	"objective-tests" |
	"support-dependency" |
	"context"

#ProfileProjectionPolicy: close({
	state:         "derived"
	deterministic: true
	authority:     "none"
	sourceOfTruth: "evidence-world"
})

#NormalizedSubjectProfile: close({
	id:          #SubjectProfileID
	kind:        "normalized-subject-profile"
	subject:     #ActorRef
	sourceWorld: #EvidenceWorldRef
	asOf:        #TemporalPosition
	projection:  #ProfileProjectionPolicy

	partitions: close({
		conditions:        [...#ObservationRef]
		symptoms:          [...#ObservationRef]
		functionalEvents:  [...#ObservationRef]
		substanceUse:      [...#ObservationRef]
		sleep:             [...#ObservationRef]
		objectiveTests:    [...#ObservationRef]
		supportDependency: [...#ObservationRef]
		context:           [...#ObservationRef]
	})

	episodes:      [...#EpisodeRef]
	capacities:    [...#CapacityRef]
	interventions: [...#InterventionRef]
	relations:     [...#ClinicalRelationRef]
	evidence:      [...#EvidenceArtifactRef]
})

#ProfileSelector: close({
	partitions?:         [...#ProfilePartition]
	capacityDomains?:    [...#CapacityDomain]
	episodeKinds?:       [...#EpisodeKind]
	relationPredicates?: [...#ClinicalPredicate]
	temporal:            #TemporalSelector
})

#CasePlant: close({
	review:  #Plant
	world:   #EvidenceWorld
	profile: #NormalizedSubjectProfile
})

#ValidatedCasePlant: close({
	review:  #ValidatedPlant
	world:   #EvidenceWorld
	profile: #NormalizedSubjectProfile

	_subject:        review.actors[world.subject.id] & {kind: "claimant"}
	_profileSubject: profile.subject & world.subject
	_profileWorld:   profile.sourceWorld & {id: world.id}

	_worldEvidence: [for ref in world.evidence {
		_artifact: review.evidence[ref.id]
	}]

	_observationIntegrity: [for id, observation in world.observations {
		_value: observation & {id: id, subject: world.subject}
		_evidence: [for ref in observation.provenance.evidence {
			_artifact: review.evidence[ref.id]
		}]
		if observation.provenance.assertedBy != _|_ {
			_actor: review.actors[observation.provenance.assertedBy.id]
		}
	}]

	_episodeIntegrity: [for id, episode in world.episodes {
		_value: episode & {id: id, subject: world.subject}
		_members: [for ref in episode.members {
			_observation: world.observations[ref.id]
		}]
		_evidence: [for ref in episode.provenance.evidence {
			_artifact: review.evidence[ref.id]
		}]
		if episode.provenance.assertedBy != _|_ {
			_actor: review.actors[episode.provenance.assertedBy.id]
		}
	}]

	_interventionIntegrity: [for id, intervention in world.interventions {
		_value: intervention & {id: id, subject: world.subject}
		_evidence: [for ref in intervention.provenance.evidence {
			_artifact: review.evidence[ref.id]
		}]
		if intervention.provider != _|_ {
			_provider: review.actors[intervention.provider.id]
		}
		if intervention.provenance.assertedBy != _|_ {
			_actor: review.actors[intervention.provenance.assertedBy.id]
		}
	}]

	_capacityIntegrity: [for id, capacity in world.capacities {
		_value: capacity & {id: id, subject: world.subject}
		_evidence: [for ref in capacity.provenance.evidence {
			_artifact: review.evidence[ref.id]
		}]
		if capacity.support != _|_ {
			_support: [for ref in capacity.support {
				_intervention: world.interventions[ref.id]
			}]
		}
		if capacity.provenance.assertedBy != _|_ {
			_actor: review.actors[capacity.provenance.assertedBy.id]
		}
	}]

	_relationIntegrity: [for id, relation in world.relations {
		_value: relation & {id: id}
		_evidence: [for ref in relation.provenance.evidence {
			_artifact: review.evidence[ref.id]
		}]

		if relation.provenance.assertedBy != _|_ {
			_actor: review.actors[relation.provenance.assertedBy.id]
		}
		if relation.attributedBy != _|_ {
			_attributor: review.actors[relation.attributedBy.id]
		}

		if relation.subject.kind == "evidence-artifact" {
			_subjectEvidence: review.evidence[relation.subject.id]
		}
		if relation.subject.kind == "finding" {
			_subjectFinding: review.findings[relation.subject.id]
		}
		if relation.subject.kind == "claim-axis" {
			_subjectAxis: review.axes[relation.subject.id]
		}
		if relation.subject.kind == "observation" {
			_subjectObservation: world.observations[relation.subject.id]
		}
		if relation.subject.kind == "episode" {
			_subjectEpisode: world.episodes[relation.subject.id]
		}
		if relation.subject.kind == "capacity" {
			_subjectCapacity: world.capacities[relation.subject.id]
		}
		if relation.subject.kind == "intervention" {
			_subjectIntervention: world.interventions[relation.subject.id]
		}
		if relation.subject.kind == "subject-profile" {
			_subjectProfile: profile & {id: relation.subject.id}
		}

		if relation.object.kind == "evidence-artifact" {
			_objectEvidence: review.evidence[relation.object.id]
		}
		if relation.object.kind == "finding" {
			_objectFinding: review.findings[relation.object.id]
		}
		if relation.object.kind == "claim-axis" {
			_objectAxis: review.axes[relation.object.id]
		}
		if relation.object.kind == "observation" {
			_objectObservation: world.observations[relation.object.id]
		}
		if relation.object.kind == "episode" {
			_objectEpisode: world.episodes[relation.object.id]
		}
		if relation.object.kind == "capacity" {
			_objectCapacity: world.capacities[relation.object.id]
		}
		if relation.object.kind == "intervention" {
			_objectIntervention: world.interventions[relation.object.id]
		}
		if relation.object.kind == "subject-profile" {
			_objectProfile: profile & {id: relation.object.id}
		}

		if relation.predicate == "impairs" {
			_causalMode: relation & {assertionMode: "clinician-attributed"}
			_clinicalAttributor: review.actors[relation.attributedBy.id] & {kind: "medical-expert" | "treating-clinician"}
		}
		if relation.predicate == "resulted-in" {
			_causalMode: relation & {assertionMode: "clinician-attributed"}
			_clinicalAttributor: review.actors[relation.attributedBy.id] & {kind: "medical-expert" | "treating-clinician"}
		}
		if relation.predicate == "triggered-by" {
			_causalMode: relation & {assertionMode: "clinician-attributed"}
			_clinicalAttributor: review.actors[relation.attributedBy.id] & {kind: "medical-expert" | "treating-clinician"}
		}
	}]

	_profileConditions:        [for ref in profile.partitions.conditions {world.observations[ref.id]}]
	_profileSymptoms:          [for ref in profile.partitions.symptoms {world.observations[ref.id]}]
	_profileFunctionalEvents:  [for ref in profile.partitions.functionalEvents {world.observations[ref.id]}]
	_profileSubstanceUse:      [for ref in profile.partitions.substanceUse {world.observations[ref.id]}]
	_profileSleep:             [for ref in profile.partitions.sleep {world.observations[ref.id]}]
	_profileObjectiveTests:    [for ref in profile.partitions.objectiveTests {world.observations[ref.id]}]
	_profileSupportDependency: [for ref in profile.partitions.supportDependency {world.observations[ref.id]}]
	_profileContext:           [for ref in profile.partitions.context {world.observations[ref.id]}]
	_profileEpisodes:          [for ref in profile.episodes {world.episodes[ref.id]}]
	_profileCapacities:        [for ref in profile.capacities {world.capacities[ref.id]}]
	_profileInterventions:     [for ref in profile.interventions {world.interventions[ref.id]}]
	_profileRelations:         [for ref in profile.relations {world.relations[ref.id]}]
	_profileEvidence:          [for ref in profile.evidence {review.evidence[ref.id]}]
})
