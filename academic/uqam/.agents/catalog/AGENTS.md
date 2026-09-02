# UQAM institutional and community catalog

This is the contracted catalog procedure for `academic.uqam.catalog`.

Semantic authority is `contracts/academic/uqam/catalog/`. Shared comparison state is `contracts/state/comparison.cue`. Public pages, acquired records, search results, prior runs and model conclusions remain observations until admitted by this task.

## Objective and boundary

Maintain the stable UQAM academic/student/community identity graph used as bounded context by events, academic offerings and derived relevance projections.

```text
official UQAM / organizer evidence
        ↓
source-qualified observations
        ↓
catalog entities + explicit relations
        ↓
admitted catalog baseline
        ├──► event identity context
        ├──► academic offering identity context
        └──► deterministic relational projections
```

The catalog does not own event deltas, term timetable state or user-specific registration state.

## Required acquisition

Every complete run must acquire `uqam-student-services`, `uqam-student-life`, `uqam-student-associations`, `uqam-student-groups`, `uqam-student-cafes`, and `uqam-student-media`, and traverse all declared group categories: community, entrepreneurship-management, student-media, multicultural, science-technology, sports, and cultural.

Normalize every current official identity with sufficient source information. A missing required surface/category is `source_gap`.

Also acquire useful official academic/community substrate when available: faculties/departments, programs, stable course identities, BIRÉ/SEA/PESH, funding/RIBÉ, digital platforms, libraries/study/computing resources and Centre sportif resources.

## Evidence and graph discipline

Observations are first-class and source-qualified by observation ID, source, channel, ref, observed surface and acquisition time. Entities and relations reference observation IDs. Never merge identities or infer topology from names.

Only emit explicit evidence-backed edges such as:

```text
student group -> categorized-as -> official category
student café -> operated-by -> faculty association
department -> part-of -> faculty
program -> offered-by -> department
service -> accessed-via -> platform
```

Stable course/program identities belong here. Instructor, section, room, meeting schedule, enrolment and term deadlines do not.

## Normalized run layout

The admitted `normalized.json` is a small index, not a monolithic graph document. It digest-addresses:

- `observations.json`;
- semantic `entities/*.json` shards;
- semantic `relations/*.json` shards.

The index digest transitively seals normalized state because every shard path, row count and SHA-256 is embedded in it.

## Comparison

Compare entities by stable entity ID and relations by stable relation ID against `academic/uqam/catalog/state/admitted-baseline.json`.

Outcomes are `baseline_established`, `no_change`, `catalog_changed`, `source_gap`, `comparison_gap`, or `state_conflict`. Removal is conservative: absence is not enough unless an authoritative directory was completely traversed or primary evidence establishes that the entity is no longer current.

## Deterministic relational projection

Run:

```text
python scripts/project-uqam-catalog.py \
  academic/uqam/catalog/runs/<run-id>/normalized.json \
  <materialization-directory>
```

The adapter generates `entities.jsonl`, `entity_evidence.jsonl`, `observations.jsonl`, `relation_evidence.jsonl`, `relations.jsonl`, and `projection-manifest.json` deterministically from admitted state.

These are reproducible projections, not semantic authority. They may be materialized or cached by Ibis/DuckDB adapters without being admitted into the canonical run bundle.

## Publication

A run contains the normalized index and shards, `decision.json`, then sealing `manifest.json`. Advance `state/admitted-baseline.json` only when the decision says `advance`, using compare-and-swap. Never overwrite an immutable run.

Run `scripts/validate-uqam-substrate.sh` to validate the admitted catalog pointer/run, regenerate relational projections, and validate academic/relevance contract fixtures.

Return the task-native outcome with entity/relation counts, group-category coverage, source gaps and run ID.
