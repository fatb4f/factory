package workstreams

#Workstream: {
	aliases: [string, ...string]
	status: "active" | "merged" | "documented" | "unresolved"
	summary: string
	if status != "unresolved" {
		repo: string & =~"^[^/]+/[^/]+$"
		url: string & =~"^https://github.com/"
	}
	if status == "merged" {
		mergeSHA: string & =~"^[0-9a-f]{40}$"
	}
}

workstreams: [string]: #Workstream
workstreams: {
	"semagrams-dpi": {
		aliases: ["DPI","datom lowering","feat/dpi-cue-datom-lowering"]
		status: "merged"
		summary: "CUE fact extraction, lowering, and validation."
		repo: "fatb4f/semagrams"
		url: "https://github.com/fatb4f/semagrams/pull/3"
		mergeSHA: "6fdaa7d6123cd32ae532d184794fe18eb5315bba"
	}
	"semagrams-patchplan": {
		aliases: ["ordered patches","TypeScript compiler","Patchplan"]
		status: "documented"
		summary: "TypeScript patch qualification prototype."
		repo: "fatb4f/semagrams"
		url: "https://github.com/fatb4f/semagrams/blob/main/patchplan/README.md"
	}
	"oracle-run-evidence": {
		aliases: ["Oracle","OTel","OpenTelemetry"]
		status: "documented"
		summary: "Structured run capture and reconstruction."
		repo: "fatb4f/oracle"
		url: "https://github.com/fatb4f/oracle/blob/main/docs/overview.md"
	}
	"fixpoint-evaluator": {
		aliases: ["fixpoint","fixed point","OTel fixpoint"]
		status: "unresolved"
		summary: "Implementation location to verify."
	}
	"term": {
		aliases: ["Term"]
		status: "unresolved"
		summary: "Repository or path to verify."
	}
	"logograms": {
		aliases: ["Logograms","logogram"]
		status: "unresolved"
		summary: "Relationship to Semagrams to verify."
	}
}
