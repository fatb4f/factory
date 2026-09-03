package inf1120a26

issues: [
    {
        id: "issue:week-06-date"
        kind: "source-inconsistency"
        source: "src:moodle-a26"
        source_value: "12/05/2026"
        normalized_value: "2026-10-12"
        basis: "schedule-sequence"
        note: "The Moodle snapshot labels week 06 with literal 12/05/2026 while surrounding weeks, the Oct. 13 quiz date, and the A26 calendar sequence place week 06 on Monday 2026-10-12. The normalized date is explicitly marked as sequence-derived rather than silently replacing the source literal."
    },
    {
        id: "issue:quiz-currentness"
        kind: "source-currentness"
        source: "src:quiz-2016"
        source_value: "2016 quiz files inside Quiz(1).zip"
        basis: "explicit"
        note: "Treat these files as historical practice evidence only. They do not establish the content of A26 Quiz #1 or Quiz #2."
    },
    {
        id: "issue:tp-dates-pending"
        kind: "source-gap"
        source: "src:moodle-a26"
        source_value: "TP1/TP2/TP3 dates: Voir site Moodle / published with statements"
        basis: "explicit"
        note: "Exact TP due dates and modalities are not present in the supplied snapshot; they remain unresolved until the statements are published."
    },
]
