package agentcontextresolver

import "list"

#MatcherMode:
	"word" |
	"phrase" |
	"pathGlob" |
	"regexWordBoundary"

#MatcherTerm: close({
	value: string & !=""
	mode: #MatcherMode
	caseFold: true
	rawContains: false
})

#RequiredMatcherGroup: close({
	id: #DeclaredID
	terms: [#MatcherTerm, ...#MatcherTerm]
	semantics: *"all" | "all" | "any"
})

#ExactPhraseTrigger: #MatcherTerm & {
	mode: "phrase"
}

#PathTrigger: close({
	glob: string & !=""
	repoLocal: true
	rawContains: false
})

#WordBoundaryTerm: close({
	term: string & !=""
	boundary: "word"
	regexBoundary: true
	rawContains: false
})

#PromptMatcher: close({
	all: *([]) | [...#RequiredMatcherGroup]
	any: *([]) | [...#MatcherTerm]
	none: *([]) | [...#MatcherTerm]
	phrases: *([]) | [...#ExactPhraseTrigger]
	paths: *([]) | [...#PathTrigger]
	wordTerms: *([]) | [...#WordBoundaryTerm]
	semantics: close({
		rawSubstringAllowed: false
		genericTermMayMatchAlone: false
	})
})

#PromptRoute: close({
	id: #DeclaredID
	matcher: #PromptMatcher
	selects: [...#DeclaredID] & [_, ...]
	invokes: [...#DeclaredID] & [_, ...]
	hint: string & !=""
	priority: int & >=0
})

_genericStandaloneTerms: ["provider", "providers", "dotfiles"]

#PromptMatcherGuard: close({
	route: #PromptRoute

	if len(route.matcher.all) == 0 && len(route.matcher.phrases) == 0 && len(route.matcher.paths) == 0 {
		for term in route.matcher.any {
			if list.Contains(_genericStandaloneTerms, term.value) {
				_genericAnyTermCanMatchAlone: _|_
			}
		}
		for term in route.matcher.wordTerms {
			if list.Contains(_genericStandaloneTerms, term.term) {
				_genericWordTermCanMatchAlone: _|_
			}
		}
	}
})

promptMatcherValidation: {
	for promptRoute in promptRoutes {
		"\(promptRoute.id)": #PromptMatcherGuard & {
			route: promptRoute
		}
	}
}

promptRoutes: [...#PromptRoute] & [
	{
		id: "resolver"
		matcher: {
			all: [{
				id: "resolver-core"
				semantics: "any"
				terms: [
					{value: "resolver", mode: "word"},
					{value: "context", mode: "word"},
					{value: "prompt", mode: "word"},
					{value: "hook", mode: "word"},
					{value: "turnstart", mode: "word"},
				]
			}]
			any: [
				{value: "agent-context-resolver", mode: "phrase"},
				{value: "context resolver", mode: "phrase"},
			]
			none: [
				{value: "provider execution", mode: "phrase"},
				{value: "runtime execution", mode: "phrase"},
			]
			phrases: [
				{value: "agent context resolver", mode: "phrase"},
				{value: "resolve agent context", mode: "phrase"},
			]
			paths: [
				{glob: "contracts/plugin-bundle/agent-context-resolver/**", repoLocal: true},
				{glob: ".codex/plugins/agent-context-resolver/**", repoLocal: true},
			]
			wordTerms: [
				{term: "resolver", boundary: "word", regexBoundary: true},
				{term: "hook", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["agent-context-resolver.authority"]
		invokes: ["resolver.inspect.current", "resolver.plan.compile"]
		hint:     "Apply the resolver lifecycle and generated-fragment boundary."
		priority: 100
	},
	{
		id: "patch-stack"
		matcher: {
			all: [{
				id: "patch-stack-core"
				semantics: "any"
				terms: [
					{value: "patch", mode: "word"},
					{value: "stack", mode: "word"},
					{value: "rebase", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [{value: "patch stack", mode: "phrase"}]
			paths: [{glob: "contracts/vcs/**", repoLocal: true}]
			wordTerms: [
				{term: "patch", boundary: "word", regexBoundary: true},
				{term: "rebase", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["vcs.patch-stack"]
		invokes: ["vcs.patch-stack.inspect"]
		hint:     "Apply the declared patch-stack workflow."
		priority: 80
	},
	{
		id: "mcp"
		matcher: {
			all: [{
				id: "mcp-core"
				semantics: "any"
				terms: [
					{value: "mcp", mode: "word"},
					{value: "tool", mode: "word"},
					{value: "server", mode: "word"},
				]
			}]
			any: []
			none: [{value: "provider execution", mode: "phrase"}]
			phrases: [{value: "mcp evidence", mode: "phrase"}]
			paths: [{glob: "contracts/protocols/mcp/**", repoLocal: true}]
			wordTerms: [{term: "mcp", boundary: "word", regexBoundary: true}]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["mcp.evidence-plane"]
		invokes: ["mcp.evidence.inspect"]
		hint:     "Keep MCP results in the evidence plane."
		priority: 80
	},
	{
		id: "skill"
		matcher: {
			all: [{
				id: "skill-core"
				semantics: "any"
				terms: [
					{value: "skill", mode: "word"},
					{value: "hook", mode: "word"},
					{value: "codex", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [
				{value: "agent skill", mode: "phrase"},
				{value: "codex hook", mode: "phrase"},
			]
			paths: [
				{glob: "contracts/agent-skill/**", repoLocal: true},
				{glob: ".codex/skills/**", repoLocal: true},
			]
			wordTerms: [
				{term: "skill", boundary: "word", regexBoundary: true},
				{term: "codex", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["agent-skill.projection"]
		invokes: ["agent-skill.projection.validate"]
		hint:     "Apply the generated agent skill and hook projection constraints."
		priority: 70
	},
	{
		id: "context-packet"
		matcher: {
			all: [{
				id: "context-packet-core"
				semantics: "any"
				terms: [
					{value: "context", mode: "word"},
					{value: "packet", mode: "word"},
					{value: "dependency", mode: "word"},
					{value: "projection", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [
				{value: "context packet", mode: "phrase"},
				{value: "dependency projection", mode: "phrase"},
			]
			paths: [{glob: "contracts/context/packet/**", repoLocal: true}]
			wordTerms: [
				{term: "context", boundary: "word", regexBoundary: true},
				{term: "packet", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["resolver.context-packet"]
		invokes: ["resolver.context-packet.inspect"]
		hint:     "Apply the context packet projection workflow."
		priority: 70
	},
	{
		id: "repo"
		matcher: {
			all: [{
				id: "repo-core"
				semantics: "any"
				terms: [
					{value: "repository", mode: "word"},
					{value: "generated", mode: "word"},
					{value: "fixture", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [
				{value: "repo lifecycle", mode: "phrase"},
				{value: "generated output", mode: "phrase"},
			]
			paths: [
				{glob: "contracts/repo/**", repoLocal: true},
				{glob: "generated/**", repoLocal: true},
				{glob: "fixtures/**", repoLocal: true},
			]
			wordTerms: [
				{term: "repository", boundary: "word", regexBoundary: true},
				{term: "fixture", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["repo.lifecycle"]
		invokes: ["repo.lifecycle.validate"]
		hint:     "Preserve repository lifecycle and generated-output boundaries."
		priority: 70
	},
]
