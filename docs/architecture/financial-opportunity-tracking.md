# Financial Opportunity Tracking Substrate

Status: proposed architecture

Snapshot date: 2026-09-02

Proposed semantic authority: `contracts/world/financial-opportunities/`

This document proposes a dedicated financial-opportunity **projection** substrate. It does **not** extend the semantic authority of `world.industrial-constraints`, and it must not construct a second relationship graph beside the one already modeled under `contracts/world/industrial-constraints/`.

The industrial domain owns industrial entities, relations, constraint claims, and their provenance. The financial domain consumes an admitted graph snapshot/path and overlays issuer, instrument, market, valuation, scenario, and risk observations. Financial conclusions remain derived claims subject to their own admission rules.

The September 2 opportunity register below is observation-derived speculative analysis. Scenario returns are model outputs from explicit assumptions, not admitted facts, price targets, or investment recommendations.

## 1. Authority boundary

`world.industrial-constraints` owns admitted industrial constraint intelligence and the relationship topology used to reach it. Its existing `#Relation` records and controlled predicates such as `supplies`, `consumes`, `requires`, `depends-on`, `funded-by`, `procured-by`, and `projects-to` remain the semantic source of industrial connectivity.

The financial domain does not restate those relations. It consumes graph-qualified records through declared projections and combines them with independently acquired issuer and market observations.

```text
world.industrial-constraints
    admitted entities
    admitted relations
    constraint claims
    capacity / scarcity
    funding / procurement
    institutional response
              |
              | admitted graph snapshot
              | + declared path projection
              v
world.financial-opportunities
    graph-path reference
    issuer / instrument mapping
    financial observations
    economic-capture projection
    valuation
    scenarios
    risk
    catalysts
    expected-return distribution
    opportunity decision
              |
              v
    admitted opportunity snapshots
```

Preserve the invariant:

```text
industrial observation
        !=
industrial claim
        !=
relationship path
        !=
economic capture
        !=
investable exposure
        !=
investment thesis
        !=
attractive valuation
        !=
admitted opportunity
```

Industrial evidence and topology may support a financial thesis. They cannot establish one by implication.

### 1.1 No duplicate financial graph

Do not introduce finance-owned equivalents of:

```text
#Entity
#Relation
#Predicate
industrial dependency topology
industrial supplier topology
industrial project topology
```

The base graph already answers the structural question:

```text
what is related to what, by which admitted relation, under which provenance?
```

The financial substrate answers a different question:

```text
given an admitted relationship path,
what investable instrument maps to its economic terminal,
what financial observations support capture,
and what return/risk distribution follows at the current valuation?
```

If a required industrial relationship is missing, that is a base-graph coverage gap. Finance must not repair the gap by inventing a private relation.

## 2. Proposed repository shape

```text
contracts/world/financial-opportunities/
    contract.cue
    observations.cue
    projection.cue
    mappings.cue
    thesis.cue
    valuation.cue
    scenarios.cue
    risk.cue
    decision.cue
    public.cue

world/financial-opportunities/
    .agents/AGENTS.md
    queries/
    projections/
    runs/
    state/
```

`projection.cue` defines references to admitted industrial graph state and financial derivations over those references. It does not define a parallel relation vocabulary.

`mappings.cue` owns only the boundary that the industrial graph should not own: mapping an industrial entity to a legal issuer and then to an investable security or other instrument.

The implementation objective remains:

```text
CUE authority
    |
    v
generated Python types
    |
    v
Ibis relational projection
    |
    v
DuckDB / BigQuery execution
    |
    v
thin acquisition / market-data adapters
```

Ibis, DuckDB, BigQuery, pricing APIs, filings providers, analysts, and model outputs remain realization or evidence providers. They do not become semantic authority.

## 3. Base-graph projection and opportunity identity

An opportunity is identified by an investable instrument plus the admitted industrial graph path that motivates evaluating it. A company name or industrial event alone is insufficient.

```cue
#OpportunityIdentity: close({
    opportunityID: string

    graphProjection: #IndustrialGraphProjectionRef
    instrument:      #InstrumentRef

    strategy:        #StrategyClass
    thesisMechanism: #ThesisMechanism
})
```

