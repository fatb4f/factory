package upstream

import "strings"

#NonEmptyString:        string & strings.MinRunes(1)
#ID:                    #NonEmptyString & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#GitCommit:             string & =~"^[0-9a-f]{40}$"
#GitBlob:               string & =~"^[0-9a-f]{40}$"
#Semver:                string & =~"^v[0-9]+\\.[0-9]+\\.[0-9]+$"
#ResolvedEngineVersion: "v0.18.0-0.dev.0.20260713132914-0c547ba896a5"

#SourceClass:
	"normative-specification" |
	"standard-library-documentation" |
	"go-api-contract" |
	"cli-behavior" |
	"executable-test" |
	"explanatory-documentation" |
	"release-notes" |
	"version-identity"

#AuthorityRole:   "normative" | "supporting" | "context-only"
#DigestAlgorithm: "git-blob-sha1"

#ClassPolicy: close({
	id:                   #SourceClass
	role:                 #AuthorityRole
	mayDefineConcepts:    bool
	requiredForAdmission: bool
})

#Digest: close({
	algorithm: #DigestAlgorithm
	value:     #GitBlob
})

#ArtifactIdentity: close({
	id:         #ID
	class:      #SourceClass
	role:       #AuthorityRole
	repository: "https://github.com/cue-lang/cue"
	revision:   #GitCommit
	path:       #NonEmptyString & !~"^(https?://|refs/heads/|refs/tags/)"
	digest:     #Digest
	retrieval:  "github-contents-at-commit"
	mutable:    false
})

#ModuleIdentity: close({
	path:     "cuelang.org/go"
	version:  #ResolvedEngineVersion
	revision: #GitCommit
})

#CLIIdentity: close({
	binary:   "cue"
	version:  #ResolvedEngineVersion
	revision: #GitCommit
})

#EngineIdentity: close({
	languageVersion: #Semver
	goModule:        #ModuleIdentity
	cli:             #CLIIdentity
})

#AuthorityBoundary: close({
	"normative-specification": #ClassPolicy & {id: "normative-specification"}
	"standard-library-documentation": #ClassPolicy & {id: "standard-library-documentation"}
	"go-api-contract": #ClassPolicy & {id: "go-api-contract"}
	"cli-behavior": #ClassPolicy & {id: "cli-behavior"}
	"executable-test": #ClassPolicy & {id: "executable-test"}
	"explanatory-documentation": #ClassPolicy & {id: "explanatory-documentation"}
	"release-notes": #ClassPolicy & {id: "release-notes"}
	"version-identity": #ClassPolicy & {id: "version-identity"}
})

#AuthorityRecord: close({
	id:           "cue-upstream-authority-v1"
	repository:   "https://github.com/cue-lang/cue"
	revision:     #GitCommit
	pinnedAt:     #NonEmptyString
	retrieval:    "github-contents-at-commit"
	movingTarget: false
	boundary:     #AuthorityBoundary
	engine:       #EngineIdentity
	artifacts: {[#ID]: #ArtifactIdentity}
})

// Negative-fixture observations contain execution facts only. The evaluator,
// not the producer, derives whether the expected bottom was established.
#NegativeFixtureObservation: close({
	fixtureKey:     #NonEmptyString
	target:         #NonEmptyString
	protocol:       "cueprobe/v1"
	sourceRevision: #GitCommit
	executionState: "completed" | "runner-failure" | "timeout" | "protocol-error" | "infrastructure-failure"
	stages: close({
		load:         "succeeded" | "failed" | "not-run"
		lookup:       "succeeded" | "failed" | "not-run"
		precondition: "succeeded" | "failed" | "not-run"
		operation:    "succeeded" | "failed" | "not-run"
	})
	semanticBottom: "observed-true" | "observed-false" | "not-observed"
})

#NegativeFixtureEvaluationShape: close({
	fixtureKey:       #NonEmptyString
	evidenceComplete: bool
	verdict:          "bottoms" | "unifies" | "incomplete" | "runner-error"
	satisfied:        bool
})

#NegativeFixtureEvaluation: {
	Fixture: close({target: #NonEmptyString, value: _})
	Observation: #NegativeFixtureObservation

	_fixture:     Fixture
	_observation: Observation
	_identity:    _observation.fixtureKey == _fixtureKey &&
		_observation.target == _fixture.target &&
			_observation.sourceRevision == authority.revision
	_fixtureKey:    _observation.fixtureKey
	_preconditions: _observation.stages.load == "succeeded" &&
		_observation.stages.lookup == "succeeded" &&
				_observation.stages.precondition == "succeeded"
	_semanticObserved: _identity && _observation.executionState == "completed" &&
		_preconditions && _observation.stages.operation == "succeeded"

	Result: #NegativeFixtureEvaluationShape & {
		fixtureKey:       _fixtureKey
		evidenceComplete: _semanticObserved
		verdict:          "bottoms" | "unifies" | "incomplete" | "runner-error"
		_resultComplete:  evidenceComplete
		_resultVerdict:   verdict

		if _observation.executionState != "completed" {
			verdict: "runner-error"
		}
		if _observation.executionState == "completed" && !_semanticObserved {
			verdict: "incomplete"
		}
		if _semanticObserved && _observation.semanticBottom == "observed-true" {
			verdict: "bottoms"
		}
		if _semanticObserved && _observation.semanticBottom == "observed-false" {
			verdict: "unifies"
		}
		if _semanticObserved && _observation.semanticBottom == "not-observed" {
			verdict: "incomplete"
		}

		satisfied: _resultComplete && _resultVerdict == "bottoms"
	}
}
