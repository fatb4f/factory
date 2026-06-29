package issue0checks

import impl "github.com/fatb4f/factory/contracts/meta"

#IssueGeneratedComplianceSlice: close({
	sliceID:                         string & !=""
	issueNumber:                     int
	parentAuthority:                 "contracts/meta"
	generatedArtifactsAreAuthority?: false
	usesMetaConstructors:            true
	usesBottomCheckProof:            true
})

#IssueValidatorBoundary: close({
	staleIssueLocalChecks?:   false
	externalLookupAuthority?: false
})

#IssueRelativePath: string & !="" & !~"^/" & !~"(^|/)\\.\\.(/|$)"

_negativeBottomChecks: {
	generatedArtifactsAuthorityAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "generatedArtifactsAuthorityAccepted"
			input: {
				evidence: "generator projection promoted past evidence"
				value: {
					sliceID:                        "factory.meta-generated-contract-compliance-hardening"
					issueNumber:                    0
					parentAuthority:                "contracts/meta"
					usesMetaConstructors:           true
					usesBottomCheckProof:           true
					generatedArtifactsAreAuthority: true
				}
			}
			target: {
				name: "#IssueGeneratedComplianceSlice"
				contract: {
					evidence: "issue slice rejects projection promotion"
					value:    #IssueGeneratedComplianceSlice
				}
			}
		}
	}).out.generatedArtifactsAuthorityAccepted

	staleLocalCheckAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "staleLocalCheckAccepted"
			input: {
				evidence: "retired issue check references are inadmissible"
				value: {staleIssueLocalChecks: true}
			}
			target: {
				name: "#IssueValidatorBoundary"
				contract: {
					evidence: "validator boundary rejects retired check references"
					value:    #IssueValidatorBoundary
				}
			}
		}
	}).out.staleLocalCheckAccepted

	externalLookupAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "externalLookupAccepted"
			input: {
				evidence: "outside lookup is inadmissible"
				value: {externalLookupAuthority: true}
			}
			target: {
				name: "#IssueValidatorBoundary"
				contract: {
					evidence: "validator boundary rejects outside lookup"
					value:    #IssueValidatorBoundary
				}
			}
		}
	}).out.externalLookupAccepted

	rootedPathAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "rootedPathAccepted"
			input: {
				evidence: "rooted scaffold paths are inadmissible"
				value: {path: "/contracts/issues/0"}
			}
			target: {
				name: "#IssueRelativePath"
				contract: {
					evidence: "issue boundary rejects rooted paths"
					value: {path: #IssueRelativePath}
				}
			}
		}
	}).out.rootedPathAccepted

	parentTraversalAccepted!: (impl.#MakeBottomCheckProof & {
		in: {
			name: "parentTraversalAccepted"
			input: {
				evidence: "dot-dot scaffold paths are inadmissible"
				value: {path: "../outside"}
			}
			target: {
				name: "#IssueRelativePath"
				contract: {
					evidence: "issue boundary rejects dot-dot paths"
					value: {path: #IssueRelativePath}
				}
			}
		}
	}).out.parentTraversalAccepted
}
