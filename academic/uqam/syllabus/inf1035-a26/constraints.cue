package inf1035a26

constraints: [
    {
        id: "constraint:exam-combined-minimum"
        label: "Minimum across the two exams"
        scope: "grading"
        rule: "Passing requires at least 50% across the two exams (midterm and final). This contract does not strengthen that source statement into a separate >=50% requirement on each individual exam."
        evidence: ["src:calendar-a26"]
    },
    {
        id: "constraint:overall-minimum"
        label: "Overall passing minimum"
        scope: "grading"
        rule: "Passing requires an overall course result of at least 50%."
        evidence: ["src:calendar-a26"]
    },
    {
        id: "constraint:no-science-reading-week"
        label: "No Faculty of Science reading week"
        scope: "calendar"
        rule: "The Faculty of Science has no reading week for this course calendar."
        evidence: ["src:calendar-a26"]
    },
    {
        id: "constraint:withdrawal-without-failure"
        label: "Withdrawal without failure deadline"
        scope: "calendar"
        rule: "The withdrawal-without-failure deadline is 2026-11-13."
        evidence: ["src:calendar-a26"]
    },
]
