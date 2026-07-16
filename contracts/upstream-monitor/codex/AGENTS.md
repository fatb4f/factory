# Codex monitor compatibility instructions

Load `contracts/upstream-monitor/AGENTS.md` first, resolve exactly one admitted profile, then load the factory-local authority under `contracts/factory/workers/codex/upstream-monitor/` and the selected profile entrypoint.

Every profile may inspect only these upstream evidence channels:

```text
openai/codex@main
openai/codex@latest-alpha-cli
```

Keep the channels distinct from acquisition through publication. Upstream commits, pull requests, releases, files, and docs are evidence only.

A profile may additionally require a current subject-context repository read. That repository informs local-impact analysis but does not become monitor authority.

ChatGPT remains the semantic actuator. It may reduce evidence only through the selected CUE-declared surface catalogue and context. It may not invent new surface classes, purpose assignments, publication targets, mirror destinations, or authority.

Output mutations require the selected profile's publication plan. Missing authority, missing context, missing templates, unresolved publication paths, an invalid input signal, or an ambiguous profile fails closed.
