# AGENTS.md

Implementation prompt: [prompt.txt](prompt.txt)

## Scope

This branch implements issue #106: the executable CUE kernel–probe–eval skill
package rooted at:

```text
.codex/skills/cue/
```

The admitted P0 implementation surfaces are:

```text
.codex/skills/cue/SKILL.md
.codex/skills/cue/agents/openai.yaml
.codex/skills/cue/interface/**
.codex/skills/cue/contracts/**
.codex/skills/cue/runner/go.mod
.codex/skills/cue/runner/go.sum
.codex/skills/cue/runner/cmd/cueprobe/**
```

Root `AGENTS.md` and `prompt.txt` are operator guidance for this implementation
unit. They are not semantic authority.

Do not add a Marimo workbook, Python adapter, cue-py/libcue adapter, custom CUE
language server, or second P0 runner. Those surfaces are deferred by issue #106.

## Authority and revision gate

Use authority in this order:

```text
online fatb4f/factory issue #106
    canonical requirements, acceptance criteria, and dependency topology

skill-local CUE contracts
    canonical kernel, package, probe, subject, observation, evaluator,
    coverage, suite, and artifact semantics

machine-readable skill-interface manifest
    canonical procedural identifiers and command bindings

Go cueprobe runner
    admitted execution, subject-derivation, LSP-client, structural-gate,
    skill-check, and raw-observation producer

CUE CLI
    structural formatting, unification, and concrete-surface gates

CUE LSP
    advisory authoring service

SKILL.md
    human procedural guidance linked to the machine-readable interface

generated observations, evaluations, reports, and bundles
    non-authoritative projections
```

Before implementation, fetch issue #106 and verify that the online body contains
the marker `issue-106-requirements-matrix:v3`. At minimum it must contain
`PR-09`, `RN-07`, `LS-03`, and `SK-05`, in addition to the complete preceding
P0 dependency closure, and must identify `cueprobe`, rather than CUE CLI failure,
as the P0 semantic observation channel. Stop if the online issue is stale,
ambiguous, or internally inconsistent.

The normative dependency graph is generated from the issue's `depends_on`
fields. Never reconstruct dependency ranges or use the diagram in place of the
requirement records.

## Core invariants

1. The complete lattice meta kernel is migrated as executable CUE inside the
   skill package and its consumers bind to its exported definitions.
2. The kernel remains domain-neutral; runner, verdict, coverage, and artifact
   vocabularies live above it.
3. Probe specifications are generated from kernel operations and candidate
   declarations, not arbitrary expected outcomes.
4. Conflict fixtures contain two independently valid closed states.
5. Schema-invalid ingress fixtures are a separate proof class.
6. The runner derives the effective subject from actual loaded sources, build
   inputs, selectors, and engine identity. A caller subject is expectation only.
7. Pre-load and post-operation source digests must match. Source change suppresses
   semantic facts.
8. Exact CUE numbers use the bounded `PR-09` tagged coefficient/exponent
   representation before RFC 8785 canonicalization.
9. Raw observations contain facts only. They never contain claimant-supplied
   verdict, satisfaction, coverage, success, or admission fields.
10. Semantic bottom may be observed only after module loading, lookup, and the
   declared operand preconditions succeed and the declared operation bottoms.
11. CLI failure, timeout, protocol failure, and infrastructure failure never
   prove semantic bottom.
12. Structured `#ProbeSubject` equality is authoritative. Its SHA-256 digest is
   a reproducibility projection, not the identity proof.
13. CUE alone derives verdicts, permitted and required satisfaction, family and
    candidate aggregation, coverage, and suite state.
14. Structural gates and semantic probes are both required and remain distinct.
15. LSP observations are advisory and cannot admit or reject the suite.
16. Manifest, interface, probe, subject, observation, runner-request, and publication
    ingress fail closed on unknown fields.
17. The only P0 execution boundary is the source-controlled Go `cueprobe`
    command with an explicit CUE Go API dependency closure.
