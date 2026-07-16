Use the GitHub App to operate on fatb4f/factory@main.

Load and follow the instruction chain in order:
1. contracts/upstream-monitor/AGENTS.md
2. contracts/upstream-monitor/codex/AGENTS.md
3. contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md

Input signal:
signal_id: loop_bootstrap_request
profile_id: cuestrap
target_repo: fatb4f/factory
context_repo: fatb4f/cuestrap
entrypoint: contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md
adapter: github_app

Run the CUEstrap-adapted Codex contract-surface upstream-monitor loop through the admitted publication surface. Use the factory-local CUE profile as authority. Read the current fatb4f/cuestrap@main context before classifying upstream evidence. Use upstream openai/codex only as evidence. Check openai/codex targets `main` and `latest-alpha-cli`; keep both channels distinct in report, summary, and evidence.

Assess impact separately for:
- the gopy, CUE, Pydantic, and Hypothesis supervisory session controller;
- the gopy-backed Marimo workbook harness for idiomatic CUE.

Apply `cuestrapCodexImpactReportTemplate`, `cuestrapRunSummaryTemplate`, and `cuestrapPublicationPlan` for every canonical factory artifact, cross-repository report projection, and tracking issue update.

Required constraints:
- Publish the canonical report, summary, evidence, and sealing manifest into one factory run directory declared by the publication plan.
- Update only the factory `latest.json` pointer after the canonical manifest exists.
- Publish only the admitted report-and-summary projection bundle to fatb4f/cuestrap.
- Make each cuestrap report and summary copy byte-equivalent to its corresponding factory source.
- Bind the CUEstrap projection manifest to the canonical factory bundle.
- Do not publish evidence, CUE authority, AGENTS files, prompts, or actuator plumbing to cuestrap.
- Treat legacy report and evidence paths as read-only migration inputs.
- Resolve `fatb4f/cuestrap#9` before acquisition and use it as the sole tracking issue.
- Append exactly one comment for every terminal run, including success, abort, deferred, and coverage-gap outcomes.
- Use tracking identity `cuestrap-codex-contract-surface/<run_id>` to suppress duplicate comments.
- Never edit the tracking issue title or body during a run.
- Do not update any other issue unless separately declared by `cuestrapPublicationPlan`.
- Do not treat ChatGPT output, GitHub adapter output, cuestrap repository state, issue comments, or upstream Codex state as monitor authority.
- Keep unresolved upstream signals unresolved unless concrete branch/ref/tag evidence is available.
- Do not collapse latest-alpha-cli evidence into main or main evidence into alpha.

Expected output:
- Concise run summary.
- One sealed canonical factory run bundle if publication is admitted.
- One CUEstrap report-projection bundle if mirror publication is admitted.
- One deduplicated append-only run comment on fatb4f/cuestrap#9.
- Validation notes for context reads, CUE exports, bundle completeness, manifest seals, source binding, mirror equivalence, tracking issue append, and forbidden-attractor checks.