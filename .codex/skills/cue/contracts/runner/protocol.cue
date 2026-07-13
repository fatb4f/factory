package runner

import (
	kernel "github.com/fatb4f/factory/cue-skill/kernel"
	"github.com/fatb4f/factory/cue-skill/probe"
	"github.com/fatb4f/factory/cue-skill/subject"
)

#Bounds: close({
	timeoutMillis:  int & >=1 & <=120000
	maxOutputBytes: int & >=1024 & <=16777216
})

#ObserveRequest: close({
	protocol:   "cueprobe/v1"
	moduleRoot: string
	package:    string
	declaredFiles: [...subject.#RelativePOSIXPath] & [_, ...]
	probeID: kernel.#KebabIdentifier
	family:  kernel.#KebabIdentifier
	candidate: close({id: kernel.#KebabIdentifier, class: kernel.#KebabIdentifier})
	operation: probe.#Operation
	value:     kernel.#CueSelectorExpr
	operands: {[kernel.#KebabIdentifier]: kernel.#CueSelectorExpr}
	inputs: {[kernel.#KebabIdentifier]: _}
	build:               subject.#BuildOptions
	bounds:              #Bounds
	subjectExpectation?: subject.#ProbeSubject
})

#StructuralGateObservation: close({
	id:              "format" | "vet-structural" | "vet-concrete"
	template:        "cue-fmt-check" | "cue-vet-structural" | "cue-vet-concrete"
	exitCode:        int
	startedUnixNano: int & >=0
	elapsedNanos:    int & >=0
	stdout:          string
	stderr:          string
})
