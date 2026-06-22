---
name: Factory control-loop implementation
about: Plan factory work through root contract plumbing, generated surfaces, evidence, and gates.
title: "feat(factory): "
labels: factory, contract
---

# Root factory control-loop issue

Every implementation packet starts from the root-control question and must stay inside the root contract plumbing.

```text
N0.root-question:
  How can the root contract express, materialize and gate this?
```

If the answer cannot be expressed through existing root plumbing, do not invent a new interface. Extend the root contract, then regenerate the derived surfaces.

# Canonical CUE issue model

```cue
package issue

#FactoryControlLoopIssue: {
  contract: {
    rootAuthority: {
      path: "contracts/factory/**"
      owns: [
        "admitted factory state",
        "contract extension",
        "generated assertions",
        "generated fixtures",
        "generated evals",
        "generated evidence",
        "materialization gates",
      ]
    }
    reflection: {
      path: "contracts/factory/reflection.cue"
      role: "discovers/refines the reflection inventory and materialization plan"
    }
    control: {
      path: "contracts/factory/control.cue"
      role: "models the validation/materialization control loop"
    }
    introspection: {
      path: "contracts/factory/introspection.cue"
      role: "exposes bounded adapter-visible views, commands, materializations, and evidence packets"
    }
    generated: {
      path: "generated/**"
      authority: false
      role: "materialized projection/evidence only"
    }
    apertures: {
      sdk: {
        authority: false
        role: "adapter aperture only"
      }
      handler: {
        authority: false
        role: "executor for introspection-declared commands only"
      }
      mcp: {
        authority: false
        role: "projection aperture only"
      }
    }
  }

  rootQuestion: {
    id: "N0.root-question"
    text: "How can the root contract express, materialize and gate this?"
  }

  plumbing: {
    available: [
      "extend the contract",
      "generate assertions",
      "generate fixtures",
      "generate evals",
      "generate evidence",
      "feed gate/control action",
      "produce next state",
    ]
    route: [
      "root contract extension",
      "reflection inventory",
      "materialization plan",
      "generated assertion surface",
      "generated fixture surface",
      "generated eval/check surface",
      "generated evidence surface",
      "gate/control action",
      "next state",
    ]
  }

  constraints: {
    noNewInferredInterfaces: true
    noNewInferredAuthority: true
    noSDKLocalAuthority: true
    noAdapterOnlySemanticContract: true
    noShellOnlySemanticPath: true
    noGeneratedArtifactWithoutProvenance: true
    adaptersOnlyDeclaredBehavior: true
  }

  dag: {
    nodes: {
      N0: {
        id: "N0.root-question"
        question: rootQuestion.text
      }
      N1: {
        id: "N1.contract-extension"
        question: "Which root CUE value/schema must be extended?"
      }
      N2: {
        id: "N2.generated-assertions"
        question: "Which assertion surfaces are generated from the extension?"
      }
      N3: {
        id: "N3.generated-fixtures"
        question: "Which fixtures are generated from the extension?"
      }
      N4: {
        id: "N4.generated-evals"
        question: "Which eval/check surfaces are generated from the extension?"
      }
      N5: {
        id: "N5.generated-evidence"
        question: "Which evidence packets/materializations are generated?"
      }
      N6: {
        id: "N6.gate"
        question: "Which control-loop gate admits/rejects/revises the transition?"
      }
      N7: {
        id: "N7.next-state"
        question: "What admitted next state is observable?"
      }
    }

    allowedEdges: [
      "N0 -> N1",
      "N1 -> N2",
      "N1 -> N3",
      "N1 -> N4",
      "N2 -> N5",
      "N3 -> N5",
      "N4 -> N5",
      "N5 -> N6",
      "N6 -> N7",
    ]

    forbiddenEdges: [
      "SDK -> authority",
      "handler -> authority",
      "MCP -> authority",
      "shell script -> semantic authority",
      "generated artifact -> authority",
      "worker output -> transition without gate",
      "materialization -> admitted state without control action",
    ]
  }
}
```

# Issue-specific DAG instantiation

```cue
package issue

issue: #FactoryControlLoopIssue & {
  dag: nodes: {
    N1: answer: ""
    N2: answer: ""
    N3: answer: ""
    N4: answer: ""
    N5: answer: ""
    N6: answer: ""
    N7: answer: ""
  }
}
```

# Contract authority surfaces

```text
Root extension point:
  - existing CUE value/path:
  - required extension:

Authority surfaces:
  - contracts/factory/reflection.cue:
  - contracts/factory/control.cue:
  - contracts/factory/introspection.cue:

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

Generated evals/checks:
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
- [ ] Implementation plan instantiates the canonical `#FactoryControlLoopIssue` DAG.
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
