package pluginbundlesrc

import (
	impl "github.com/fatb4f/factory/contracts/meta"
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
)

_staleLocalCheckPath: "contracts/stale/checks"

_negativeBottomChecks: {
	generatedAuthorityAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "generatedAuthorityAccepted"
			input: {
				evidence: "generated authority is inadmissible"
				value: {generatedAuthority: true}
			}
			target: {
				name: "#PluginBundleAuthorityPolicy"
				contract: {
					evidence: "template authority rejects generated authority"
					value:    tmpl.#PluginBundleAuthorityPolicy
				}
			}
		}
	}).out.generatedAuthorityAccepted

	externalLookupAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "externalLookupAccepted"
			input: {
				evidence: "external factory lookup is inadmissible"
				value: {externalFactoryRootLookup: true}
			}
			target: {
				name: "#PluginBundleAuthorityPolicy"
				contract: {
					evidence: "template authority rejects external factory lookup"
					value:    tmpl.#PluginBundleAuthorityPolicy
				}
			}
		}
	}).out.externalLookupAccepted

	absolutePathAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "absolutePathAccepted"
			input: {
				evidence: "absolute paths are inadmissible"
				value: {path: "/absolute/path"}
			}
			target: {
				name: "#RelativeContractPath"
				contract: {
					evidence: "template authority rejects absolute paths"
					value: {path: tmpl.#RelativeContractPath}
				}
			}
		}
	}).out.absolutePathAccepted

	parentTraversalAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "parentTraversalAccepted"
			input: {
				evidence: "parent traversal paths are inadmissible"
				value: {path: "../outside"}
			}
			target: {
				name: "#RelativeContractPath"
				contract: {
					evidence: "template authority rejects parent traversal paths"
					value: {path: tmpl.#RelativeContractPath}
				}
			}
		}
	}).out.parentTraversalAccepted

	missingRequiredPathAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "missingRequiredPathAccepted"
			input: {
				evidence: "required path inventory cannot be empty"
				value: {
					root: "contracts/plugin-bundle/example/src"
					cuePackages: [{id: "example", path: "manifest.cue"}]
					requiredPaths: []
				}
			}
			target: {
				name: "#PluginBundleContractsShape"
				contract: {
					evidence: "template authority requires non-empty requiredPaths"
					value:    tmpl.#PluginBundleContractsShape
				}
			}
		}
	}).out.missingRequiredPathAccepted

	bundleLocalOverrideAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "bundleLocalOverrideAccepted"
			input: {
				evidence: "bundle-local shape overrides are inadmissible"
				value: {
					srcRoot: "contracts/plugin-bundle/example/src"
					contracts: {
						root: "contracts/plugin-bundle/example/src"
						cuePackages: [{id: "example", path: "manifest.cue"}]
						requiredPaths: ["manifest.cue"]
					}
					generated: {
						root:         "contracts/plugin-bundle/generated/example"
						evidenceOnly: true
						artifacts: [{path: "contracts/plugin-bundle/generated/example/.codex-plugin/plugin.json", required: true, evidenceOnly: true}]
					}
					contractProjection: {
						pluginName: "example"
					}
					generatedProjection: {
						pluginName: "example"
					}
					validation: {
						commands: ["cue vet ./contracts/plugin-bundle/example/src"]
					}
					manifest: {
						bundleID:                          "example"
						shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
						srcRootShapeAuthority:             "contracts/plugin-bundle/src/manifest.cue"
						generatedArtifactsAreEvidenceOnly: true
						bundleLocalShapeOverride:          false
					}
					bundleLocalShapeOverride: true
				}
			}
			target: {
				name: "#PluginBundleSrcRootShape"
				contract: {
					evidence: "template authority rejects bundle-local shape overrides"
					value:    tmpl.#PluginBundleSrcRootShape
				}
			}
		}
	}).out.bundleLocalOverrideAccepted

	staleLocalCheckReferenceAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "staleLocalCheckReferenceAccepted"
			input: {
				evidence: "stale local validation references are inadmissible"
				value: {command: "cue export ./\(_staleLocalCheckPath) -e _negativeBottomChecks.shapeDrift"}
			}
			target: {
				name: "#ValidationCommand"
				contract: {
					evidence: "template authority rejects stale local validation references"
					value: {command: tmpl.#ValidationCommand}
				}
			}
		}
	}).out.staleLocalCheckReferenceAccepted

	cwdRelativeWriteAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "cwdRelativeWriteAccepted"
			input: {
				evidence: "cwd-relative adapter writes are inadmissible"
				value: {
					repoRoot:              "/repo"
					scriptPath:            "/repo/contracts/plugin-bundle/src/adapters/scaffold-plugin-bundle"
					contractRoot:          "Path(out_arg)"
					generatedRoot:         "Path(generated_root)"
					writesAreRepoAnchored: false
				}
			}
			target: {
				name: "#PluginBundleAdapterRepoRootBoundary"
				contract: {
					evidence: "template authority requires adapter writes anchored to the script-derived repo root"
					value:    tmpl.#PluginBundleAdapterRepoRootBoundary
				}
			}
		}
	}).out.cwdRelativeWriteAccepted

	uppercaseOrUnderscorePluginNameAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "uppercaseOrUnderscorePluginNameAccepted"
			input: {
				evidence: "uppercase and underscore plugin names are inadmissible"
				value: {
					pluginName:               "Agent_Context_Resolver"
					pattern:                  "^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$"
					maxLength:                64
					folderEqualsManifestName: true
				}
			}
			target: {
				name: "#PluginBundlePluginNameRule"
				contract: {
					evidence: "template authority requires lowercase hyphen-case plugin names"
					value:    tmpl.#PluginBundlePluginNameRule
				}
			}
		}
	}).out.uppercaseOrUnderscorePluginNameAccepted

	numericLeadingCuePackageAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "numericLeadingCuePackageAccepted"
			input: {
				evidence: "numeric-leading generated CUE package declarations are inadmissible"
				value: {
					bundleID:           "1plugin"
					cuePackage:         "1pluginpluginbundle"
					packagePrefix:      "pluginbundle_"
					validCueIdentifier: true
				}
			}
			target: {
				name: "#PluginBundleCuePackageNameRule"
				contract: {
					evidence: "template authority requires a stable non-numeric CUE package prefix"
					value:    tmpl.#PluginBundleCuePackageNameRule
				}
			}
		}
	}).out.numericLeadingCuePackageAccepted
}
