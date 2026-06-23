# Codex Manifest Slice Workflow

Codex implementation slices start from compact issue bodies. The issue body should contain intent and, when available, a manifest path such as `contracts/issues/<issue-number>/manifest.cue`.

Workflow:

1. Run `gh issue view <number>` to read the compact issue body.
2. Open the manifest path when the body provides one.
3. Treat `contracts/meta/impl` as constructor authority.
4. Expand the manifest into concrete target CUE files with normal patch work.
5. Run the manifest's generated validation plan.
6. Return the manifest's completion report sections.

Boundaries:

- CUE manifests and `contracts/meta/impl` define shape authority.
- GitHub, shell commands, and runtime tools provide evidence only.
- Go wrappers, MCP transport, GitHub Projects mutation, and automatic materializers are deferred to later slices.
