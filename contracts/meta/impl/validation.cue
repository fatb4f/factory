package impl

#ValidationPlanSpec: close({
	path: string & !=""
	validBaselineExpr: string & !=""
	publicExpr: string & !=""
	bottomChecks: [...string & !=""] | *[]
	checkFile: string | *""
	forbiddenPattern: string | *"bottomCheckSurface|expression:|isInvalid: true"
})

#ValidationPlan: close({
	kind: "validation-plan"
	commands: [...string & !=""]
})

#MakeValidationPlan: {
	in: #ValidationPlanSpec

	out: #ValidationPlan & {
		kind: "validation-plan"
		commands: [
			"cue vet ./\(in.path)",
			"cue export ./\(in.path) -e \(in.validBaselineExpr)",
			"cue export ./\(in.path) -e \(in.publicExpr)",
			for c in in.bottomChecks {
				if in.checkFile == "" {
					"! cue export ./\(in.path) -e '_negativeBottomChecks.\(c)'"
				}
				if in.checkFile != "" {
					"! cue export ./\(in.path) \(in.checkFile) -e '_negativeBottomChecks.\(c)'"
				}
			},
			"! rg '\(in.forbiddenPattern)' ./\(in.path)",
		]
	}
}
