# UQAM event comparison state

`admitted-baseline.json` is the single mutable pointer for `academic.uqam.events`.

It points to one immutable normalized run under `../runs/<run-id>/` and carries the comparison schema and pointer generation. It is task state, not dispatcher scheduler state and not a source observation.

The pointer is advanced only after a run has complete required-source acquisition and a valid comparison state. The update is compare-and-swap: the writer must re-read the pointer immediately before publication and verify the expected generation and current file revision. An overlapping writer must not overwrite a newer pointer.

No baseline is seeded from historical prose or dispatcher outcomes. Absence of this file means `bootstrap`; the next complete run establishes the first admitted baseline and returns `baseline_established`.
