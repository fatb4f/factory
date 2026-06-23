package impl

#CompletionReportSpec: close({
	primitives: [...string & !=""] | *[]
	surfaces: [...string & !=""] | *[]
	fixtures: [...string & !=""] | *[]
	checks: [...string & !=""] | *[]
	commands: [...string & !=""] | *[]
})

#CompletionReportContract: close({
	kind: "completion-report-contract"
	requiredSections: [...string & !=""]
	expected: close({
		primitives: [...string & !=""]
		surfaces: [...string & !=""]
		fixtures: [...string & !=""]
		checks: [...string & !=""]
		commands: [...string & !=""]
	})
})

#MakeCompletionReport: {
	in: #CompletionReportSpec

	out: #CompletionReportContract & {
		kind: "completion-report-contract"

		requiredSections: [
			"files changed",
			"primitives implemented",
			"surfaces implemented",
			"fixtures implemented",
			"bottom checks implemented",
			"commands run",
			"final result",
		]

		expected: {
			primitives: in.primitives
			surfaces: in.surfaces
			fixtures: in.fixtures
			checks: in.checks
			commands: in.commands
		}
	}
}
