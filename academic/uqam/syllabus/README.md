# UQAM syllabi

`academic/uqam/syllabus/` stores course-local normalized syllabi. It is distinct from the institutional catalog and the time-sensitive event watch.

```text
UQAM catalog      stable institutional identity/context
UQAM events       time-sensitive activity + delta state
UQAM syllabus     course-local teaching/evaluation/material topology
```

Semantic shape: `contracts/academic/uqam/syllabus/`.

A syllabus is not a scheduled monitor. It is a source-qualified projection of supplied course materials. Explicit source facts and derived topology are separated through each relationship's `basis` and `evidence`.

Current courses live under a term-qualified directory such as `inf1120-a26/`.
