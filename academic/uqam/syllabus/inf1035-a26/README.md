# INF1035 — Automne 2026 normalized syllabus contract

This directory normalizes the supplied INF1035 calendar and Chapter 1 material.

```text
computer representation
    ↓
Python fundamentals
    ↓
structured data
    ↓
scientific/data tooling
```

## Source authority

Current claims are grounded in:

- `Calendrier_INF1035_Automne_2026.pdf` for course identity, group/instructor metadata, weekly scope, assessment timing/weights, pass gates and term-calendar constraints;
- `INF1035 - Chapitre 01 - Introduction.pdf` for Chapter 1 concepts and page-local emphasis.

Readable Git-native projections of both supplied PDFs are vendored under `source-material/`. They are extracted text projections, not byte-identical replacements for the original PDFs; figures, layout and exact source-byte identity remain properties of the originals.

## Projection

- `course.cue` — course identity and metadata established by the current source set.
- `sources.cue` / `materials.cue` — current source and page-local material identities.
- `schedule.cue` — 16 dated sessions, including reserve and final-assessment sessions.
- `assessments.cue` — TP1/TP2/TP3 + midterm + final; weights sum to 100%.
- `constraints.cue` — dual pass gate, no Faculty of Science reading week, withdrawal deadline.
- `concepts.cue` — Chapter 1 representation/execution concepts plus later schedule-level Python/data concepts.
- `relationships.cue` — schedule, dependency, assessment and evidence topology.
- `issues.cue` — remaining metadata/content/source-byte gaps kept explicit.
- `normalized.cue` — projection against `contracts/academic/uqam/syllabus/#NormalizedSyllabus`.
- `source-material/` — readable text projections of supplied course artifacts.

## Currentness boundary

Chapter 1 is concept-rich because the actual notes are represented. Weeks 2–14 are normalized only to the granularity exposed by the calendar. Group `020`, instructor Dylan Lebatteux, instructor email and Tuesday sessions are explicit in the calendar; meeting time/location and department remain unresolved. No detailed TP scope or later-chapter subtopics are inferred.
