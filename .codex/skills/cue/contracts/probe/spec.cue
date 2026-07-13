package probe

import (
	"strings"

	"github.com/fatb4f/factory/cue-skill/canonical"
	kernel "github.com/fatb4f/factory/cue-skill/kernel"
)

#Operation: "unify" | "validate" | "validate-concrete" | "project" | "ingress-reject" | "no-widening" | "negative-fixture-conflict"

#ModuleCoordinates: close({
	moduleRoot: string & strings.MinRunes(1)
	package:    string & strings.MinRunes(1)
	declaredFiles: [...string] & [_, ...]
	value: kernel.#CueSelectorExpr
})

#Base: {
	id:        kernel.#KebabIdentifier
	version:   "v1"
	family:    kernel.#KebabIdentifier
	candidate: kernel.#KebabIdentifier
	module:    #ModuleCoordinates
	inputs: {[kernel.#KebabIdentifier]: canonical.#CanonicalSubjectValue}
	policy: close({
		permitted: {[string]: true}
		requiredAny: [...string]
		requiredEach: [...string]
	})
}

#Unify: close({
	#Base
	operation: "unify"
	operands: close({left: kernel.#CueSelectorExpr, right: kernel.#CueSelectorExpr})
})
#Validate: close({
	#Base
	operation: "validate"
	operands: close({value: kernel.#CueSelectorExpr, schema: kernel.#CueSelectorExpr})
})
#ValidateConcrete: close({
	#Base
	operation: "validate-concrete"
	operands: close({value: kernel.#CueSelectorExpr})
})
#Project: close({
	#Base
	operation: "project"
	operands: close({value: kernel.#CueSelectorExpr})
})
#IngressReject: close({
	#Base
	operation: "ingress-reject"
	operands: close({raw: kernel.#CueSelectorExpr, schema: kernel.#CueSelectorExpr})
})
#NoWidening: close({
	#Base
	operation: "no-widening"
	operands: close({authority: kernel.#CueSelectorExpr, target: kernel.#CueSelectorExpr})
})
#NegativeFixtureConflict: close({
	#Base
	operation: "negative-fixture-conflict"
	operands: close({authority: kernel.#CueSelectorExpr, mutation: kernel.#CueSelectorExpr})
})

#ProbeSpec: #Unify | #Validate | #ValidateConcrete | #Project | #IngressReject | #NoWidening | #NegativeFixtureConflict

#ProbePlan: close({
	id:        kernel.#KebabIdentifier
	candidate: kernel.#KebabIdentifier
	families: [...kernel.#KebabIdentifier] & [_, ...]
	probeIDs: [...kernel.#KebabIdentifier] & [_, ...]
	invariants: {[kernel.#KebabIdentifier]: [...kernel.#KebabIdentifier] & [_, ...]}
})
