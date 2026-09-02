# UQAM + Montréal student/community/technical events

This is the contracted daily condition-watch procedure for `academic.uqam.events`.

Semantic authority is `contracts/academic/uqam/events/`. `academic.uqam.catalog` owns stable institutional/community identity; it does not decide event identity, comparison or publication.

## Scope

Acquire newly announced or materially updated events useful to UQAM students: associations/groups, rentrée, cafés/community activity, student media, volunteering, networking, culture, computing/open source/data/AI/security/science/research, hackathons, seminars, career/funding/support sessions and recreation.

Required completeness surfaces remain `uqam-central-events`, `uqam-numerique`, and `uqam-information-diffusion`, preserving continuity of the existing `uqam-events/v1` baseline. Student-life/group/café/media/association sources are high-priority optional primary surfaces.

## Catalog context

When `academic/uqam/catalog/state/admitted-baseline.json` resolves to a valid run, record it as `catalog_context`. Use it only to resolve explicitly evidenced organizer/venue IDs or discover admitted organizer-owned primary surfaces.

Never infer an edge from name similarity. Never suppress a valid event because it lacks a catalog projection. Catalog projection enrichment alone is not a reportable event change.

## Normalization and comparison

Normalize as `#NormalizedEvent`. Stable identity prefers source event ID, canonical primary URL, then organizer/title/source fallback. `kind`, date/time, location, registration, scope and catalog projections are excluded from stable identity. Classify `kind` when primary evidence supports it.

Compare with the admitted event baseline. Report only a new stable event identity or source-observed material changes to date/time, location, registration, scope or event details. Missing listings remain state-only unless primary evidence establishes cancellation/material removal.

Outcomes remain `baseline_established`, `no_change`, `new_matches`, `source_gap`, `comparison_gap`, or `state_conflict`.

Persist immutable runs under `academic/uqam/events/runs/<run-id>/` and advance the baseline only through compare-and-swap. Preserve the existing event schema/baseline continuity.

Use `academic/uqam/.agents/events/report-template.md` only for admitted additions/material changes.
