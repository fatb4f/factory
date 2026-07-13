package artifact

import (
	"list"
	"github.com/fatb4f/factory/cue-skill/subject"
)

#Artifact: close({id: string, role: string, subjectDigest: subject.#Digest, digest: subject.#Digest})

#Bundle: close({
	id:            string
	packageID:     string
	subject:       subject.#ProbeSubject
	subjectDigest: subject.#Digest
	artifacts: [...#Artifact] & [_, ...]
	publicationIDs: [...string]

	_ids: [for artifact in artifacts {artifact.id}]
	_unique: list.UniqueItems(_ids)
	_singleSubject: !list.Contains([for artifact in artifacts {
		artifact.subjectDigest == subjectDigest
	}], false)
	_roles: [for artifact in artifacts {artifact.role}]
	_requiredRoles: ["package-manifest", "kernel", "probe-spec", "subject", "canonical-subject", "probe-observation", "lsp-observation", "probe-evaluation", "family-evaluation", "candidate-evaluation", "coverage", "suite", "structural-gate"]
	_complete: !list.Contains([for role in _requiredRoles {list.Contains(_roles, role)}], false)

	complete: _unique && _singleSubject && _complete
})
