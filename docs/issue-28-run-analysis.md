# Issue 28 prompt-run analysis

## Purpose

This document records the `issue_28.patch` run sequence as a prompt/control case study.

The useful result was not just the final CUE patch. The useful result was the discovery of a reusable input shape for CUE-centered work:

```text
Eval-first prompts produce structural CUE.
Vocabulary-first prompts produce decorative schema.
Review-first prompts produce metadata.
```

This document captures:

- the input patterns used across runs;
- the output patterns those inputs produced;
- the inference from the run sequence;
- the specific input shape that fixed the model.

---

## Target invariant

The intended CUE invariant was:

```cue
badObservedPatch & #RootPromotionCandidate == _|_
```

More concretely, each invalid negative fixture should fail by real intersection:

```cue
negativeFixtures.<fixture>.input & #RootPromotionCandidate
```

The refusal must happen because the observed object shape contradicts the candidate/admissible type, not because an operator-supplied flag says the input is invalid.

---

## Run sequence summary

| Run | Input shape | Output shape | Result |
|---:|---|---|---|
| 28.0 | Broad prose rejection with many required nouns | Side-package schema, fake provenance defaults, regex path admission, placeholder evidence | Block |
| 28.1 | Asked for `#ObservedPatch`, `#PatchPredicates`, `#PromotionCandidate`, typed fixtures | Root package improved, but invalidity modeled as diagnostic booleans | Block |
| 28.2 | Asked to encode what changed, why blocked, and next shape | CUE review metadata and stringified bottom-check expressions | Block |
| 28.3 | Asked to summarize/analyze patch attempts | Identified recurring pattern: vocabulary without connected constraint authority | Analysis pass |
| 28.4 | Used the previous analysis as the next prompt | Introduced `#DerivedPath`, `#VCSEvidence`, `#RootPromotionCandidate`, real `_negativeBottomChecks` | Mostly correct |
| 28.5 | Applied narrow correction slice to prior good run | Broadened observed state, narrowed candidate, added fake provenance structural fixture and bottom check | Accept |

---

## Observed failure pattern

The repeated failure was:

```text
semantic vocabulary exists
but constraint authority is not connected
```

Earlier runs created the requested nouns:

```cue
#ObservedPatch
#PatchPredicates
#PromotionCandidate
#NegativeFixture
expectedBottom
promotionGate
closureReport
```

But the actual control loop looked like:

```text
ObservedPatch
  -> contains operator-supplied booleans

PatchPredicates
  -> declared but not authoritative

PromotionCandidate
  -> duplicates boolean checks inline

NegativeFixture
  -> declares expectedBottom

PromotionGate
  -> lists checks as strings or metadata
```

That is a review model, not a CUE control model.

---

## Boolean-control attractor

Several rejected patches represented invalidity like this:

```cue
paths: {
    finalPathSuppliedDirectly: true
    regexOnlyAdmission: true
    rootPolicyDerived: false
}

evidence: {
    placeholderEvidence: true
    adapterDeclaredHead: true
    fakeDigestDefault: true
}
```

That reverses authority:

```text
wrong:
  operator declares whether object is bad

right:
  contract derives badness from object structure
```

The fixed shape uses contradictory structure instead:

```cue
paths: {
    agentContextHookCheck: #ObservedPath & {
        kind:  "check"
        name:  "agent-context-hook"
        value: "contracts/factory/reflection/projections/checks/manual-invalid"
    }
}
```

and the candidate narrows it through an algebraic path policy:

```cue
#DerivedPath: close({
    owner: {
        path: "contracts/factory"
    }

    pathPolicy: {
        segments: {
            check: "reflection/projections/checks"
        }
    }

    kind: "check"
    name: string

    value: "\(owner.path)/\(pathPolicy.segments[kind])/\(name)"
})
```

Now the invalid path bottoms because `value` contradicts the derived equation.

---

## Review-metadata attractor

The prompt:

