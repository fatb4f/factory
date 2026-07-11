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
└── context_resolver.py
```

The only Python file is the Marimo workbook. It owns:

- prompt normalization;
- nested `.kb` loading;
- context graph construction and filtering;
- fragment and implementation-plan projection;
- check and gate evaluation;
- Codex `UserPromptSubmit` envelope transport.

There is no standalone Python runtime or adapter layer. The repository-level `.codex/hooks.json` file only declares the Codex lifecycle binding and invokes this workbook directly.

## Authority

The parent `.kb/context.cue` file owns the admitted nested boundaries. Each child `.kb` module exports its own fragments, plan steps, checks, and gates. The workbook loads those projections, constructs the available graph, and reactively filters it from the submitted prompt.

The workbook-generated graph and packet are transient. They do not become knowledge authority.

## Reactive stages

1. Normalize the prompt and retrieval budget.
2. Export the parent and admitted child `.kb` outputs.
3. Construct the available context graph.
4. Select matching seeds and close their declared relationships.
5. Materialize source-backed fragments and project the implementation plan, checks, and gates.

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
