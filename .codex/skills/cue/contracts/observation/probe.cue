package observation

import (
	"github.com/fatb4f/factory/cue-skill/canonical"
	kernel "github.com/fatb4f/factory/cue-skill/kernel"
	"github.com/fatb4f/factory/cue-skill/probe"
	"github.com/fatb4f/factory/cue-skill/subject"
)

#ExecutionState: "completed" | "runner-failure" | "timeout" | "protocol-error" | "infrastructure-failure" | "subject-mismatch" | "source-changed"
#StageState:     "not-run" | "succeeded" | "failed"

#StageFact: close({
	state: #StageState
	code:  kernel.#KebabIdentifier
})

#Stages: close({
	request:      #StageFact
	subject:      #StageFact
	load:         #StageFact
	build:        #StageFact
	lookup:       #StageFact
	precondition: #StageFact
	operation:    #StageFact
	projection:   #StageFact
})

#DigestPair: close({path: subject.#RelativePOSIXPath, before: subject.#Digest, after: subject.#Digest})

#OperationFacts: close({
	semanticBottom:     "observed-true" | "observed-false" | "not-observed"
	concrete:           "observed-true" | "observed-false" | "not-observed"
	projectionObserved: bool
	projectionBefore:   canonical.#CanonicalSubjectValue
	projectionAfter:    canonical.#CanonicalSubjectValue
})

#Diagnostic: close({
	stage:   "request" | "subject" | "load" | "build" | "lookup" | "precondition" | "operation" | "concrete" | "projection" | "internal"
	code:    kernel.#KebabIdentifier
	message: string
})

#ProbeObservation: close({
	protocol:      "cueprobe/v1"
	probeID:       kernel.#KebabIdentifier
	operation:     probe.#Operation
	subject:       subject.#ProbeSubject
	subjectDigest: subject.#Digest
	adapter: close({id: "cue-go-api", protocol: "cueprobe/v1", engineVersion: string})
	executionState: #ExecutionState
	timing: close({startedUnixNano: int & >=0, elapsedNanos: int & >=0})
	stages: #Stages
	sourceDigests: [...#DigestPair] & [_, ...]
	facts: #OperationFacts
	diagnostics: [...#Diagnostic]

	if executionState == "source-changed" {
		facts: {
			semanticBottom:     "not-observed"
			concrete:           "not-observed"
			projectionObserved: false
		}
	}
})
