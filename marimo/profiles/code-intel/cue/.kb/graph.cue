package kb

import aperpatterns "apercue.ca/patterns@v0"

_graphInput: {
	for id, step in steps {
		(id): {name: id, "@type": {PlanStep: true}, depends_on: *step.depends_on | {}}
	}
}

_graph: aperpatterns.#Graph & {Input: _graphInput}
_graphValid: true & _graph.valid
topology: _graph.topology
