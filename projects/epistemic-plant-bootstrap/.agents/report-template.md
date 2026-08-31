# epistemic-plant-bootstrap upstream impact report

## Run identity

- Run ID: `{{run_id}}`
- Monitor state: `{{monitor_state}}`
- Terminal state: `{{terminal_state}}`
- Qualification state: `{{qualification_state}}`
- Authority revision: `{{authority_revision}}`
- Publication revision: `{{publication_revision|not-yet-sealed}}`
- Subject revision: `{{subject_revision}}`
- Bootstrap baseline: `{{bootstrap_baseline}}`

## Subject authority

{{subject_authority}}

The subject repository provides context and subject-local semantic authority only where the selected profile declares it. It does not become Factory monitor authority.

## Source state

{{source_state}}

List each source/channel independently with its exact revision/ref and observed surface. Preserve unresolved states rather than manufacturing a comparison or qualification result.

## Authority separation

- Pinned source remains admission oracle: `{{pinned_source_oracle_preserved}}`
- GUAC remains observation-only: `{{guac_observation_only_preserved}}`
- CUE remains qualification authority: `{{cue_qualification_authority_preserved}}`
- Operational failure remains inconclusive: `{{operational_failure_inconclusive_preserved}}`

## Dependency and admission graph

{{dependency_and_admission_graph}}

Show the declared source observation → graph relation → local obligation → evidence/admission path. Do not infer propagation from names or paths alone.

## Correlation lineage

{{correlation_lineage}}

Preserve source document digest, admitted receipt, graph generation, and epistemic observation lineage. Volatile GUAC IDs, ordering, timestamps, and ports are not stable semantic identity.

## Critical

{{critical_items}}

## High

{{high_items}}

## Notes

{{note_items}}

## No local action

{{no_local_action_items}}

## Executable validation

- CUE execution: `{{cue_execution}}`
- Bootstrap execution: `{{bootstrap_execution}}`
- Experiment execution: `{{experiment_execution}}`

`terminal_success` does not imply executable qualification success. Report `qualification_state` independently and preserve unavailable execution as a coverage gap rather than an asserted pass.

## Publication

- Bundle: `{{bundle_path}}`
- Manifest: `{{manifest_path}}`
- Latest pointer: `{{latest_pointer_path}}`
- Export unit: directory

The immutable run directory is the canonical export. `manifest.json` is written after report, summary, and evidence; the latest pointer advances only after the manifest seals the bundle.
