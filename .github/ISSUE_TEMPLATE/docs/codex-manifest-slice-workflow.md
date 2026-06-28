# Codex Manifest Slice Workflow

Codex implementation slices start from compact issue bodies. The issue body should contain intent and, when available, a manifest path such as `contracts/issues/<issue-number>/manifest.cue`.

Workflow:

1. Run `gh issue view <number>` to read the compact issue body.
2. Open the manifest path when the body provides one.
3. Treat `contracts/meta/impl` as constructor authority.
4. Expand the manifest into concrete target CUE files with normal patch work.
   Main manifests carry constructor calls and bottom-check plans only.
   Check packages carry executable bottom-check proofs through issue-local adapters that bind concrete targets.
5. Run the manifest's generated validation plan.
6. Return the manifest's completion report sections.

Boundaries:

- CUE manifests and `contracts/meta/impl` define shape authority.
- Observed input, admissible input, lowered objects, proof objects, and materialized surfaces are separate phases.
- Proof constructors must not take Codex-authored top placeholders for targets; check adapters bind targets internally.
- GitHub, shell commands, and runtime tools provide evidence only.
- Generated artifacts, stringified CUE expressions, boolean invalidity flags, and operator-supplied predicate truth are not authority.
- Go wrappers, MCP transport, GitHub Projects mutation, and automatic materializers are deferred to later slices.
