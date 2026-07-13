package kernel

projection: {
	pilotPattern: "bounded-int.#BoundedInt"
	kernelValue:  "#BoundedInt"
	claims: [
		"integer-kind-preserved",
		"inclusive-lower-bound-preserved",
		"inclusive-upper-bound-preserved",
		"no-widening",
	]
}
