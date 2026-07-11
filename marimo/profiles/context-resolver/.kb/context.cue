package kb

import aperpatterns "apercue.ca/patterns@v0"

#Boundary: close({
	id:        string & !=""
	path:      string & !=""
	selectors: [...string]
})

boundary: close({
	id:   "context-resolver"
	kind: "self"
})

// The parent boundary owns discovery. Child modules remain independently valid.
boundaries: {
	self: #Boundary & {
		id:        "context-resolver"
		path:      "."
		selectors: ["self", "context", "marimo", "dag"]
	}
	cue: #Boundary & {
		id:        "code-intel-cue"
		path:      "../../code-intel/cue/.kb"
		selectors: ["code-intel", "cue"]
	}
	python: #Boundary & {
		id:        "code-intel-python"
		path:      "../../code-intel/python/.kb"
		selectors: ["code-intel", "python"]
	}
}

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

fragments: {
	workbook: #ContextFragment & {
		id:          "workbook"
		description: "Reactive Marimo DAG and Codex hook ingress"
		source: path: "../context_resolver.py"
		selectors: ["marimo", "reactive", "dag", "context", "filter", "codex", "hook"]
		priority: 100
	}
	boundary_manifest: #ContextFragment & {
		id:          "boundary_manifest"
		description: "Authoritative nested .kb boundary manifest and Apercue adapter"
		source: path: "context.cue"
		selectors: ["kb", "boundary", "registry", "self", "apercue", "graph"]
		priority: 80
	}
}

#PlanStep: close({
	id:          string & !=""
	description: string & !=""
	depends_on?: {[string]: true}
	fragments?:  {[string]: true}
	checks?:     {[string]: true}
	gates?:      {[string]: true}
})

steps: {
	normalize_prompt: #PlanStep & {
		id:          "normalize_prompt"
		description: "Normalize the submitted prompt into bounded retrieval inputs"
		fragments: {workbook: true}
	}
	load_boundaries: #PlanStep & {
		id:          "load_boundaries"
		description: "Load validated parent and child .kb graph projections"
		depends_on: {normalize_prompt: true}
		fragments: {boundary_manifest: true}
	}
	filter_context_graph: #PlanStep & {
		id:          "filter_context_graph"
		description: "Reactively select a bounded subgraph from Apercue projections"
		depends_on: {load_boundaries: true}
		fragments: {workbook: true, boundary_manifest: true}
	}
	project_packet: #PlanStep & {
		id:          "project_packet"
		description: "Project context fragments, implementation steps, checks, and gates"
		depends_on: {filter_context_graph: true}
		checks: {references_admitted: true, sources_bounded: true}
		gates: {packet_admitted: true}
	}
}

#Check: close({
	id:          string & !=""
	description: string & !=""
	command?:    string & !=""
	depends_on?: {[string]: true}
})

checks: {
	references_admitted: #Check & {
		id:          "references_admitted"
		description: "Every selected reference comes from a validated CUE graph projection"
	}
	sources_bounded: #Check & {
		id:          "sources_bounded"
		description: "Every materialized fragment source remains inside the repository"
	}
}

#Gate: close({
	id:          string & !=""
	description: string & !=""
	requires:    {[string]: true}
})

gates: packet_admitted: #Gate & {
	id:          "packet_admitted"
	description: "The Codex context packet is admitted only after boundary checks pass"
	requires: {references_admitted: true, sources_bounded: true}
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

#GraphProjection: close({
	valid:      true
	resources:  {[string]: _}
	topology:   {[string]: {[string]: true}}
	roots:      {[string]: true}
	leaves:     {[string]: true}
	dependents: {[string]: {[string]: true}}
})

context: #GraphProjection & {
	valid:      _contextGraphValid
	resources:  _contextResources
	topology:   contextGraph.topology
	roots:      contextGraph.roots
	leaves:     contextGraph.leaves
	dependents: contextGraph.dependents
}

workflow: #GraphProjection & {
	valid:      _workflowGraphValid
	resources:  _workflowResources
	topology:   workflowGraph.topology
	roots:      workflowGraph.roots
	leaves:     workflowGraph.leaves
	dependents: workflowGraph.dependents
}

#WorkbookRequest: close({
	schema: "factory.context-request.v0"
	event:  string & !=""
	prompt: string & !=""
	repo_root: string & !=""
	budget: close({
		maxFragments: int & >=1
		maxSteps:     int & >=1
		maxNodes:     int & >=1
		maxTokens:    int & >=1
	})
})

#WorkbookResult: close({
	schema:    "factory.context-packet.v0"
	authority: false
	generated: true
	transient: true
	admitted:  bool
	request:   #WorkbookRequest
	context_graph: _
	selected_fragments: [..._]
	implementation_plan: [..._]
	checks: [..._]
	gates: [..._]
	unresolved_context: [..._]
})

output: close({
	boundary:   boundary
	boundaries: boundaries
	fragments:  fragments
	steps:      steps
	checks:     checks
	gates:      _validatedGates
	context:    context
	workflow:   workflow
})
