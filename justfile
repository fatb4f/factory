set shell := ["sh", "-eu", "-c"]

scaffold-contract-slice slice_id title out force="false":
	python3 - '{{slice_id}}' '{{title}}' '{{out}}' '{{force}}' <<'PY'
	import json
	import re
	import subprocess
	import sys
	from pathlib import Path

	slice_id, title, out, force = sys.argv[1:5]

	if not slice_id:
	    raise SystemExit("slice_id is required")
	if not title:
	    raise SystemExit("title is required")
	if not out:
	    raise SystemExit("out is required")
	if out.startswith("/") or out.startswith("../") or "/../" in out or out.endswith("/.."):
	    raise SystemExit("out must be a repo-relative path without parent traversal")

	root = Path(out)
	manifest = root / "manifest.cue"
	checks_dir = root / "checks"
	checks = checks_dir / "manifest.cue"
	package_name = "slice" + re.sub(r"[^0-9A-Za-z_]", "_", slice_id)
	checks_package = package_name + "checks"

	if force != "true":
	    for path in (manifest, checks):
	        if path.exists():
	            raise SystemExit(f"{path} exists; pass force=true to overwrite")

	checks_dir.mkdir(parents=True, exist_ok=True)

	cue_expr = "[e]xpression:"
	invalid_flag = "[i]sInvalid: true"
	truth_flag = "[o]peratorTruthFlag"
	inline_ctor = "[i]nline constructor"
	generated_authority = "[g]enerated.*authority"
	target_top = "[t]arget:[[:space:]]*_"
	input_top = "[i]nput:[[:space:]]*_"
	default_fallback = r"\*\("
	top_fallback = r"\| _"
	raw_bottom = r"_\|_"
	forbidden_pattern = "|".join([
	    target_top,
	    input_top,
	    cue_expr,
	    invalid_flag,
	    truth_flag,
	    inline_ctor,
	    generated_authority,
	    default_fallback,
	    top_fallback,
	    raw_bottom,
	])

	manifest_text = r'''package __PACKAGE__

import impl "github.com/fatb4f/factory/contracts/meta"

_sliceID: __SLICE_ID__
_title: __TITLE__
_root: __ROOT__

#SkeletonAdmissible: close({
	requiredField: string & !=""
	generatedAuthority?: false
})

_workflow: [
	for step in impl.constructorPipeline {
		order:         step.order
		id:            step.id
		instantiateAt: step.instantiateAt
	},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#SkeletonAdmissible"
			role: "scaffolded admissible contract boundary for \(_sliceID)"
			requiredFields: ["requiredField", "generatedAuthority"]
			constraints: [
				"replace this primitive with the concrete contract shape",
				"generated artifacts remain evidence only",
			]
			closed: true
		}
	},
]

_observed: [
	impl.#MakeObservedSurface & {
		in: {
			name: "ObservedSkeletonRuntime"
			role: "scaffolded observed surface for \(_sliceID)"
			factFields: ["requiredField", "generatedAuthority"]
			constraints: ["replace with concrete observed facts"]
		}
	},
]

_admissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name:            "AdmissibleSkeletonContract"
			role:            "scaffolded admissible contract for \(_sliceID)"
			observedSurface: "ObservedSkeletonRuntime"
			requiredFields: ["requiredField"]
			rejectedFields: ["generatedAuthority"]
			constraints: ["generatedAuthority must remain false or absent"]
		}
	},
]

_predicates: [
	impl.#MakePredicateSet & {
		in: {
			name:              "#SkeletonPredicates"
			role:              "scaffolded derived predicates for \(_sliceID)"
			observedSurface:   "ObservedSkeletonRuntime"
			admissibleSurface: "AdmissibleSkeletonContract"
			derivedPredicates: ["generated-artifacts-are-evidence-only"]
			constraints: ["predicate truth derives from concrete structure"]
		}
	},
]

_promotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name:              "#SkeletonPromotionCandidate"
			role:              "scaffolded promotion candidate for \(_sliceID)"
			observedSurface:   "ObservedSkeletonRuntime"
			admissibleSurface: "AdmissibleSkeletonContract"
			predicateSet:      "#SkeletonPredicates"
			controlPredicates: ["generated-artifacts-are-evidence-only"]
			admissibilityEvidence: [
				"cue vet ./\(_root)",
				"cue export ./\(_root) -e contractSliceManifest",
			]
			constraints: ["replace with concrete promotion evidence"]
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["AdmissibleSkeletonContract"]
		observed: ["ObservedSkeletonRuntime"]
		candidates: ["#SkeletonPromotionCandidate"]
		fixtures: ["negative.generatedAuthorityAccepted"]
		checks: ["_negativeBottomChecks.generatedAuthorityAccepted"]
		publicExports: [
			"contractSliceManifest",
			"contractSliceValidationPlan",
			"contractSliceCompletionReport",
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name:     "generatedAuthorityAccepted"
			violates: "generated-artifacts-are-evidence-only"
			refusal:  "keep generated artifacts as evidence, not authority"
			input: {
				requiredField: "fixture"
				generatedAuthority: true
			}
		}
	},
]

negativeFixtures: {
	generatedAuthorityAccepted: _negativeFixtures[0].out
}

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "generatedAuthorityAccepted"
			fixture:      "negative.generatedAuthorityAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./\(_root)/checks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		path:              _root
		validBaselineExpr: "contractSliceManifest"
		publicExpr:        "contractSliceValidationPlan"
		bottomChecks: ["generatedAuthorityAccepted"]
		checkFile:        "./\(_root)/checks"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: __FORBIDDEN_PATTERN__
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for item in _primitives {item.out.name}]
		surfaces: [
			_observed[0].out.name,
			_admissible[0].out.name,
			_promotion[0].out.name,
		]
		fixtures: [for item in _negativeFixtures {item.out.id}]
		checks: [for item in _bottomCheckPlans {item.out.name}]
		commands: _validation.out.commands
		evidence: [
			"just scaffold-contract-slice",
			"contract slice manifest",
			"constructor-bound negative check surface",
		]
	}
}

contractSliceManifest: {
	id:    _sliceID
	title: _title
	workflow: _workflow
	primitives: [for item in _primitives {item.out}]
	observed: [for item in _observed {item.out}]
	admissible: [for item in _admissible {item.out}]
	predicates: [for item in _predicates {item.out}]
	promotion: [for item in _promotion {item.out}]
	surfaces: _surfaces.out
	negativeFixtures: [for item in _negativeFixtures {item.out}]
	bottomCheckPlans: [for item in _bottomCheckPlans {item.out}]
}

contractSliceValidationPlan: _validation.out
contractSliceCompletionReport: _completion.out
'''

	checks_text = r'''package __CHECKS_PACKAGE__

import impl "github.com/fatb4f/factory/contracts/meta"

#SkeletonAdmissible: close({
	requiredField: string & !=""
	generatedAuthority?: false
})

contractAssertions: {
	generatedArtifactsEvidenceOnly: {
		id:       "generated-artifacts-are-evidence-only"
		check:    "generatedAuthorityAccepted"
		fixture:  "negative.generatedAuthorityAccepted"
		target:   "#SkeletonAdmissible"
		refusal:  "generatedAuthority must bottom when projected into the admissible target"
	}
}

_assertionProofs: {
	generatedAuthorityAccepted: (impl.#MakeBottomCheckProof & {
		in: {
			name: contractAssertions.generatedArtifactsEvidenceOnly.check
			input: {
				evidence: "generated authority is inadmissible"
				value: {
					requiredField: "fixture"
					generatedAuthority: true
				}
			}
			target: {
				name: contractAssertions.generatedArtifactsEvidenceOnly.target
				contract: {
					evidence: "scaffold target rejects generated authority"
					value:    #SkeletonAdmissible
				}
			}
		}
	}).out.generatedAuthorityAccepted
}

_negativeBottomChecks: {
	for _, assertion in contractAssertions {
		"\(assertion.check)": _assertionProofs[assertion.check]
	}
}
'''

	manifest_text = manifest_text.replace("__PACKAGE__", package_name)
	manifest_text = manifest_text.replace("__SLICE_ID__", json.dumps(slice_id))
	manifest_text = manifest_text.replace("__TITLE__", json.dumps(title))
	manifest_text = manifest_text.replace("__ROOT__", json.dumps(out))
	manifest_text = manifest_text.replace("__FORBIDDEN_PATTERN__", json.dumps(forbidden_pattern))
	checks_text = checks_text.replace("__CHECKS_PACKAGE__", checks_package)

	manifest.write_text(manifest_text)
	checks.write_text(checks_text)
	subprocess.run(["cue", "fmt", str(manifest), str(checks)], check=True)
	print(f"created {manifest}")
	print(f"created {checks}")
	PY

