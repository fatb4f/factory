package ivaceval

import ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"

// These are model execution lenses, NOT actor kinds or professional credentials.
#MedicoLegalLens:
    "medico-legal-analyst" |
    "ivac-legal-analyst" |
    "claimant-advocate" |
    "adversarial-reviewer" |
    "evidence-auditor"

#MedicoLegalRoleRun: close({
    role: #MedicoLegalLens
    state: "pending" | "complete"
    issueIDs: [...ivac.#ID]
    rationale: string & !=""
    if state == "pending" {issueIDs: []}
})

#MedicoLegalSource: close({
    id: ivac.#ID
    kind: "legal-citation" | "clinical-evidence" | "clinical-finding"
    citation?: ivac.#RegulatoryCitation
    evidence?: ivac.#EvidenceArtifactRef
    finding?: ivac.#FindingRef
    if kind == "legal-citation" {
        citation: ivac.#RegulatoryCitation
        evidence?: _|_
        finding?: _|_
    }
    if kind == "clinical-evidence" {
        evidence: ivac.#EvidenceArtifactRef
        citation?: _|_
        finding?: _|_
    }
    if kind == "clinical-finding" {
        finding: ivac.#FindingRef
        citation?: _|_
        evidence?: _|_
    }
})

#MedicoLegalPosition: close({
    theory: string & !=""
    reasoning: string & !=""
    sourceIDs: [...ivac.#ID]
    limitations: [...(string & !="")]
})

#MedicoLegalIssue: close({
    id: ivac.#ID
    axis: ivac.#ClaimAxisRef
    raisedBy: #MedicoLegalLens
    category:
        "clinical-function" |
        "clinical-causation" |
        "regulatory-interpretation" |
        "procedural" |
        "evidence-integrity" |
        "unit-overlap" |
        "percentage-method"
    question: string & !=""
    basis: "source-observed" | "inferred" | "arguable" | "insufficient-evidence"
    confidence: "source-backed" | "plausible" | "speculative" | "contradicted"
    sources: [string]: #MedicoLegalSource
    favorable: #MedicoLegalPosition
    restrictive: #MedicoLegalPosition
    coverageGaps: [...(string & !="")]
    clinicalQualification: "not-determined"
    legalQualification: "not-determined"
    adjudication: "not-determined"
    if basis == "insufficient-evidence" {
        coverageGaps: [string & !="", ...(string & !="")]
    }
})

// A draft is *always* an internal candidate. It cannot sign itself, issue a
// clinical finding, author a legal ground, submit, or adjudicate.
#MedicoLegalReviewDraft: close({
    apiVersion: "ivac.medico-legal-review/v1"
    kind: "MedicoLegalReviewDraft"
    id: ivac.#ID
    usage: "synthetic-test" | "private-assessment"
    case: ivac.#ValidatedCasePlant
    profile: ivac.#SubjectProfileRef
    roles: close({
        "medico-legal-analyst": #MedicoLegalRoleRun & {role: "medico-legal-analyst"}
        "ivac-legal-analyst": #MedicoLegalRoleRun & {role: "ivac-legal-analyst"}
        "claimant-advocate": #MedicoLegalRoleRun & {role: "claimant-advocate"}
        "adversarial-reviewer": #MedicoLegalRoleRun & {role: "adversarial-reviewer"}
        "evidence-auditor": #MedicoLegalRoleRun & {role: "evidence-auditor"}
    })
    issues: [string]: #MedicoLegalIssue
    workProduct: "internal-analytical-candidate"
    professionalStatus: "not-reviewed"
    disclosure: "not-authorized"
    submission: "not-authorized"
    adjudication: "not-determined"

    if id != "" {
        _profile: profile & {id: case.profile.id}
        _roleIntegrity: [for roleID, run in roles {
            _identity: run & {role: roleID}
            _issues: [for ref in run.issueIDs {
                _matches: [for issueID, issue in issues if issueID == ref {
                    issue & {raisedBy: run.role}
                }] & [_, ...]
            }]
        }]
        _issueIntegrity: [for issueID, issue in issues {
            let expectedID = issueID
            _identity: issue & {id: expectedID}
            _axis: [for axisID, axis in case.review.axes if axisID == issue.axis.id {
                axis & {id: axisID}
            }] & [_, ...]
            _sources: [for sourceID, source in issue.sources {
                let expectedSourceID = sourceID
                _identity: source & {id: expectedSourceID}
                if source.kind == "clinical-evidence" {
                    _evidence: [for evidenceID, artifact in case.review.evidence if evidenceID == source.evidence.id {
                        _axis: [for axisRef in artifact.axes if axisRef.id == issue.axis.id {axisRef}] & [_, ...]
                    }] & [_, ...]
                }
                if source.kind == "clinical-finding" {
                    _finding: [for findingID, finding in case.review.findings if findingID == source.finding.id {
                        finding & {axis: issue.axis}
                    }] & [_, ...]
                }
                // Legal citation slices must be checked against pinned bytes by
                // the existing source verifier; type validation alone is not provenance.
            }]
            _readings: [for position in [issue.favorable, issue.restrictive] {
                _references: [for ref in position.sourceIDs {
                    _matches: [for sourceID, source in issue.sources if sourceID == ref {source}] & [_, ...]
                }]
            }]
        }]
    }
})

// These are *links to existing, independently authored records*, not a model
// endorsement. External authentication and professional mandate checks remain
// required before relying on the linked record.
#MedicoLegalClinicalReviewLink: close({
    draft: #MedicoLegalReviewDraft
    issueID: ivac.#ID
    reviewer: ivac.#ActorRef
    finding: ivac.#FindingRef
    linkKind: "existing-clinical-finding"
    professionalVerification: "external-required"
    adjudication: "not-determined"
    if issueID != "" {
        _issue: [for id, issue in draft.issues if id == issueID {issue}] & [_, ...]
        _actor: [for id, actor in draft.case.review.actors if id == reviewer.id {
            actor & {kind: "medical-expert" | "treating-clinician"}
        }] & [_, ...]
        _finding: [for id, f in draft.case.review.findings if id == finding.id {
            f & {producer: reviewer, axis: _issue[0].axis}
        }] & [_, ...]
    }
})

#MedicoLegalLegalReviewLink: close({
    draft: #MedicoLegalReviewDraft
    issueID: ivac.#ID
    reviewer: ivac.#ActorRef
    ground: ivac.#ReviewGroundRef
    linkKind: "existing-counsel-review-ground"
    professionalVerification: "external-required"
    adjudication: "not-determined"
    if issueID != "" {
        _issue: [for id, issue in draft.issues if id == issueID {issue}] & [_, ...]
        _actor: [for id, actor in draft.case.review.actors if id == reviewer.id {
            actor & {kind: "legal-representative"}
        }] & [_, ...]
        _ground: [for id, g in draft.case.review.grounds if id == ground.id {
            g & {author: reviewer, axis: _issue[0].axis}
        }] & [_, ...]
    }
})

medicoLegalReviewContract: close({
    id: "personal.ivac.medico-legal-review"
    version: "1.0.0"
    companionTo: ["permanent-sequela", "legal-review"]
    authority: "cue"
    producer: "model-analytical-candidate"
    outputRoot: "#MedicoLegalReviewDraft"
    clinicalReviewLink: "#MedicoLegalClinicalReviewLink"
    legalReviewLink: "#MedicoLegalLegalReviewLink"
    admission: "never-automatic"
    projection: "downstream-of-factory.analytics-ir/v1"
})
