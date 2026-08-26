# factory Codex upstream-monitor task

This project-local surface is execution procedure only. Semantic authority remains in `contracts/factory/workers/codex/upstream-monitor/` and `profiles_factory/`.

When invoked:

1. Read the shared Codex upstream-monitor authority and every current CUE file in `contracts/factory/workers/codex/upstream-monitor/profiles_factory/`.
2. Read `projects/factory/.agents/report-template.md` and `projects/factory/upstream-monitor/latest.json` when present.
3. Submit the profile's accepted `loop_bootstrap_request` signal with this file as `entrypoint`.
4. Execute the profile's existing main/latest-alpha channel acquisition, classification, rendering, and publication workflow.
5. Publish new bundles only under `projects/factory/upstream-monitor/runs/`, then update `projects/factory/upstream-monitor/latest.json` after manifest seal.
6. Treat `projects/factory/upstream-monitor/legacy-reports/` and `legacy-evidence/` as read-only historical migration inputs.

This procedure and all generated artifacts are observations, not semantic authority.
