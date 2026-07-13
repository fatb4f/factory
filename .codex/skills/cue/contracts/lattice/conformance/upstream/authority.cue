package upstream

import "list"

let cueRepository = "https://github.com/cue-lang/cue"
let cueRevision = "0c547ba896a57afc8990e69217d0743eb8d366c8"

authority: #AuthorityRecord & {
	id:           "cue-upstream-authority-v1"
	repository:   cueRepository
	revision:     cueRevision
	pinnedAt:     "2026-07-13T17:21:09Z"
	retrieval:    "github-contents-at-commit"
	movingTarget: false
	boundary: {
		"normative-specification": {role: "normative", mayDefineConcepts: true, requiredForAdmission: true}
		"standard-library-documentation": {role: "supporting", mayDefineConcepts: false, requiredForAdmission: false}
		"go-api-contract": {role: "normative", mayDefineConcepts: true, requiredForAdmission: true}
		"cli-behavior": {role: "normative", mayDefineConcepts: true, requiredForAdmission: true}
		"executable-test": {role: "supporting", mayDefineConcepts: false, requiredForAdmission: true}
		"explanatory-documentation": {role: "context-only", mayDefineConcepts: false, requiredForAdmission: false}
		"release-notes": {role: "context-only", mayDefineConcepts: false, requiredForAdmission: false}
		"version-identity": {role: "supporting", mayDefineConcepts: false, requiredForAdmission: true}
	}
	engine: {
		languageVersion: "v0.18.0"
		goModule: {
			path:     "cuelang.org/go"
			version:  "v0.18.0-0.dev.0.20260713132914-0c547ba896a5"
			revision: cueRevision
		}
		cli: {
			binary:   "cue"
			version:  "v0.18.0-0.dev.0.20260713132914-0c547ba896a5"
			revision: cueRevision
		}
	}
	artifacts: close({
		"language-specification": {
			id:         "language-specification", class: "normative-specification", role: "normative"
			repository: cueRepository, revision:         cueRevision
			path:       "doc/ref/spec.md", digest: {algorithm: "git-blob-sha1", value: "6a6e6fd631d96e7025e0e16cc9b54eaa6a5baa6a"}
			retrieval: "github-contents-at-commit", mutable: false
		}
		"standard-library-list": {
			id:         "standard-library-list", class: "standard-library-documentation", role: "supporting"
			repository: cueRepository, revision:        cueRevision
			path:       "pkg/list/list.go", digest: {algorithm: "git-blob-sha1", value: "2de2545fecf8643799dc42e731da54017fe90846"}
			retrieval: "github-contents-at-commit", mutable: false
		}
		"go-api-value": {
			id:         "go-api-value", class:   "go-api-contract", role: "normative"
			repository: cueRepository, revision: cueRevision
			path:       "cue/types.go", digest: {algorithm: "git-blob-sha1", value: "8164b5189beca47f835c14688c04d41f2f4fc6fc"}
			retrieval: "github-contents-at-commit", mutable: false
		}
		"cli-vet": {
			id:         "cli-vet", class:        "cli-behavior", role: "normative"
			repository: cueRepository, revision: cueRevision
			path:       "cmd/cue/cmd/vet.go", digest: {algorithm: "git-blob-sha1", value: "b0aae204af5529e301a696df3105751adc3bb6d1"}
			retrieval: "github-contents-at-commit", mutable: false
		}
		"subsumption-tests": {
			id:         "subsumption-tests", class: "executable-test", role: "supporting"
			repository: cueRepository, revision:    cueRevision
			path:       "internal/core/subsume/subsume_test.go", digest: {algorithm: "git-blob-sha1", value: "f7e7643f7c62715f6f6b09b9bfa2a9edcbda0e32"}
			retrieval: "github-contents-at-commit", mutable: false
		}
		"implementation-reference": {
			id:         "implementation-reference", class: "explanatory-documentation", role: "context-only"
			repository: cueRepository, revision:           cueRevision
			path:       "doc/ref/impl.md", digest: {algorithm: "git-blob-sha1", value: "d61b8a46229f1a1e7d1dea002c3c75cdd549f957"}
			retrieval: "github-contents-at-commit", mutable: false
		}
		"language-features-context": {
			id:         "language-features-context", class: "explanatory-documentation", role: "context-only"
			repository: cueRepository, revision:            cueRevision
			path:       "doc/context/language-features.md", digest: {algorithm: "git-blob-sha1", value: "5331bacd96bbb3be261f95e1f3c63007df1661bc"}
			retrieval: "github-contents-at-commit", mutable: false
		}
		"cue-version-identity": {
			id:         "cue-version-identity", class: "version-identity", role: "supporting"
			repository: cueRepository, revision:       cueRevision
			path:       "internal/cueversion/version.go", digest: {algorithm: "git-blob-sha1", value: "09f7bbf1806f3b56a688738dd1ce42ffda8b0cb5"}
			retrieval: "github-contents-at-commit", mutable: false
		}
	})
}

artifactIDs: list.SortStrings([for id, _ in authority.artifacts {id}])
expectedArtifactIDs: ["cli-vet", "cue-version-identity", "go-api-value", "implementation-reference", "language-features-context", "language-specification", "standard-library-list", "subsumption-tests"]

_artifactIdentityProof: {
	for id, artifact in authority.artifacts {
		"\(id)-key":      artifact.id & id
		"\(id)-repo":     artifact.repository & authority.repository
		"\(id)-revision": artifact.revision & authority.revision
		"\(id)-mutable":  artifact.mutable & false
	}
}

classBoundaryComplete:  len(authority.boundary) == 8
artifactSetComplete:    artifactIDs == expectedArtifactIDs && len(_artifactIdentityProof) == len(artifactIDs)*4
engineIdentityComplete: authority.engine.goModule.revision == authority.revision &&
	authority.engine.cli.revision == authority.revision &&
	authority.engine.goModule.version == "v0.18.0-0.dev.0.20260713132914-0c547ba896a5" &&
	authority.engine.cli.version == "v0.18.0-0.dev.0.20260713132914-0c547ba896a5" &&
			authority.engine.languageVersion == "v0.18.0"
authorityPinned: classBoundaryComplete && artifactSetComplete && engineIdentityComplete && !authority.movingTarget
