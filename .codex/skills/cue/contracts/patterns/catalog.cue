package patterns

import (
	"list"
	"strings"
)

#KebabIdentifier: string & strings.MinRunes(1) & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#Visibility:      "public" | "internal" | "restricted"
#Role:            string & strings.MinRunes(1)

#Resource: {
	id:         #KebabIdentifier
	path:       string & strings.MinRunes(1)
	role:       #Role
	visibility: #Visibility | *"internal"
}

#ClosedResource: close(#Resource)

#TaggedSelector: close({
	selector: string @tag(selector)
	path:     string @tag(path)
})

#GatePolicy: close({
	id:          #KebabIdentifier
	description: string & strings.MinRunes(1)
	required:    bool | *true
})

#OperationIntent:
	close({kind: "inspect", reads: {[#KebabIdentifier]: true}}) |
	close({kind: "generate", creates: {[#KebabIdentifier]: true}})

#ResourceInputs: {[#KebabIdentifier]: {
	path: string & strings.MinRunes(1)
	role: #Role
}}

#MakeResources: {
	in: #ResourceInputs
	out: {
		for resourceID, resource in in {
			"\(resourceID)": resource & {id: resourceID}
		}
	}
}

#MakeResource: {
	in: close({
		id:   #KebabIdentifier
		path: string & strings.MinRunes(1)
		role: #Role
	})
	out: #ClosedResource & {
		id:         in.id
		path:       in.path
		role:       in.role
		visibility: #Visibility | *"internal"
	}
}

// Definitions close recursively when referenced; explicit close belongs to
// the closedness pattern rather than this definition pattern.
#DefinitionResource: {
	id:         #KebabIdentifier
	path:       string & strings.MinRunes(1)
	role:       #Role
	visibility: #Visibility | *"internal"
}

#CreateProof: {
	createdID: #KebabIdentifier
	operation: {creates: {[#KebabIdentifier]: true}}
	resources: {[#KebabIdentifier]: {role: #Role}}
	proof: {
		created: operation.creates[createdID] & true
		role:    resources[createdID].role & "generated-output"
	}
}

#NonEmptyKeyList: [...#KebabIdentifier] & [_, ...]

#NegativeFixtureSpec: close({
	id:          #KebabIdentifier
	description: string & strings.MinRunes(1)
	authority:   _
	mutation:    _
})

#NegativeFixtureProbe: {
	spec:  #NegativeFixtureSpec
	proof: spec.authority & spec.mutation
}

#TopRefinement: {
	open: _
	out: open & {
		resource: #KebabIdentifier
		role:     #Role
	}
}

#BottomConflict: {
	left:  string
	right: string
	proof: left & right
}

#PublicResourceProjection: {
	resources: {[#KebabIdentifier]: #Resource}
	out: [for resourceID, resource in resources if resource.visibility == "public" {
		id:   resourceID
		path: resource.path
	}]
}

#DirectionalSubsumption: #DirectionalFixture & {
	patternID: "subsumption"
	mode:      "subsumes"
}

#ProjectionPreservation: #DirectionalFixture & {
	patternID: "projections"
	mode:      "preserves"
}

#PatternCatalog: close({
	attributes: {id: "attributes", description: "bounded field attributes", assertionMode: "unifies", schema: #TaggedSelector}
	bounds: {id: "bounds", description: "intersected lexical bounds", assertionMode: "unifies", schema: #KebabIdentifier}
	closedness: {id: "closedness", description: "explicitly closed ingress", assertionMode: "bottoms", schema: #ClosedResource}
	comprehensions: {id: "comprehensions", description: "keyed construction comprehension", assertionMode: "exports", schema: #MakeResources}
	constructors: {id: "constructors", description: "input output constructor with real default", assertionMode: "exports", schema: #MakeResource}
	cycles: {id: "cycles", description: "fixed point and invalid cycle classes", assertionMode: "requires", schema: _}
	defaults: {id: "defaults", description: "marked default materialization", assertionMode: "exports", schema: #GatePolicy}
	definitions: {id: "definitions", description: "recursive definition closure", assertionMode: "bottoms", schema: #DefinitionResource}
	disjunctions: {id: "disjunctions", description: "closed tagged operation union", assertionMode: "unifies", schema: #OperationIntent}
	"hidden-and-let": {id: "hidden-and-let", description: "hidden creation edge and role proof", assertionMode: "requires", schema: #CreateProof}
	lists: {id: "lists", description: "nonempty lists exact tuples and sorted keys", assertionMode: "exports", schema: #NonEmptyKeyList}
	"negative-fixtures": {id: "negative-fixtures", description: "destructive expected-bottom fixture", assertionMode: "forbids", schema: #NegativeFixtureProbe}
	projections: {id: "projections", description: "projection separate from preservation relation", assertionMode: "exports", schema: #PublicResourceProjection}
	subsumption: {id: "subsumption", description: "runner-backed directional subsumption", assertionMode: "subsumes", schema: #DirectionalSubsumption}
	"top-and-bottom": {id: "top-and-bottom", description: "top refinement and selected bottom", assertionMode: "forbids", schema: #BottomConflict}
	unification: {id: "unification", description: "greatest lower bound intersection", assertionMode: "unifies", schema: #Resource}
})

patternIDs: list.SortStrings([for _, pattern in #PatternCatalog {pattern.id}])
catalogComplete: patternIDs == [
	"attributes",
	"bounds",
	"closedness",
	"comprehensions",
	"constructors",
	"cycles",
	"defaults",
	"definitions",
	"disjunctions",
	"hidden-and-let",
	"lists",
	"negative-fixtures",
	"projections",
	"subsumption",
	"top-and-bottom",
	"unification",
]
