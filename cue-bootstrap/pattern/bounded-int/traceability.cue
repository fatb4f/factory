package boundedint

traceability: {
	pattern: "#BoundedInt"
	authority: [{
		repository: "https://github.com/cue-lang/cue"
		commit:     "829b565633abb51541be4f8b7ad6d3372c689d2d"
		path:       "doc/ref/spec.md"
		sections: ["Values", "Unification", "Bounds"]
	}]
	claims: {
		integerKind: {
			statement: "The pattern admits integer values only."
			fixtures: ["bounded-int.positive.mid", "bounded-int.negative.wrong-type"]
			operations: ["unify", "validate"]
		}
		inclusiveBounds: {
			statement: "The pattern admits 0 and 10 and rejects values below 0 or above 10."
			fixtures: [
				"bounded-int.positive.min",
				"bounded-int.positive.max",
				"bounded-int.negative.below",
				"bounded-int.negative.above",
			]
			operations: ["unify"]
		}
		directionalOrdering: {
			statement: "int subsumes the bounded range, and the bounded range subsumes a contained concrete integer."
			fixtures: [
				"bounded-int.directional.general",
				"bounded-int.directional.bounded",
				"bounded-int.directional.specific",
			]
			operations: ["subsume"]
		}
	}
}
