package gate

import "github.com/fatb4f/factory/cue-skill/runner"

#PackageGates: close({
	observations: [runner.#StructuralGateObservation, runner.#StructuralGateObservation, runner.#StructuralGateObservation]
	structuralComplete: bool
	allSucceeded:       bool
})

#PackageGateEvaluation: #PackageGates & {
	observations: [runner.#StructuralGateObservation, runner.#StructuralGateObservation, runner.#StructuralGateObservation]
	_observations:      observations
	structuralComplete: _observations[0].id == "format" && _observations[1].id == "vet-structural" && _observations[2].id == "vet-concrete"
	allSucceeded:       _observations[0].exitCode == 0 && _observations[1].exitCode == 0 && _observations[2].exitCode == 0
}
