# ctrl upstream-monitor summary

Run `20260902T162000Z` completed `terminal_success`; qualification remains `observation_only`.

`fatb4f/ctrl@main` is unchanged at `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`. Codex main advanced by 126 commits and materially changed app-server schemas, plugin reconciliation, permissions, MCP/hooks, thread lifecycle and retained-context behavior, so the existing Codex policy/protocol compatibility gate remains open. OTel-Arrow and Weaver also advanced materially. CPython 3.14/main, OpenTelemetry Python/GenAI, Ruff and SCIP moved, but no new source observation overrides ctrl semantic authority.

No local semantic-kernel, CUE, CPython probe/regrtest, OTLP↔OTAP or Weaver projection execution was available through the GitHub actuator; those gaps remain explicit.