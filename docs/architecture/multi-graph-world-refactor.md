# Multi-Graph World Refactor

Status: implementation plan / active authority scaffold

## Objective

Factory remains an engineering-to-industry intelligence system: track engineering developments, observe how industrial actors react and evolve, qualify real industrial constraints, identify high-leverage interventions, and select bounded POCs that test them.

The industrial model is now explicitly two-layered:

```text
engineering signals
        |
        | translation / adoption
        v
industrial signals
        |
        | actor trajectories / actions / outcomes
        v
industrial constraints
        |
        | qualified choke points
        +-----------------------------+
                                      |
clean energy -------------------------+
climate readiness --------------------+--> resource allocation
                                      |
                                      v
                               financial signals
                                      |
                         +------------+------------+
                         |                         |
                         v                         v
                  engineering POCs       financial opportunities
```

`industrial-signals` owns the evolving industrial ecosystem. `industrial-constraints` is downstream qualification over industrial state; it is no longer the semantic container for all industrial behavior.

No domain may manufacture another domain's topology.

## Authority boundaries

```text
contracts/world/engineering-signals/
    engineering mechanisms, maturity, technical observations, future engineering graph

contracts/world/industrial-signals/
    industrial actors, roles, facilities/projects, signals, actions, response hypotheses,
    admitted responses, innovation adoption, public-support flows, milestones and outcomes

contracts/world/industrial-constraints/
    evidence-backed bottleneck, shortage, dependency and choke-point qualification
    over admitted industrial state

contracts/world/canada-clean-energy/
    Canadian/Quebec clean-energy programs, projects and obligations

contracts/world/canada-climate-readiness/
    adaptation, hazards and resilience obligations

contracts/world/financial-signals/
    issuers, segments, instruments, capital structure, financial relations and measurements

contracts/world/resource-allocation/
    external snapshot references, bridge hypotheses/admission, shared resources,
    resource demand, cross-graph conjunctions, intervention candidates and allocation decisions

contracts/world/financial-opportunities/
    downstream point-in-time investment qualification

contracts/projects/engineering-pocs/
    Factory-owned POC hypotheses and decisions
```

Do not introduce a generic `graph` or `multigraph` package yet. Early domains may duplicate structurally similar vocabulary until their real intersection establishes a shared invariant.

## Industrial epistemic invariants

The industrial system must preserve these distinctions mechanically:

```text
observed actor label != canonical actor identity
signal != action
action after signal != admitted response
technology evaluation != adoption
adoption != successful outcome
funding announcement != authorized award
authorized award != disbursement
disbursement != recipient expenditure
recipient-reported expenditure != audited expenditure
expenditure != project milestone
project milestone != industrial outcome
industrial observation != binding constraint
```

A missing downstream record is a coverage gap unless positive evidence establishes another state.

## Subsidized-actor accountability

Public support is part of industrial state, not merely a government-news event.

For every material subsidized actor/project where evidence is obtainable, the industrial signal graph should preserve a trajectory such as:

```text
program / funder
      |
      v
award / authorization
      |
      v
disbursement
      |
      v
recipient expenditure
      |
      +--> capital equipment
      +--> facility construction
      +--> R&D
      +--> workforce
      +--> materials / supplier development
      |
      v
project milestones
      |
      v
commissioning / production / capacity
      |
      v
measured industrial outcome
```

Different sources remain distinct observations. Actor self-report, funder record, procurement evidence, regulatory filing and audited report are not interchangeable evidence classes merely because they describe the same money.

The current event watch may record each stage as a source-qualified observation. It may not infer that unobserved spending failed to occur, nor may it publish a performance judgment from an award announcement alone.

## Actor and trajectory model

Industrial identity is canonical only in the future graph phase. Actor roles are time- and surface-qualified rather than frozen into organization identity.

Relevant roles include manufacturers, suppliers, operators, developers, integrators, customers, contract manufacturers, equipment vendors, technology providers, logistics providers, utilities and research partners.

The graph target models:

```text
actor
  +--> role assignment
  +--> signal
  +--> action
  +--> innovation exposure/adoption state
  +--> funding award / flow
  +--> project milestone
  +--> outcome
```

Response causality is separately admitted:

```text
industrial signal
      |
      +--> ResponseHypothesis
                |
                | actor-explicit / contractual-link / qualified-correlation
                v
          AdmittedResponse
```

Temporal sequence or name similarity is insufficient.

## Constraint boundary

`world.industrial-constraints` retains its current independent `event-watch` for continuity. Its future `relational-pipeline` now explicitly requires a snapshot-qualified `world.industrial-signals` input.

