package uqamsyllabus

#NonEmptyString: string & != ""
#Date: string & =~"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
#Time: string & =~"^[0-2][0-9]:[0-5][0-9]$"
#SHA256: string & =~"^[0-9a-f]{64}$"

#SourceID: string & =~"^src:[a-z0-9][a-z0-9._:-]*$"
#MaterialID: string & =~"^material:[a-z0-9][a-z0-9._:-]*$"
#ConceptID: string & =~"^concept:[a-z0-9][a-z0-9._:-]*$"
#WeekID: string & =~"^week:[a-z0-9][a-z0-9._:-]*$"
#AssessmentID: string & =~"^assessment:[a-z0-9][a-z0-9._:-]*$"
#ConstraintID: string & =~"^constraint:[a-z0-9][a-z0-9._:-]*$"
#RelationID: string & =~"^relation:[a-z0-9][a-z0-9._:-]*$"
#IssueID: string & =~"^issue:[a-z0-9][a-z0-9._:-]*$"
#CourseID: string & =~"^uqam:course:[a-z0-9][a-z0-9._:-]*$"
#NodeID: #CourseID | #MaterialID | #ConceptID | #WeekID | #AssessmentID | #ConstraintID

#SourceStatus: "current-course" | "course-resource" | "historical"
#SourceKind:
    "moodle-snapshot" |
    "evaluation-agreement" |
    "course-directive" |
    "course-calendar" |
    "chapter-notes" |
    "style-guide" |
    "correction-guide" |
    "topic-archive" |
    "quiz-archive"

#SourceArtifact: close({
    id: #SourceID
    title: #NonEmptyString
    kind: #SourceKind
    status: #SourceStatus
    filename: #NonEmptyString
    sha256?: #SHA256
    bytes?: int & >=0
    members?: [...#NonEmptyString]
    note?: #NonEmptyString
})

#MaterialRole:
    "slides" |
    "notes" |
    "example" |
    "exercise" |
    "solution" |
    "helper-library" |
    "reference" |
    "assessment" |
    "assessment-solution" |
    "sample-data"

#Material: close({
    id: #MaterialID
    title: #NonEmptyString
    role: #MaterialRole
    source: #SourceID
    path: #NonEmptyString
    locator?: #NonEmptyString
    topic?: #NonEmptyString
    currentness: "current-topic-material" | "historical-assessment" | "course-reference"
})

#Meeting: close({
    kind: "lecture" | "lab"
    day: "monday" | "tuesday" | "wednesday" | "thursday" | "friday" | "saturday" | "sunday"
    start: #Time
    end: #Time
    room?: #NonEmptyString
    leader?: #NonEmptyString
})

#Course: close({
    id: #CourseID
    code: #NonEmptyString
    group?: #NonEmptyString
    term: #NonEmptyString
    title?: #NonEmptyString
    department?: #NonEmptyString
    instructor?: close({
        name: #NonEmptyString
        email?: #NonEmptyString
    })
    meetings?: [...#Meeting]
})

#ConceptKind:
    "foundation" |
    "hardware" |
    "representation" |
    "encoding" |
    "execution" |
    "specification" |
    "language" |
    "environment" |
    "control-flow" |
    "function" |
    "method" |
    "library" |
    "object" |
    "array" |
    "exception" |
    "io" |
    "collection" |
    "structured-data" |
    "numerical-computing" |
    "tabular-data" |
    "visualization" |
    "machine-learning"

#Concept: close({
    id: #ConceptID
    label: #NonEmptyString
    kind: #ConceptKind
    description: #NonEmptyString
    evidence: [...#SourceID] & [_, ...]
})

#Week: close({
    id: #WeekID
    number: int & >=1 & <=16
    week_start: #Date
    source_week_start_literal?: #NonEmptyString
    lecture_topics: [...#NonEmptyString]
    lab_topics: [...#NonEmptyString]
    lecture_status: "scheduled" | "no-course" | "reserve" | "assessment-only"
    lab_status: "scheduled" | "no-lab" | "not-specified"
    evidence: [...#SourceID] & [_, ...]
})

#AssessmentKind: "quiz" | "exam" | "practical-work"
#Assessment: close({
    id: #AssessmentID
    label: #NonEmptyString
    kind: #AssessmentKind
    weight_percent: number & >0 & <=100
    date?: #Date
    release_date?: #Date
    due_date?: #Date
    start?: #Time
    end?: #Time
    due: "fixed" | "moodle-publication"
    evidence: [...#SourceID] & [_, ...]
})

#ConstraintScope: "code" | "submission" | "exam" | "documentation" | "design" | "grading" | "calendar"
#Constraint: close({
    id: #ConstraintID
    label: #NonEmptyString
    scope: #ConstraintScope
    rule: #NonEmptyString
    evidence: [...#SourceID] & [_, ...]
})

#RelationType:
    "prerequisite" |
    "precedes" |
    "introduces" |
    "practices" |
    "assesses" |
    "constrained-by" |
    "uses" |
    "extends" |
    "depends-on" |
    "evidenced-by" |
    "releases" |
    "due-at"

#RelationBasis:
    "explicit" |
    "schedule-sequence" |
    "content-dependency" |
    "historical-assessment-derived"

#Relation: close({
    id: #RelationID
    type: #RelationType
    from: #NodeID
    to: #NodeID
    basis: #RelationBasis
    evidence: [...#SourceID] & [_, ...]
    note?: #NonEmptyString
})

#NormalizationIssue: close({
    id: #IssueID
    kind: "source-inconsistency" | "source-currentness" | "source-gap"
    source: #SourceID
    source_value?: #NonEmptyString
    normalized_value?: #NonEmptyString
    basis: "explicit" | "schedule-sequence" | "content-dependency"
    note: #NonEmptyString
})

#NormalizedSyllabus: close({
    schema: "uqam-syllabus/v1"
    course: #Course
    sources: [...#SourceArtifact] & [_, ...]
    materials: [...#Material] & [_, ...]
    concepts: [...#Concept] & [_, ...]
    weeks: [...#Week] & [_, ...]
    assessments: [...#Assessment] & [_, ...]
    constraints: [...#Constraint] & [_, ...]
    relations: [...#Relation] & [_, ...]
    issues: [...#NormalizationIssue]
})
