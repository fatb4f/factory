# Upstream monitor compatibility ingress

This tree is the scheduled ChatGPT actuator and publication surface. It is not an independent semantic authority.

Before acting:

1. read `contracts/factory/workers/codex/upstream-monitor/AGENTS.md`;
2. resolve exactly one profile from the request entrypoint and accepted signal;
3. load the shared CUE worker files and every CUE file declared by that profile;
4. load only the selected profile's compatibility entrypoint and report template.

## Admitted profiles

```text
factory:
  contracts/upstream-monitor/codex/contract-surface/AGENTS.md

cuestrap:
  contracts/upstream-monitor/codex/cuestrap-contract-surface/AGENTS.md
```

Do not combine profile surface catalogues, context reads, prior evidence, templates, publication plans, or output paths.

## Control doctrine

The monitor is a closed feedback loop executed by ChatGPT through the GitHub App.

```text
instruction → admitted context/acquisition → separate channel evidence
→ selected-profile semantic classification → fixed report rendering
→ publication admission → bounded GitHub mutation → terminal state
```

Factory-local CUE and AGENTS files control the loop. Upstream repositories, subject-context repositories, adapter responses, and generated outputs are evidence only.

Preserve signal, profile, and run IDs across transitions. Do not infer scope from repository layout. Write only to paths declared by the selected profile's publication plan. Do not update an issue unless its exact target is declared there. Cross-repository writes are forbidden unless the selected plan declares the repository, branch, artifact kind, path, and content policy.
