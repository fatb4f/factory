# M1 Core candidate qualification

`factory-domain-core` 0.1.0rc1 contains the shared typed transform port, entry-point discovery, executor, Ibis lowering adapter and the CUE module files needed to validate invocation receipts. The Review Desk extension and its domain fixture are separate. The candidate wheel SHA-256 is recorded in [m1-candidate.sha256](../../state/transform-core/m1-candidate.sha256). A successful build of that digest qualifies the candidate for review. The M1 owner records acceptance of the exact version and digest on [#293](https://github.com/fatb4f/factory/issues/293) before M2 can use it.

| Input | Evidence exercised for M1 |
| --- | --- |
| [T0 #285](https://github.com/fatb4f/factory/pull/285) | Port, two smoke tests and original T0 design are byte-identical to `cd583653f3f367629ff6232839124275c0093f8f`. The executor rejects loss that the pilot receipt cannot represent. |
| [T1 #286](https://github.com/fatb4f/factory/pull/286) | Both probes from `f2f8f73a24d8139ab1e0850d346a4e85e496c09c` run on hash-checked direct wheel artifacts for CPython 3.12/Linux x86_64. The declaration probe checks the four reviewed release sources and the DuckDB compiled-interface stub. |
| [T2 #292](https://github.com/fatb4f/factory/issues/292) | The installed `py.typed` Core port and the independent extension hook are checked using mypy 2.4.1. `stubtest` compares the port to its runtime. Synthetic Desk tests check discovery, enablement, provenance, permission withdrawal, replay, and native/serialized parity against the installed candidate. Other T2 capabilities retain their own acceptance gates. |

The exact wheel artifacts are in [requirements-transform-wheels.txt](../../scripts/requirements-transform-wheels.txt). Versions are checked against the existing IVAC requirements. The runtime probes cover strict Pydantic wire validation and ordered, null-preserving Ibis/DuckDB evaluation through Arrow. The declaration probe pins the following interfaces, independently of their runtime probes.

| Upstream source | Inspected interfaces | Reviewed Git blob |
| --- | --- | --- |
| [Pydantic 2.14.0 main.py](https://github.com/pydantic/pydantic/blob/v2.14.0/pydantic/main.py) | `BaseModel.model_validate`, `model_dump` | `5527adcb35deb6bf2d8e291003070635426de4a1` |
| [Pydantic 2.14.0 config.py](https://github.com/pydantic/pydantic/blob/v2.14.0/pydantic/config.py) | `ConfigDict.strict`, `extra` | `237be865af71f0703b79b4bfc9fac8d9039dbaed` |
| [Ibis 11.0.0 DuckDB backend](https://github.com/ibis-project/ibis/blob/11.0.0/ibis/backends/duckdb/__init__.py) | `Backend.do_connect`, `to_pyarrow` | `5a82df1c33d8a526a24cb58f00456642814b2089` |
| [DuckDB 1.5.6 package](https://github.com/duckdb/duckdb-python/blob/v1.5.6/duckdb/__init__.py) | `_duckdb.connect`, `DuckDBPyConnection` exports plus the wheel's `_duckdb-stubs/__init__.pyi` | `d17c530fe755bd07d18a5bf431d7541f4efea334` |

Build and run from the checkout with CPython 3.12, CUE 0.16.1 and a fresh virtual environment:

```sh
out=$(mktemp -d)
SOURCE_DATE_EPOCH=1580601600 python -m pip wheel --no-deps --wheel-dir "$out" .
checksum="$PWD/state/transform-core/m1-candidate.sha256"
(cd "$out" && sha256sum -c "$checksum")
python -m pip install "$out"/*.whl ./extensions/review-desk-navigation -r scripts/requirements-ivac-regulatory.txt
python -m pip install --force-reinstall --no-deps --only-binary=:all: --require-hashes -r scripts/requirements-transform-wheels.txt
python scripts/qualify-transform-libraries.py -v
python -I scripts/qualify-installed-transform-core.py
```

The [qualification workflow](../../.github/workflows/transform-library-qualification.yml) adds the independent static checks and uploads the verified wheel for the candidate review. Review Desk extension approvals pin installed module bytes as well as the distribution version. A different draft build at the same version requires a new explicit pin.
