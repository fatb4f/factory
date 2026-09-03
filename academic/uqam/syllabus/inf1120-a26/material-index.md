# INF1120 material index

`source.cue` is not used; the canonical artifact inventory is `sources.cue`, and file-level material projections are in `materials*.cue`.

## Current A26 authority

| Source ID | Artifact | Role |
| --- | --- | --- |
| `src:moodle-a26` | `Cours _ INF1120-20 AUTOMNE 2026 _ Moodle(1).pdf` | schedule, meetings, evaluation dates, lab sequence |
| `src:evaluation-agreement-a26` | `INF1120-20_A26_EntenteEvaluation.pdf` | weights and TP/quiz submission rules |

## Course contract references

| Source ID | Artifact |
| --- | --- |
| `src:style-conventions` | `ConventionsStyleJavaPourINF1120_INF2120(1).pdf` |
| `src:correction-criteria` | `CriteresGenerauxDeCorrection_V4.pdf` |
| `src:exam-directives` | `directivesPourEtudiants.pdf` |

## Topic archives

| Source ID | Archive |
| --- | --- |
| `src:introduction` | `Introduction au cours de programmation 1-20260902(1).zip` |
| `src:spec-conception` | `Spécifications et conception-20260902(1).zip` |
| `src:intro-java` | `Introduction au langage Java-20260902(1).zip` |
| `src:methods` | `Les méthodes de classe-20260902(1).zip` |
| `src:string` | `La classe String-20260902(1).zip` |
| `src:math` | `La classe Math-20260902(1).zip` |
| `src:classes-objects` | `Introduction aux classes et aux objets-20260902(1).zip` |
| `src:arrays` | `Les tableaux-20260902(1).zip` |
| `src:exceptions` | `Les exceptions-20260902(1).zip` |
| `src:text-files` | `Les fichiers texte-20260902(1).zip` |

## Historical assessment archives

| Source ID | Archive | Authority |
| --- | --- | --- |
| `src:quiz-2016` | `Quiz(1).zip` | historical practice evidence only |
| `src:quiz-history-2018-2019` | `QuizSessionsAnterieures(1).zip` | historical A18/H19 practice evidence only |

`src:*` entries in `sources.cue` carry the SHA-256 digest, byte size and archive member inventory. `material:*` nodes retain the member path and role (`slides`, `example`, `exercise`, `solution`, `helper-library`, `sample-data`, `assessment`, or `reference`). Raw course binaries are intentionally not duplicated in Git.