The financial domain should reference rather than reproduce graph topology:

```cue
#IndustrialGraphProjectionRef: close({
    domain: "world.industrial-constraints"

    // Immutable identity of the admitted industrial state used by this run.
    snapshot: #ExternalSnapshotRef

    // Ordered references to admitted relation/claim records traversed by the
    // projection. The referenced records remain owned by the industrial domain.
    path: [...#ExternalRecordRef] & [_, ...]

    terminalEntity: #ExternalEntityRef
})
```

The industrial terminal can then be mapped across the domain boundary:

```cue
#InstrumentMapping: close({
    industrialEntity: #ExternalEntityRef
    issuer:            #IssuerRef
    instrument:        #InstrumentRef

    provenance: [...#EvidenceRef] & [_, ...]
})
```

The financial exposure state is an **overlay on the graph projection**, not a replacement for it:

```cue
#FinancialExposureProjection: close({
    graphProjection: #IndustrialGraphProjectionRef
    mapping:         #InstrumentMapping

    captureMechanism:
        "revenue-growth" |
        "margin-expansion" |
        "capacity-utilization" |
        "pricing-power" |
        "asset-revaluation" |
        "cost-reduction" |
        "subsidy" |
        "contract-award" |
        "financing-spread" |
        "scarcity-rent"

    revenueExposurePct?:  >=0 & <=100
    earningsExposurePct?: >=0 & <=100
    assetExposurePct?:    >=0 & <=100

    financialEvidence: [...#EvidenceRef]
    assumptions:       [...#AssumptionRef]
})
```

Do not author a second `directness` or adjacency relation as semantic truth. Views such as `direct`, `adjacent`, `second-order`, or `plumbing` are query projections over the referenced path and its predicates. They may be useful labels, but they are not a new topology.

### 3.1 Relationship-centric discovery

Candidate discovery should begin from admitted graph state rather than ticker universes:

```text
admitted constraint / state change
        |
        v
traverse declared relationships
        |
        +-- requires
        +-- depends-on
        +-- supplies
        +-- consumes
        +-- funded-by
        +-- procured-by
        +-- projects-to
        |
        v
candidate terminal entities
        |
        v
issuer / instrument mapping
        |
        v
financial observation join
        |
        v
opportunity qualification
```

This naturally captures direct, indirect, adjacent, and plumbing exposure without giving those categories independent authority.

For example:

```text
data-center load growth
    -> requires -> grid expansion
    -> depends-on -> substations
    -> requires -> switchgear
    -> supplied-by relationship represented in base graph
    -> terminal organization
            |
            | financial mapping
            v
         issuer
            |
            v
        instrument
```

Every industrial hop must resolve to an admitted base-graph record. The issuer/security boundary is a financial mapping, not an industrial relationship.

### 3.2 Derived relationship metrics

The projection layer may deterministically derive useful financial search features from base topology:

```text
path length
path predicate composition
number of independent paths to a terminal
number of distinct constraint nodes reaching a terminal
source / evidence diversity across a path
substitutability observations
capacity / backlog observations attached to terminal nodes
path persistence across graph snapshots
```

These support derived views such as:

```text
exposure purity
path convergence
plumbing depth
constraint centrality
capture confidence
substitution risk
```

None is a replacement for the underlying relation records.

A particularly useful derived condition is **path convergence**:

```text
data centers -----------+
reshoring --------------+
electrification --------+--> grid expansion --> terminal supplier
reliability investment -+
```

Multiple independently supported industrial paths converging on the same terminal may strengthen the economic-capture hypothesis. The convergence score remains a projection; the individual paths and their provenance remain canonical.

### 3.3 Economic capture and constraint rent

`constraint rent` is a financial analytical projection, not a new graph edge.

A useful model is:

```text
admitted demand / constraint path
        +
issuer operating observations
        +
scarcity / substitution observations
        |
        v
modeled economic capture
```

For example:

