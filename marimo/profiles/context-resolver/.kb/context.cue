package kb

#Boundary: close({
	id:        string & !=""
	path:      string & !=""
	selectors: [...string]
})

boundary: close({
	id:   "context-resolver"
	kind: "self"
})

// The parent boundary owns federation. Child modules remain independently valid.
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
		description: "Reactive Marimo DAG, context graph runtime, and Codex hook ingress"
		source: path: "../context_resolver.py"
		selectors: ["marimo", "reactive", "dag", "context", "filter", "codex", "hook"]
		priority: 100
	}
	boundary_manifest: #ContextFragment & {
		id:          "boundary_manifest"
		description: "Authoritative nested .kb boundary manifest"
		source: path: "context.cue"
		selectors: ["kb", "boundary", "registry", "self"]
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
		description: "Load the parent and admitted child .kb projections"
		depends_on: {normalize_prompt: true}
		fragments: {boundary_manifest: true}
	}
	filter_context_graph: #PlanStep & {
		id:          "filter_context_graph"
		description: "Filter and close the context graph around relevant seeds"
		depends_on: {load_boundaries: true}
		fragments: {workbook: true}
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
		description: "Every selected graph edge resolves to an admitted declaration"
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
	gates:      gates
})
