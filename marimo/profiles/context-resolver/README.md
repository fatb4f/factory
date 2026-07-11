# Context resolver

The context resolver is the single runtime path from a Codex prompt to a bounded context packet.

```text
UserPromptSubmit
  -> .kg/hooks/codex/user-prompt-submit
  -> adapters/codex_hook.py
  -> context_resolver.app.run(defs={"workbook_request": ...})
  -> reactive Marimo DAG
  -> filtered context graph
  -> fragments + implementation plan + checks + gates
```

## Authority

The parent `.kb/context.cue` file owns the admitted nested boundaries. Each child `.kb` module exports its own fragments, plan steps, checks, and gates. The workbook loads those projections, constructs the available graph, and reactively filters it from the submitted prompt.

The workbook-generated graph and packet are transient. They do not become knowledge authority.

## Runtime stages

1. Normalize the prompt and retrieval budget.
2. Export the parent and admitted child `.kb` outputs.
3. Construct the available context graph.
4. Select matching seeds and close their declared relationships.
5. Materialize source-backed fragments and project the implementation plan, checks, and gates.

## Validation

```bash
bash scripts/validate-context-resolver-hook.sh
```

The hook requires `uv`, `cue`, and `jq`. The bridge uses an inline `marimo` dependency through `uv run --script`.
