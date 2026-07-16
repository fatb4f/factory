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

Run the CUEstrap-adapted Codex contract-surface upstream-monitor loop through the admitted report/publication surface. Use the factory-local CUE profile as authority. Read the current fatb4f/cuestrap@main context before classifying upstream evidence. Use upstream openai/codex only as evidence. Check openai/codex targets `main` and `latest-alpha-cli`; keep both channels distinct in report and evidence.

Assess impact separately for:
- the gopy, CUE, Pydantic, and Hypothesis supervisory session controller;
- the gopy-backed Marimo workbook harness for idiomatic CUE.

Apply `cuestrapCodexImpactReportTemplate`. Use `cuestrapPublicationPlan` for every factory artifact and cross-repository report copy.

Required constraints:
- Keep all authority, actuator instructions, evidence, and primary report plumbing in fatb4f/factory.
- Do not create factory reports outside contracts/upstream-monitor/codex/cuestrap-contract-surface/reports/.
- Do not create factory evidence outside contracts/upstream-monitor/codex/cuestrap-contract-surface/evidence/.
- Publish only report copies to fatb4f/cuestrap under reports/upstream-monitor/codex/.
- Make each cuestrap report copy byte-equivalent to the corresponding factory report.
- Do not publish evidence, CUE authority, AGENTS files, prompts, or actuator plumbing to cuestrap.
- Do not update issues unless the target is declared by cuestrapPublicationPlan.
- Do not treat ChatGPT output, GitHub adapter output, cuestrap repository state, or upstream Codex state as monitor authority.
- Keep unresolved upstream signals unresolved unless concrete branch/ref/tag evidence is available.
- Do not collapse latest-alpha-cli evidence into main or main evidence into alpha.

Expected output:
- Concise run report.
- Factory-local report and evidence artifacts if publication is admitted.
- Byte-equivalent report copies in fatb4f/cuestrap if mirror publication is admitted.
- Issue update summary only for declared targets.
- Validation notes for context reads, CUE exports, mirror equivalence, and forbidden-attractor checks.
