package world

// SRW is a vocabulary contract, not an assertion that any instance exists.
#ConceptID:  "actor" | "activity" | "observation" | "claim" | "evidence" | "hypothesis" | "attribution" | "source" | "artifact" | "place"
#RelationID: "observes" | "asserts" | "about" | "supports" | "contradicts" | "proposes" | "attributes"
#Concept:    close({description: string & !=""})
#Relation:   close({description: string & !=""})

ontology: close({
	version: "srw/0.1.0"
	concepts: close({
		actor:       #Concept & {description: "A person, organization, or other identified or hypothesized agent; identity and agency are not presumed established."}
		activity:    #Concept & {description: "A bounded occurrence or behavior of analytical interest; its occurrence is not presumed established."}
		observation: #Concept & {description: "A recorded observation, distinct from an interpretation of what it means."}
		claim:       #Concept & {description: "A proposition asserted by a source, regardless of its truth."}
		evidence:    #Concept & {description: "Source-qualified material considered in relation to a proposition; its evidential weight and admission are context dependent."}
		hypothesis:  #Concept & {description: "A defeasible analytical explanation that can have alternatives and supporting or contradicting evidence."}
		attribution: #Concept & {description: "A claim or assessment assigning responsibility for an activity to an actor; not established by naming it."}
		source:      #Concept & {description: "An origin of material or assertions, including an organization, person, publication, or dataset."}
		artifact:    #Concept & {description: "A material or digital item of analytical interest."}
		place:       #Concept & {description: "A location or geographic reference of analytical interest."}
	})
	relations: close({
		observes:    #Relation & {description: "A source records an observation; recording does not prove the observation accurate."}
		asserts:     #Relation & {description: "A source expresses a claim or attribution."}
		about:       #Relation & {description: "Information concerns an entity or proposition; this does not establish its truth."}
		supports:    #Relation & {description: "Evidence is assessed as supporting a proposition in a stated context, not as proof."}
		contradicts: #Relation & {description: "Evidence is assessed as contradicting a proposition in a stated context, not as disproof."}
		proposes:    #Relation & {description: "An analyst or source proposes a hypothesis; proposal does not admit it as fact."}
		attributes:  #Relation & {description: "An attribution names a candidate responsible actor; the relation itself is not a finding of responsibility."}
	})
	boundaries: {
		vocabulary_is_evidence:                  false
		mapping_establishes_fact:                false
		model_proposal_is_attribution_authority: false
		graph_or_admission_implemented:          false
	}
})
