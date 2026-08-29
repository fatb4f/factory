package gym

#BodyRegionID: string
#BodyRegionRef: close({id: #BodyRegionID})

#BodyRegionLevel:
	"global" |
	"trunk" |
	"pelvis" |
	"thigh" |
	"knee" |
	"lower-leg" |
	"ankle" |
	"foot"

#BodyRegion: close({
	id:    #BodyRegionID
	label: string
	level: #BodyRegionLevel
})

bodyRegions: close({
	global:                  #BodyRegion & {id: "global", label: "Global support", level: "global"}
	trunk:                   #BodyRegion & {id: "trunk", label: "Trunk", level: "trunk"}
	pelvis:                  #BodyRegion & {id: "pelvis", label: "Pelvis", level: "pelvis"}
	"anterior-thigh":        #BodyRegion & {id: "anterior-thigh", label: "Anterior thigh", level: "thigh"}
	"posterior-thigh":       #BodyRegion & {id: "posterior-thigh", label: "Posterior thigh", level: "thigh"}
	"medial-thigh":          #BodyRegion & {id: "medial-thigh", label: "Medial thigh", level: "thigh"}
	knee:                    #BodyRegion & {id: "knee", label: "Knee", level: "knee"}
	calf:                    #BodyRegion & {id: "calf", label: "Calf", level: "lower-leg"}
	ankle:                   #BodyRegion & {id: "ankle", label: "Ankle", level: "ankle"}
	foot:                    #BodyRegion & {id: "foot", label: "Foot", level: "foot"}
	hallux:                  #BodyRegion & {id: "hallux", label: "Hallux", level: "foot"}
})
