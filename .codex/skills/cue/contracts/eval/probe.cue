package eval

import (
	"list"

	"github.com/fatb4f/factory/cue-skill/observation"
	"github.com/fatb4f/factory/cue-skill/probe"
	subjectpkg "github.com/fatb4f/factory/cue-skill/subject"
)

#Verdict: "unifies" | "bottoms" | "concrete" | "incomplete" | "projection-match" | "projection-mismatch" | "runner-error"

#ProbeEvaluationShape: close({
	probeID:          string
	candidate:        string
	family:           string
	subject:          subjectpkg.#ProbeSubject
	identityValid:    bool
	evidenceComplete: bool
	verdict:          #Verdict
	permitted:        bool
	satisfied:        bool
	diagnosticCodes: [...string]
})

#ProbeEvaluation: #ProbeEvaluationShape & {
	Spec:        probe.#ProbeSpec
	Observation: observation.#ProbeObservation
	Subject:     subjectpkg.#ProbeSubject
	Digest:      subjectpkg.#Digest

	_spec:        Spec
	_observation: Observation
	_subject:     Subject
	_digest:      Digest

	probeID:   _spec.id
	candidate: _spec.candidate
	family:    _spec.family
	subject:   _subject

	_identity: _observation.probeID == _spec.id &&
		_observation.operation == _spec.operation &&
		_observation.subject == _subject &&
		_observation.subjectDigest == _digest &&
		_observation.adapter.protocol == "cueprobe/v1"
	_sourceChanged: list.Contains([for pair in _observation.sourceDigests {pair.before == pair.after}], false)
	_sourceStable:  !_sourceChanged
	_preconditions: _observation.stages.load.state == "succeeded" &&
		_observation.stages.build.state == "succeeded" &&
		_observation.stages.lookup.state == "succeeded" &&
				_observation.stages.precondition.state == "succeeded"
	_semanticObserved: _observation.executionState == "completed" && _sourceStable && _preconditions &&
				_observation.stages.operation.state == "succeeded"
	_projectionMatch: _observation.facts.projectionBefore == _observation.facts.projectionAfter
	verdict:          #Verdict
	_verdict:         verdict

	identityValid:    _identity
	evidenceComplete: _identity && _sourceStable && _preconditions &&
		_observation.stages.operation.state == "succeeded"

	if !_semanticObserved {
		verdict: "runner-error"
	}
	if _semanticObserved && _spec.operation == "project" && _observation.facts.projectionObserved && _projectionMatch {
		verdict: "projection-match"
	}
	if _semanticObserved && _spec.operation == "project" && _observation.facts.projectionObserved && !_projectionMatch {
		verdict: "projection-mismatch"
	}
	if _semanticObserved && _spec.operation == "validate-concrete" && _observation.facts.concrete == "observed-true" {
		verdict: "concrete"
	}
	if _semanticObserved && _spec.operation == "validate-concrete" && _observation.facts.concrete == "observed-false" {
		verdict: "incomplete"
	}
	if _semanticObserved && _spec.operation != "project" && _spec.operation != "validate-concrete" && _observation.facts.semanticBottom == "observed-true" {
		verdict: "bottoms"
	}
	if _semanticObserved && _spec.operation != "project" && _spec.operation != "validate-concrete" && _observation.facts.semanticBottom == "observed-false" {
		verdict: "unifies"
	}

	permitted: _spec.policy.permitted[_verdict] == true
	satisfied: identityValid && evidenceComplete && permitted
	diagnosticCodes: [for diagnostic in _observation.diagnostics {diagnostic.code}]
}
