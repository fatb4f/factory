# Multi-Graph World Refactor

Status: implementation plan / initial authority scaffold

## Objective

Factory's primary purpose remains engineering-to-industry intelligence: track engineering developments, observe industrial translation and constraints, identify high-leverage mechanisms, and select bounded POCs that test them.

Clean-energy, climate-readiness and financial domains are not replacements for that purpose. They add independent demand, resilience, policy and economic context that can materially change which engineering developments deserve attention.

The target architecture is therefore:

```text
engineering graph
      |
      | translation
      v
industrial graph
      |
      +-------------------------------+
      |                               |
      v                               v
clean-energy graph             climate-readiness graph
      |                               |
      +---------------+---------------+
                      |
                      v
             resource-allocation
      identity / bridges / conjunctions
        shared resources / competing demand
                      |
                      v
               financial graph
                      |
                      v
             financial qualification
                      |
             +--------+--------+
             |                 |
             v                 v
      allocation decision   investment opportunity
             |
             v
      engineering POC selection
```

No domain may manufacture another domain's topology.

## Authority boundaries

```text
contracts/world/engineering-signals/
    engineering mechanisms, maturity, technical observations, future engineering graph

contracts/world/industrial-constraints/
    industrial facilities, capacity, suppliers, infrastructure, constraints

contracts/world/canada-clean-energy/
    Canadian/Quebec clean-energy programs, projects, obligations and future policy/project graph

contracts/world/canada-climate-readiness/
    adaptation, hazards, resilience obligations and future resilience graph

contracts/world/financial-signals/
    issuers, segments, instruments, capital structure, financial relations and measurements

contracts/world/resource-allocation/
    external snapshot references, bridge hypotheses/admission, shared resources,
    resource demand, cross-graph conjunctions, intervention candidates and allocation decisions

contracts/world/financial-opportunities/
    downstream point-in-time investment qualification over admitted allocation + financial state

contracts/projects/engineering-pocs/
    Factory-owned POC hypotheses and decisions; world domains do not decide what Factory builds
```

Do not introduce a generic `graph` or `multigraph` worker/core package yet. The four graph domains are intentionally independent. Promote shared vocabulary only after their demonstrated intersection warrants it.

## Current versus target execution

Initial implementation is deliberately asymmetric.

Enabled observation phases:

```text
world.engineering-signals.monitor
world.industrial-constraints.monitor
world.canada-clean-energy.monitor
world.canada-climate-readiness.monitor
```

These run as bounded event watches. They may publish source-qualified observations and coverage gaps, but may not claim that canonical graph/correlation pipelines already exist.

Present but disabled until prerequisites exist:

```text
world.financial-signals.monitor
world.resource-allocation.correlate
world.financial-opportunities.qualify
projects.engineering-pocs.qualify
```

This prevents the architecture from inventing issuer coverage, graph bridges, allocation decisions or POC qualification before their evidence paths are implemented.

## Core epistemic invariants

```text
domain observation != domain graph fact
hypothesis != admitted edge
graph A node != graph B node without identity evidence
cross-domain correlation != source-domain authority
conjunction != causal claim
financial measurement != timeless relation
financial qualification != allocation decision
industrial scarcity != investment opportunity
shared-resource demand != proof of shortage
poc-candidate disposition != admitted POC
```

All cross-domain paths must remain snapshot-qualified and reproducible.

## Shared-resource optimization target

The system should eventually identify independently admitted demands converging on a shared constrained resource:

```text
renewable deployment -----+
climate adaptation -------+--> shared resource
industrial expansion -----+
AI / strategic demand ----+
```

Candidate interventions then compete on dimensions such as:

```text
resource capacity relieved
number of independent demands relieved
engineering tractability
capital required
time to effect
financial/economic capture
avoided loss
policy leverage
resilience value
strategic value
execution risk
substitution risk
```

Do not freeze these dimensions into a universal scalar in CUE. Scalar ranking is a derived analytical projection whose weights remain explicit model/configuration state.

## Sequenced refactor

### Phase 0 — preserve current authority

- Keep `world.industrial-constraints` current phase at `event-watch`.
- Preserve its future relational pipeline as target semantics only.
- Do not generalize industrial graph types into worker core.

Gate: existing industrial event watch continues to execute independently.

### Phase 1 — engineering signal authority

- Add `world.engineering-signals` as the primary frontier monitor.
- Track mechanisms, papers, patents, prototypes, standards, tests, process innovations and failure analysis.
- Keep `poc-candidate` as a disposition only.
- Model a future engineering graph without requiring it for current observation.

Gate: source-qualified engineering events can be recorded without industrial/POC inference.

### Phase 2 — policy-demand event watches