```text
industrial-signals immutable snapshot
        |
        v
industrial-constraints relational input
        |
        v
correlation / constraint evidence
        |
        v
constraint claim
```

A binding constraint still requires multi-record evidence. Industrial actions that appear to address a problem are evidence about response, not proof that the problem exists or has been resolved.

## Current versus target execution

Enabled observation phases:

```text
world.engineering-signals.monitor
world.industrial-signals.monitor
world.industrial-constraints.monitor
world.canada-clean-energy.monitor
world.canada-climate-readiness.monitor
```

These are independent Monday watches because scheduler dependencies are not yet part of the generic task contract.

Current `industrial-signals` publication is limited to source-qualified event-watch records and coverage gaps. Canonical identity, admitted response causality, funding-accountability qualification and immutable industrial graph snapshots remain target semantics.

Present but disabled until prerequisites exist:

```text
world.financial-signals.monitor
world.resource-allocation.correlate
world.financial-opportunities.qualify
projects.engineering-pocs.qualify
```

## Cross-domain invariants

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
industrial expansion -----+
renewable deployment -----+
climate adaptation -------+--> shared resource
AI / strategic demand ----+
```

Candidate interventions can then be qualified across capacity relieved, number of independent demands relieved, engineering tractability, capital required, time to effect, financial/economic capture, avoided loss, policy leverage, resilience value, strategic value, execution risk and substitution risk.

Do not freeze those dimensions into a universal scalar in CUE. Ranking remains an explicit derived analytical projection.

## Sequenced implementation

### Phase 0 — authority split

Implemented:

- independent engineering, industrial-signal, industrial-constraint, policy-demand and financial authorities;
- resource-allocation and downstream decision boundaries;
- registry and validation wiring.

### Phase 1 — engineering event acquisition

Acquire bounded source-qualified engineering mechanisms, tests, prototypes, standards, patents and failure analysis.

Gate: engineering observations do not create industrial adoption or POC admission.

### Phase 2 — industrial actor ecosystem acquisition

Acquire actor-centric industrial updates and build longitudinal event-watch state around:

- actor/facility/project changes;
- demand/capacity/supply/lead-time signals;
- actor actions and industrial responses;
- innovation evaluation, qualification, deployment and scaling;
- public funding awards, disbursements and evidenced expenditure;
- project milestones and realized outcomes.

Gate: actor labels remain source-qualified observations until canonical identity is executable.

### Phase 3 — policy-demand watches

Continue clean-energy and climate-readiness watches as independent demand/obligation authorities.

Gate: initiative observations do not create industrial shortages or financial claims.

### Phase 4 — industrial graph realization

```text
CUE schema
  -> constrained instances
  -> generated types
  -> deterministic relational projection
  -> backend adapter
  -> immutable industrial snapshot
```

Gate: response causality, funding-accountability coverage and actor identity are admitted only through their contracted evidence paths.

### Phase 5 — industrial constraint qualification

Consume a snapshot-qualified industrial-signals input and qualify bottlenecks/choke points.

Gate: no relational constraint run without an admitted industrial snapshot; no binding claim from a single observation.

### Phase 6 — financial graph authority

Build the issuer/segment/instrument universe and time-qualified financial state independently from industrial topology.

### Phase 7 — cross-domain resource coordination

Admit explicit bridges and shared-resource conjunctions only when at least two independent demand paths exist.

### Phase 8 — intervention, financial and POC qualification

Generate candidate interventions from admitted engineering and industrial paths. Financial value or government convergence may raise priority but cannot manufacture the technical rationale.

### Phase 9 — scheduler dependency semantics

Only when correlation/qualification tasks become executable, add typed task dependencies. Do not infer ordering from names.

### Phase 10 — calibration

Compare predicted technical relevance, actor responses, subsidy/project trajectories, industrial outcomes, constraint evolution, economic capture, POC results and investment results against realized state.

## Initiative placement

Do not create a graph for every government initiative. Route observations into the domain whose semantics they actually establish.

Examples:

```text
industrial subsidy / grant
    clean-energy or policy source observation when applicable
    + industrial-signals award/disbursement/spend/milestone trajectory
    + financial-signals financing state when economically relevant

Major Projects Office
    coordinating/discovery source; underlying project authority remains source-specific

Workforce programs
    industrial-signals actor/workforce progress
    + later resource-allocation workforce-capacity evidence

Critical-mineral finance
    industrial project/capacity trajectory
    + financial financing observation

Sovereign AI compute
    engineering + industrial + clean-energy demand observations
```

The monitor's value is not collecting more announcements. It is preserving enough longitudinal evidence to answer: **who acted, why, with what resources, what changed, what failed to change, and what remains constrained?**