```text
Use CUE to encode:
- what the changes represent;
- why they are blocked;
- what the next iteration shape should be for promo
```

produced useful explanatory CUE, but not the desired authority surface.

The output shape was effectively:

```cue
issue28ObservedPromoPatch: {
    currentModel: {
        pathModel: "regexOrBooleanFlags"
    }
}

#NextPromoIterationShape: {
    currentModel: {
        pathModel: "algebraicDerivedPath"
    }
}

bottomCheckSurface: {
    expression: "negativeFixtures.nonDerivedPath.input & #RootPromotionCandidate"
    expectedBottom: true
}
```

That bottoms metadata labels, not invalid CUE structures.

Correct bottom surface:

```cue
_negativeBottomChecks: {
    nonDerivedPath:
        negativeFixtures.nonDerivedPath.input & #RootPromotionCandidate
}
```

The check must be an evaluated CUE expression, not a string field.

---

## Inference from the run sequence

The stable prompt/output pattern was:

```text
Prompt asks for concept
  -> Codex emits vocabulary

Prompt asks for review
  -> Codex emits metadata

Prompt asks for constraints
  -> Codex often emits flags

Prompt asks for specific bottoming intersections
  -> Codex emits structural CUE
```

This gives the reusable control rule:

```text
CUE prompts must be eval-first, not vocabulary-first.
```

In practice, the prompt must name:

1. the required invalid input object;
2. the required candidate/admissible type;
3. the exact intersection that must bottom;
4. the forbidden boolean/review attractors;
5. the acceptance commands.

---

## Working primitive split

The successful model used this role boundary:

```text
#Observed<T>
  -> broad fact substrate
  -> can represent valid and invalid observed states

#Admissible<T>
  -> narrow admissible structure
  -> rejects invalid values structurally

#PatchPredicates
  -> derived from observed structure
  -> no operator-supplied truth flags

#RootPromotionCandidate
  -> closed admissibility surface
  -> wires predicates as control

#NegativeFixture
  -> typed invalid observed object

_negativeBottomChecks
  -> real CUE intersections
  -> expected to bottom
```

The critical split is:

```text
observed bad state is representable
  ∧
root promotion candidate is narrow
  =
bottom
```

---

## The input that fixed the run

The successful input was not a broad architecture request. It was a narrow correction slice.

Use this pattern as the canonical prompt shape:

```text
Correct the last issue_28 patch without redesigning it.

Keep:
- package factory only
- #ObservedPath / #DerivedPath split
- #ObservedVCSEvidence / #VCSEvidence split
- #RootPromotionCandidate
- predicates: #PatchPredicates & { input: ... }
- _negativeBottomChecks as real intersections
- blocked-only #RootPromotionGate
- passed=false #ClosureReport

Change only the remaining impurity:

1. Broaden #ObservedPatch so it can represent bad observed states.
   #ObservedPatch must allow:
   - closureClaim.decision: #Decision
   - closureClaim.declaresPass: bool
   - closureClaim.declaresClosurePassed: bool
   - empiricalGate.closureProven: bool

2. Keep #RootPromotionCandidate narrow.
   #RootPromotionCandidate must require:
   - closureClaim.decision: "blocked"
   - closureClaim.declaresPass: false
   - closureClaim.declaresClosurePassed: false
   - empiricalGate.closureProven: false

3. Add #ObservedProvenance.
   #ObservedPatch.provenance must use #ObservedProvenance, not #Provenance.
   #RootPromotionCandidate.provenance must use #Provenance.

4. Change #NegativeFixture.input from _ to #ObservedPatch.

5. Add a fake-provenance negative fixture whose input uses actual fake zero provenance:
   sourceDigest: "sha256:0000000000000000000000000000000000000000000000000000000000000000"
   inventoryDigest: "sha256:0000000000000000000000000000000000000000000000000000000000000000"
   materializedAt: "run:0000000000000000"

6. Add a real bottom check:
   _negativeBottomChecks.fakeProvenance:
     negativeFixtures.fakeProvenance.input & #RootPromotionCandidate

7. Remove decorative/unused surfaces unless they are used by the contract:
   - #Truth
   - #Authority
   - injectedProvenance

Do not reintroduce:
- finalPathSuppliedDirectly
- regexOnlyAdmission
- rootPolicyDerived
- placeholderEvidence: bool
- expectedBottom-only checks
- bottomCheckSurface.expression
- review-only promo metadata

The target invariant is:

negativeFixtures.fakeProvenance.input & #RootPromotionCandidate == _|_

for structural reasons, not because a boolean flag says provenance is fake.
```

