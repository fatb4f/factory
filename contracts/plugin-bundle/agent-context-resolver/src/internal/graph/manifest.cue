package graph

// Compatibility bridge for consolidated contract roots.
// Canonical authority lives at contracts/agent-context-resolver/src/internal/graph/manifest.cue.

import canonical "github.com/fatb4f/factory/contracts/agent-context-resolver/src/internal/graph:graph"

#ID: canonical.#ID
#RelPath: canonical.#RelPath
#ObjectModelKind: canonical.#ObjectModelKind
#ContractSectionKind: canonical.#ContractSectionKind
#ContractLeafKind: canonical.#ContractLeafKind
#AuthorityEdgeKind: canonical.#AuthorityEdgeKind
#RelationEdgeKind: canonical.#RelationEdgeKind
#AssertionPolarity: canonical.#AssertionPolarity
#AssertionStrength: canonical.#AssertionStrength
#FixtureCaseKind: canonical.#FixtureCaseKind
#ExpectedFixtureResult: canonical.#ExpectedFixtureResult
#FixtureGenerationMode: canonical.#FixtureGenerationMode
#CheckKind: canonical.#CheckKind
#WorkerBindingKind: canonical.#WorkerBindingKind
#WorkerBindingAction: canonical.#WorkerBindingAction
#WorkerRuntimeAdapter: canonical.#WorkerRuntimeAdapter
#A2AWorkerAdapter: canonical.#A2AWorkerAdapter
#WorkerProfile: canonical.#WorkerProfile
#ObjectModel: canonical.#ObjectModel
#AuthorityRoot: canonical.#AuthorityRoot
#ContractSection: canonical.#ContractSection
#ContractLeaf: canonical.#ContractLeaf
#AuthorityEdge: canonical.#AuthorityEdge
#RelationEdge: canonical.#RelationEdge
#Assertion: canonical.#Assertion
#FixtureObligation: canonical.#FixtureObligation
#TestObligation: canonical.#TestObligation
#AssertionCoverage: canonical.#AssertionCoverage
#Check: canonical.#Check
#CheckManifestEntry: canonical.#CheckManifestEntry
#CheckManifest: canonical.#CheckManifest
#ValidationCertificateEntry: canonical.#ValidationCertificateEntry
#ValidationCertificate: canonical.#ValidationCertificate
#WorkerPathScope: canonical.#WorkerPathScope
#WorkerBinding: canonical.#WorkerBinding
#AdapterContract: canonical.#AdapterContract
#EvidenceRecord: canonical.#EvidenceRecord
#HookBoundary: canonical.#HookBoundary
#ContractDomain: canonical.#ContractDomain
