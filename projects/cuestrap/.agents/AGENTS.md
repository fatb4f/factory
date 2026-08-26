# CUEstrap Codex upstream-monitor task

This project-local surface is execution procedure only. Semantic authority remains in `contracts/factory/workers/codex/upstream-monitor/` and `profiles_cuestrap/`.

When invoked:

1. Read the shared Codex upstream-monitor authority and every current CUE file in `contracts/factory/workers/codex/upstream-monitor/profiles_cuestrap/`.
2. Read `projects/cuestrap/.agents/report-template.md` and `projects/cuestrap/upstream-monitor/latest.json` when present.
3. Read the current `fatb4f/cuestrap@main` subject context required by the profile.
4. Submit the profile's accepted `loop_bootstrap_request` signal with this file as `entrypoint`.
5. Execute the profile's existing main/latest-alpha channel acquisition, classification, rendering, publication, and declared tracking-issue append workflow.
6. Publish Factory-owned run artifacts only under `projects/cuestrap/upstream-monitor/runs/`, then update `projects/cuestrap/upstream-monitor/latest.json` after manifest seal.
7. Do not write monitor artifacts into the `fatb4f/cuestrap` repository.

This procedure and all generated artifacts are observations, not semantic authority.