18. Subjects, probe specs, observations, evaluations, coverage, package gates,
    LSP observations, and suite results remain separately exportable.
19. The closed skill-interface manifest owns machine-readable procedural
    identities; `SKILL.md` references them through bounded frontmatter.
20. Static checks do not claim that an LLM obeyed prose at runtime.

## Implementation-unit protocol

Issue #106 is a parent matrix, not an implementation plan. Before changing an
implementation surface:

1. Select the requirement IDs the unit directly satisfies.
2. Compute their complete transitive local dependency closure from direct
   `depends_on` edges.
3. Cite every requirement and acceptance-criterion ID in scope.
4. Declare a validation DAG that refines, but does not replace, the architectural
   dependency order.
5. Map every acceptance criterion to each required scenario class.
6. Identify inputs, commands, fixtures, observations, evaluations, artifacts,
   and exported evidence.
7. Implement only nodes whose prerequisite evidence has validated.
8. Require CUE-computed unit satisfaction; command success is evidence only.

P1 `WB-*` and `CP-*` requirements must not enter a P0 unit without their full
closure and explicit authorization.

## Package boundary

Implement a versioned, skill-local package with surfaces equivalent to:

```text
.codex/skills/cue/
├── SKILL.md
├── agents/openai.yaml
├── interface/manifest.cue
├── contracts/
│   ├── cue.mod/module.cue
│   ├── kernel/kernel.cue
│   ├── package/manifest.cue
│   ├── probe/spec.cue
│   ├── subject/subject.cue
│   ├── canonical/value.cue
│   ├── observation/{probe,lsp}.cue
│   ├── eval/{probe,family,candidate,coverage,suite}.cue
│   ├── runner/protocol.cue
│   ├── fixtures/{kernel,conflict,invalid-ingress,invalid-probe,invalid-observation,valid-observation}/
│   └── candidates/{accepted,rejected}/
└── runner/
    ├── go.mod
    ├── go.sum
    └── cmd/cueprobe/main.go
```

The final split may differ only when the issue's requirement and artifact-role
contracts still resolve deterministically and without role collisions.

## Kernel and fixture rules

Migrate the complete domain-neutral lattice meta kernel from
`~/src/lattice/meta/kernel.cue` into the skill-local CUE module. Preserve all
exported definitions and proof surfaces required by `KR-01` through `KR-05`.
Package and module adaptation is permitted, but selective reconstruction and an
external runtime import from the lattice checkout are not.

Candidate and fixture contracts must bind to the migrated kernel through CUE
package imports or same-package definition references. They must use the
appropriate exported state definitions, constructors, exact-key proofs,
no-widening proof, and destructive conflict surface rather than reproduce
kernel-shaped schemas. Package validation must prove every declared kernel
selector resolves. Do not reimplement the kernel in Go or conjoin the entire
system into a monolithic `#Kernel & ...` expression.

Preserve:

- closed ingress and guarded keyed maps;
- local aliases for conjunct-provided fields;
- shape/proof separation and hidden proof fields;
- exact state and operation-reference key sets;
- no-widening proofs;
- destructive conflict proof through unification.

Keep these fixture classes distinct:

```text
valid conflict fixture
    authority and mutation validate independently
    destructive unification bottoms

schema-invalid ingress fixture
    raw data is applied to an explicit target schema
    rejection occurs before any conflict proof
```

Do not call malformed fields, invalid keys, dangling references, wrong generated
roles, or incomplete required ingress a valid conflict fixture.

## Probe and subject rules

`#ProbeSpec` must be a closed discriminated operation contract. Each operation
admits only its required operands and explicit module, package, value, and build
coordinates.

`#ProbeSubject` is a closed structured projection. Structured equality is the
identity proof. Materialize defaults before comparison, normalize paths to
repository- or module-relative POSIX paths, and exclude machine-local paths.

