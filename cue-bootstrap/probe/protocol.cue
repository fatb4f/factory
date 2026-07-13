package probe

#Operation: "compile" | "lookup" | "unify" | "validate" | "subsume" | "project-json"

#ExecutionState: "completed" | "cue-rejection" | "unsupported" |
	"backend-error" | "backend-crash" | "timeout" | "protocol-error"

#Request: close({
	protocol:  "cue-workbook/v0"
	requestID: string & !=""
	operation: #Operation
	payload:   {...}
	limits: close({
		timeoutMS:      int & >0
		maxOutputBytes: int & >0
	})
})

#Response: close({
	protocol:       "cue-workbook/v0"
	requestID:      string & !=""
	executionState: #ExecutionState
	backend:        {...}
	stages:         {...}
	facts:          {...}
	diagnostics:    [...]
	metrics:        {...}
})
