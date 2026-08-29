package gym

#ChainID: string
#ChainRef: close({id: #ChainID})

#ChainKind: "regional" | "functional" | "cross-body" | "global-support"

#Chain: close({
	id:        #ChainID
	label:     string
	kind:      #ChainKind
	regions:   [...#BodyRegionRef]
	functions?: [...string]
})

chains: close({
	"distal-foot-ankle": #Chain & {
		id: "distal-foot-ankle"
		label: "Distal foot-ankle chain"
		kind: "regional"
		regions: [{id: "calf"}, {id: "ankle"}, {id: "foot"}, {id: "hallux"}]
		functions: ["load acceptance", "pronation-supination transition", "push-off"]
	}
	"anterior-knee-hip": #Chain & {
		id: "anterior-knee-hip"
		label: "Anterior knee-hip chain"
		kind: "functional"
		regions: [{id: "anterior-thigh"}, {id: "knee"}, {id: "pelvis"}]
		functions: ["knee extension control", "anterior-chain lengthened loading", "pelvic load transfer"]
	}
	"posterior-chain": #Chain & {
		id: "posterior-chain"
		label: "Posterior chain"
		kind: "functional"
		regions: [{id: "posterior-thigh"}, {id: "calf"}, {id: "pelvis"}, {id: "trunk"}]
		functions: ["knee flexion output", "hip extension output", "posterior load transfer"]
	}
	"frontal-pelvic": #Chain & {
		id: "frontal-pelvic"
		label: "Frontal pelvic chain"
		kind: "functional"
		regions: [{id: "medial-thigh"}, {id: "pelvis"}, {id: "trunk"}]
		functions: ["frontal-plane pelvic control", "adduction-abduction load transfer"]
	}
	"trunk-pelvis": #Chain & {
		id: "trunk-pelvis"
		label: "Trunk-pelvis control interface"
		kind: "functional"
		regions: [{id: "trunk"}, {id: "pelvis"}]
		functions: ["stack control", "anti-extension", "anti-rotation", "load transfer"]
	}
	"contralateral-cross-support": #Chain & {
		id: "contralateral-cross-support"
		label: "Contralateral cross-support"
		kind: "cross-body"
		regions: [{id: "trunk"}, {id: "pelvis"}, {id: "anterior-thigh"}, {id: "posterior-thigh"}]
		functions: ["cross-body support", "pelvic rotation control"]
	}
	"global-stance-support": #Chain & {
		id: "global-stance-support"
		label: "Global stance support"
		kind: "global-support"
		regions: [{id: "global"}, {id: "pelvis"}, {id: "knee"}, {id: "ankle"}, {id: "foot"}]
		functions: ["bilateral stance organization", "load distribution"]
	}
})