The patch then passed because it implemented the target split:

```text
#ObservedProvenance
  -> permits observed fake zero values

#Provenance
  -> rejects zero digest / fake run IDs

negativeFixtures.fakeProvenance.input & #RootPromotionCandidate
  -> bottoms
```

---

## Final accepted output shape

The final accepted patch reported:

```text
Summary:
- Broadened #ObservedPatch so bad closure and provenance observations are representable.
- Kept #RootPromotionCandidate narrow for blocked closure, admissible provenance, derived paths, and typed VCS evidence.
- Added #ObservedProvenance, tightened #NegativeFixture.input to #ObservedPatch, and added negativeFixtures.fakeProvenance.
- Added _negativeBottomChecks.fakeProvenance as a real intersection in checks_test.cue.
- Removed unused #Truth and #Authority.
- Kept injectedProvenance only because existing control.cue/introspection.cue required that package-level binding for cue vet.
```

Validation reported:

```text
cue vet ./contracts/factory: pass
cue export ./contracts/factory -e factory: pass
cue export ./contracts/factory -e issue: pass
cue export ./contracts/factory -e promotionGate: pass
cue export ./contracts/factory -e closureReport: pass
cue export ./contracts/factory -e negativeFixtures.prematureClosureClaim.input: pass
cue export ./contracts/factory -e negativeFixtures.fakeProvenance.input: pass
negativeFixtures.fakeProvenance.input & #RootPromotionCandidate: pass, expected bottom
all negative fixture intersections with #RootPromotionCandidate: pass, expected bottom
old boolean/review-field search: pass, no matches
```

The compatibility exception was accepted under this rule:

```text
injectedProvenance
  -> compatibility binding only
  -> not default provenance
  -> not admissibility evidence
  -> not used to make missing provenance valid
```

---

## Reusable prompt contract

For future CUE-centered repos, use this prompt contract:

```text
Implement a bounded CUE slice.

Start from evals, not vocabulary.

Required positive evals:
- cue vet ./<contract-path>
- cue export ./<contract-path> -e <validBaselineExpr>
- cue export ./<contract-path> -e <publicSurfaceExpr>

Required negative evals, if the slice has refusal logic:
- ! cue export ./<contract-path> -e '_negativeBottomChecks.<fixtureName>'

Required model split:
- #Observed<T> is broad enough to represent invalid observations.
- #Admissible<T> / #Candidate is narrow enough to reject them.
- #Predicates derives violations from structure.
- #Candidate wires predicates as control.
- #NegativeFixture.input is typed as the observed type.
- _negativeBottomChecks contains real intersections.

Forbidden attractors:
- diagnostic boolean fields used as authority
- expectedBottom without real intersections
- stringified CUE expressions
- bottomCheckSurface.expression
- review-only metadata as proof
- fake/default provenance
- placeholder evidence accepted as admissible evidence
- manually supplied derived values accepted as valid
- side-package schema sprawl
```

---

## Design conclusion

The patch_28 run did not merely fix a factory contract. It produced a reusable Codex-control lesson:

```text
Do not ask the agent to understand the architecture first.
Ask it to satisfy the eval surface first.
```

For CUE work, the primitive unit of implementation should be:

```text
valid export
+
invalid fixture intersection that bottoms
+
forbidden attractor search
```

Only after those surfaces exist should the slice expand into richer documentation, adapters, projections, or downstream promotion states.