```text
ConstraintRent
    ~= DemandShock
       * Exposure
       * Scarcity
       * CaptureAbility
       * Persistence

EconomicValueSignal
    ~= ConstraintRent
       * PathConfidence
       * ContractVisibility
       / (Substitutability * ExecutionRisk * CapitalIntensity)
```

These are analytical functions over admitted graph state plus financial observations. Their coefficients, weights, and outputs are assumptions/model state unless separately calibrated and admitted.

The final investment question remains valuation-dependent:

```text
Opportunity
    = f(
        graph projection,
        economic capture,
        instrument mapping,
        current valuation,
        scenario distribution,
        risk
      )
```

A strong industrial path may therefore terminate in `valuation_constrained`, `uninvestable`, or `coverage_gap` rather than an actionable opportunity.

## 4. ROI semantics

Canonical ROI state should preserve a scenario distribution rather than collapse to one target price.

```cue
#Scenario: close({
    id:           string
    state:        "failure" | "bear" | "base" | "bull"
    horizonYears: >0

    probability?: >=0 & <=1

    entryValue:    number
    terminalValue: number
    distributions: >=0

    totalReturn:      number
    annualizedReturn: number

    assumptions: [...#AssumptionRef]
    evidence:    [...#EvidenceRef]
})
```

For scenario `i`:

```text
R_i = (V_terminal,i + distributions_i - V_entry) / V_entry
CAGR_i = (1 + R_i)^(1/T) - 1
```

Only after probability calibration is justified should the system derive:

```text
E[R] = sum(p_i * R_i)
```

Initial scenario probabilities should therefore remain optional. An uncalibrated subjective probability must not become authoritative merely because a model emitted it.

Useful projections include:

- failure return;
- bear/base/bull return;
- probability of positive return, once calibrated;
- probability of permanent capital impairment;
- expected return and expected CAGR, once calibrated;
- expected excess return against a hurdle rate;
- upside/downside asymmetry;
- time to catalyst.

A ranking score may be generated as a UI/query projection, but the underlying dimensions remain canonical.

## 5. Risk profile

Risk remains multidimensional. A scalar `riskScore` may be projected for convenience but must not replace the underlying state.

```cue
#RiskProfile: close({
    thesis:        #RiskLevel
    valuation:     #RiskLevel
    execution:     #RiskLevel
    timing:        #RiskLevel
    liquidity:     #RiskLevel
    financing:     #RiskLevel
    dilution:      #RiskLevel
    technology:    #RiskLevel
    regulatory:    #RiskLevel
    policy:        #RiskLevel
    commodity?:    #RiskLevel
    currency?:     #RiskLevel
    counterparty:  #RiskLevel
    concentration: #RiskLevel

    permanentLoss: #ProbabilityBand
    evidence:      [...#EvidenceRef]
})
```

This preserves the distinction between, for example, a highly valued profitable infrastructure supplier and an early-stage mine requiring financing and dilution.

Graph-related risk should be derived from the referenced industrial path where possible. For example, substitution risk should consume admitted `substitutable-by` relationships rather than be recreated from prose in the financial profile.

## 6. Thesis, catalysts, and invalidators

Every qualified thesis should define both realization paths and failure conditions.

```cue
#Thesis: close({
    proposition: string

    graphProjection: #IndustrialGraphProjectionRef

    catalysts:    [...#Catalyst]
    invalidators: [...#Invalidator] & [_, ...]

    evidence: [...#EvidenceRef] & [_, ...]
})
```

A monitoring loop must be able to invalidate its own thesis rather than accumulate only confirming observations.

Graph changes are first-class invalidators. If an admitted dependency disappears, a substitute becomes available, capacity expands enough to relieve a bottleneck, or a project path is cancelled, the financial thesis must be re-evaluated even if market observations have not changed.

## 7. Valuation snapshots

Industrial strength and investment attractiveness are separate axes. A valid opportunity decision therefore requires point-in-time valuation state.

```cue
#ValuationSnapshot: close({
    instrument: #InstrumentRef

    observedAt: #Timestamp
    price:      number
    currency:   string

    marketCap?:       number
    enterpriseValue?: number

    trailing: {...}
    forward:  {...}

    assumptions: [...#AssumptionRef]
    provenance:  [...#EvidenceRef]
})
```

