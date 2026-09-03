package inf1035a26

issues: [
    {
        id: "issue:course-metadata-gap"
        kind: "source-gap"
        source: "src:calendar-a26"
        basis: "explicit"
        note: "The calendar establishes group 020, instructor identity/email and Tuesday sessions, but does not establish lecture time, room or department. Those fields remain unset rather than inferred."
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
        note: "Original PDF bytes are not transferable from the File Library interface in this run. Git-native text projections are present under source-material/, while source SHA-256 and byte-size remain unset until original bytes are reacquired."
    },
]
