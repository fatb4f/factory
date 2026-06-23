package impl

#SurfaceSetSpec: close({
	admissible: [...string & !=""] | *[]
	observed: [...string & !=""] | *[]
	candidates: [...string & !=""] | *[]
	fixtures: [...string & !=""] | *[]
	checks: [...string & !=""] | *[]
	publicExports: [...string & !=""] | *[]
})

#SurfaceSetDescriptor: close({
	kind: "surface-set"
	admissible: [...string & !=""]
	observed: [...string & !=""]
	candidates: [...string & !=""]
	fixtures: [...string & !=""]
	checks: [...string & !=""]
	publicExports: [...string & !=""]
})

#MakeSurfaceSet: {
	in: #SurfaceSetSpec

	out: #SurfaceSetDescriptor & {
		kind: "surface-set"
		admissible: in.admissible
		observed: in.observed
		candidates: in.candidates
		fixtures: in.fixtures
		checks: in.checks
		publicExports: in.publicExports
	}
}