Historical opportunity snapshots are immutable. A graph path and thesis can remain valid while a security moves from attractive to unattractive because price changes.

```text
industrial graph path unchanged
          +
price rises materially
          |
          v
expected return contracts
          |
          v
qualified -> watch / overvalued
```

Likewise, an unchanged path plus a material price decline can increase prospective return and trigger requalification.

## 8. Admission lifecycle

```text
observed
   |
   v
candidate
   |
   v
qualified
   |
   v
watch
   |
   v
actionable
   |
   v
realized
```

Terminal or exceptional states:

```text
rejected
invalidated
expired
uninvestable
coverage_gap
```

`actionable` should fail closed unless the run contains at least:

- an immutable admitted industrial graph snapshot reference;
- at least one declared graph path reaching the economic terminal;
- a resolved issuer/instrument mapping;
- a current valuation observation;
- an explicit failure/downside scenario;
- scenario assumptions and evidence;
- a financial exposure/capture projection;
- a risk assessment;
- a declared catalyst or structural return mechanism;
- sufficient provenance to reproduce the decision;
- no material unresolved base-graph or financial coverage gap affecting the return thesis.

A missing relationship path is not satisfiable by a model assertion. It remains a coverage gap until the base graph admits the missing relation.

## 9. Calibration

Each admitted snapshot should eventually be evaluated against realized outcomes.

```text
t0
industrial graph snapshot
projected path set
price
scenario distribution
probabilities
thesis
risk
evidence
        |
        v
t1 / t2 / t3
realized graph + market observations
        |
        v
forecast evaluation
```

Calibration metrics may include:

```text
probability calibration
Brier score
forecast error
realized CAGR
maximum drawdown
benchmark-relative return
time-to-catalyst error
thesis invalidation accuracy
path-persistence accuracy
capture-model error
```

This allows the substrate to learn whether particular graph motifs, evidence classes, capture mechanisms, or opportunity profiles are systematically over- or under-estimated.

---

# 10. Current speculative opportunity register

Snapshot: 2026-09-02.

The profiles below are candidate observations for future qualification. They are not admitted financial decisions. Market observations must be re-acquired before any later evaluation.

The industrial relationships motivating each candidate should be represented by references to admitted base-graph paths. The prose below describes the financial overlay and does not create new relationship authority.

## 10.1 Vertiv — AI power, cooling, switchgear, and microgrid infrastructure

Instrument: NYSE `VRT`

Profile: `structural-growth` / `constraint-beneficiary`

Horizon: 2-4 years

Exposure purity: very high

Industrial signal: very high

Primary risk: valuation compression

Observed evidence:

- Q2 2026 net sales were $3.274B, up 24% year over year; adjusted operating profit increased 51% and adjusted diluted EPS increased 60%.
- Full-year 2026 guidance was raised to $13.8B-$14.2B revenue, $6.65-$6.75 adjusted diluted EPS, and $2.4B-$2.6B adjusted free cash flow.
- On 2026-09-02 Vertiv announced an agreement to acquire UtilityInnovation Group for approximately $1.45B cash plus up to $1.15B contingent consideration, adding microgrid controls, specialized switchgear, onsite generation orchestration, and behind-the-meter architecture.
- The latest available September 1 close was approximately $255.97, with market capitalization about $98.55B and forward P/E about 32.75x.

Illustrative three-year model using $6.70 FY2026 adjusted-EPS guidance midpoint as the initial earnings base:

| Scenario | EPS CAGR | Terminal P/E | Approx. total return |
| --- | ---: | ---: | ---: |
| failure | -5% | 18x | -60% |
| bear | +10% | 24x | -16% |
| base | +20% | 30x | +36% |
| bull | +30% | 36x | +107% |

Projected risk profile, 1 low to 5 extreme:

```text
thesis        2
execution     2
financing     1
valuation     5
concentration 4
permanent-loss band: moderate
```

Candidate state: `qualified/watch`.

