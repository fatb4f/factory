# Context resolver

The context resolver is the single runtime path from a Codex prompt to a bounded context packet.

```text
UserPromptSubmit
  -> .codex/hooks.json
  -> context_resolver.py --codex-hook
  -> context_resolver.app.run(defs={"workbook_request": ...})
  -> reactive Marimo DAG
  -> Pydantic-validated request and boundary projections
  -> filtered context graph
  -> Pydantic-validated packet
  -> fragments + implementation plan + checks + gates
```

## Ownership

Everything specific to context resolution remains under this profile:

```text
marimo/profiles/context-resolver/
├── .kb/
│   └── context.cue
├── README.md
└── context_resolver.py
```

The only Python file is the Marimo workbook. It owns:

- strict request, hook-envelope, graph-projection, packet, and validation-report models through Pydantic;
- prompt normalization and exact-token scoring;
- loading validated nested `.kb` projections;
- reactive subgraph selection and budgeting;
- source-fragment materialization;
- packet, check, gate, and metric projection;
- embedded deterministic and Hypothesis property validation;
- Codex `UserPromptSubmit` envelope transport.

There is no standalone Python runtime, adapter, or test module. The repository-level `.codex/hooks.json` file only declares the Codex lifecycle binding and invokes this workbook directly.

## Authority

Each `.kb` boundary adapts its local fragments and workflow steps into `apercue.ca/patterns.#Graph`. CUE/Apercue owns:

- dependency-reference validation;
- graph depth and ancestry;
- inverse dependents;
- roots, leaves, and topology;
- cross-reference validation for fragments, checks, and gates.

The workbook consumes only exported, validated graph projections. It does not reconstruct the graph or calculate a second topology. Pydantic validates the transport contract and verifies that exported references remain closed when projected. Marimo remains the reactive filtering primitive: it ranks prompt matches, selects Apercue-provided ancestor/dependent closure, federates boundary projections, applies budgets, and emits a transient packet.

The packet is generated context, not source authority.

## Runtime contracts

The workbook rejects unknown fields and malformed values at every external boundary.

- `HookEvent` admits only `UserPromptSubmit` envelopes with a non-empty prompt.
- `RequestInput` accepts requested budgets, which normalization clamps into the bounded `ContextRequest` contract.
- `BoundaryOutput` requires valid context and workflow projections and closed declaration references.
- `ContextPacket` requires unique nodes, resolved edges, exact budget accounting, repository-bounded sources, and satisfied resolver gates before admission.
- `ValidationReport` is the machine-readable exit result for embedded validation mode.

The corresponding CUE `#WorkbookRequest`, `#PacketMetrics`, and `#WorkbookResult` definitions describe the same projected wire contract.

## Reactive stages

1. Validate and normalize the prompt, scope, and retrieval budget.
2. Export the parent `.kb` boundary.
3. Apply the boundary allowlist before exporting children.
4. Reject missing or invalid Apercue graph projections.
5. Score fragment and workflow resources using exact token intersections.
6. Select exported ancestor/dependent closure and cross-project fragment usage.
7. Order implementation steps through exported workflow topology.
8. Materialize repository-bounded sources.
9. Enforce `maxFragments`, `maxSteps`, `maxNodes`, and final serialized `maxTokens`.
10. Validate the final packet before hook transport.

## Embedded validation

Validation mode executes deterministic scenarios and Hypothesis properties from inside the workbook. The suite covers:

- request normalization and budget bounds across generated inputs;
- scoped-boundary success without exporting excluded children;
- unresolved-boundary rejection;
- repository source-escape rejection;
- strict `maxNodes` truncation and rejection;
- final-packet `maxTokens` measurement and rejection;
- malformed hook-envelope rejection;
- exact token matching without substring matches;
- live CUE-to-workbook integration on the context-resolver boundary.

Run the complete profile-local suite:

```bash
uv run --script marimo/profiles/context-resolver/context_resolver.py \
  --validate \
  --repo-root "$PWD" |
  jq -e '.passed == true and ([.cases[].status] | all(. == "pass"))'
```

The command exits non-zero when any deterministic case, Hypothesis property, Pydantic contract, or live CUE integration check fails.

## Hook validation

```bash
payload='{"hook_event_name":"UserPromptSubmit","prompt":"inspect the CUE and Python code-intel context profiles"}'

printf '%s\n' "$payload" |
  uv run --script marimo/profiles/context-resolver/context_resolver.py \
    --codex-hook \
    --repo-root "$PWD" |
  jq -e '
    .hookSpecificOutput.hookEventName == "UserPromptSubmit"
    and (.hookSpecificOutput.additionalContext | fromjson
      | .schema == "factory.context-packet.v0"
      and .admitted == true
      and (.selected_fragments | length > 0)
      and (.implementation_plan | length > 0)
      and (.context_graph.nodes | length > 0))
  '
```
