# Cyber Incidents

The project has two monitoring streams. Both use the same CUE contracts for acquiring sources and analyzing what those sources establish.

| Role | Stream | Example |
| --- | --- | --- |
| Primary | Major cyber incidents worldwide | [Replay a synthetic utility outage](global-major-cyber/replay.json) |
| Secondary | Canadian surveillance developments, including legislation and oversight | [Review a synthetic Canadian oversight bulletin](canadian-surveillance/review.json) |

The Canadian example records the committee's announcement as a public claim and leaves technical observations empty.

## Original request

> Anyway, perfect. So um, basically, okay, so we have two big pieces. Like, we have the Uh. the Uh. first the the the the sources and the the acquisition and then we have the the bigger model. Uh. Can you generate two two contracts, one for each linking the two um, add them to, excuse me. Um, basically Uh. switch to work mode, and Uh. in the factory repo Uh. create a cyber incidence Uh. structure and add our our main Uh. global major major cyber incidents and a secondary Uh. Canadian focused surveillance. And basically just Um. create the Uh. the basic, the basic Q contracts, and we'll start with that

## What we agreed

Keep three linked rails so a public account can be compared with the evidence without becoming evidence of an actor or motive on its own.

| Rail | What it records | Starter boundary |
| --- | --- | --- |
| Public reporting | Mainstream coverage, official statements, and corrections | Keep the original assertion, citation, revision, and lineage. Repetition of one dispatch is not independent corroboration. |
| Technical evidence | Sourced detection, indicators, documented impact, containment, and forensic findings | Keep the first alert, initial access, affected assets, and disclosure dates distinct. A shutdown does not identify the detection trigger or the attacker’s effect. |
| Strategic assessment (shadow rail) | Candidate explanations for objective, actor, sponsorship, and historical playbook resemblance | Link supporting and contradictory observations. Keep profit, strategic leverage, mixed motives, and insufficient evidence open when supported. Similarity is not attribution, and public silence is not proof. |

The Wyoming discussion illustrated the distinction between **not publicly disclosed**, **under investigation**, and **unknown**. Store the status and the reason, not a fabricated indicator, zero-day, or attribution. Use dated source revisions to replay what was knowable at the time. Compare changing tactics as overlapping patterns rather than as a single linear progression. A shared technique or tool is not an actor fingerprint.

Historical benchmark candidates include Stuxnet, WannaCry and NotPetya, Olympic Destroyer, Triton, and Pegasus. EternalBlue belongs in the benchmark as a reused tool or capability reference, not as a separate attributed incident. Use these as curation leads, not ground truth. Confirm dates, observations, and attribution independently before adding them to a fixture.

## Contracts

- [Acquisition](../../contracts/projects/cyber-incidents/acquisition.cue) describes the source, channel, acquisition method, captured revision, digest, availability evidence, lineage, and coverage gaps.
- [Incident bundle](../../contracts/projects/cyber-incidents/incident.cue) links public claims and technical observations to source captures, and strategic assessments to those assertions. Historical replay checks the cutoff for all included assertions, their cited revisions, and each hypothesis assessment. Review mode can retain later assessments without representing them as available at the replay cutoff. It rejects citations with undocumented availability. Retrospective capture is allowed when the earlier availability of the exact cited revision is documented.

The handoff is `#IncidentBundle.acquisition`, which takes a complete `#Acquisition` record. For example, in the global replay, the public claim `outage-report` cites paragraph 1 of capture `dispatch`. That capture names source `news` and records the digest of the cited revision. Removing either the capture or its source makes the bundle fail validation.

| Interface | Intended role |
| --- | --- |
| [OASIS STIX 2.1](https://docs.oasis-open.org/cti/stix/v2.1/os/stix-v2.1-os.html) | Preferred interchange. Preserve original object IDs, versions, markings, and extensions during conversion. |
| [OASIS STIX 2.0](https://docs.oasis-open.org/cti/stix/v2.0/stix-v2.0.html) and [MISP JSON](https://www.misp-standard.org/) | Inbound compatibility through explicit, tested adapters. Keep raw originals and report conversion loss rather than flattening provenance. |
| [OASIS TAXII 2.1](https://docs.oasis-open.org/cti/taxii/v2.1/os/taxii-v2.1-os.html) | Transport for supported STIX collections, not the incident schema. |
| [MITRE ATT&CK](https://attack.mitre.org/resources/attack-data-and-tools/) and [DISARM](https://github.com/DISARMFoundation/DISARMframeworks) | Versioned enrichment references. A catalog mapping is not evidence that a technique was used in an incident. |

Public reports and hypotheses stay native to the CUE model. Adapters can project sourced narrative as STIX Reports or Notes when appropriate. Preserve claim-level provenance and hypothesis status through the native record or an explicit extension. Never export a candidate actor relationship as an established one.

## Starter data stack

| Layer | Role |
| --- | --- |
| CUE | Canonical schema and cross-record admission checks, including source references and replay cutoffs. |
| JSON Schema and Pydantic v2 | Derive transport shapes and Python types from CUE. Validate and parse data at the adapter boundary without maintaining a second hand-written domain schema. Revalidate assembled bundles in CUE. |
| Python and uv | Keep acquisition, normalization, and replay projection in testable Python modules. Use uv to manage the runtime and lock dependencies when the first adapter lands. |
| xonsh | Operator shell for composing capture, normalization, validation, and replay commands. Keep the checks usable from ordinary shells and CI without xonsh. |
| Arrow and DuckDB | Proposed downstream analytical projections for querying source lineage and comparing incident histories. They do not own schema semantics or admit evidence. |

The first runtime slice is one fixture-backed, read-only adapter. It retains the original source and revision, parses the input in Python, checks the assembled bundle in CUE, and emits a separate as-of replay projection. This PR documents the stack without installing runtime dependencies, generating models, or enabling live feeds.

## Implementation order

1. Qualify representative source revisions and adapter fixtures. Capture inputs and their digests before normalization. Record access, parsing, or coverage failures separately.
2. Generate JSON Schema and Python types from the CUE shapes, then build read-only adapters. Run CUE at the admission boundary. Generated types are not a substitute for cross-record validation, and validation does not verify the source assertions.
3. Add a deterministic replay projection. Provide only eligible assertions and their cited material to the model. Exclude retrospective assessments, untimed open questions, unselected captures, and later labels from model inputs.
4. Benchmark against a rules-only baseline. Keep related campaigns together across splits. Use separate validation for tuning and reserve the test set for final evaluation. Measure late-evidence leakage, false attribution, abstention, and calibration before considering any integration.

No adapters, live feeds, generated types, graph admission, or registry entries are implemented in this scaffold.

## Local check

From the repository root with CUE v0.16 and Python 3 available:

```sh
cue export ./contracts/projects/cyber-incidents -e watchStreams
python3 contracts/projects/cyber-incidents/testdata/check.py
```

The repository-wide `bash scripts/validate-contracts.sh` also vets this package and runs the fixture checks in CI. Both example bundles use synthetic sources and events.
