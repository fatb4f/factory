# AGENTS.md

## Scope

This directory owns the Codex context-resolver profile.

Keep all profile-specific implementation under:

```text
marimo/profiles/context-resolver/
```

The only permitted Python implementation is the Marimo workbook:

```text
context_resolver.py
```

Do not add standalone Python runtimes, adapters, generators, test modules, or hook scripts.

## Architecture

```text
nested .kb declarations
  → CUE/Apercue graph validation
  → exported graph projections
  → Pydantic transport validation
  → Marimo reactive filtering
  → bounded Codex context packet
```

Responsibilities:

* `.kb` owns declarations, source authority, graph structure, checks, and gates.
* Apercue owns graph validation, ancestry, dependents, and topology.
* Pydantic owns strict runtime envelope and projection contracts.
* Marimo owns prompt normalization, reactive selection, budgets, source materialization, packet projection, and embedded validation orchestration.
* Hypothesis owns generated behavioral checks executed only through workbook validation mode.
* `.codex/hooks.json` only invokes the workbook and transports its result.

## Invariants

* Validate every `.kb` boundary before consuming it.
* Apply the boundary allowlist before exporting child boundaries.
* Never reconstruct Apercue graph computations in Python.
* Every returned fragment must reference an admitted `.kb` declaration and repository-bounded source.
* Validate the final serialized packet against its Pydantic contract before transport.
* Generated packets are transient projections, never authority.
* Use Apercue-safe graph identifiers.
* Keep context and workflow graphs distinct.
* Do not treat operational `.kb` fragments as quicue-kg decisions, insights, patterns, or rejected records.
* Keep deterministic scenarios and Hypothesis properties inside the Marimo workbook.

## Changes

When modifying the profile:

1. Update CUE declarations and projections first.
2. Update the corresponding Pydantic wire models.
3. Keep filtering logic inside reactive Marimo cells.
4. Add or update an embedded validation case for every behavior change.
5. Preserve the `app.run(defs={"workbook_request": ...})` execution path.
6. Preserve the direct `UserPromptSubmit` workbook bridge.
7. Avoid repository-root files unless required for Codex lifecycle registration.

## Validation

Run:

```bash
cue vet ./marimo/profiles/context-resolver/.kb
cue export ./marimo/profiles/context-resolver/.kb -e output --out json

python -m py_compile \
  marimo/profiles/context-resolver/context_resolver.py

uv run --script \
  marimo/profiles/context-resolver/context_resolver.py \
  --validate \
  --repo-root "$PWD"

printf '%s\n' \
  '{"hook_event_name":"UserPromptSubmit","prompt":"inspect context resolver"}' |
  uv run --script \
    marimo/profiles/context-resolver/context_resolver.py \
    --codex-hook \
    --repo-root "$PWD"
```

A change is admitted only when:

* all boundary graphs are valid;
* all Pydantic contracts validate;
* all deterministic and Hypothesis validation cases pass;
* selected sources remain inside the repository;
* node and token budgets are enforced against the final packet;
* the context packet is admitted;
* no Python implementation exists outside Marimo workbooks.
