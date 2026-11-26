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
The probe also checks the existing Arrow pin (26.0.0) and fails on any missing or different version. No backend fallback is
allowed. Save the resolved dependency versions, Python and platform details,
and exact upstream artifact digests with a successful qualification receipt.

The current workspace has Pydantic 2.13.4 and no Ibis or DuckDB installation.
The package index available here did not supply the pinned Pydantic candidate.
The local environment does not qualify the complete candidate runtime stack.

## Reviewed upstream declaration surfaces

These selected public declarations were located at the candidate release
references. Git blob IDs identify the inspected source files. This is API
presence evidence, not a static assignability check, wheel provenance, or
behavior evidence.

- Pydantic `BaseModel.model_validate` and `model_dump`, release `v2.14.0`,
  [main.py](https://github.com/pydantic/pydantic/blob/v2.14.0/pydantic/main.py),
  blob `5527adcb35deb6bf2d8e291003070635426de4a1`.
- Pydantic `ConfigDict.strict` and `extra`, same release,
  [config.py](https://github.com/pydantic/pydantic/blob/v2.14.0/pydantic/config.py),
  blob `237be865af71f0703b79b4bfc9fac8d9039dbaed`.
- Ibis DuckDB backend `do_connect` and `to_pyarrow`, release `11.0.0`,
  [backend module](https://github.com/ibis-project/ibis/blob/11.0.0/ibis/backends/duckdb/__init__.py),
  blob `5a82df1c33d8a526a24cb58f00456642814b2089`.
- DuckDB exports `connect` and `DuckDBPyConnection`, release `v1.5.6`,
  [package module](https://github.com/duckdb/duckdb-python/blob/v1.5.6/duckdb/__init__.py),
  blob `d17c530fe755bd07d18a5bf431d7541f4efea334`.
  This proves the names are exported, not the compiled API signatures.
The probes use synthetic local data only and do not validate BigQuery.
