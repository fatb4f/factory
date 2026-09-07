# Canada climate readiness sources and acquisition

This document describes monitored source families and acquisition realization for `world.canada-climate-readiness`. The CUE contract remains authoritative.

## Monitored source families

Prefer primary Canadian and Quebec sources that establish adaptation requirements, hazard guidance, infrastructure-readiness obligations, standards, funding, procurement, or project state.

| Source family | Typical evidence | Current access | Projected adapter |
| --- | --- | --- | --- |
| Federal/provincial adaptation strategies | adaptation priorities and requirement changes | browser / documents | strategy/document adapter |
| Environment and Climate Change Canada and related federal climate surfaces | hazard guidance, climate assessments, program state | browser / datasets / publications | federal publication/data adapter |
| Provincial environment/infrastructure ministries | resilience programs, requirements and funding | browser / datasets | provincial publication/data adapter |
| Standards and code bodies | climate design standards, code/guidance changes | browser / standards publications | standards adapter |
| Regulators | infrastructure/resilience requirements and approvals | browser / registers / filings | regulator/register adapter |
| Utilities | electrical/water resilience projects and planning | browser / project/planning documents | utility/project adapter |
| Municipalities | local adaptation plans, infrastructure projects, procurement | browser / open data / procurement | municipal data/document adapter |
| Public financing/funding institutions | adaptation/resilience funding state | browser / reports / datasets | funding adapter |
| Procurement systems | tenders and requirements for resilience work | browser / dataset / API where available | procurement adapter |
| Project proponents | resilience project milestones | browser / project updates / filings | proponent adapter |

## Current acquisition

```text
watch request
  ↓
manual / agent-assisted reconnaissance
  ↓
primary source selection
  ↓
bounded record capture
  ↓
source + channel + recordID + revision + acquiredAt
  ↓
climate-readiness EventObservation
  ↓
contract validation
  ↓
run manifest / explicit coverage gap
```

Record hazards and resilience requirements only as established by the source. Acquisition does not upgrade guidance into evidence of actual asset failure.

The current contract distinguishes adaptation program launch/update, resilience funding awards, standard/code changes, hazard-guidance changes, project announcements/milestones, risk-requirement changes, and procurement.

## Projected automated acquisition

```text
source registry
  ↓
scheduled acquisition request
  ↓
source-specific replaceable adapter
  ↓
immutable captured payload/document/dataset slice
  ↓
canonical source occurrence
  ↓
typed event extraction
  ↓
geography/surface/event-kind qualification
  ↓
CUE validation + domain admission
  ↓
resilience graph snapshot
```

The target graph may expose resource demand only after the domain's `resilience-graph` execution is actually implemented and admitted.

## Coverage and fail-closed behavior

Record an explicit coverage gap when an applicable source is unavailable, inaccessible, historically incomplete, machine-unreadable, or insufficient for the requested hazard/project/requirement observation.

Do not infer:

- physical asset failure from hazard guidance;
- industrial shortage from an adaptation program;
- clean-energy adequacy;
- investment attractiveness;
- resource contention;
- project success.

Those are separately admitted downstream concerns.