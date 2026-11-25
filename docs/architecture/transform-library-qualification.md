# Shared transform library qualification (T1 draft)

The candidate matrix reuses the Pydantic, Ibis and DuckDB versions in
`scripts/requirements-ivac-regulatory.txt` rather than introducing a second
candidate pin policy. That existing project's validation is not evidence for
this interface.

| Candidate | Declaration evidence still needed | Runtime probe |
| --- | --- | --- |
| Pydantic 2.14.0 | Retain release source provenance and the typed model validation, config and dump declarations. | Strict field types, forbidden extras, round-trip JSON payload. |
| Ibis 11.0.0 | Retain release provenance and typed expression, backend and Arrow export declarations. | Explicitly ordered projection with nulls preserved. |
| DuckDB 1.5.6 | Retain release provenance and the API used by Ibis's DuckDB adapter. | Execute the Ibis probe against the exact local backend. |

In a Python 3.12 environment with the candidate stack installed, run
`python3 scripts/qualify-transform-libraries.py` from the repository root.
The probe fails on a missing or different version. No backend fallback is
allowed. Save the resolved dependency versions, Python and platform details,
and exact upstream artifact digests with a successful qualification receipt.

The current workspace has Pydantic 2.13.4 and no Ibis or DuckDB installation.
The package index available here did not supply the pinned Pydantic candidate.
Neither the declaration pins nor the complete runtime stack are qualified.
The probes use synthetic local data only and do not validate BigQuery.
