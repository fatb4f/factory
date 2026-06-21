# Factory Parity Certificate

Issue: `#71`

State: `S5 ParityValidated`

Source:

- Repository: `fatb4f/contract.cuemod`
- Branch: `factory/reflective-transition-factory`
- Commit: `0743121d8806f657ef20e22aadb77da93c735a1f`
- Path: `contracts/factory`

Target:

- Repository: `fatb4f/factory`
- Branch: `main`
- Seed commit: `3f657e745abfbefccfe0fa64537126e95b016560`
- Rebind commit: `46dcd6d60cba949ec8deecb351635f9942430a1a`
- Path: `contracts/factory`

Validation:

```bash
just check
```

Result: pass.

Parity comparison:

```bash
diff -qr normalized(source/contracts/factory) normalized(target/contracts/factory)
```

Normalization replaced both source and target factory module import prefixes
with `FACTORY_MODULE`. The comparison passed with no differences.

This certificate admits source repository detach.
