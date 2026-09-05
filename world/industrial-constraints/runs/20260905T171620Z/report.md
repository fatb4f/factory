# Industrial Constraints Monitor

Run: `20260905T171620Z`  
Phase: `event-watch`  
Window: 2026-08-30 through 2026-09-05

## Observed events

- **McIlvenna Bay production milestone — track.** Natural Resources Canada reports first copper concentrate in June, zinc and pyrite concentrates in July, ramp-up toward commercial production in Q3 2026, connection through a new 85-km transmission line and substation, and an expansion study evaluating processing capacity from 4,900 to about 7,000 tonnes/day. The same release says the copper will be smelted in Québec.
  - Source: Natural Resources Canada, 2026-09-02
  - Surfaces: `critical-minerals`, `electricity-grid`
  - Observation only; no binding-capacity or downstream-impact claim is admitted.

- **Responsible Data Centre Development Principles — track.** Innovation, Science and Economic Development Canada launched a national framework requiring participating data-centre development to address electricity-ratepayer protection, water/environmental impacts, transparency, local benefits and strategic value.
  - Source: ISED, 2026-09-03
  - Surfaces: `ai-compute`, `electricity-grid`
  - Observation only; no claim is made about Québec grid adequacy or project feasibility.

- **CMRDD contribution-funding stream — track.** Natural Resources Canada lists the contribution-funding stream as open for applications through a continuous EOI process for critical-mineral processing, recycling and circular technologies. The program explicitly identifies advanced manufacturing, semiconductors, ICT and critical-infrastructure value chains among intended raw-material uses.
  - Source: Natural Resources Canada, page revision 2026-09-01
  - Surfaces: `critical-minerals`, `semiconductors`

- **Joliette pad-mounted-transformer procurement amendment — track.** CanadaBuys notice `20162777` shows Ville de Joliette seeking 167 kVA and 1500 kVA pad-mounted transformers; the notice was amended 2026-09-02 and closes 2026-09-10.
  - Source: CanadaBuys / Ville de Joliette
  - Surfaces: `transformers-switchgear`, `electricity-grid`
  - This is a procurement observation, not evidence by itself of a transformer shortage.

## Infrastructure and capacity signals

- McIlvenna Bay's official release records a completed 85-km grid connection and substation plus a processing-capacity expansion study.
- The federal data-centre principles create a current policy signal around electricity-cost allocation, water use and local impacts for future compute infrastructure.

## Institutional responses

- ISED and the Federation of Canadian Municipalities announced a national data-centre development framework with broad industry signatories.
- NRCan continues to expose critical-minerals processing/commercialization funding through CMRDD.

## Funding and procurement signals

- CMRDD contribution funding is currently listed as open under a continuous EOI.
- Ville de Joliette has an active pad-mounted-transformer procurement closing 2026-09-10.

## Evidence and provenance

Every admitted item is represented in `evidence.json` as a source-qualified `document` plus `event-observation`. Event actors and subjects remain observed labels. No canonical entity identity or source-to-source equivalence was asserted.

## Coverage gaps

- The bounded web acquisition is search-index dependent and does not enumerate every selected institution, operator or supplier.
- This pass inspected a material CanadaBuys transformer notice but did not enumerate the complete CanadaBuys procurement dataset.
- No absence-of-event inference should be drawn for semiconductor, advanced-packaging or cleanroom surfaces from this bounded pass alone.

> Current phase: `event-watch`. Constraint claims, canonical graph propagation, relational qualification and Ibis/DuckDB state are intentionally unavailable.