Project exact CUE numbers into the bounded `#CanonicalSubjectValue` tagged
coefficient/exponent representation before JSON serialization. Normalize only
lists whose schema declares set semantics. The subject digest pipeline is:

```text
concrete closed #ProbeSubject
→ exact-number projection to #CanonicalSubjectValue
→ schema-declared set normalization
→ UTF-8 RFC 8785 canonical JSON
→ SHA-256
```

Treat the digest as a checked projection. Never replace structured equality
with digest-only matching.

## Go runner rules

The sole P0 runner is `.codex/skills/cue/runner/cmd/cueprobe`.

It may:

- consume one closed runner request;
- load only explicitly declared module, package, files, and values;
- derive the effective subject from the actual module manifest, declared source
  bytes, normalized build options, selector inputs, runner protocol, and CUE
  semantic-engine version;
- compare an optional caller `subjectExpectation` without allowing it to
  override the derived subject;
- hash every subject source and module file before load and after operation;
- execute declared operations through the pinned official CUE Go API;
- invoke only declared structural CUE CLI command templates;
- act as the bounded JSON-RPC client for the verified `cue lsp` binding;
- validate the bounded skill-interface references;
- record stage-specific raw facts;
- materialize closed observations atomically;
- enforce declared path, deadline, and output-size bounds.

It must not:

- generate candidates, expected verdicts, evaluator policy, coverage, or
  admission;
- accept arbitrary command vectors or guess roots;
- infer semantic results from diagnostic wording;
- convert CLI or infrastructure failure into semantic bottom;
- mutate candidate authority;
- execute undeclared probes or read undeclared files.

Any manifest, source, selector-input, or declared build-input change during
execution emits `source-changed` and suppresses semantic facts.

The admitted bounded subcommands are:

```text
cueprobe observe
cueprobe lsp-observe
cueprobe skill-check
```

Keep request decoding, module loading, build, lookup, operand validation,
operation, concreteness, and projection stages independently observable.

The runner's dedicated `go.mod` and `go.sum` own its Go and `cuelang.org/go`
dependency closure. Do not borrow an ambient repository Go dependency or edit
`go.sum` manually.

## Evaluation rules

CUE evaluators must be total for every admitted spec/observation pair. They
derive identity validity, evidence completeness, exactly one verdict,
diagnostic projections, and policy satisfaction.

Require:

- operation-specific proof rather than expected-outcome dispatch;
- independent evidence completeness and exact cardinality;
- permitted verdict checks for every scoped result;
- `requiredAny` and, where declared, `requiredEach` witnesses;
- exact candidate, family, probe, and structured-subject scoping;
- complete kernel, candidate, fixture, gate, evaluator, and coverage proofs;
- no claimant-provided suite or admission Boolean.

## Structural gates and LSP

Use explicit structural gates:

```bash
cue fmt --check --files <declared-files>
cue vet -c=false <declared-package>
cue vet -c <declared-concrete-surface>
```

`-c=false` proves structural unification without requiring concreteness.
`-c` applies only to a declared concrete surface. Neither gate replaces semantic
probes.

Use `cueprobe lsp-observe` as the admitted bounded JSON-RPC client for the fixed,
verified standard `cue lsp` binding. It initializes against explicit workspace
and module coordinates, records server capabilities, sends `initialized`, opens
declared documents with explicit versions, collects version-correlated
diagnostics until declared quiescence or deadline, performs orderly shutdown,
and emits one closed `#LSPObservation`. Retain unavailability, startup failure,
protocol error, timeout, capabilities, diagnostics, and shutdown facts. LSP
cleanliness or failure is never a semantic verdict or admission gate.

## Static skill boundary

The closed machine-readable skill-interface manifest owns the exact kernel and
package IDs, runner binary and subcommands, LSP binding, structural gate
templates, artifact-role IDs, stop conditions, file IDs, and single `SKILL.md`
path. `SKILL.md` frontmatter references that manifest, and its prose routes users
to those identifiers. It must not copy:

