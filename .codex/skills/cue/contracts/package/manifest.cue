package packagecontract

import kernel "github.com/fatb4f/factory/cue-skill/kernel"

#Role: close({
	id:   kernel.#KebabIdentifier
	root: string
	extensions: [...string] & [_, ...]
})

#Discovery: close({
	recursiveRegularFiles: true
	normalization:         "utf8-nfc-posix-package-relative"
	order:                 "normalized-utf8-bytes"
	rejectSymlinks:        true
	rejectDotSegments:     true
	excludeHiddenSegments: true
	rootFiles: [...string]
})

#PackageManifest: close({
	id:                      kernel.#KebabIdentifier
	packageFormatVersion:    "v1"
	kernelPackageID:         kernel.#KebabIdentifier
	kernelVersion:           "lattice-meta-v1"
	authorityPackage:        string
	subjectSchemaVersion:    "v1"
	canonicalizationVersion: "rfc8785-exact-cue-v1"
	runnerProtocols: ["cueprobe/v1"]
	evaluatorVersion: "v1"
	probeFamilies: [...kernel.#KebabIdentifier] & [_, ...]
	candidateClasses: [...kernel.#KebabIdentifier] & [_, ...]
	artifactRoles: [...#Role] & [_, ...]
	discovery: #Discovery
	requiredExports: [...kernel.#KebabIdentifier] & [_, ...]
})

manifest: #PackageManifest & {
	id:               "cue-kernel-probe-eval"
	kernelPackageID:  "lattice-meta-kernel"
	authorityPackage: "github.com/fatb4f/factory/cue-skill/kernel"
	probeFamilies: [
		"closed-ingress", "reference-resolution", "generated-output-role",
		"constructor-wiring", "state-key-set", "operation-reference-key-set",
		"no-widening", "negative-fixture", "publication",
	]
	candidateClasses: ["accepted", "open-ingress", "dangling-reference", "wrong-generated-role", "widened-state", "widened-operation-reference", "incomplete-publication", "invalid-negative-fixture"]
	artifactRoles: [
		{id: "kernel", root: "kernel", extensions: [".cue"]},
		{id: "package-manifest", root: "package", extensions: [".cue"]},
		{id: "probe-spec", root: "probe", extensions: [".cue", ".json"]},
		{id: "subject", root: "subject", extensions: [".cue", ".json"]},
		{id: "canonical-subject", root: "canonical", extensions: [".cue", ".json"]},
		{id: "candidate", root: "candidates", extensions: [".cue"]},
		{id: "fixture", root: "fixtures", extensions: [".cue", ".json"]},
		{id: "probe-observation", root: "observation", extensions: [".cue", ".json"]},
		{id: "lsp-observation", root: "observation", extensions: [".cue", ".json"]},
		{id: "evaluation", root: "eval", extensions: [".cue", ".json"]},
		{id: "coverage", root: "eval", extensions: [".cue", ".json"]},
		{id: "structural-gate", root: "gate", extensions: [".cue", ".json"]},
		{id: "artifact-bundle", root: "artifact", extensions: [".cue", ".json"]},
	]
	discovery: {
		rootFiles: ["cue.mod/module.cue"]
	}
	requiredExports: ["probe-subject", "canonical-subject", "probe-spec", "probe-observation", "lsp-observation", "probe-evaluation", "family-evaluation", "candidate-evaluation", "coverage", "suite", "package-gates", "artifact-bundle"]
}
