package interface

#ID: string & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#Command: close({id: #ID, argv: [...string] & [_, ...]})
#Role: close({id: #ID, path: string})

#SkillInterface: close({
	id:                "cue-skill-interface-v1"
	version:           "v1"
	skillPath:         ".codex/skills/cue/SKILL.md"
	packageManifestID: "cue-kernel-probe-eval"
	kernelPackages: close({"lattice-meta-kernel": "contracts/kernel"})
	runner: close({
		binary:   "runner/cueprobe"
		protocol: "cueprobe/v1"
		subcommands: ["observe", "lsp-observe", "skill-check"]
	})
	lsp: close({id: "cue-lsp-standard", argv: ["cue", "lsp"]})
	structuralGates: close({
		"cue-fmt-check": #Command & {id: "cue-fmt-check", argv: ["cue", "fmt", "--check", "--files", "<declared-files>"]}
		"cue-vet-structural": #Command & {id: "cue-vet-structural", argv: ["cue", "vet", "-c=false", "<declared-package>"]}
		"cue-vet-concrete": #Command & {id: "cue-vet-concrete", argv: ["cue", "vet", "-c", "<declared-concrete-surface>"]}
	})
	artifactRoles: [...#Role] & [_, ...]
	stopConditions: [...#ID] & [_, ...]
	files: close({
		"package-manifest":  "contracts/package/manifest.cue"
		"runner-protocol":   "contracts/runner/protocol.cue"
		"probe-contract":    "contracts/probe/spec.cue"
		"subject-contract":  "contracts/subject/subject.cue"
		"probe-observation": "contracts/observation/probe.cue"
		"lsp-observation":   "contracts/observation/lsp.cue"
		"suite-evaluator":   "contracts/eval/suite.cue"
		"artifact-bundle":   "contracts/artifact/bundle.cue"
	})
})

manifest: #SkillInterface & {
	artifactRoles: [
		{id: "package-manifest", path: "contracts/package"},
		{id: "kernel", path: "contracts/kernel"},
		{id: "probe-spec", path: "contracts/probe"},
		{id: "subject", path: "contracts/subject"},
		{id: "canonical-subject", path: "contracts/canonical"},
		{id: "probe-observation", path: "contracts/observation"},
		{id: "lsp-observation", path: "contracts/observation"},
		{id: "evaluation", path: "contracts/eval"},
		{id: "coverage", path: "contracts/eval"},
		{id: "structural-gate", path: "contracts/gate"},
		{id: "artifact-bundle", path: "contracts/artifact"},
	]
	stopConditions: ["source-changed", "subject-mismatch", "protocol-error", "timeout", "infrastructure-failure", "stale-interface"]
}
