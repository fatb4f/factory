# INF1035 — Automne 2026 initial syllabus contract

This directory normalizes the currently supplied INF1035 calendar and Chapter 1 material.

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

Current claims are limited to:

- `Calendrier_INF1035_Automne_2026.pdf` for weekly scope, assessment timing/weights, pass gates and term-calendar constraints;
- `INF1035 - Chapitre 01 - Introduction.pdf` for Chapter 1 concepts and page-local emphasis.

The binary files were supplied in the UQAM project context but are not mounted in this turn, so this initial contract records their filenames without inventing SHA-256 digests or byte sizes. Those fields can be sealed when the artifacts are reacquired.

## Projection

- `course.cue` — course identity known from the current source set.
- `sources.cue` / `materials.cue` — current source and page-local material identities.
- `schedule.cue` — 16 dated sessions, including reserve and final-assessment sessions.
- `assessments.cue` — TP1/TP2/TP3 + midterm + final; weights sum to 100%.
- `constraints.cue` — dual pass gate, no Faculty of Science reading week, withdrawal deadline.
- `concepts.cue` — Chapter 1 representation/execution concepts plus later schedule-level Python/data concepts.
- `relationships.cue` — schedule, dependency, assessment and evidence topology.
- `issues.cue` — metadata/content gaps kept explicit.
- `normalized.cue` — projection against `contracts/academic/uqam/syllabus/#NormalizedSyllabus`.

## Currentness boundary

Chapter 1 is concept-rich because the actual notes are represented. Weeks 2–14 are normalized only to the granularity exposed by the calendar. No detailed TP scope, later-chapter subtopics, instructor/group metadata or meeting location is inferred.
