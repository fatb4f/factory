package world

// Mappings are curated comparisons, not OWL equivalences or conversion rules.
#Mapping: close({
	concept:   #ConceptID
	relation:  "unmapped"
	rationale: string & !=""
}) | close({
	concept:   #ConceptID
	relation:  "broader-reference" | "related-reference"
	reference: close({iri: string & =~"^https://www\\.commoncoreontologies\\.org/ont[0-9]+$", label: string & !=""})
	rationale: string & !=""
})
#Crosswalk: close({
	ontology_version: "srw/0.1.0"
	reference: close({
		name:    "Common Core Ontologies"
		version: "2.2"
		source:  "https://github.com/CommonCoreOntology/CommonCoreOntologies/blob/v2.2/src/cco-merged/CommonCoreOntologiesMerged.ttl"
	})
	mappings: close({
		actor:       #Mapping & {concept: "actor", ...}
		activity:    #Mapping & {concept: "activity", ...}
		observation: #Mapping & {concept: "observation", ...}
		claim:       #Mapping & {concept: "claim", ...}
		evidence:    #Mapping & {concept: "evidence", ...}
		hypothesis:  #Mapping & {concept: "hypothesis", ...}
		attribution: #Mapping & {concept: "attribution", ...}
		source:      #Mapping & {concept: "source", ...}
		artifact:    #Mapping & {concept: "artifact", ...}
		place:       #Mapping & {concept: "place", ...}
	})
})

crosswalk: #Crosswalk & {
	ontology_version: ontology.version
	reference:        {name: "Common Core Ontologies", version: "2.2", source: "https://github.com/CommonCoreOntology/CommonCoreOntologies/blob/v2.2/src/cco-merged/CommonCoreOntologiesMerged.ttl"}
	mappings: {
		actor:       {concept: "actor", relation: "related-reference", reference: {iri: "https://www.commoncoreontologies.org/ont00001017", label: "Agent"}, rationale: "CCO Agent requires material agency capability; an SRW candidate actor may be unknown or unverified."}
		activity:    {concept: "activity", relation: "related-reference", reference: {iri: "https://www.commoncoreontologies.org/ont00000005", label: "Act"}, rationale: "CCO Act requires a causative agent; an SRW activity need not have an identified or established agent."}
		observation: {concept: "observation", relation: "related-reference", reference: {iri: "https://www.commoncoreontologies.org/ont00000958", label: "Information Content Entity"}, rationale: "A recorded observation can have informational content; SRW does not assert all observations satisfy CCO's formal commitments."}
		claim:       {concept: "claim", relation: "related-reference", reference: {iri: "https://www.commoncoreontologies.org/ont00000958", label: "Information Content Entity"}, rationale: "A claim can be represented as informational content; this does not assert truth or formal equivalence."}
		evidence:    {concept: "evidence", relation: "unmapped", rationale: "Evidence is context dependent and may be material; no general CCO class alignment is asserted."}
		hypothesis:  {concept: "hypothesis", relation: "related-reference", reference: {iri: "https://www.commoncoreontologies.org/ont00000958", label: "Information Content Entity"}, rationale: "A recorded hypothesis can have informational content; no formal equivalence or evidential acceptance is asserted."}
		attribution: {concept: "attribution", relation: "related-reference", reference: {iri: "https://www.commoncoreontologies.org/ont00000958", label: "Information Content Entity"}, rationale: "A recorded attribution can have informational content; a mapping does not establish responsibility."}
		source:      {concept: "source", relation: "unmapped", rationale: "Sources span agents, publications and datasets; no single CCO class covers this SRW usage."}
		artifact:    {concept: "artifact", relation: "unmapped", rationale: "SRW includes digital items and makes no general materiality or design commitment."}
		place:       {concept: "place", relation: "unmapped", rationale: "SRW allows geographic references without choosing a CCO spatial class."}
	}
}
