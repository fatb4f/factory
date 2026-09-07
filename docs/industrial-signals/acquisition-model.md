# Shared acquisition model

This document defines the common documentation vocabulary for acquisition across monitored graph and initiative directories under `docs/industrial-signals/`. It is descriptive and does not replace any domain's CUE authority.

## Current control surface

```text
monitor request
      ↓
manual / agent-assisted source reconnaissance
      ↓
bounded acquisition from an applicable source surface
      ↓
source-qualified captured occurrence
      ↓
typed observation candidate
      ↓
validation / admission OR explicit coverage gap
      ↓
run state
```

Manual and agent-assisted acquisition may use browsers, APIs, downloadable datasets, public registers, repositories, released record packages, procurement systems, standards publications, regulatory filings, or request-based access. The mechanism is execution metadata rather than semantic identity.

## Projected pipeline control surface

```text
source obligations / registry
      ↓
schedule / acquisition request
      ↓
replaceable source adapter
      ↓
immutable raw capture
      ↓
canonicalization
      ↓
structural extraction / normalization
      ↓
identity and relation candidates
      ↓
typed domain-specific observation candidates
      ↓
CUE validation
      ↓
domain-owned admission
      ↓
immutable domain snapshot
```

The projected pipeline should preserve the same epistemic constraints as the current manual path. Automation is not a new admission authority.

## Source obligation record

Graph- and initiative-specific source documentation should be able to express, at minimum:

- source family;
- named source/surface when stable enough to matter operationally;
- access mode: browser, API, dataset, feed, repository, register, procurement system, document package, request-based access;
- expected record type or observation surface;
- current acquisition status;
- projected adapter class;
- source-local identity/revision hints;
- immutable captured-content identity when required;
- expected refresh/follow-up cadence where contractually meaningful;
- coverage/failure modes;
- authority class of the resulting evidence.

Coordinating/index surfaces are discovery sources unless their own record is the fact being observed. When an underlying project, regulator, funder, utility, proponent, issuer, standard, or procurement record exists, preserve that source-specific authority rather than treating an umbrella initiative page as a substitute.

## Acquisition outcomes

Acquisition should terminate explicitly as one of:

```text
record acquired
record acquired but identity unresolved
record acquired but evidence insufficient
source unavailable
source inaccessible
source historically incomplete
source machine-unreadable
expected follow-through unavailable
```

The exact vocabulary remains domain-contract specific. Documentation must not convert an acquisition failure into evidence that the monitored event/state does not exist.

## Cross-domain routing

Acquisition and semantic routing are separate operations:

```text
source occurrence
      ↓
typed observation candidate
      ↓
which authority does this evidence establish?
      ↓
owner-domain admission
```

One source occurrence may support separately qualified observations in more than one authority, but no downstream domain may copy another domain's topology merely because the same Canadian initiative appears in both contexts.

## Pipeline realization boundary

A future implementation may use different transport and storage products for different source families. The stable architecture is:

```text
CUE schema
  → constrained acquisition/source state
  → normalized observation projection
  → adapter realization
```

Products such as ingestion frameworks, queues, object stores, warehouses, search indexes, or schedulers are replaceable realizations unless an authoritative contract explicitly requires one.
