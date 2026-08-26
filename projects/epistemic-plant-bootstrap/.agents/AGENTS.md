# epistemic-plant-bootstrap upstream-monitor task

This directory is execution procedure only. Semantic authority remains in `contracts/factory/workers/upstream-monitor/` and the selected `profiles_epistemic_plant_bootstrap/` package.

When invoked:

1. Read `contracts/factory/workers/upstream-monitor/AGENTS.md`, `contract.cue`, and every current CUE file in `contracts/factory/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/`.
2. Read `projects/epistemic-plant-bootstrap/.agents/report-template.md` and the current `projects/epistemic-plant-bootstrap/upstream-monitor/latest.json` when present.
3. Read the current `fatb4f/epistemic-plant-bootstrap@main` subject context required by the profile.
4. Submit the profile's accepted `loop_bootstrap_request` signal with this file as `entrypoint`.
5. Execute the existing epistemic-plant-bootstrap workflow through its normal terminal and qualification states.
6. Publish only through the profile publication plan under `projects/epistemic-plant-bootstrap/upstream-monitor/`; write the run manifest last and update `latest.json` only after the bundle is sealed.
7. Return the run ID, terminal state, qualification state, and a compact outcome to the caller.

This procedure, scheduler state, prior reports, and generated run bundles are not semantic authority. Current worker/profile CUE overrides this procedure if it evolves.
