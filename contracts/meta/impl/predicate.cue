package impl

#PredicateSetSpec: close({
	name: string & !=""
	role: string & !=""
	inputSurface: string & !=""
	derivedPredicates: [...string & !=""] & [_, ...]
	operatorSupplied: false | *false
	constraints: [...string & !=""] | *[]
})

#PredicateSetDescriptor: close({
	kind: "predicate-set"
	name: string & !=""
	role: string & !=""
	inputSurface: string & !=""
	derivedPredicates: [...string & !=""] & [_, ...]
	operatorSupplied: false
	constraints: [...string & !=""]
})

#MakePredicateSet: {
	in: #PredicateSetSpec

	out: #PredicateSetDescriptor & {
		kind: "predicate-set"
		name: in.name
		role: in.role
		inputSurface: in.inputSurface
		derivedPredicates: in.derivedPredicates
		operatorSupplied: in.operatorSupplied
		constraints: in.constraints
	}
}
