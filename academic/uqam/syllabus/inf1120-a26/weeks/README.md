# INF1120 A26 weekly material projection

`weeks/` is the filesystem projection for course material as it is acquired during the term. It complements, but does not replace, the normalized CUE syllabus.

Authority remains:

- `schedule.cue` for week semantics and dates;
- `sources.cue` / `materials*.cue` for source identity and material topology;
- `constraints.cue` for course-specific rules;
- `assessments.cue` for evaluation state.

## Directory contract

```text
weeks/
  week-1/
    README.md
    environment-bluej.md
    materials/
      ...
  week-2/
    README.md
  ...
  week-15/
    README.md
```

A week directory may contain source projections, environment/setup notes, exercises, examples, and study notes. Exact binary course artifacts are mirrored separately in the private Google Drive course syllabus folder; Git keeps readable/source-qualified projections and manifests.

## A26 mapping

| Week | Start | Lecture | Lab |
| ---: | --- | --- | --- |
| 1 | 2026-09-07 | Introduction au cours de programmation | no lab |
| 2 | 2026-09-14 | Spécifications et conception | Spécifications et conception |
| 3 | 2026-09-21 | Introduction au langage Java | Familiarisation avec l’IDE BlueJ |
| 4 | 2026-09-28 | Introduction au langage Java (suite) | Implémentation des algorithmes conçus à la semaine 2 |
| 5 | 2026-10-05 | Introduction au langage Java (suite); méthodes de classe | Sélections |
| 6 | 2026-10-12 | Méthodes de classe (suite); Quiz 1 | Boucles |
| 7 | 2026-10-19 | String; Math | Méthodes — partie 1 |
| 8 | 2026-10-26 | no course | Méthodes — partie 2 |
| 9 | 2026-11-02 | Introduction aux classes et aux objets | String |
| 10 | 2026-11-09 | Classes/objets (suite); tableaux | Math |
| 11 | 2026-11-16 | Tableaux (suite) | Classes et objets |
| 12 | 2026-11-23 | Exceptions | Tableaux |
| 13 | 2026-11-30 | Exceptions (suite); fichiers texte; Quiz 2 | Exceptions |
| 14 | 2026-12-07 | Fichiers texte (suite) | Fichiers texte |
| 15 | 2026-12-14 | no course | Exercices de révision |
