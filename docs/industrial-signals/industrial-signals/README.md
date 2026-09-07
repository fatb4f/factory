# Industrial signals graph documentation

Graph authority: `contracts/world/industrial-signals/`.

Authoritative source registry: `contracts/world/industrial-signals/sources.cue`.

Execution procedure: `world/industrial-signals/.agents/AGENTS.md`.

- [Exhaustive monitored source catalog](source-catalog.md)
- [Source surface / adapter / interface matrix](surface-adapter-interface-matrix.md)
- [Sources and acquisition](sources-and-acquisition.md)

The source catalog is an exhaustive documentation projection of the CUE registry. GDELT, Google BigQuery/Google Patents, grants, procurement, measurements, identity sources, institutional sources, ATI/ATIP and primary operational/follow-through channels are all enumerated there individually.

The interface matrix is a separate capability projection over the same registry. It distinguishes native/direct interfaces (for example BigQuery → SQL, Ibis, dbt, Google clients, JDBC/ODBC) from generic acquisition adapters and post-landing analytical interfaces. A listed interface is technically viable, not evidence that Factory has implemented or qualified that adapter.

Current monitoring is bounded manual/agent-assisted `event-watch`. Longitudinal actor, funding, adoption and project follow-through must remain source-qualified until the industrial graph admission path establishes canonical identity and relations.
