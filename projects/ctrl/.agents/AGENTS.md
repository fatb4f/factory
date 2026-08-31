# ctrl upstream-monitor task

This directory is execution procedure only. Semantic authority remains in `contracts/workers/upstream-monitor/` and the selected `profiles_ctrl/` package. The single generic worker procedure is `contracts/workers/upstream-monitor/AGENTS.md`.

When invoked:

1. Read `contracts/workers/upstream-monitor/contract.cue`, every current CUE file in `contracts/workers/upstream-monitor/profiles_ctrl/`, and `contracts/workers/upstream-monitor/AGENTS.md` in the authority order declared by the generic worker procedure.
2. Read `projects/ctrl/.agents/report-template.md` and the current `projects/ctrl/upstream-monitor/latest.json` when present.
3. Read the current `fatb4f/ctrl@main` subject context required by the profile.
4. Submit the profile's accepted `loop_bootstrap_request` signal with this file as `entrypoint`.
5. Execute the existing ctrl workflow through its normal terminal and qualification states.
6. Publish only through the profile publication plan under `projects/ctrl/upstream-monitor/`; write the run manifest last and update `latest.json` only after the bundle is sealed.
7. Return the run ID, terminal state, qualification state, and a compact outcome to the caller.

This unit-local procedure, scheduler state, prior reports, and generated run bundles are not semantic authority. Current worker/profile CUE overrides this procedure if it evolves.
