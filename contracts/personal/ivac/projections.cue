package ivac

projectionPolicy: close({
	authority: "derived-qualification-target"
	generationPath: ["cue", "json-schema", "pydantic", "relational", "ibis"]
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
	mandateID:   #MandateID
	kind:        #MandateKind
	principalID: #ActorID
	agentID:     #ActorID
	state:       string
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
	stateID:         #PlantStateID
	axisID:          #ClaimAxisID
	state:           string
	recognizedBand?: string
})

#TransitionRow: close({
	transitionID: #TransitionID
	primitive:    #TransitionPrimitive
	actorID:      #ActorID
	authorityID:  #AuthorityID
	fromStateID:  #PlantStateID
	toStateID:    #PlantStateID
	mandateID?:   #MandateID
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
	valueKind:       "boolean" | "number" | "categorical" | "text"
	valueText:       string
	temporalStatus:  #TemporalExtentStatus
	temporalStart?:  string
	temporalEnd?:    string
	basis:            #AssertionBasis
	assertedByID?:   #ActorID
})

#ObservationEvidenceRow: close({
	observationID: #ObservationID
	evidenceID:    #EvidenceArtifactID
})

#EpisodeRow: close({
	episodeID:      #EpisodeID
	episodeKind:    #EpisodeKind
	subjectID:      #ActorID
	label:          string
	temporalStatus: #TemporalExtentStatus
	temporalStart?: string
	temporalEnd?:   string
	basis:           #AssertionBasis
	assertedByID?:  #ActorID
})

#EpisodeObservationRow: close({
	episodeID:     #EpisodeID
	observationID: #ObservationID
})

#EpisodeEvidenceRow: close({
	episodeID:  #EpisodeID
	evidenceID: #EvidenceArtifactID
})

#CapacityRow: close({
	capacityID:      #CapacityID
	subjectID:       #ActorID
	domain:          #CapacityDomain
	state:           #CapacityState
	label:           string
	temporalStatus:  #TemporalExtentStatus
	temporalStart?:  string
	temporalEnd?:    string
	basis:            #AssertionBasis
	assertedByID?:   #ActorID
})

#CapacityEvidenceRow: close({
	capacityID: #CapacityID
	evidenceID: #EvidenceArtifactID
})

#CapacitySupportRow: close({
	capacityID:     #CapacityID
	interventionID: #InterventionID
})

#InterventionRow: close({
	interventionID:   #InterventionID
	subjectID:        #ActorID
	interventionKind: #InterventionKind
	state:            #InterventionState
	label:            string
	temporalStatus:   #TemporalExtentStatus
	temporalStart?:   string
	temporalEnd?:     string
	basis:             #AssertionBasis
	assertedByID?:    #ActorID
	providerID?:      #ActorID
})

#InterventionEvidenceRow: close({
	interventionID: #InterventionID
	evidenceID:     #EvidenceArtifactID
})

#ClinicalRelationRow: close({
	relationID:      #ClinicalRelationID
	subjectKind:     #ClinicalNodeKind
	subjectID:       #ID
	predicate:       #ClinicalPredicate
	objectKind:      #ClinicalNodeKind
	objectID:        #ID
	assertionMode:   #RelationAssertionMode
	attributedByID?: #ActorID
	temporalStatus?: #TemporalExtentStatus
	temporalStart?:  string
	temporalEnd?:    string
})

#RelationEvidenceRow: close({
	relationID: #ClinicalRelationID
	evidenceID: #EvidenceArtifactID
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

#GraphEdgeClass: "clinical" | "membership" | "evidence" | "support" | "review"

#GraphEdgeRow: close({
	edgeID:          #ID
	edgeClass:       #GraphEdgeClass
	subjectKind:     string & !=""
	subjectID:       #ID
	predicate:       string & !=""
	objectKind:      string & !=""
	objectID:        #ID
	assertionMode?:  #RelationAssertionMode
	attributedByID?: #ActorID
	temporalStatus?: #TemporalExtentStatus
	temporalStart?:  string
	temporalEnd?:    string
})

#GraphIndexRow: close({
	indexID:    #ID
	keyName:    string & !=""
	keyValue:   string
	memberKind: string & !=""
	memberID:   #ID
	edgeID?:    #ID
})

