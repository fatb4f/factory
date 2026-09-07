# Factory documentation

Factory documentation is organized by the repository subject it explains rather than by a global document type.

## Layout

Use project/domain-relative top-level directories under `docs/`:

```text
docs/
  <project-or-domain>/
    README.md
    ... subject-specific documentation
```

A documentation TLD is a navigation and comprehension surface only. It does not become semantic authority. Normative semantics remain in the narrowest owning CUE contract, with colocated `AGENTS.md` files defining execution procedure where applicable.

Cross-project architecture documents may remain under `docs/architecture/` only when they genuinely span independent authorities. Project-specific architecture belongs under that project's documentation TLD.

## Graph-oriented projects

When one documentation TLD coordinates several independent graphs, nest each graph by its authoritative graph ID rather than flattening graph-specific material into the umbrella directory.

Each monitored graph documentation directory should identify at least:

- semantic authority and execution procedure;
- monitored source families and important named source surfaces;
- current acquisition method;
- projected automated acquisition path;
- provenance and identity requirements;
- coverage-gap/fail-closed behavior;
- graph publication/snapshot boundary;
- downstream consumers and authority exclusions.

The acquisition documentation must distinguish current manual/agent-assisted execution from a projected data pipeline. A projected pipeline is not evidence that an adapter or automated acquisition path is implemented.
