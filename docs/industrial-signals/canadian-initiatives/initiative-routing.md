# Canadian initiative routing

Factory should not create a graph for every government initiative. Initiative and coordinating surfaces are discovery/routing inputs; admitted state belongs to the domain whose semantics the evidence actually establishes.

## Routing rules

```text
initiative observation
        ↓
what fact does the evidence establish?
        ├─ clean electricity / renewable / grid / electrification demand
        │      → world.canada-clean-energy
        ├─ adaptation / resilience / hazard / infrastructure-readiness obligation
        │      → world.canada-climate-readiness
        ├─ actor action / facility / project / subsidy follow-through
        │      → world.industrial-signals
        ├─ engineering mechanism / technical feasibility
        │      → world.engineering-signals
        ├─ issuer / financing / instrument / market measurement
        │      → world.financial-signals
        └─ conjunction / shared-resource decision
               → world.resource-allocation only after admitted upstream state
```

## Cross-cutting Canadian initiative classes

### Major-project coordinating surfaces

Major Projects Office or equivalent coordinating/index surfaces may be used for discovery and correlation. Preserve the underlying project/program authority whenever available. A coordinating listing does not replace regulator, funder, utility, proponent, procurement, or project records.

### Industrial subsidies and grants

Route program/policy facts to the applicable initiative authority and actor/project accountability state to `world.industrial-signals`.

Preserve:

```text
announcement != award
authorized award != disbursement
disbursement != expenditure
expenditure != milestone
milestone != outcome
```

Financial financing state may separately enter `world.financial-signals` when the evidence establishes a financial fact.

### Workforce programs

Program obligations or funding may be initiative observations. Actor hiring, training, workforce progress, or capacity effects belong in `world.industrial-signals`; later shared workforce capacity/competition belongs in resource-allocation only through admitted cross-domain evidence.

### Critical-mineral finance

Industrial project/capacity trajectory belongs in `world.industrial-signals`; financing measurements/claims belong in `world.financial-signals`; clean-energy policy demand belongs in `world.canada-clean-energy` only where the source establishes that relation.

### Sovereign AI / compute initiatives

Technical mechanisms belong in engineering signals, facility/supply-chain/buildout state in industrial signals, electricity/grid demand in clean-energy when explicitly established, and shared-resource conjunction only in resource-allocation after independent admitted paths exist.

## Acquisition behavior

Current manual/agent-assisted acquisition should follow the authoritative source behind the initiative rather than relying on an umbrella announcement when a more specific record exists.

Projected pipelines should preserve the same rule by treating coordinating/index sources as discovery adapters and source-specific systems as evidence adapters. Cross-source identity and relations remain candidates until admitted by the owning domain.