---
name: cue-emergency-transaction
description: Run Factory issue 105's bounded, shadow-only CUE implementation transaction. Use when constructing or validating a CUE candidate through the admitted Marimo workbook with pinned kernel forms, cue-py/libcue probes, module-aware CUE CLI gates, and an operator-reviewed candidate patch.
---

# CUE emergency transaction

Use the issue 105 workbook as the sole implementation surface. Keep the live repository read-only and leave patch application to the operator.

## Workflow

1. Read the current body of issue 105 and confirm the emergency authority remains active. Do not treat issue comments as authority.
2. Inspect `marimo/workflows/cue/cue_workbook.py --authority` for the workbook's pinned implementation constants. Verify external checkouts against those values; do not copy them into this skill.
3. Select only the kernel forms needed for the candidate intents and probes.
4. Create a request using schema `factory.cue-emergency-transaction-request.v3`:
   - Declare repository, exact base revision, allowed paths, structured candidate intents, package gates, and probes.
   - Give every gate explicit module, package, and file coordinates.
   - Give every equivalent value-level probe exactly one CUE source file.
   - Include positive and negative probes; use an adversarial probe when the proof is nontrivial.
   - Do not include LSP argv, binding expectations, generated CUE source, or validation harnesses.
5. Choose a new absolute promotion root outside the repository and runtime transaction root.
6. Run `just cue-transaction <absolute-request> <absolute-promotion-root>` from the repository root. The recipe resolves pinned dependencies, derives tools, creates disposable roots, and invokes locked/exact project execution.
7. Inspect `bounded-result.json`. Treat `accepted` as transaction evidence, not admission.
8. If a patch pair exists, verify the manifest and show the patch to the operator. Apply it only after explicit operator direction.

## Validation

Run `just validate-cue-emergency` after changing the workbook, request protocol, kernel projection, or this skill. Require every durable conformance check to pass.

Never generate source CUE or probe harnesses in this skill, guess a module root, improvise a failed command, apply a patch, mutate issue authority, or claim ordinary admission.