Interpretation: exceptionally strong operating and industrial evidence, but prospective return is highly sensitive to sustained earnings growth and terminal multiple. Signal strength alone does not establish an attractive entry valuation.

## 10.2 Eaton — diversified electrical infrastructure beneficiary

Instrument: NYSE `ETN`

Profile: `structural-growth` / `electrification` / `constraint-beneficiary`

Horizon: 3-5 years

Exposure purity: high but diversified

Industrial signal: very high

Primary risk: valuation plus broad industrial-cycle exposure

Observed evidence:

- Q2 2026 sales increased 21%, with 14% organic growth.
- Electrical Americas twelve-month rolling orders increased 41%; Electrical Global orders increased 33%.
- Total Electrical backlog increased 43% year over year.
- Full-year adjusted EPS guidance was $13.40-$13.60 and organic growth guidance 11%-13%.
- Management explicitly identified data centers as a key growth driver.
- September 2 price was approximately $390.85.

Illustrative three-year model using $13.50 FY2026 adjusted-EPS guidance midpoint:

| Scenario | EPS CAGR | Terminal P/E | Approx. total return* |
| --- | ---: | ---: | ---: |
| failure | 0% | 18x | -38% |
| bear | +6% | 21x | -14% |
| base | +12% | 25x | +21% |
| bull | +18% | 29x | +65% |

`*` Dividends excluded.

Projected risk profile:

```text
thesis        2
execution     2
financing     2
valuation     4
concentration 2
permanent-loss band: low-to-moderate
```

Candidate state: `qualified/watch`.

Interpretation: lower exposure purity than Vertiv but substantially more diversified. It is a plausible higher-resilience expression of the same grid/data-center constraint complex.

## 10.3 Soitec — AI photonics / Photonics-SOI capacity

Instrument: Euronext Paris `SOI`

Profile: `structural-growth` / `semiconductor-turnaround`

Horizon: 2-4 years

Exposure purity: very high

Industrial signal: very high

Primary risks: valuation, cyclicality, execution, concentration

Observed evidence:

- Q1 FY2027 revenue reached EUR113M, up 23% year over year at constant currency and scope.
- Photonics-SOI sales doubled year over year and Q2 revenue was expected to grow more than 30% year over year.
- Soitec qualified its Singapore 300mm SOI fab for high-volume Photonics-SOI manufacturing.
- Reuters reported multi-year supply agreements with deposits, fixed pricing and minimum volumes, an estimated roughly 95% Photonics-SOI share, and expected Photonics-SOI revenue above $200M this financial year versus above $100M previously.
- September 2 price was EUR112.00, market capitalization approximately EUR4.00B, versus trailing revenue of approximately EUR592M.

Illustrative three-year sales-multiple model:

| Scenario | Revenue CAGR | Terminal P/S | Approx. total return |
| --- | ---: | ---: | ---: |
| failure | 0% | 2x | -70% |
| bear | +8% | 3x | -44% |
| base | +20% | 5x | +28% |
| bull | +30% | 6.5x | +112% |

Projected risk profile:

```text
thesis       2
technology   3
execution    4
cyclicality  5
valuation    5
permanent-loss band: moderate-to-high
```

Candidate state: `qualified/watch`.

Interpretation: unusually direct AI optical-interconnect evidence with contract-backed demand, but the equity has already repriced sharply and remains sensitive to semiconductor-cycle and multiple-compression risk.

## 10.4 First Phosphate — Quebec phosphate/LFP development

Instrument: CSE `PHOS`

Profile: `policy-supported` / `critical-mineral` / `speculative-development`

Horizon: 3-7+ years

Exposure purity: extremely high

Industrial signal: high

Primary risks: financing, dilution, development execution, permitting, commodity economics

Observed evidence:

- On 2026-08-05 Canada announced nearly $5M through the First and Last Mile Fund for road and electrical transmission infrastructure supporting First Phosphate's Begin-Lamarche project.
- The company reported $4.84M of non-repayable contributions, in addition to $16.7M of earlier federal support.
- The 2024 PEA reported after-tax NPV8 of C$1.59B, after-tax IRR of 33%, initial capex of C$675M, and a 23-year mine life. The PEA used indicated and inferred mineral resources.
- September 2 market capitalization was approximately C$426.25M at C$2.27/share.

