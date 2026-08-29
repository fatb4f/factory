package gym

#ChainRelationID: string
#ChainRelationRef: close({id: #ChainRelationID})

#ChainRelationKind:
	"shares-region" |
	"shares-constraint" |
	"co-loaded" |
	"proximal-distal" |
	"cross-support" |
	"reciprocal" |
	"candidate-load-transfer" |
	"observed-association"

#ChainRelationStatus: "structural" | "operational-assumption" | "derived-association"

#ChainRelation: close({
	id:       #ChainRelationID
	source:   #ChainRef
	target:   #ChainRef
	kind:     #ChainRelationKind
	status:   #ChainRelationStatus
	note?:    string
	evidence?: [...#ObservationRef]
})

chainRelations: close({
	"distal-to-anterior": #ChainRelation & {
		id: "distal-to-anterior"
		source: {id: "distal-foot-ankle"}
		target: {id: "anterior-knee-hip"}
		kind: "proximal-distal"
		status: "operational-assumption"
	}
	"anterior-to-frontal-pelvic": #ChainRelation & {
		id: "anterior-to-frontal-pelvic"
		source: {id: "anterior-knee-hip"}
		target: {id: "frontal-pelvic"}
		kind: "shares-region"
		status: "structural"
	}
	"posterior-to-trunk-pelvis": #ChainRelation & {
		id: "posterior-to-trunk-pelvis"
		source: {id: "posterior-chain"}
		target: {id: "trunk-pelvis"}
		kind: "shares-constraint"
		status: "structural"
	}
	"frontal-to-trunk-pelvis": #ChainRelation & {
		id: "frontal-to-trunk-pelvis"
		source: {id: "frontal-pelvic"}
		target: {id: "trunk-pelvis"}
		kind: "shares-constraint"
		status: "structural"
	}
	"cross-support-to-stance": #ChainRelation & {
		id: "cross-support-to-stance"
		source: {id: "contralateral-cross-support"}
		target: {id: "global-stance-support"}
		kind: "cross-support"
		status: "operational-assumption"
	}
	"distal-to-stance": #ChainRelation & {
		id: "distal-to-stance"
		source: {id: "distal-foot-ankle"}
		target: {id: "global-stance-support"}
		kind: "candidate-load-transfer"
		status: "operational-assumption"
	}
})
