# UQAM event run bundles

Each invocation may persist an immutable directory:

```text
runs/<run-id>/
  manifest.json
  normalized.json
  decision.json
```

`normalized.json` contains the source-qualified normalized event set used for comparison. `manifest.json` records run identity, schema, acquisition coverage, and the normalized-set digest. `decision.json` records comparison state, delta, outcome, and baseline action.

Run bundles are evidence/state inputs. They do not become institutional facts merely because an upstream page or organizer emitted them. The mutable admitted baseline pointer lives under `../state/admitted-baseline.json`.