The PEA economics are project observations, not current equity value. Project capex exceeds current market capitalization, so construction finance and dilution are first-order unknowns.

Illustrative gross equity-value scenarios, before modeling future dilution:

| Scenario | Illustrative equity value | Change vs. C$426M snapshot |
| --- | ---: | ---: |
| failure/stall | C$80M-C$150M | -81% to -65% |
| bear | C$250M-C$450M | -41% to +6% |
| base derisking | C$650M-C$900M | +53% to +111% |
| bull / financed development | C$1.1B-C$1.5B | +158% to +252% |

These are not valid per-share return estimates while financing structure and dilution remain unresolved.

Required coverage gaps:

```text
financing_structure
dilution
construction_finance
definitive_feasibility_economics
permitting_path
```

Projected risk profile:

```text
thesis      3
execution   5
financing   5
dilution    5
permitting  4
commodity   4
liquidity   4
permanent-loss band: very-high
```

Candidate state: `candidate/qualified-speculative`; fail closed from `actionable`.

## 10.5 IBM / C2MI advanced packaging

Profile: industrial signal with unresolved investable exposure.

The IBM/C2MI Bromont advanced-packaging expansion is a strong industrial event, but IBM common equity provides highly diluted exposure to the project economics.

The appropriate financial state is therefore:

```text
admitted industrial path
    |
    v
terminal industrial entities
    |
    v
issuer / instrument mapping
    |
    v
financial exposure qualification
```

The financial substrate should traverse the existing equipment, materials, supplier, capacity, and local-beneficiary relationships in the base graph and then evaluate mapped instruments. It should not recreate those relationships inside the financial domain. IBM itself should not be promoted merely because it participates in the project.

## 10.6 Comparative speculative profile

| Opportunity | Signal | Exposure purity | Upside convexity | Permanent-loss risk | Valuation risk | Candidate state |
| --- | --- | --- | --- | --- | --- | --- |
| Vertiv | very high | very high | medium-high | medium | very high | watch |
| Eaton | very high | high | medium | low-medium | high | watch |
| Soitec | very high | very high | high | medium-high | very high | watch |
| First Phosphate | high | extreme | very high | very high | project-stage | speculative candidate |
| IBM/C2MI | high | low/unresolved | unresolved | unresolved | unresolved | exposure gap |

The current ordering is not `strongest signal -> best investment`.

A more useful projection is:

```text
best operating evidence          Vertiv / Eaton
best concentrated AI exposure    Soitec / Vertiv
best downside resilience         Eaton
greatest convexity               First Phosphate
greatest permanent-loss risk     First Phosphate
largest valuation constraint     Vertiv / Soitec
weakest instrument mapping       IBM / C2MI
```

No current candidate clearly combines high-confidence industrial evidence, low valuation risk, high exposure purity, high upside, and low permanent-loss risk.

## 10.7 Relationship-centric expansion candidates

The next candidate set should be discovered by graph traversal, not by adding a hand-maintained stock list.

Useful traversal families include:

```text
transformer constraints
    -> electrical steel
    -> copper / windings
    -> testing
    -> transport / installation

cleanroom expansion
    -> filtration
    -> specialty gases
    -> process chemicals
    -> ultrapure water
    -> HVAC
    -> certification / maintenance

advanced packaging
    -> substrates
    -> bonding
    -> metrology
    -> plating chemistry
    -> packaging equipment

grid congestion
    -> substations
    -> transformers
    -> switchgear
    -> conductors
    -> engineering
    -> storage

data-center cooling
    -> chillers / CDUs
    -> pumps
    -> heat exchangers
    -> piping / valves
    -> water treatment
```

These lines are query intents. Actual propagation is valid only where the base graph contains the corresponding admitted relationships.

---

# 11. Initial implementation milestone

Implement only the smallest closed path first:

