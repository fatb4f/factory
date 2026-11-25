# Hourly Cyber Incident Watch

Run the enabled `projects.cyber-incidents.upstream-monitor` entry from current Factory main. Read the shared upstream-monitor procedure and contract, every CUE file under `profiles_cyber_incidents`, and the local report template. Read the latest sealed run, and search earlier evidence by stable item ID before acquiring deltas. The hourly automation owns this invocation. The weekly dispatcher selects weekly tasks.

## Acquire and compare

1. Check dated victim disclosures, vendor revisions, CISA KEV, the Canadian Cyber Centre, CERTs and relevant regulator filings for new incidents, reported exploitation, remediation and downstream consequences. Fetch KEV JSON by revision and compare by CVE. For an oversized index, use bounded pages or dated individual advisories. Keep event, disclosure, update and acquisition dates distinct.
2. Independently check federal, Québec and Montréal sources in English and French for changes in public powers, rights, commercial profiling, oversight and safeguards. Include amendments in unrelated bills, court rulings, regulations, commencement orders, public procurement and documented use. Track C-297 clauses, C-22 committee reports, C-8 commencement, C-36 oversight and the OPC pricing consultation. Compare the version with current law. Identify actor, authority, provision, threshold, data, authorizer, safeguards, effective date and Montréal applicability where established. Record missing details. Distinguish tender, award, deployment and use.
3. Rotate Québec, intelligence oversight, procurement and public community channels within retrieval limits. Revisit unresolved gaps. Use technical research, news, bilingual copies and public discussions as discovery. Attribute leads, check their underlying sources, and group repeated dispatches by provenance. Limit collection to public disclosures. Keep independent source identity even when several records describe one event.
4. Route each item to its contracted stream. Reuse a stable item ID when new evidence concerns the same incident, bill and session, or consultation. Record the basis for correlation. Separate public assertions, policy stages, impacts and disputed interpretations. A revised advisory can strengthen one record. Exploitation on unnamed sites establishes neither named victims nor local exposure. Relate Factory to a record only through a documented dependency. Foreign precedents need their own sources and remain comparative context.
5. Capture the exact source, scoped channel, URL, record ID, version, dated event or publication when known, locator within the record, and UTC check time. Add newly encountered publishers in `additionalSources`; use primary for their own disclosures and reporting/community for leads. Attribute secondary assertions. Mark material acquisition failures and the next recovery action. A partial scan cannot establish an empty period.

## Publish

Use the fixed report sections and `#RunEvidence` in the selected profile. Use `material` for a verified material change, `baseline` for first coverage, and `lead` for unresolved reporting. Publish a new run for a material change, initial baseline, or changed material coverage gap. Carry only new or revised items. If comparison finds no change, leave the current run and pointer in place and suppress notification.

Prepare the evidence JSON outside the worktree. Set `authority_revision` to the exact commit read and `previous_run` to the latest sealed ID (null only at initial publication). From the repository root with Python and CUE on PATH, run:

```sh
python3 projects/cyber-incidents/upstream-monitor/publish.py /path/to/evidence.json
python3 projects/cyber-incidents/upstream-monitor/publish.py --check
```

The publisher vets the input, renders per-stream views, seals the canonical directory by Git blob SHA, and writes the pointer last. Publish the run, stream views and pointer together via a fast-forward guarded update or repository-policy PR. Re-read main and verify the pointer and manifest before claiming publication. On concurrent publication, compare again against the winner before staging any remaining delta. Corrections use a new run. If evidence cannot be vetted, stored or verified, report the specific gap and preserve the last sealed baseline. Structural validation qualifies the files. It supplies no finding about a local deployment and admits no graph edge.
