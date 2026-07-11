package code_intel_python

import "quicue.ca/patterns"

execution: patterns.#ExecutionPlan & {
	resources: resources
	providers: providers
}

output: {
	summary:  execution.graph.metrics
	topology: execution.graph.topology
	plan:     execution.plan
}
