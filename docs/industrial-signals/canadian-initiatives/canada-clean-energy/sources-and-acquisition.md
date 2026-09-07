# Canada clean energy sources and acquisition

This document describes monitored source families and acquisition realization for `world.canada-clean-energy`. The CUE contract remains authoritative.

## Monitored source families

Prefer primary Canadian and Quebec sources that establish program, project, funding, regulatory, procurement, utility, or proponent state.

| Source family | Typical evidence | Current access | Projected adapter |
| --- | --- | --- | --- |
| Federal/provincial program pages | program launch/update, eligibility, policy changes | browser / document retrieval | program-page/document adapter |
| Natural Resources Canada and related federal energy surfaces | project/funding/grid/technology initiative records | browser / structured releases where available | federal publication/API adapter |
| Provincial energy ministries/agencies | policy, program, project and funding state | browser / datasets where available | provincial publication/data adapter |
| Regulators and system operators | approvals, interconnection, transmission/distribution state | browser / registers / filings | regulator/register adapter |
| Utilities | grid projects, procurement, capacity and milestones | browser / procurement / project pages | utility/project adapter |
| Public financing institutions | financing/award program state | browser / reports / datasets | finance-institution adapter |
| Procurement systems | tenders, awards, project requirements | browser / dataset / API where available | procurement adapter |
| Project proponents | project milestones and declared capacity | browser / filings / project updates | proponent adapter |
| Major-project coordinating surfaces | discovery/correlation only | browser / index | discovery/index adapter |

Named coordinating/index sources never replace the underlying authoritative project/program source when that source is available.

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
clean-energy EventObservation
  ↓
contract validation
  ↓
run manifest / explicit coverage gap
```

The acquisition mechanism is execution metadata. Event identity remains source-qualified.

The current contract distinguishes event kinds including program launch/update, funding award, tax incentive change, project announcement/approval, procurement, capacity-target change, grid milestone, and policy change.

## Projected automated acquisition

```text
source registry
  ↓
scheduled acquisition request
  ↓
source-specific replaceable adapter
  ↓
immutable captured payload/document
  ↓
canonical source occurrence
  ↓
typed event extraction
  ↓
geography/surface/event-kind qualification
  ↓
CUE validation + domain admission
  ↓
policy-project graph snapshot
```

The target graph may expose resource demand only after the domain's `policy-project-graph` execution is actually implemented and admitted.

## Coverage and fail-closed behavior

Record an explicit coverage gap when an applicable source is unavailable, inaccessible, historically incomplete, lacks a stable record/revision, or cannot support the requested observation. Missing evidence is not `no_material_events` when source coverage is blocking.

Do not infer:

- industrial shortage;
- resource contention;
- financial attractiveness;
- climate resilience;
- project success;
- POC relevance as an admitted decision.

Those are downstream authority concerns.