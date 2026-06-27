package contractsurface

upstreamCodexImpactReportTemplate: #ImpactReport & {
	impacts: {
		critical: []
		high: []
		notes: []
		noLocalAction: []
	}
	suggestedLocalTargets: []
	unresolvedEvidence: []
}

upstreamCodexPublicationPlan: #PublicationPlan & {
	report: {
		path: "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md"
	}
	issueTargets: {}
}

upstreamCodexScheduledTaskPrompt: """
Use the GitHub App to operate on fatb4f/factory@main.

Load and follow the instruction chain in order:

1. contracts/upstream-monitor/AGENTS.md
2. contracts/upstream-monitor/codex/AGENTS.md
3. contracts/upstream-monitor/codex/contract-surface/AGENTS.md

Input signal:

```text
signal_id: loop_bootstrap_request
target_repo: fatb4f/factory
entrypoint: contracts/upstream-monitor/codex/contract-surface/AGENTS.md
adapter: github_app
```

Task:

Run the Codex contract-surface upstream-monitor loop through the admitted report/publication surface. Use the loop-local CUE files as authority. Use upstream openai/codex only as evidence. Apply the fixed report template from `upstreamCodexImpactReportTemplate`. Use `upstreamCodexPublicationPlan` for any repo report path or issue update target.

Required constraints:

- Do not create report artifacts outside `contracts/upstream-monitor/codex/contract-surface/reports/`.
- Do not create evidence artifacts outside `contracts/upstream-monitor/codex/contract-surface/evidence/`.
- Do not update issues unless the issue target is declared by the publication plan.
- Do not treat ChatGPT output, GitHub adapter output, or upstream Codex state as authority.
- Keep unresolved upstream signals, including alpha-latest, unresolved unless concrete branch/ref/tag evidence is available.

Expected output:

- concise run report
- repo-local report artifact if publication is admitted
- issue update summary only for declared targets
- validation notes for CUE exports and forbidden-attractor checks
"""
