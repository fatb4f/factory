# Codex evidence run records

This directory stores durable per-run JSON evidence records for the Codex contract-surface upstream-monitor loop.

Admitted filename shape:

```text
<run_id>.codex-impact.report.json
```

`run_id` must use UTC execution time in `YYYYMMDDTHHMMSSZ` form.

The sibling `../latest.codex-impact.report.json` file is only an overwriteable projection of the most recent admitted run.
