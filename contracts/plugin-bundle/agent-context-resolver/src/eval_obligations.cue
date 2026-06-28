package agentcontextresolver

#EvalObligation: close({
	id:   string & !=""
	kind: "cueVet" | "cueExport" | "cueBottom" | "grepAbsent"
	command: [string & !="", ...string & !=""]
	expect: "pass" | "fail"
})

#IssueEvalObligations: close({
	input: #ImplementationSliceIssue

	required: {
		vet: #EvalObligation & {
			id:   "issue.cue-vet"
			kind: "cueVet"
			command: ["cue", "vet", "./\(input.contract.path)"]
			expect: "pass"
		}

		publicExports: [
			for e in input.surfaces.publicExports {
				#EvalObligation & {
					id:   "issue.export.\(e)"
					kind: "cueExport"
					command: ["cue", "export", "./\(input.contract.path)", "-e", e]
					expect: "pass"
				}
			},
		]

		negativeChecks: [
			for c in input.surfaces.checks {
				#EvalObligation & {
					id:   "issue.bottom.\(c)"
					kind: "cueBottom"
					command: ["cue", "export", "./\(input.contract.path)", "-e", c]
					expect: "fail"
				}
			},
		]
	}
})
