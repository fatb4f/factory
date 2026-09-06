# Factory Observatory

Status: implementation architecture / tracked by GitHub Issues

## Objective

Factory Observatory is the comprehension surface for a repository that increasingly contains independent CUE authorities, graph state, substrates, runtime projections, documentation, tracker state, runs and evidence.

The architecture must make those surfaces navigable together without turning repository locality, Python objects, workbook code, property-graph tooling or GitHub state into semantic authority.

The default direction is:

```text
CUE semantic authority
        ↓
constrained / admitted state
        ↓
typed context acquisition + qualification
        ↓
immutable SemanticContextSnapshot
        ↓
Python semantic/context runtime
        ↓
directory-bound workbook projection
        ↓
replaceable renderers / exploratory adapters
```

## Authority-qualified semantic identity

`factory.semantic-context` must not define a global Factory ontology.

Semantic subjects are authority-relative:

```text
SemanticRef
    authority
    authority-local subject identity
    optional authority-local kind
```

A semantic relation requires more than authority-qualified endpoints:

```text
SemanticRelation
    authority
    authority-owned predicate/relation identity
    admitted domain snapshot
    source SemanticRef
    target SemanticRef
```

Two references appearing together in documentation, repository structure, tracker state or evidence do not establish a semantic relation. Qualified endpoints alone are insufficient; the owning authority and admitted domain snapshot must establish the predicate/relation.

Documentary, operational, structural and evidential relations remain distinct relation planes and cannot validate as semantic relations by endpoint coincidence.

## Reproducible context snapshot identity

The root Factory commit is an anchor, not a complete context-snapshot identity. A semantic-context snapshot may also contain mutable external operational state, run/evidence occurrences and outputs from analyzers whose versions affect deterministic results.

Snapshot identity therefore binds an immutable input/configuration manifest containing all output-affecting inputs, including where applicable:

```text
root repository identity + revision
captured source occurrence identities
canonical captured-payload digests
compiler/acquisition configuration
canonicalization algorithm/version
CUE/compiler version
Python/runtime semantics where relevant
Jedi version
Tree-sitter runtime version
Tree-sitter grammar revisions
other analyzer/runtime versions
admitted records/relations
coverage state
```

`acquiredAt` is provenance unless an owning contract explicitly makes capture time identity-bearing.

Provider timestamps such as GitHub `updatedAt` are revision/version hints. They are not immutable captured-content identity. Mutable external occurrences use a canonical captured-payload digest for immutable content identity.

For a captured Factory-managed GitHub issue, useful occurrence state includes:

```text
factory-issue-key          semantic tracker identity
repository                 source identity
issue number               provider locator only
provider revision hints    e.g. updatedAt
canonical payload digest   immutable captured content identity
acquiredAt                 acquisition provenance
```

GitHub issue number remains a locator and never replaces `factory-issue-key`.

## Repository-context admission planes

`factory.repository-context` may qualify and admit generic context facts, but authority remains plane-specific.

```text
repository/context observations
        ↓
plane-specific qualification
        ├── documentary admission
        ├── operational admission
        ├── structural admission
        └── evidential admission
```

Domain-semantic candidates follow a separate path:

```text
domain-semantic candidate
        ↓
owning domain authority
        ↓
semantic admission
```

AST, Jedi and Tree-sitter may establish structural observations and, under generic structural rules, admitted structural context. They cannot independently establish domain-semantic predicates, equivalence or graph edges.

## Python runtime versus analytical IR

The Python semantic runtime is an executable facade over admitted state, not an independent semantic or analytical authority.

It may directly provide bounded snapshot-local navigation such as:

```text
exact lookup
typed object access
plane-qualified adjacency
bounded traversal
provenance navigation
```

Analytical operations belong to `factory.analytics-ir`, including:

```text
joins
aggregation / grouping
grain changes
ordering / ranking / windowing
derived series
analytical transformations
```

The workbook boundary is therefore:

