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
- `source-material/` — readable Git-native projections of currently accessible PDF course material.
- `weeks/` — nested weekly filesystem projection for material acquired during the term; week semantics still come from `schedule.cue`.

## Authority rule

Current A26 claims come from the supplied Moodle snapshot and signed evaluation agreement. Course-resource files support topic and correction/style constraints. Historical quiz archives may only justify `historical-assessment-derived` edges; they must not be promoted to current A26 assessment coverage without current evidence.

## Source material policy

Original binary/source identities remain canonical in `sources.cue`, including filenames, archive membership, byte sizes and SHA-256 digests where acquired.

Git keeps readable projections/manifests rather than duplicating raw course binaries. Exact acquired course PDFs are mirrored in the private Google Drive course folder `factory/inf1120/syllabus/`; the weekly tree records their source identity and Git-readable projections.

A text projection improves Git-native reading/search but does not replace its original artifact when exact wording, visual layout or byte identity is authoritative.
