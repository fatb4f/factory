# Financial Opportunity Tracking Substrate

Status: proposed architecture

Snapshot date: 2026-09-02

Proposed semantic authority: `contracts/world/financial-opportunities/`

This document proposes a dedicated financial-opportunity intelligence substrate. It does **not** extend the semantic authority of `world.industrial-constraints`, and it does not establish financial authority until corresponding CUE contracts are introduced and qualified.

The September 2 opportunity register below is observation-derived speculative analysis. Scenario returns are model outputs from explicit assumptions, not admitted facts, price targets, or investment recommendations.

## 1. Authority boundary

`world.industrial-constraints` owns admitted industrial constraint intelligence: capacity, scarcity, funding/procurement, institutional response, and evidence-backed constraint claims.

A separate financial domain should consume admitted industrial outputs through declared projections and combine them with independently acquired market and issuer observations.

```text
world.industrial-constraints
    admitted industrial facts
    constraints
    funding / procurement
    capacity changes
    institutional response
              |
              | declared projection
              v
world.financial-opportunities
    exposure resolution
    market observations
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
economic beneficiary
        !=
investable exposure
        !=
investment thesis
        !=
attractive valuation
        !=
admitted opportunity
```

Industrial evidence may support a financial thesis. It cannot establish one by implication.

## 2. Proposed repository shape

```text
contracts/world/financial-opportunities/
    contract.cue
    observations.cue
    exposure.cue
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

## 3. Opportunity identity and exposure

An opportunity is identified by an investable exposure, not by a company name or industrial event alone.

```cue
#OpportunityIdentity: close({
    opportunityID: string

    instrument: close({
        issuerID:   string
        securityID: string
        kind:       "equity" | "bond" | "fund" | "commodity" | "private-project"
        currency:   string
        venue?:     string
    })

    strategy:        #StrategyClass
    thesisMechanism: #ThesisMechanism
})

#ExposureAssessment: close({
    industrialDriver: #ExternalRecordRef
    beneficiary:      #EntityRef
    instrument:       #InstrumentRef

    mechanism:
        "revenue-growth" |
        "margin-expansion" |
        "capacity-utilization" |
        "pricing-power" |
        "asset-revaluation" |
        "cost-reduction" |
        "subsidy" |
        "contract-award"

    directness: "direct" | "second-order" | "indirect"

    revenueExposurePct?:  >=0 & <=100
    earningsExposurePct?: >=0 & <=100
    assetExposurePct?:    >=0 & <=100

    confidence: #Confidence
    evidence:   [...#EvidenceRef]
})
```

Exposure propagation must be graph-declared:

```text
industrial constraint
    -> projects-to
beneficiary
    -> realized-by
issuer
    -> represented-by
security
```

Do not infer exposure because names, sectors, or paths appear related.

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

## 6. Thesis, catalysts, and invalidators

Every qualified thesis should define both realization paths and failure conditions.

```cue
#Thesis: close({
    proposition: string

    catalysts:    [...#Catalyst]
    invalidators: [...#Invalidator] & [_, ...]

    evidence: [...#EvidenceRef] & [_, ...]
})
```

A monitoring loop must be able to invalidate its own thesis rather than accumulate only confirming observations.

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

Historical opportunity snapshots are immutable. A thesis can remain valid while a security moves from attractive to unattractive because price changes.

```text
industrial thesis unchanged
          +
price rises materially
          |
          v
expected return contracts
          |
          v
qualified -> watch / overvalued
```

Likewise, an unchanged thesis plus a material price decline can increase prospective return and trigger requalification.

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

- a resolved investable instrument;
- a current valuation observation;
- an explicit failure/downside scenario;
- scenario assumptions and evidence;
- an exposure assessment;
- a risk assessment;
- a declared catalyst or structural return mechanism;
- sufficient provenance to reproduce the decision;
- no material unresolved coverage gap affecting the return thesis.

## 9. Calibration

Each admitted snapshot should eventually be evaluated against realized outcomes.

```text
t0
price
scenario distribution
probabilities
thesis
risk
evidence
        |
        v
t1 / t2 / t3
realized observations
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
```

This allows the substrate to learn whether particular evidence classes or opportunity profiles are systematically over- or under-estimated.

---

# 10. Current speculative opportunity register

Snapshot: 2026-09-02.

The profiles below are candidate observations for future qualification. They are not admitted financial decisions. Market observations must be re-acquired before any later evaluation.

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
industrial-signal
    |
    v
exposure-resolution-required
```

The financial substrate should resolve equipment, materials, supplier, capacity, and local-beneficiary relationships before generating an opportunity claim. IBM itself should not be promoted merely because it participates in the project.

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
weakest exposure mapping         IBM / C2MI
```

No current candidate clearly combines high-confidence industrial evidence, low valuation risk, high exposure purity, high upside, and low permanent-loss risk.

---

# 11. Initial implementation milestone

Implement only the smallest closed path first:

```text
IndustrialRecordRef
        |
        v
ExposureAssessment
        |
        v
Instrument
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

Use Vertiv, Eaton, Soitec, and First Phosphate as initial real-observation fixtures/candidate records. Keep IBM/C2MI deliberately unresolved as a positive coverage-gap case.

Do not generalize this domain into worker-core CUE until another profile demonstrates genuine shared invariants.

## 12. Re-evaluation loop

Both world state and market state can invalidate or materially alter an opportunity:

```text
world changes                    market changes
     |                                |
new contract                      price falls
new backlog                       multiple rises
constraint relief                 dilution
project cancellation              financing
     \----------------+---------------/
                      |
                      v
               requalification
```

A financial opportunity substrate is therefore a control plane over changing evidence, not a feed of bullish events.

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
