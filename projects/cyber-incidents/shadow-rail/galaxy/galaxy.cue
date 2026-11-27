package galaxy

import world "github.com/fatb4f/factory/projects/cyber-incidents/shadow-rail/world"

// Identifiers are scoped to a catalog and remain stable across revisions.
#ID: string & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#Source: close({uri: string & =~"^https?://", version: string & !=""})
#Alignment: close({
	status:      "mapped"
	target:      string & !=""
	relation:    "related" | "broader" | "narrower"
	source:      #Source
	limitations: string & !=""
}) | close({
	status: "unmapped"
	reason: string & !=""
})
#Term: close({
	id:          #ID
	label:       string & !=""
	description: string & !=""
	srw_concept: world.#ConceptID
	source:      #Source
	alignment:   #Alignment
})
#Galaxy: close({
	apiVersion: "shadow-galaxy/0.1.0"
	id:         #ID
	version:    string & !=""
	terms: [#Term, ...#Term]
	boundaries: close({
		vocabulary_establishes_fact: false
		mapping_establishes_fact:    false
		actor_affiliation_inferred:  false
	})
})
