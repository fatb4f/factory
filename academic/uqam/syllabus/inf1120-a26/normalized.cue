package inf1120a26

import syllabus "github.com/fatb4f/factory/contracts/academic/uqam/syllabus"

normalized: syllabus.#NormalizedSyllabus & {
    schema: "uqam-syllabus/v1"
    course: course
    sources: sources
    materials: materials
    concepts: concepts
    weeks: weeks
    assessments: assessments
    constraints: constraints
    relations: relations
    issues: issues
}