```text
AdmittedIndustrialGraphSnapshot
        |
        v
IndustrialGraphProjectionRef
        |
        v
InstrumentMapping
        |
        v
FinancialExposureProjection
        |
        v
ValuationSnapshot
        |
        v
ScenarioSet
        |
        v
RiskProfile
        |
        v
OpportunityDecision
        |
        v
immutable snapshot
```

The first implementation should therefore **reuse** the existing industrial relation model rather than introduce financial relationship CUE.

Minimal requirements:

1. pin the industrial graph snapshot/revision used by the financial run;
2. record ordered references to every industrial relation/claim traversed;
3. resolve the terminal industrial entity to issuer and instrument through an explicitly evidenced mapping;
4. join issuer/market observations without mutating industrial state;
5. derive relationship metrics and capture hypotheses deterministically;
6. qualify valuation, scenarios, risk, and decision;
7. preserve the graph snapshot and path references in the immutable financial run bundle.

Use Vertiv, Eaton, Soitec, and First Phosphate as initial real-observation fixtures/candidate records. Keep IBM/C2MI deliberately unresolved as a positive issuer/instrument-mapping coverage-gap case.

Do not generalize this domain into worker-core CUE until another profile demonstrates genuine shared invariants.

## 12. Re-evaluation loop

Both graph state and market state can invalidate or materially alter an opportunity:

```text
industrial graph changes                  market / issuer changes
        |                                          |
new relation / path                         price falls
path disappears                             multiple rises
substitute admitted                         dilution
constraint relief                           financing
capacity expansion                          margin / backlog changes
project cancellation                        contract award / loss
        \----------------------+-------------------/
                               |
                               v
                        requalification
```

The financial run should compare both:

```text
previous industrial graph snapshot
        -> current industrial graph snapshot

previous financial snapshot
        -> current financial observations
```

A graph delta can therefore trigger financial requalification even when the instrument price is unchanged; a market delta can trigger requalification while the graph remains unchanged.

A financial opportunity substrate is a control plane over changing evidence and projected relationships, not a feed of bullish events.

## 13. Snapshot sources

These sources support the September 2 observation register and should be treated as acquired external observations, not Factory authority:

- Vertiv, Q2 2026 results, 2026-07-29: https://investors.vertiv.com/news/news-details/2026/Vertiv-Reports-Strong-Second-Quarter-2026-with-Diluted-EPS-Growth-of-53-Adjusted-Diluted-EPS-Growth-of-60-Raises-Full-Year-2026-Guidance-Across-All-Key-Metrics/default.aspx
- Vertiv, UtilityInnovation Group acquisition, 2026-09-02: https://investors.vertiv.com/news/news-details/2026/Vertiv-Announces-Agreement-to-Acquire-UtilityInnovation-Group-to-Accelerate-Time-to-Power-for-AI-Data-Centers/default.aspx
- Eaton, Q2 2026 results / SEC exhibit: https://www.sec.gov/Archives/edgar/data/1551182/000155118226000027/etn06302026exhibit99.htm
- Soitec, Q1 FY2027 revenue, 2026-07-22: https://www.globenewswire.com/news-release/2026/07/22/3331579/0/en/Soitec-Reports-First-Quarter-Revenue-of-Fiscal-Year-2027.html
- Reuters, Soitec multi-year Photonics-SOI agreements, 2026-08-31: https://www.reuters.com/world/asia-pacific/soitec-locks-customers-into-multi-year-deals-ai-wafer-demand-surges-2026-08-31/
- Natural Resources Canada, First Phosphate infrastructure funding, 2026-08-05: https://www.canada.ca/en/natural-resources-canada/news/2026/08/canada-invests-to-connect-quebec-critical-minerals-to-market.html
- First Phosphate PEA disclosure / SEC exhibit, 2024-12-04: https://www.sec.gov/Archives/edgar/data/1490078/000175392624002027/g084584_ex99-1.htm
- Point-in-time market observations used only for the snapshot: StockAnalysis pages for VRT, ETN, EPA:SOI, and CSE:PHOS, observed 2026-09-02.
