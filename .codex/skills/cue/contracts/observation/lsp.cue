package observation

import "github.com/fatb4f/factory/cue-skill/subject"

#LSPOutcome: "available" | "unavailable" | "startup-failure" | "protocol-error" | "timeout"

#Document: close({
	path:    subject.#RelativePOSIXPath
	digest:  subject.#Digest
	version: int & >=1
})

#LSPObserveRequest: close({
	protocol:      "cueprobe-lsp/v1"
	workspaceRoot: string
	moduleRoot:    string
	documents: [...#Document] & [_, ...]
	deadlineMillis:   int & >=1 & <=120000
	quiescenceMillis: int & >=1 & <=10000
	maxOutputBytes:   int & >=1024 & <=16777216
})

#LSPDiagnostic: close({
	uri:       string
	version?:  int
	severity?: int
	code?:     string
	message:   string
	range: close({
		start: close({line: int & >=0, character: int & >=0})
		end: close({line: int & >=0, character: int & >=0})
	})
})

#LSPObservation: close({
	protocol:      "cueprobe-lsp/v1"
	serverBinding: "cue-lsp-standard"
	outcome:       #LSPOutcome
	workspaceRoot: string
	moduleRoot:    string
	documents: [...#Document] & [_, ...]
	capabilities: _
	diagnostics: [...#LSPDiagnostic]
	timing: close({startedUnixNano: int & >=0, elapsedNanos: int & >=0})
	shutdown: close({requested: bool, acknowledged: bool, exited: bool})
	detail?: string
})