- Add `world.canada-clean-energy`.
- Add `world.canada-climate-readiness`.
- Treat government initiatives as demand/constraint observations only when they materially affect engineering or industrial capacity.
- Use coordinating surfaces such as major-project registries for discovery while preserving underlying project/program authority.

Gate: initiative observations are independently admissible and do not create industrial shortage or financial claims.

### Phase 3 — financial graph authority

- Add `world.financial-signals` with financial-specific node/relation vocabulary.
- Keep issuer filings, financing, capital structure and market measurements distinct from industrial topology.
- Seed explicit issuer/segment hypotheses before enabling broad recurring acquisition.

Gate: financial relations cannot exist from ticker/name matching alone; measurements remain time-qualified.

### Phase 4 — cross-domain resource coordination

- Add `world.resource-allocation`.
- Introduce immutable external snapshot/node/path references.
- Separate bridge hypotheses from admitted bridges.
- Add shared-resource identity, resource-demand paths and cross-graph conjunctions.
- Require at least two independently admitted demands before a conjunction can represent competing/coincident demand.

Gate: no conjunction can be admitted from labels or prose-only correlation.

### Phase 5 — intervention generation and financial qualification

- Generate candidate mechanisms such as capacity expansion, substitution, utilization improvement, lead-time reduction, repair/remanufacture, demand reduction and risk reduction.
- Join intervention candidates to independently admitted financial state.
- Preserve multidimensional qualification rather than hiding weights in a single score.

Gate: financial evidence qualifies an intervention but does not rewrite source-domain facts.

### Phase 6 — financial opportunities

- Narrow `financial-opportunities` to downstream investment qualification.
- Consume a resource-allocation candidate plus financial graph state.
- Require current valuation, explicit downside/failure scenarios, risk and reproducible evidence before `actionable`.

Gate: missing graph path, issuer mapping, current valuation or downside evidence remains a coverage gap.

### Phase 7 — engineering POC qualification

- Add project-owned `engineering-pocs` authority.
- Require an admitted engineering mechanism/path and an explicit industrial problem.
- Let initiative-demand convergence and resource-allocation leverage raise priority without substituting for technical evidence.
- Require bounded experiment, expected learning and falsifiers before `prototype-ready`.

Gate: world observations never directly instruct Factory to build a POC.

### Phase 8 — graph realization

For each domain independently:

```text
CUE schema
  -> constrained instances
  -> generated types
  -> deterministic relational projection
  -> backend adapter
  -> immutable graph snapshot
```

Do not require each domain to use the same backend. Ibis/DuckDB/BigQuery remain realization mechanisms, not authority.

Gate: each graph can publish immutable snapshot references with mechanically validated provenance.

### Phase 9 — scheduler dependency semantics

Only after the first enabled correlation task exists, extend the generic task contract with explicit dependencies. Then schedule acquisition before correlation/qualification by declared task IDs rather than by task-name inference.

Do not add dependency semantics merely for disabled future tasks.

### Phase 10 — calibration

Evaluate predicted technical relevance, industrial impact, economic capture, POC outcomes and investment outcomes against realized state. Preserve forecast assumptions and snapshot identity so calibration is reproducible.

## Initiative placement

Do not create a new graph for every government initiative.

Initial routing:

```text
Major Projects Office
    discovery/coordinating source across clean-energy, climate, industrial and later allocation

Defence Industrial Strategy
    industrial/engineering demand signal initially; candidate independent graph only if topology matures

Workforce Alliances / workforce programs
    resource-allocation workforce-capacity evidence via source-domain observations

Strategic Response Fund / diversification funds
    industrial capacity + financial financing observations

Critical-mineral finance programs
    industrial project/capacity + financial financing observations

Sovereign AI compute
    engineering/industrial/clean-energy demand signal

Trade corridors
    industrial logistics-capacity signal; later shared resource

Build Communities Strong / infrastructure programs
    climate/clean-energy/industrial demand depending on admitted project purpose
```

The system monitors initiatives because they change engineering relevance and shared-resource demand, not as an end in themselves.

## Implementation state after this refactor

Implemented now:

- independent semantic authorities for engineering, clean-energy, climate-readiness and financial signals;
- resource-allocation boundary types;
- financial-opportunity downstream authority;
- engineering-POC project authority;
- Monday registry entries with observation-ready domains enabled and downstream correlation/qualification tasks disabled;
- contract-validation entries for all new CUE packages.

Still intentionally not implemented:

- canonical graph snapshots for the new domains;
- cross-domain admitted bridges;
- source-specific acquisition adapters beyond current web/event-watch actuation;
- financial issuer/hypothesis universe;
- resource-allocation correlation execution;
- POC or investment qualification execution;
- generic scheduler dependency semantics.

Those remain gated by the sequence above rather than represented as asserted capability.
