package inf1035a26

assessments: [
    {id: "assessment:tp1", label: "TP1", kind: "practical-work", weight_percent: 10, release_date: "2026-09-29", due_date: "2026-10-20", due: "fixed", evidence: ["src:calendar-a26"]},
    {id: "assessment:midterm", label: "Examen intra", kind: "exam", weight_percent: 35, date: "2026-10-27", due: "fixed", evidence: ["src:calendar-a26"]},
    {id: "assessment:tp2", label: "TP2", kind: "practical-work", weight_percent: 10, release_date: "2026-11-03", due_date: "2026-11-24", due: "fixed", evidence: ["src:calendar-a26"]},
    {id: "assessment:tp3", label: "TP3", kind: "practical-work", weight_percent: 10, release_date: "2026-12-01", due_date: "2026-12-22", due: "fixed", evidence: ["src:calendar-a26"]},
    {id: "assessment:final", label: "Examen final", kind: "exam", weight_percent: 35, date: "2026-12-22", due: "fixed", evidence: ["src:calendar-a26"]},
]

assessmentWeightTotal: 100
_assessmentWeightInvariant: (10 + 35 + 10 + 10 + 35) & assessmentWeightTotal
