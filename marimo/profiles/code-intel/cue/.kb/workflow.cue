package kb

#PlanStep: {
	id:          string
	description: string
	depends_on?: {[string]: true}
	fragments?:  {[string]: true}
	checks?:     {[string]: true}
	gates?:      {[string]: true}
}

steps: {
	select_context: #PlanStep & {
		id: "select_context", description: "Select authoritative context fragments"
		fragments: {workbook: true}
	}
	construct_plan: #PlanStep & {
		id: "construct_plan", description: "Construct the bounded implementation plan"
		depends_on: {select_context: true}
		checks: {references_admitted: true}
	}
	evaluate_controls: #PlanStep & {
		id: "evaluate_controls", description: "Evaluate declared checks and gates"
		depends_on: {construct_plan: true}
		gates: {execution_admitted: true}
	}
}
