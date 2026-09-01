# UQAM institutional and community catalog

This is the contracted catalog procedure for `academic.uqam.catalog`.

Semantic authority is `contracts/academic/uqam/catalog/`. Shared comparison-state vocabulary is in `contracts/state/comparison.cue`. Public pages, organizer pages, acquired records, prior normalized runs, search results, and model conclusions are observations until admitted by this task contract.

## Objective

Maintain a source-qualified graph of the UQAM substrate that student/community events can project onto.

The catalog is deliberately separate from `academic.uqam.events`:

```text
official UQAM / organizer surfaces
        ↓
catalog acquisition
        ↓
normalized entities + explicit relations
        ↓
admitted catalog baseline

event discovery surfaces
        ↓
academic.uqam.events
        ↓
event observations
        ↓
optional references to admitted catalog entity IDs
```

The catalog does not decide whether an event is new. The event task does not define institutional identity.

## Required discovery surfaces

Acquire all of these on each due run:

- `uqam-student-services` — `https://portailetudiant.uqam.ca/services/`
- `uqam-student-life` — `https://portailetudiant.uqam.ca/vie-etudiante/`
- `uqam-student-associations` — the official Portail étudiant associations directory
- `uqam-student-groups` — the official student-groups index
- `uqam-student-cafes` — the official student-cafés directory
- `uqam-student-media` — the official student-media directory

Expand every current student-group category page reachable from the official group index. Normalize all currently listed groups that have enough source information to establish stable identity.

## Priority academic/community acquisition

Also acquire current official primary surfaces for useful known substrate when available:

- UQAM / Portail étudiant / Services à la réussite et à la vie étudiante;
- Faculté des sciences and its departments, especially Département d'informatique;
- academic program and calendar discovery surfaces where they provide stable institutional nodes;
- Boîte à outils numérique, computer laboratories, seminars and major student technology platforms;
- Service des bibliothèques and materially useful study/technology spaces;
- BIRÉ, student-success, accessibility and accommodated-exam services;
- financial-aid and scholarship/RIBÉ services;
- Centre sportif, Citadins and high-signal student recreation resources;
- faculty associations, program associations when current official identity is available;
- student cafés and their operating faculty associations;
- student media and recognized student/community groups.

Prefer official UQAM or organizer-owned sources. Third-party/social pages may corroborate contact or activity, but must not replace an available institutional identity source.

## Normalization

Normalize into `#NormalizedSnapshot`.

For every entity preserve:

```text
stable entity id
kind
canonical source name
status
optional category / description
primary URL when known
location when explicitly published
audience when explicitly published
one or more source-qualified evidence observations
```

For every relation preserve:

```text
stable relation id
typed edge
from entity id
to entity id
source-qualified evidence
```

Only emit graph edges explicitly supported by evidence. Do not infer `part-of`, `operated-by`, `represents`, `supported-by`, or another relation because names appear related.

A page saying that a café is under a named faculty association supports `cafe -> operated-by -> association`. A page naming a department under a faculty supports `department -> part-of -> faculty`. Naming similarity by itself supports nothing.

## Identity

Prefer a durable source-defined identifier. Otherwise derive an ID from canonical entity kind plus canonical source name and retain the source URL as evidence.

Mutable fields such as location, description, contact information and status do not define identity.

Never merge two groups, services or associations because their acronyms or names resemble one another.

## Comparison

Read `academic/uqam/catalog/state/admitted-baseline.json` when present and load its referenced immutable `normalized.json`.

- no pointer -> `bootstrap`;
- compatible baseline -> `comparable`;
- incompatible/unusable baseline -> `invalidated`.

Compare entities by stable entity ID and relations by stable relation ID.

Classify additions, material entity changes, removals, relation additions/changes/removals. Treat disappearance from an optional source conservatively: do not remove a previously admitted entity unless required acquisition is complete and the authoritative source establishes that the entity is no longer current or the relevant directory no longer lists it after a complete traversal.

Outcomes:

- complete acquisition + bootstrap -> `baseline_established`;
- complete acquisition + comparable + identical admitted graph -> `no_change`;
- complete acquisition + comparable + material graph delta -> `catalog_changed`;
- incomplete required acquisition -> `source_gap`;
- invalid comparison state -> `comparison_gap`;
- failed compare-and-swap -> `state_conflict`.

## Publication

Persist each run under:

`academic/uqam/catalog/runs/<run-id>/`

with:

- `normalized.json`
- `decision.json`
- `manifest.json`

`manifest.json` seals the normalized and decision digests and is written last.

Advance `academic/uqam/catalog/state/admitted-baseline.json` only when the decision says `advance`. Re-read the pointer immediately before publication and require the expected generation and current file revision. Publish the immutable run and pointer in one fast-forward update. Never overwrite an existing run directory.

The admitted catalog baseline is context for other UQAM tasks, not semantic authority for them.

## Output

Return only the task-native outcome plus a compact count summary:

```text
outcome
entities total / added / changed / removed
relations total / added / changed / removed
source gaps, if any
run id
```
