package code_intel_python

import "quicue.ca/patterns@v0"

execution: patterns.#ExecutionPlan & {
	resources: resources
	providers: providers
}

output: {
	summary:  resources: len(resources)
	topology: execution.graph.topology
	plan:     execution.plan
}
