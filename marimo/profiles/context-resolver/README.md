# Context resolver

The context resolver is the single runtime path from a Codex prompt to a bounded context packet.

```text
UserPromptSubmit
  -> .codex/hooks.json
  -> context_resolver.py --codex-hook
  -> context_resolver.app.run(defs={"workbook_request": ...})
  -> reactive Marimo DAG
  -> filtered context graph
  -> fragments + implementation plan + checks + gates
```

## Ownership

Everything specific to context resolution remains under this profile:

```text
marimo/profiles/context-resolver/
├── .kb/
│   └── context.cue
├── README.md
├── architecture_validation.py
└── context_resolver.py
```

Both Python files are Marimo workbooks. `context_resolver.py` owns:

- prompt normalization and scoring;
- loading validated nested `.kb` projections;
- reactive subgraph selection and budgeting;
- source-fragment materialization;
- packet, check, and gate projection;
- Codex `UserPromptSubmit` envelope transport.

There is no standalone Python runtime or adapter layer. The repository-level `.codex/hooks.json` file only declares the Codex lifecycle binding and invokes this workbook directly.

`architecture_validation.py` is an operator-only workbook. It validates CUE
exports with Pydantic contracts and runs deterministic Hypothesis properties;
it is not registered as a Codex hook and never contributes prompt context.

## Authority

Each `.kb` boundary adapts its local fragments and workflow steps into `apercue.ca/patterns.#Graph`. CUE/Apercue owns:

- dependency-reference validation;
- graph depth and ancestry;
- inverse dependents;
- roots, leaves, and topology;
- cross-reference validation for fragments, checks, and gates.

The workbook consumes only exported, validated graph projections. It does not reconstruct the graph or calculate a second topology. Marimo remains the reactive filtering primitive: it ranks prompt matches, selects Apercue-provided ancestor/dependent closure, federates boundary projections, applies budgets, and emits a transient packet.

The packet is generated context, not source authority.

## Relation to quicue-kg

These `.kb` modules are context-boundary modules and do not claim conformance to the quicue-kg specification's root-level `.kg/`, `package kg` layout. They follow the applicable processing rules:

- CUE remains the source of truth;
- processors validate before consuming;
- contradictions fail during CUE evaluation;
- computed graph views are derived, never hand-maintained;
- external packets are one-way projections and do not become authority.

Architectural decisions, validated insights, rejected approaches, and reusable patterns belong in a conforming quicue-kg graph when that knowledge surface is introduced. They should not be encoded as transient context fragments.

## Reactive stages

1. Normalize the prompt and retrieval budget.
2. Export the parent and admitted child `.kb` outputs.
3. Reject missing or invalid Apercue graph projections.
4. Score fragment and workflow resources against the prompt.
5. Select exported ancestor/dependent closure and cross-project fragment usage.
6. Order implementation steps through exported workflow topology.
7. Materialize source-backed fragments and evaluate packet checks and gates.

## Validation

The hook requires `uv`, `cue`, and `jq`.

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

Run the operator validation on demand:

```bash
uv run --script marimo/profiles/context-resolver/architecture_validation.py \
  --validate --repo-root "$PWD"
```
