# Codex contract-surface evidence

This directory is the contract-local evidence output root for the Codex contract-surface upstream-monitor loop.

Evidence here may record observed upstream signals, report-generation inputs, publication plans, and validation results. Evidence is downstream of CUE authority and must not become authority by location or naming.

Admitted evidence layout:

```text
evidence/runs/<run_id>.codex-impact.report.json   durable per-run evidence record
evidence/latest.codex-impact.report.json          overwriteable latest-run projection
```

`run_id` uses UTC execution time in `YYYYMMDDTHHMMSSZ` form.

Do not write evidence outside this directory unless a future CUE contract admits another evidence root.
