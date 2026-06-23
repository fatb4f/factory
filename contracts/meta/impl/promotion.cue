package impl

#PromotionCandidateSpec: close({
	name: string & !=""
	role: string & !=""
	observedSurface: string & !=""
	admissibleSurface: string & !=""
	predicateSet: string & !=""
	controlPredicates: [...string & !=""] & [_, ...]
	closed: true | *true
	constraints: [...string & !=""] | *[]
})

#PromotionCandidateDescriptor: close({
	kind: "promotion-candidate"
	name: string & !=""
	role: string & !=""
	observedSurface: string & !=""
	admissibleSurface: string & !=""
	predicateSet: string & !=""
	controlPredicates: [...string & !=""] & [_, ...]
	closed: true
	constraints: [...string & !=""]
})

#MakePromotionCandidate: {
	in: #PromotionCandidateSpec

	out: #PromotionCandidateDescriptor & {
		kind: "promotion-candidate"
		name: in.name
		role: in.role
		observedSurface: in.observedSurface
		admissibleSurface: in.admissibleSurface
		predicateSet: in.predicateSet
		controlPredicates: in.controlPredicates
		closed: in.closed
		constraints: in.constraints
	}
}