- CUE schema bodies;
- probe generators;
- verdict or aggregation rules;
- dependency matrices or validation DAGs;
- alternative or fallback command implementations.

`cueprobe skill-check` parses only the bounded YAML frontmatter needed to resolve
the interface manifest, validates the manifest through CUE, and proves its exact
command, package, artifact, and file identifiers resolve. General Markdown
interpretation, broader prose duplication, fallback wording, and runtime LLM
behavior remain review policy.

## Artifacts and non-authority

Keep the package and skill-interface manifests, kernel inventory, structured
subjects, canonical subject values and digest projections, generated probes,
raw observations, evaluations, coverage, suite state, package gates, and LSP
observations as distinct artifact roles.

Artifact IDs, ordering, canonicalization, and digests must be deterministic.
Reject partial, duplicate, stale, or mixed-subject bundles. Export rejected,
incomplete, and runner-failure results without hiding their state. Optional
publication artifacts remain linked to the evaluated candidate and subject.

Generated observations, evaluations, reports, and bundles are transient
projections. Do not commit runtime output or treat it as authority.

## Change protocol

1. Verify the revised online issue #106 contract.
2. Select a dependency-closed implementation unit.
3. Update CUE contracts before adapters or procedural guidance.
4. Add positive, negative, invariant, compatibility, and adversarial fixtures
   required by the cited acceptance criteria.
5. Update the Go runner only for admitted observation-production operations.
6. Run structural gates and semantic probes independently.
7. Vet raw observations through the closed CUE ingress.
8. Export and inspect evaluation, coverage, suite, and artifact projections.
9. Verify CUE-computed unit satisfaction is true.
10. Run `cueprobe skill-check` against the closed interface manifest.
11. Update `SKILL.md` last, using only stable admitted references.

Make small, reversible changes. Do not edit generated, cache, vendor, runtime,
secret, credential, or machine-local files.

## Validation

Use coordinates exported by the admitted package manifest, skill-interface
manifest, and runner protocol. Validate the migrated kernel package and every
consuming package. At minimum, applicable units must run:

```bash
cue fmt --check --files <declared-files>
cue vet -c=false <declared-package>
cue vet -c <declared-concrete-surface>
```

For the Go runner:

```bash
cd .codex/skills/cue/runner
go mod verify
go test -mod=readonly ./...
go build -mod=readonly ./cmd/cueprobe
```

Run the applicable bounded command surfaces:

```bash
cueprobe observe --request <request> --output <probe-observation>
cueprobe lsp-observe --request <request> --output <lsp-observation>
cueprobe skill-check --skill <SKILL.md> --manifest <interface-manifest>
```

Then execute the declared reference probes, validate every raw observation
against the CUE ingress, export the probe/family/candidate/coverage/suite
evaluations, and require the declared CUE satisfaction expression to be
literally `true`.

## Forbidden changes

Do not:

- use CUE CLI exit status or diagnostics as semantic-bottom evidence;
- place verdict, satisfaction, coverage, or admission logic in Go;
- accept claimant conclusions at raw ingress;
- conflate schema-invalid ingress with valid-state conflict fixtures;
- parse CUE source or diagnostics to infer semantics;
- match subjects by labels, diagnostic text, or digest alone;
- accept a caller subject as the effective subject or emit semantic facts after
  a detected source change;
- import the lattice checkout as a runtime kernel dependency or reconstruct only
  a kernel-shaped subset;
- add a second P0 runner, Go adapter, Python adapter, or workbook;
- introduce P1 Marimo or cue-py work during a P0 unit;
- duplicate executable contracts or dependency topology in `SKILL.md`;
- publish partial or mixed-subject bundles;
- let generated artifacts become authority.

## Final response schema

```text
Summary:
- <what changed>

Validation:
- <command>: <pass/fail/blocked>
```
