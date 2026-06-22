---
name: Factory control-loop implementation
about: Plan factory work through existing root contract plumbing, generated evidence, and gates.
title: "feat(factory): "
labels: factory, contract
---

# Root contract question

All implementation planning starts here:

```text
N0.root-question:
  How can the root contract express, materialize and gate this?
```

Answer:

- 

# Existing root plumbing

The root contract is expected to already dispose of the plumbing required to:

```text
contracts/factory/reflection.cue
  -> extend the contract
  -> generate assertions
  -> generate fixtures
  -> generate evals
  -> generate evidence

contracts/factory/control.cue
  -> input
  -> transform
  -> output
  -> sensor
  -> error-signal
  -> control-action
  -> next-state

contracts/factory/introspection.cue
  -> bounded adapter-visible views
  -> AdapterCommand
  -> EvidencePacket
  -> Materialization
```

This issue must not introduce inferred interfaces, inferred authority, shell-only behavior, or SDK-local authority. If required plumbing appears missing, the task is to express the missing extension through the root contract first, then regenerate derived surfaces.

# DAG implementation model

Implementation plans must be reasoned as a DAG. Start from `N0.root-question` and route through existing root plumbing.

```text
Nodes:
  N0.root-question:
    How can the root contract express, materialize and gate this?

  N1.contract-extension:
    Existing root contract extension point that admits the work.
    Authority remains under contracts/factory/**.

  N2.generated-assertions:
    Assertion surfaces generated from the reflected contract inventory.
    No hand-authored assertion instance may become authority.

  N3.generated-fixtures:
    Fixture projections generated from the root contract materialization plan.
    Fixtures are non-authoritative.

  N4.generated-evals:
    Eval or validation projections generated from root contract authority.
    Eval commands must be declared, reproducible, and gate-bound.

  N5.generated-evidence:
    Evidence packets, assertion results, or loop-stage exports.
    Evidence is bounded and non-authoritative.

  N6.gate:
    Declared assertion, drift check, control action, or validation gate.

  N7.next-state:
    Admitted state after the control loop closes.

Edges:
  N0.root-question -> N1.contract-extension
  N1.contract-extension -> N2.generated-assertions
  N1.contract-extension -> N3.generated-fixtures
  N1.contract-extension -> N4.generated-evals
  N2.generated-assertions -> N6.gate
  N3.generated-fixtures -> N4.generated-evals
  N4.generated-evals -> N5.generated-evidence
  N5.generated-evidence -> N6.gate
  N6.gate -> N7.next-state

Parallel edges:
  - 
```

# Contract authority surfaces

```text
Authority surfaces:
  - contracts/factory/reflection.cue:
  - contracts/factory/control.cue:
  - contracts/factory/introspection.cue:

Root extension point:
  - existing value/path:
  - required extension:

Non-authority inputs:
  - 
```

# Generated surfaces

```text
Generated assertions:
  - path:
    generatedFrom:
    admittedBy:

Generated fixtures:
  - path:
    generatedFrom:
    admittedBy:

Generated evals:
  - path or command:
    generatedFrom:
    declaredBy:
    admittedBy:

Generated evidence:
  - path:
    schema:
    source view:
    bounded: true
    authority: false
```

# Adapter and runtime aperture

```text
Adapter command or runtime ingress:
  - name:
    declared in: contracts/factory/introspection.cue
    action: export-view | materialize | check-drift | run-check
    outputs:
    materializes:

Forbidden:
  - new SDK-local authority
  - new adapter-only interface not declared by introspection
  - raw runtime mutation path
  - generated output without reflected provenance
```

# Gates and control actions

```text
Required gates:
  - cue eval:
  - cue vet:
  - generated eval/check:
  - just target:

Control action:
  action: admit | reject | defer | materialize | block
  reason:
  error-signal evidence:
  next-state evidence:

Drift checks:
  - generated evidence declared
  - generated checks/evals declared
  - adapter commands declared
  - no shell-only generated paths
  - no inferred interface or authority path
```

# Acceptance criteria

- [ ] Root contract question is answered before implementation details.
- [ ] Implementation plan is represented as a DAG with named nodes and edges.
- [ ] The plan uses existing root plumbing before proposing any new surface.
- [ ] Contract extension is expressed under `contracts/factory/**`.
- [ ] Assertions are generated or explicitly rooted in the reflected contract inventory.
- [ ] Fixtures are generated and non-authoritative.
- [ ] Evals/checks are generated or declared by the root contract and gate-bound.
- [ ] Evidence is generated, bounded, non-authoritative, and provenance-stamped.
- [ ] Adapter-visible behavior is declared through `contracts/factory/introspection.cue`.
- [ ] No inferred interface, adapter-local authority, SDK-local authority, or shell-only semantic path is introduced.
- [ ] Materializations are admitted by a declared control action or gate.
- [ ] `just check` passes.

# Validation commands

```bash
just generate-validation
just export-validation-loop
just check
```
