---
name: dotfiles-code-intel
description: Local generated code-intelligence bundle for dotfiles Lua, CUE, MCP declarations, and WezTerm/Neovim type overlays.
---

# Dotfiles Code Intel

This plugin is a generated, read-only code-intelligence bundle for dotfiles work. It provides local evidence surfaces for Lua-first editing, CUE contracts, MCP provider declarations, and type overlays.

## Contract boundary

- Treat every file under this plugin as generated evidence unless a CUE contract inside `contracts/code-intel/` says otherwise.
- Do not treat MCP output, LSP diagnostics, generated type stubs, or generated workflow JSON as source authority.
- Do not import or depend on the agent-context-resolver bundle.
- Do not reach outside the materialized plugin root for bundle-local authority.

## Lua-first workflow

1. Load `generated/workflows/lua-first/workflow.json`.
2. Resolve entrypoints from `generated/workflows/lua-first/entrypoints.json`.
3. Route Lua files with `generated/lsp/provider-routing.json`.
4. Attach overlays from `generated/types/nvim/vim.lua` and `generated/types/wezterm/*.lua` as read-only libraries.
5. Project diagnostics with `generated/workflows/lua-first/diagnostic-map.json`.
6. Use diagnostics as evidence only; patch authority stays with the target repository source.

## CUE workflow

Use `generated/lsp/cue-lsp.json` for editor/server configuration and `contracts/code-intel/manifest.cue` for local bundle boundary checks.

## Validation

```sh
cue vet ./contracts/plugin-bundle/code-intel/src
cue vet ./contracts/plugin-bundle/code-intel/src/contracts/code-intel
cue vet ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks
cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e normalizedMaterializedBundleShapeManifest
cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e materializedBundleShapeValidationPlan
cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e materializedBundleShapeCompletionReportContract
cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e codeIntelLuaFirstWorkflow
cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e codeIntelBoundaryReport
cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel -e codeIntelImplementationRecommendations
cue vet ./contracts/plugin-bundle/generated/code-intel/contracts/code-intel
cue export ./contracts/plugin-bundle/generated/code-intel/contracts/code-intel -e codeIntelRuntimeEvidenceManifest
cue export ./contracts/plugin-bundle/generated/code-intel/contracts/code-intel -e codeIntelRuntimeEvidenceValidationPlan
cue export ./contracts/plugin-bundle/generated/code-intel/contracts/code-intel -e codeIntelRuntimeEvidenceCompletionReport
cue vet contracts/plugin-bundle/code-intel/src/contracts/code-intel/manifest.cue contracts/plugin-bundle/code-intel/src/contracts/code-intel/generated/workflows/lua-first/workflow.json -d '#CodeIntelLuaFirstWorkflow'
jq -e '.providers[] | select(.id == "wezterm-types") | .paths | index("generated/types/wezterm/wezterm.lua") and index("generated/types/wezterm/events.lua") and index("generated/types/wezterm/config-builder.lua")' contracts/plugin-bundle/code-intel/src/contracts/code-intel/generated/workflows/lua-first/workflow.json
cue vet ./contracts/plugin-bundle/code-intel/instances/dotfiles
! cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.generatedAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.mcpOutputAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.lspDiagnosticsAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.weztermTypesAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.luaWorkflowGeneratedAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/src/contracts/code-intel/checks -e _negativeBottomChecks.resolverContractsLeak
! cue export ./contracts/plugin-bundle/code-intel/instances/dotfiles -e _negativeBottomChecks.generatedAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/instances/dotfiles -e _negativeBottomChecks.mcpOutputAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/instances/dotfiles -e _negativeBottomChecks.lspDiagnosticsAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/instances/dotfiles -e _negativeBottomChecks.weztermTypesAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/instances/dotfiles -e _negativeBottomChecks.luaWorkflowGeneratedAsAuthority
! cue export ./contracts/plugin-bundle/code-intel/instances/dotfiles -e _negativeBottomChecks.resolverContractsLeak
```
