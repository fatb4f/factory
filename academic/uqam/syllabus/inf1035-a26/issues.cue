package inf1035a26

issues: [
    {
        id: "issue:course-metadata-gap"
        kind: "source-gap"
        source: "src:calendar-a26"
        basis: "explicit"
        note: "The current normalized input does not establish group, instructor, meeting time/location, department or a canonical course title; these fields remain unset rather than inferred."
    },
    {
        id: "issue:later-chapter-detail-gap"
        kind: "source-gap"
        source: "src:calendar-a26"
        source_value: "Weekly topic labels only after Chapter 1"
        basis: "explicit"
        note: "Detailed notes for later chapters are not in the current source set. Later concepts therefore remain schedule-granularity nodes and no unsupported subtopic or TP coverage is inferred."
    },
    {
        id: "issue:source-digest-gap"
        kind: "source-gap"
        source: "src:chapter-01"
        basis: "explicit"
        note: "The two referenced PDF binaries are not mounted in this turn, so source SHA-256 and byte-size fields are intentionally omitted until reacquisition."
    },
]
