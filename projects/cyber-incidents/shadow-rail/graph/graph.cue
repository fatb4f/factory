package graph

import world "github.com/fatb4f/factory/projects/cyber-incidents/shadow-rail/world"

#ID:     string & =~"^[a-z0-9][a-z0-9._/-]*$"
#Digest: string & =~"^sha256:[0-9a-f]{64}$"
#Second: int & >=0

// Half-open UTC Unix-second intervals. Omitted end means open-ended.
#Window: close({
	start: #Second
	end?:  #Second & >start
})

#Ref: close({
	rail:     #ID
	id:       #ID
	revision: #ID
	concept:  world.#ConceptID
})

#EvidenceRef: close({
	rail:     #ID
	capture:  #Digest
	revision: #ID
	locator:  string & !=""
})

// One relationship revision, not a complete graph or an admission decision.
#RelationshipRevision: {
	apiVersion: "shadow-graph.relationship/0.1.0"
	id:         #ID
	revision:   #ID
	valid:      #Window
	knowledge:  #Window
	provenance: [#EvidenceRef, ...#EvidenceRef]
	boundaries: close({
		link_admits_evidence:           false
		reconciliation_merges_identity: false
		link_establishes_attribution:   false
	})
	kind: "supports" | "contradicts" | "reconciles"
	from: #Ref
	to:   #Ref
	if kind == "reconciles" {
		let sourceRail = from.rail
		to: {rail: !=sourceRail}
		reconciliation: close({
			status:    "candidate" | "disputed"
			rationale: string & !=""
		})
	}
	if kind != "reconciles" {
		from: {concept: "evidence" | "observation"}
		to: {concept: "claim" | "hypothesis" | "attribution"}
	}
}

// A replay probe tests visibility of a single revision, not graph consistency.
#ReplayProbe: {
	relationship: #RelationshipRevision
	validAt:      #Second
	knownAt:      #Second

	let valid = relationship.valid
	let knowledge = relationship.knowledge
	_validEnd:     int | *-1
	_knowledgeEnd: int | *-1
	if valid.end != _|_ {
		_validEnd: valid.end
	}
	if knowledge.end != _|_ {
		_knowledgeEnd: knowledge.end
	}
	visible: validAt >= valid.start && (_validEnd == -1 || validAt < _validEnd) &&
		knownAt >= knowledge.start && (_knowledgeEnd == -1 || knownAt < _knowledgeEnd)
}