```text
factory.semantic-runtime
        ├── direct bounded navigation ─────────────┐
        │                                         │
factory.analytics-ir                              │
        └── AnalyticalRequest / RelationalPlan ───┤
                                                  ↓
                                            factory.workbook
```

`factory.workbook` must not introduce a second generic filter/derivation/query algebra.

## Explicit directory binding

Filesystem locality is discovery only.

A `workbook.py` colocated with a directory resolves through admitted binding state:

```text
workbook directory occurrence
        ↓
admitted DirectoryBinding
        ↓
0 subjects  -> unresolved / explicit subject required
1 subject   -> bound
>1 subjects -> ambiguous / explicit subject required
```

There is no `nearest semantic subject` inference from directory ancestry.

A `WorkbookScope` binds an immutable snapshot identity. Freshness, `latest`, acquisition and snapshot selection remain upstream concerns.

Nested workbooks may narrow or explicitly compose admitted scopes. Directory nesting alone cannot manufacture semantic relationships.

## Property-graph projection boundary

Property-graph tooling is a downstream exploratory projection only:

```text
Factory ProjectionResult
        ↓
PropertyGraphProjection
        ↓
backend load/import
    ├── Neo4j/Bloom
    └── replaceable future backend
```

`import` means loading the Factory projection into the backend. It is one-way with respect to semantic authority:

```text
backend-created adjacency
backend layout
backend labels
backend query results
backend inferred relationships
backend mutations
        ─X→ Factory semantic admission
```

A separate explicitly contracted acquisition/admission path would be required before any external backend state could become Factory evidence or semantics. The property-graph workbook adapter itself provides no reverse admission path.

## Observatory V1 dependency topology

Observatory V1 has two converging branches.

```text
EXISTING DOMAIN REALIZATION

#132 factory.analytics-ir
       ├──────────────→ #134 factory.storage
       │                   │
       └───────────────────┴→ #139 industrial graph snapshots
                                    │
                                    │
                                    ▼

CONTEXT / COMPREHENSION

#144 semantic-context
       ├────────→ #145 repository-context ───────────────┐
       │                                                │
       └────────→ #146 semantic-runtime                 │
                       │                                │
                       ▼                                │
                 #147 workbook ←──── #132              │
                       │                                │
                       ▼                                │
                 #148 Marimo                           │
                       │                                │
                       └────────────────────────────────┼→ #149 industrial reference workbook
                                                        │
#139 ───────────────────────────────────────────────────┘
                                                        ↓
                                                     #151 Observatory V1
```

#145 and #146 may proceed substantially in parallel after #144.

#147 consumes #146 for exact and bounded plane-qualified navigation, and #132 for analytical presentation requests. #146 does not thereby acquire a dependency on #132.

#149 is the convergence point between admitted industrial graph state and the new context/workbook stack.

#150 property-graph projection remains deferred and replaceable; it is not a V1 completion dependency.

## Industrial fail-closed boundary

The reference workbook must respect the current `world.industrial-signals` execution phase.

During `event-watch`, observations remain observations. The workbook must not upgrade them into canonical industrial graph facts. It must retain the distinctions already required by the industrial authority, including:

```text
signal != action != admitted response
response hypothesis != admitted response
award != disbursement != expenditure != milestone != outcome
coverage gap != inferred non-performance
```

Only the admitted industrial graph snapshot produced through the industrial-graph realization path may supply canonical industrial graph state to the reference workbook.

## Tracking

The current tracked implementation surfaces are:

```text
#132 factory.analytics-ir
#134 factory.storage
#139 world.industrial-signals immutable snapshots
#144 factory.semantic-context
#145 factory.repository-context
#146 factory.semantic-runtime
#147 factory.workbook
#148 factory.workbook.marimo
#149 world.industrial-signals reference workbook
#150 factory.workbook.property-graph
#151 factory.observatory
```

Architecture-refinement tasks created from the upstream review are #153 through #160. GitHub Issues remains operational tracker state; the CUE contracts named by each parent issue remain the future executable semantic/projection authorities.