#ArtifactEnvelopeRow: close({
	envelopeID:         #ArtifactEnvelopeID
	evidenceID:         #EvidenceArtifactID
	layer:              #ArtifactLayer
	defaultDisposition: #PortabilityDisposition
	authorityPreserved: true
})

#ArtifactEnvelopeGateRow: close({
	envelopeID: #ArtifactEnvelopeID
	gate:       #DisclosureGate
})

#ArtifactEnvelopeProtectionRow: close({
	envelopeID: #ArtifactEnvelopeID
	protection: #PotentialProtection
})

#ReuseConsumerProfileRow: close({
	profileID:            #PortabilityProfileID
	forum:                #ForumKind
	selectionMode:        "purpose-bound-subset"
	wholeCorpusByDefault: false
	admissibility:        "not-determined"
	authority:            "consumer-specific-qualification"
})

#ReuseProfilePurposeRow: close({
	profileID: #PortabilityProfileID
	purpose:   #ReusePurpose
})

#ReuseProfileRuleRow: close({
	profileID:   #PortabilityProfileID
	layer:       #ArtifactLayer
	disposition: #PortabilityDisposition
})

#ReuseProfileRuleGateRow: close({
	profileID: #PortabilityProfileID
	layer:     #ArtifactLayer
	gate:      #DisclosureGate
})

#DerivativePackageRow: close({
	packageID:         #DerivativePackageID
	consumerProfileID: #PortabilityProfileID
	worldID:           #EvidenceWorldID
	subjectProfileID:  #SubjectProfileID
	purpose:           #ReusePurpose
	selectionMode:     "purpose-bound-subset"
	authority:         "derived-non-authoritative"
	state:             #DerivativePackageState
})

#DerivativeArtifactRow: close({
	packageID:          #DerivativePackageID
	evidenceID:         #EvidenceArtifactID
	envelopeID:         #ArtifactEnvelopeID
	disposition:        #PortabilityDisposition
	decision:           #SelectionDecision
	scopeReview:        #GateState
	clinicalScope:      #GateState
	forumQualification: #GateState
	protectionReview:   #GateState
})

#DerivativeFindingRow: close({
	packageID: #DerivativePackageID
	findingID: #FindingID
})

#DerivativeRelationRow: close({
	packageID:  #DerivativePackageID
	relationID: #ClinicalRelationID
})

#ReuseSeedRow: close({
	seedID:            #ReuseSeedID
	consumerProfileID: #PortabilityProfileID
	purpose:           #ReusePurpose
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
	observationEvidence:    "#ObservationEvidenceRow"
	episodes:               "#EpisodeRow"
	episodeObservations:    "#EpisodeObservationRow"
	episodeEvidence:        "#EpisodeEvidenceRow"
	capacities:             "#CapacityRow"
	capacityEvidence:       "#CapacityEvidenceRow"
	capacitySupport:        "#CapacitySupportRow"
	interventions:          "#InterventionRow"
	interventionEvidence:   "#InterventionEvidenceRow"
	clinicalRelations:      "#ClinicalRelationRow"
	relationEvidence:       "#RelationEvidenceRow"
	subjectProfiles:        "#SubjectProfileRow"
	profileObservations:    "#ProfileObservationRow"
	profileEpisodes:        "#ProfileEpisodeRow"
	profileCapacities:      "#ProfileCapacityRow"
	profileInterventions:   "#ProfileInterventionRow"
	profileRelations:       "#ProfileRelationRow"
	graphEdges:             "#GraphEdgeRow"
	graphIndices:           "#GraphIndexRow"
	artifactEnvelopes:      "#ArtifactEnvelopeRow"
	artifactEnvelopeGates:  "#ArtifactEnvelopeGateRow"
	artifactProtections:    "#ArtifactEnvelopeProtectionRow"
	reuseConsumerProfiles:  "#ReuseConsumerProfileRow"
	reuseProfilePurposes:   "#ReuseProfilePurposeRow"
	reuseProfileRules:      "#ReuseProfileRuleRow"
	reuseProfileRuleGates:  "#ReuseProfileRuleGateRow"
	derivativePackages:     "#DerivativePackageRow"
	derivativeArtifacts:    "#DerivativeArtifactRow"
	derivativeFindings:     "#DerivativeFindingRow"
	derivativeRelations:    "#DerivativeRelationRow"
	reuseSeeds:             "#ReuseSeedRow"
})
