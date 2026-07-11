package kb

import aperpatterns "apercue.ca/patterns@v0"

_fragmentNames: {for id, _ in fragments {(id): true}}
_checkNames: {for id, _ in checks {(id): true}}
_gateNames: {for id, _ in gates {(id): true}}

_contextInput: {
	for id, fragment in fragments {
		let graphID = "fragment.\(id)"
		let dependencies = *fragment.depends_on | {}
		(graphID): {
			name: graphID
			"@type": {ContextFragment: true}
			kind:        "fragment"
			local_id:    id
			description: fragment.description
			source:      fragment.source
			selectors:   *fragment.selectors | []
			priority:    *fragment.priority | 0
			depends_on: {
				for dependency, _ in dependencies {
					"fragment.\(dependency)": true
				}
			}
		}
	}
}

contextGraph: aperpatterns.#Graph & {Input: _contextInput}
_contextGraphValid: true & contextGraph.valid
_contextResources: {
	for id, resource in contextGraph.resources {
		(id): resource & {
			depth:     resource._depth
			ancestors: resource._ancestors
		}
	}
}

_workflowInput: {
	for id, step in steps {
		let graphID = "step.\(id)"
		let dependencies = *step.depends_on | {}
		(graphID): {
			name: graphID
			"@type": {PlanStep: true}
			kind:        "step"
			local_id:    id
			description: step.description
			depends_on: {
				for dependency, _ in dependencies {
					"step.\(dependency)": true
				}
			}
			fragments: {
				for fragmentID, _ in *step.fragments | {} {
					(fragmentID): true & _fragmentNames[fragmentID]
				}
			}
			checks: {
				for checkID, _ in *step.checks | {} {
					(checkID): true & _checkNames[checkID]
				}
			}
			gates: {
				for gateID, _ in *step.gates | {} {
					(gateID): true & _gateNames[gateID]
				}
			}
		}
	}
}

workflowGraph: aperpatterns.#Graph & {Input: _workflowInput}
_workflowGraphValid: true & workflowGraph.valid
_workflowResources: {
	for id, resource in workflowGraph.resources {
		(id): resource & {
			depth:     resource._depth
			ancestors: resource._ancestors
		}
	}
}

_validatedGates: {
	for id, gate in gates {
		(id): gate & {
			requires: {
				for checkID, _ in gate.requires {
					(checkID): true & _checkNames[checkID]
				}
			}
		}
	}
}

context: {
	valid:      _contextGraphValid
	resources:  _contextResources
	topology:   contextGraph.topology
	roots:      contextGraph.roots
	leaves:     contextGraph.leaves
	dependents: contextGraph.dependents
}

workflow: {
	valid:      _workflowGraphValid
	resources:  _workflowResources
	topology:   workflowGraph.topology
	roots:      workflowGraph.roots
	leaves:     workflowGraph.leaves
	dependents: workflowGraph.dependents
}

topology: workflow.topology
