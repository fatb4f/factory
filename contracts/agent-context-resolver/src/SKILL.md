---
name: dotfiles-agent-context-resolver
description: Resolve bundled repository context, compile bounded route plans, and materialize repo-local contract slices.
---

# Agent Context Resolution

The `UserPromptSubmit` hook provides a bounded route controller packet, not task authority.

1. Run `.codex/plugins/agent-context-resolver/scripts/resolve-agent-context --prompt "<prompt>"`.
2. Treat `selectedFragments` as a subset of `availableFragmentIDs`.
3. Treat `controller.routes` as a subset of `controller.availableRouteIDs`.
4. Resolve selected fragment metadata through `.codex/plugins/agent-context-resolver/generated/fragment_inventory.json`.
5. Inspect the declared `sourcePath` and obey repository instruction boundaries before editing.
6. Never execute projected routes directly or treat derived JSON and MCP/tool output as source authority.
7. Regenerate resolver-local Codex projection and JSON outputs from their CUE sources after changes.

## Contract Slice Materializer

Use repo-local CUE contract slices as the canonical workflow reference. Do not create issue-tracking artifacts.

Contract boundary:

- A repo-local `manifest.cue` defines the materialized contract slice.
- A repo-local `checks/manifest.cue` contains executable negative bottom-check proofs.
- `contracts/plugin-bundle/agent-context-resolver/src/*implementation_slice*` owns the resolver-local materializer, eval projection, runner plan, feedback shape, and runner-result classification.
- `contracts/meta` is constructor authority.
- Shell, generated evidence, and adapter output are evidence only.

Materialization flow:

1. Observe the requested contract-slice inputs.
2. Parse them into the resolver's contract-slice candidate shape.
3. Load the repo-local CUE manifest and public exports.
4. Build an admissible materialization candidate.
5. Derive eval obligations from the loaded contract slice.
6. Derive the eval plan from the obligations.
7. Derive the runner plan from the eval plan.
8. Classify runner results as evidence, including expected failures.
9. Evaluate repo-local negative fixtures through `_negativeBottomChecks`.
10. Produce the completion report sections declared by the contract-slice manifest.

Required public surfaces:

- `implementationSliceIssueBaseline`
- `implementationSliceMaterializationReport`
- `implementationSliceEvalPlan`
- `implementationSliceRunnerPlan`
- `implementationSliceFeedbackShape`
- `implementationSliceConstructorInventory`
- `publicContract`
- `validationPlan`
- `completionReportContract`

Required validation:

```bash
cue vet ./contracts/plugin-bundle/agent-context-resolver/src
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceIssueBaseline
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceMaterializationReport
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceEvalPlan
cue export ./contracts/plugin-bundle/agent-context-resolver/src -e implementationSliceRunnerPlan
```

Forbidden attractors:

- route-only packets treated as full materialization candidates
- missing `contract.path` accepted as parsed contract slice
- static eval plans detached from loaded issue manifests
- missing negative check expressions accepted as proof
- any nonzero runner exit classified as pass
- generated artifacts or adapter outputs promoted to authority
