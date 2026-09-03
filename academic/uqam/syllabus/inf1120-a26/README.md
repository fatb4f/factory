# INF1120-020 — Automne 2026 normalized syllabus

This directory is the course-local projection of the supplied INF1120 corpus.

```text
source artifacts
      │
      ├── current authority: Moodle + signed evaluation agreement
      ├── course resources: topic archives + correction/style/exam directives
      └── historical evidence: 2016/A18/H19 quiz archives
                │
                ▼
        normalized syllabus
                │
      ┌─────────┼─────────┐
      ▼         ▼         ▼
   schedule   concepts  constraints
      │         │         │
      └─────────┼─────────┘
                ▼
          relationships
```

## Projection

- `course.cue` — identity, instructor and lecture/lab meetings.
- `sources.cue` — supplied artifacts, SHA-256 digests and archive-member inventory.
- `materials*.cue` — file-level material nodes grouped as current topic material, historical assessment material and course references.
- `schedule.cue` — lecture/lab week sequence.
- `assessments.cue` — current A26 weights and known dates.
- `concepts*.cue` — normalized concept vocabulary.
- `constraints.cue` — INF1120-specific code, design, submission and exam constraints.
- `relationships*.cue` — prerequisite, introduction, practice, historical-assessment and constraint edges.
- `issues.cue` — source inconsistencies/currentness/gaps kept explicit.
- `normalized.cue` — projection against `contracts/academic/uqam/syllabus/#NormalizedSyllabus`.
- `material-index.md` and `learning-graph.md` — readable projections.

## Authority rule

Current A26 claims come from the supplied Moodle snapshot and signed evaluation agreement. Course-resource files support topic and correction/style constraints. Historical quiz archives may only justify `historical-assessment-derived` edges; they must not be promoted to current A26 assessment coverage without current evidence.

## Raw source policy

The repository records filenames, archive membership and SHA-256 identity for the supplied binary/source corpus. The uploaded ZIP/PDF/JAR binaries are not duplicated in Git. The normalized graph remains traceable to those artifacts without treating generated summaries as source authority.
