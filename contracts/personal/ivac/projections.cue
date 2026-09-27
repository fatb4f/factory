package ivac

projectionPolicy: close({
	authority: "derived-qualification-target"
	generationPath: ["cue", "json-schema", "pydantic", "relational"]
})

#ActorRow: close({
	actorID: #ActorID
	kind:    #ActorKind
})

#AuthorityRow: close({
	authorityID: #AuthorityID
	kind:        #AuthorityKind
})

#ClaimAxisRow: close({
	axisID: #ClaimAxisID
	label:  string
})

#EvidenceArtifactRow: close({
	evidenceID: #EvidenceArtifactID
	class:      #EvidenceClass
	producerID: #ActorID
	source?:    string
})

#EvidenceAxisRow: close({
	evidenceID: #EvidenceArtifactID
	axisID:     #ClaimAxisID
})

#FindingRow: close({
	findingID:  #FindingID
	kind:       #FindingKind
	axisID:     #ClaimAxisID
	producerID: #ActorID
	assertion:  string
})

#FindingEvidenceRow: close({
	findingID:  #FindingID
	evidenceID: #EvidenceArtifactID
})

#MandateRow: close({
	mandateID:  #MandateID
	kind:       #MandateKind
	principalID:#ActorID
	agentID:    #ActorID
	state:      string
})

#ReviewGroundRow: close({
	groundID:        #ReviewGroundID
	axisID:          #ClaimAxisID
	authorID:        #ActorID
	requestedAction: string
})

#GroundFindingRow: close({
	groundID:  #ReviewGroundID
	findingID: #FindingID
})

#SubmissionRow: close({
	submissionID: #SubmissionID
	authorID:     #ActorID
	state:        string
})

#SubmissionGroundRow: close({
	submissionID: #SubmissionID
	groundID:     #ReviewGroundID
})

#SubmissionEvidenceRow: close({
	submissionID: #SubmissionID
	evidenceID:   #EvidenceArtifactID
})

#DecisionRow: close({
	decisionID:  #DecisionID
	kind:        #DecisionKind
	authorityID: #ActorID
	outcome:     string
})

#StateSnapshotRow: close({
	stateID:              #PlantStateID
	procedural:           #ProceduralState
	record:               #RecordState
	submission:           #SubmissionState
	adjudication:         #AdjudicationState
	recognizedDecisionID: #DecisionID
})

#StateAxisRow: close({
	stateID:        #PlantStateID
	axisID:         #ClaimAxisID
	state:          string
	recognizedBand?: string
})

#TransitionRow: close({
	transitionID:    #TransitionID
	primitive:       #TransitionPrimitive
	actorID:         #ActorID
	authorityID:     #AuthorityID
	fromStateID:     #PlantStateID
	toStateID:       #PlantStateID
	mandateID?:      #MandateID
})

#TransitionDependencyRow: close({
	transitionID: #TransitionID
	grantID:      #TransitionGrantID
})

#TransitionDecisionRow: close({
	decisionID:   #TransitionDecisionID
	transitionID: #TransitionID
	state:        string
	grantID?:     #TransitionGrantID
})

#TransitionGrantRow: close({
	grantID:      #TransitionGrantID
	decisionID:   #TransitionDecisionID
	transitionID: #TransitionID
	primitive:    #TransitionPrimitive
})

#EvidenceWorldRow: close({
	worldID:   #EvidenceWorldID
	subjectID: #ActorID
})

#ObservationRow: close({
	observationID:   #ObservationID
	observationKind: #ObservationKind
	subjectID:       #ActorID
	concept:         string
	basis:           #AssertionBasis
})

#EpisodeRow: close({
	episodeID:   #EpisodeID
	episodeKind: #EpisodeKind
	subjectID:   #ActorID
	label:       string
	basis:       #AssertionBasis
})

#EpisodeObservationRow: close({
	episodeID:     #EpisodeID
	observationID: #ObservationID
})

#CapacityRow: close({
	capacityID: #CapacityID
	subjectID:  #ActorID
	domain:     #CapacityDomain
	state:      #CapacityState
	label:      string
	basis:      #AssertionBasis
})

#InterventionRow: close({
	interventionID:   #InterventionID
	subjectID:        #ActorID
	interventionKind: #InterventionKind
	state:            #InterventionState
	label:            string
	basis:            #AssertionBasis
})

#ClinicalRelationRow: close({
	relationID:    #ClinicalRelationID
	subjectKind:   #ClinicalNodeKind
	subjectID:     #ID
	predicate:     #ClinicalPredicate
	objectKind:    #ClinicalNodeKind
	objectID:      #ID
	assertionMode: #RelationAssertionMode
	attributedByID?: #ActorID
})

#SubjectProfileRow: close({
	profileID:     #SubjectProfileID
	subjectID:     #ActorID
	sourceWorldID: #EvidenceWorldID
	asOf:          string
})

#ProfileObservationRow: close({
	profileID:     #SubjectProfileID
	partition:     #ProfilePartition
	observationID: #ObservationID
})

#ProfileEpisodeRow: close({
	profileID: #SubjectProfileID
	episodeID: #EpisodeID
})

#ProfileCapacityRow: close({
	profileID:  #SubjectProfileID
	capacityID: #CapacityID
})

#ProfileInterventionRow: close({
	profileID:      #SubjectProfileID
	interventionID: #InterventionID
})

#ProfileRelationRow: close({
	profileID:  #SubjectProfileID
	relationID: #ClinicalRelationID
})

projectionRelations: close({
	actors:                 "#ActorRow"
	authorities:            "#AuthorityRow"
	claimAxes:              "#ClaimAxisRow"
	evidenceArtifacts:      "#EvidenceArtifactRow"
	evidenceAxes:           "#EvidenceAxisRow"
	findings:               "#FindingRow"
	findingEvidence:        "#FindingEvidenceRow"
	mandates:               "#MandateRow"
	reviewGrounds:          "#ReviewGroundRow"
	groundFindings:         "#GroundFindingRow"
	submissions:            "#SubmissionRow"
	submissionGrounds:      "#SubmissionGroundRow"
	submissionEvidence:     "#SubmissionEvidenceRow"
	decisions:              "#DecisionRow"
	stateSnapshots:         "#StateSnapshotRow"
	stateAxes:              "#StateAxisRow"
	transitions:            "#TransitionRow"
	transitionDependencies: "#TransitionDependencyRow"
	transitionDecisions:    "#TransitionDecisionRow"
	transitionGrants:       "#TransitionGrantRow"
	evidenceWorlds:         "#EvidenceWorldRow"
	observations:           "#ObservationRow"
	episodes:               "#EpisodeRow"
	episodeObservations:    "#EpisodeObservationRow"
	capacities:             "#CapacityRow"
	interventions:          "#InterventionRow"
	clinicalRelations:      "#ClinicalRelationRow"
	subjectProfiles:        "#SubjectProfileRow"
	profileObservations:    "#ProfileObservationRow"
	profileEpisodes:        "#ProfileEpisodeRow"
	profileCapacities:      "#ProfileCapacityRow"
	profileInterventions:   "#ProfileInterventionRow"
	profileRelations:       "#ProfileRelationRow"
})