contracts-meta:
	cue vet ./contracts/meta
	cue export ./contracts/meta -e constructorLibraryBaseline >/dev/null
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null
	cue export ./contracts/meta -e generatedContractCompliance >/dev/null
	cue export ./contracts/meta/checks -e assertionGeneratedCheckManifest >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractGeneratorMissingOutputAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorAbsoluteTargetAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.contractValidatorStaleLocalCheckAccepted >/dev/null
	! cue export ./contracts/meta/checks -e _negativeBottomChecks.generatedComplianceAuthorityAccepted >/dev/null

contracts-plugin-bundle-template:
	cue vet ./contracts/plugin-bundle/template
	cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateContract >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateContractMetaCompliance >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleScaffoldGenerator >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleScaffoldValidator >/dev/null
	cue export ./contracts/plugin-bundle/template -e pluginBundleTemplateCompliance >/dev/null
	cue vet ./contracts/plugin-bundle/template/checks
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.generatedAuthorityAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.externalLookupAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.absolutePathAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.parentTraversalAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.missingRequiredPathAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.bundleLocalOverrideAccepted >/dev/null
	! cue export ./contracts/plugin-bundle/template/checks -e _negativeBottomChecks.staleLocalCheckReferenceAccepted >/dev/null

contracts-agent-context-resolver-src:
	cue vet ./contracts/agent-context-resolver/src
	cue export ./contracts/agent-context-resolver/src -e normalizedMaterializedBundleShapeManifest >/dev/null
	cue export ./contracts/agent-context-resolver/src -e materializedBundleShapeValidationPlan >/dev/null
	cue export ./contracts/agent-context-resolver/src -e materializedBundleShapeCompletionReportContract >/dev/null

contracts-code-intel-src:
	cue vet ./contracts/code-intel/src
	cue export ./contracts/code-intel/src -e normalizedMaterializedBundleShapeManifest >/dev/null
	cue export ./contracts/code-intel/src -e materializedBundleShapeValidationPlan >/dev/null
	cue export ./contracts/code-intel/src -e materializedBundleShapeCompletionReportContract >/dev/null

contracts-consolidation-guards:
	! rg 'contracts/plugin-bundle/code-intel/src' ./contracts/code-intel/src
	! rg 'contracts/code-intel/manifest\.cue' ./contracts/code-intel/src

scaffold-smoke:
	cue export ./contracts/meta -e contractScaffoldGenerator >/dev/null
	cue export ./contracts/meta -e contractScaffoldValidator >/dev/null

validate-all: contracts-meta contracts-plugin-bundle-template contracts-agent-context-resolver-src contracts-code-intel-src contracts-consolidation-guards scaffold-smoke
