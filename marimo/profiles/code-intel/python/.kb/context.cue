package kb

import aperpatterns "apercue.ca/patterns@v0"

#ContextFragment: close({
	id:          string & !=""
	description: string & !=""
	source: close({
		path:   string & !=""
		symbol?: string & !=""
		lines?: close({start: int & >=1, end: int & >=start})
	})
	selectors?:  [...string]
	depends_on?: {[string]: true}
	priority?:   int
})

fragments: workbook: #ContextFragment & {
	id:          "workbook"
	description: "Python code-intelligence Marimo workbook boundary"
	source: path: "../code_intel_python.py"
	selectors: ["python", "code-intel", "workbook"]
	priority: 100
}

#PlanStep: close({
	id:          string & !=""
	description: string & !=""
	depends_on?: {[string]: true}
	fragments?:  {[string]: true}
	checks?:     {[string]: true}
	gates?:      {[string]: true}
})

steps: inspect_python: #PlanStep & {
	id:          "inspect_python"
	description: "Inspect Python-specific context before implementation"
	fragments: {workbook: true}
	checks: {references_admitted: true}
	gates: {execution_admitted: true}
}

#Check: close({
	id:          string & !=""
	description: string & !=""
	command?:    string & !=""
	depends_on?: {[string]: true}
})

checks: references_admitted: #Check & {
	id:          "references_admitted"
	description: "Every packet reference resolves to an admitted Python declaration"
}

#Gate: close({
	id:          string & !=""
	description: string & !=""
	requires:    {[string]: true}
})

gates: execution_admitted: #Gate & {
	id:          "execution_admitted"
	description: "Python implementation is admitted after reference validation"
	requires: {references_admitted: true}
}

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

output: close({
	fragments: fragments
	steps:     steps
	checks:    checks
	gates:     _validatedGates
	context:   context
	workflow:  workflow
})
