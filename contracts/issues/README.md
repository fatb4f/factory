# Issue Constructor Manifests

Issue manifests live under `contracts/issues/<issue-number>/manifest.cue`.

Each manifest imports `github.com/fatb4f/contract.cuemod/contracts/meta/impl` and uses constructor calls from that package. Constructor definitions remain in `contracts/meta/impl`; issue bodies and manifests carry compact intent, target paths, constructor instantiation sites, validation plans, and completion-report contracts.

Generated or normalized issue outputs should live beside the manifest:

- `normalized.cue` exports `normalizedIssueManifest`.
- `validation.cue` exports `issueValidationPlan`.
- A separate check surface exports `_negativeBottomChecks` for structural bottom checks.

Codex-facing slices follow this sequence:

1. Read the GitHub issue with `gh issue view`.
2. Open the manifest path when one is present.
3. Read constructor authority from `contracts/meta/impl`.
4. Expand the manifest into concrete target CUE files.
5. Run the generated validation plan.
6. Return the completion report.
