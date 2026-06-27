# Codex report run records

This directory stores durable per-run Markdown reports for the Codex contract-surface upstream-monitor loop.

Admitted filename shape:

```text
<run_id>.codex-impact.md
```

`run_id` must use UTC execution time in `YYYYMMDDTHHMMSSZ` form.

The sibling `../latest.codex-impact.md` file is only an overwriteable projection of the most recent admitted run.
