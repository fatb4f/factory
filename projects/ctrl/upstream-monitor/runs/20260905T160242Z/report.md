# ctrl upstream impact report

## Run identity

- Run ID: `20260905T160242Z`
- Monitor state: `terminal_success`
- Qualification state: `observation_only`
- Authority revision: `09d2ee19594152354362f0024a061c31ef7be65b`
- Publication revision: `not-yet-sealed`
- ctrl context revision: `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`
- Bootstrap baseline: `false`

## Subject context

`fatb4f/ctrl@main` remains at `b5f82c3a5e33d08d1f5d07cb2c9724c7679c7538`. `spec/` remains the sole qualification semantic authority; the root is a non-package uv workspace pinned to Python 3.14. Component roots and source imports are unchanged from the previous admitted run.

## Project topology and ownership

The profile topology remains unchanged: `ctrl` owns repository mutation control and qualification; `python-intel` remains architectural observation infrastructure; the PyPI/wheel/PEP pipeline is a materialization workload; `semagrams` remains future design substrate. Sibling projects and providers do not acquire ctrl qualification authority.

## Qualified reactive evaluation kernel

The profile-defined sequence remains: source-qualified observation -> semantic admission -> immutable EvaluationWorld -> DPI lowering -> monotonic derivation -> external CUE qualification -> qualified/rejected/inconclusive fixpoint -> immutable seal -> deterministic projection/effect intent. The current GitHub actuator observed this contract but did not execute the semantic kernel.

## Source state

Required channels resolved independently:
- Codex main `89208f09f819c0ff00c2608a33422a5f6b885c76`; latest-alpha-cli `3d2ee51ca2d5db578f328aa75e20aa22c0197c9a`.
- CPython 3.14 `5532330b7ebaf19bb7e59b2e7a03b55dfda81dcd`; main `14a93f4d91edf767e7b35413127cfcd6a2806983`.
- Astral/Ruff main `0451200c3428e4b81661b91af8ed75bdb16fa3fe`.
- SCIP main `1c2b6db7e560d5233c944f36e4ac1377cc6963fc`.
- OTel Python core `96df63add12f6e0453b265ac34c5c07ec7b9267e`; contrib `a3881e6d3070eb52a81e4dc7f8a48d78a1bd8417`.
- GenAI semconv `94f432d7126f5884d30a2cdde6f4e89908ebb6fd`; Python GenAI `59e6efe6c0be45a9da78f8f3c21c5d6ac4488ed1`.
- OTel-Arrow `6f96123c02aae9b2839d470e8b33aa7b543e4b5b`; Weaver `2983e2cf00f3138d564ed63a1b56102cb7bf15ea`.
- CUE pinned `806821e40fae070318600a264d311517e596353b`; master `eb886ed07a0864cc6bbc081bb8f1efa9fb834944`.

## Codex projection graph

Codex main is 158 commits ahead of the prior admitted baseline. App-server protocol/schema projections changed alongside MCP client-owned tool catalogs and refresh coordination, live app tool refresh, session-hook refresh, permissions/application requirements, and thread/runtime behavior. The alpha channel advanced to the v0.153.4 line. No local projection or policy compatibility execution was available.

## Python semantic and operational graph

The active CPython 3.14 channel advanced 21 commits and changed declared `inspect` and tokenizer surfaces. Forecast `main` now fixes a compiler crash for deeply nested inlined comprehensions. Ruff/ty advanced separately as analyzer evidence. SCIP reached 0.10.0 and added a generated .NET binding surface. No analyzer result is treated as CPython runtime truth, and no regrtest/probe/correlation execution was performed.

## Observation and acquisition graph

OpenTelemetry sources remain observation providers only. Python GenAI changed cancellation handling from success-like completion to failure/error observation for `BaseException` paths. GenAI semantic-convention reference scenarios expanded client metric coverage. These do not alter qualification authority.

## Relational and diagnostic projection

Arrow/DuckDB/Ibis/Polars/Marimo remain projection or execution substrates only. No relational projection was executed in this run.

## Semantic interface projection

Weaver remains a projected semantic-interface realization for `DiagnosticPacket`, not qualification authority. Its required channel resolved, but no local Weaver projection/conformance execution was available.

## Correlation carrier policy

Semantic/world identity remains distinct from trace/span identity. Baggage remains deny-by-default; no source text, prompts, credentials, or large evidence payloads are admitted as telemetry carriers.

## Current executable frontier

The profile frontier remains one Codex turn through candidate admission, immutable world, static/runtime differential observations, OTel causal correlation, DPI lowering, CUE qualification, sealed bundle, DiagnosticPacket, Weaver projection, and feedback into parent Codex. GitHub App coverage gaps remain for CUE execution, CPython probes/regrtest, SCIP/Astral correlation, OTLP/OTAP round-trip, relational projection, semantic-kernel execution, and Weaver projection.

## Critical

- **Codex MCP, hooks and live tool-catalog gate widened.** Main advanced 158 commits across the declared policy/tool boundary, including MCP client-owned catalog revision/refresh semantics and session hook refresh. The local gate remains open.

## High

- **Codex app-server protocol/schema:** request/notification, thread, MCP, permission and application-requirement schemas changed materially.
- **CPython 3.14:** active introspection/tokenizer surfaces advanced without local executable witnesses.
- **CPython main:** forecast compiler semantics changed for deeply nested inlined comprehensions; this is not projected backward onto 3.14.
- **CUE master:** recursive-disjunction evaluator scheduling changed; the pinned evaluator remains `806821e40fae070318600a264d311517e596353b` and must not be replaced without migration qualification.
- **SCIP 0.10.0:** generated binding/version surface advanced; compatibility correlation is required before local adoption.

## Notes

- Python GenAI instrumentation now records cancellation as failure/error evidence rather than success-like UNSET status.
- GenAI semantic-convention reference scenarios expanded token-usage and operation-duration metric examples. ctrl P0 remains trace-only.

## No local action

No required source was unresolved. OTel Python contrib remained unchanged at the prior head; other source movement not bound above did not establish additional local action.

## Publication

- Bundle: `projects/ctrl/upstream-monitor/runs/20260905T160242Z/`
- Manifest: `projects/ctrl/upstream-monitor/runs/20260905T160242Z/manifest.json`
- Latest pointer: `projects/ctrl/upstream-monitor/latest.json`
- Export unit: directory

## Validation notes

Authority, full selected profile CUE, subject context, topology, semantic kernel, graph, source channels, correlation carrier policy, interface boundary, publication plan, and forbidden-attractor policy were read. All required sources resolved. Report and summary are projections of `evidence.json`. CUE execution is unavailable to the GitHub App; CPython regrtest/probes, Astral/SCIP correlation, OTel pipeline/OTLP-OTAP round-trip, relational projection, semantic-kernel execution and Weaver projection were not executed. `terminal_success` therefore remains independent of `qualification_state: observation_only`.
