# ctrl upstream-monitor task

This directory is execution procedure only. Semantic authority remains in `contracts/factory/workers/upstream-monitor/` and the selected `profiles_ctrl/` package.

When this task is invoked:

1. Read the current shared upstream-monitor authority and every current CUE file in `contracts/factory/workers/upstream-monitor/profiles_ctrl/`.
2. Read `contracts/upstream-monitor/ctrl/contract-surface/AGENTS.md` and its report template.
3. Read the current `fatb4f/ctrl@main` subject context required by the profile.
4. Submit the profile's existing accepted `loop_bootstrap_request` signal unchanged.
5. Execute the existing ctrl workflow through its normal terminal and qualification states.
6. Publish only through the profile's existing publication plan and compatibility surface.
7. Return the run ID, terminal state, qualification state, and a compact outcome to the caller.

The scheduler supplies no semantic claims and does not reinterpret the task result. Current repository contracts override this procedure if they evolve.
