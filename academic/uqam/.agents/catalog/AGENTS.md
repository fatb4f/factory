# UQAM institutional and community catalog

This is the contracted catalog procedure for `academic.uqam.catalog`.

Semantic authority is `contracts/academic/uqam/catalog/`. Shared comparison-state vocabulary is in `contracts/state/comparison.cue`. Public pages, organizer pages, acquired records, prior normalized runs, search results, and model conclusions are observations until admitted by this task contract.

## Objective

Maintain a source-qualified graph of the UQAM academic/student/community substrate that event and analytical projections can reference without taking authority over institutional identity.

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

Expand every current student-group category page reachable from the official group index. Record traversal of all contract-declared categories and normalize every currently listed group/media identity for which the official page provides enough information to establish a stable identity. If a required category cannot be traversed, acquisition is incomplete even when the top-level group index is reachable.

Represent the seven directory categories as `group-category` entities when the source provides stable category surfaces. Link a listed group/media item to its category only with an explicit `categorized-as` edge supported by that category page.

## Priority academic/community acquisition

Also acquire current official primary surfaces for useful known substrate when available:

- UQAM / Portail étudiant / Services à la réussite et à la vie étudiante;
- Faculté des sciences and its departments, especially Département d'informatique;
- stable academic-program and course identities from official program/course catalog surfaces;
- academic calendars and durable academic-policy discovery surfaces;
- Boîte à outils numérique, computer laboratories, seminars and major student technology platforms;
- Service des bibliothèques and materially useful study/technology/community spaces;
- BIRÉ, student-success, accessibility and accommodated-exam services;
- financial-aid and scholarship/RIBÉ services;
- Centre sportif, Citadins and high-signal student recreation resources;
- faculty associations and program associations when current official identity is available;
- student cafés and their operating faculty associations;
- student media and recognized student/community groups.

For academic courses, keep the stable course identity separate from term-specific offering/schedule state. A course code may be a durable `course` entity; a particular section, enrolment state, room or session schedule is not folded into that identity merely because it appears on a current timetable. Do not normalize user-specific registration state into the institutional catalog.

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

Only emit graph edges explicitly supported by evidence. Do not infer `part-of`, `operated-by`, `represents`, `supported-by`, `offered-by`, `categorized-as`, `accessed-via`, or another relation because names appear related.

Examples of admissible projection:

```text
student café -> operated-by -> faculty association
student group -> categorized-as -> official group category
department -> part-of -> faculty
course -> offered-by -> academic unit
service -> accessed-via -> platform
```

Each edge still requires evidence that explicitly establishes that relationship. Naming similarity by itself supports nothing.

## Identity

Prefer a durable source-defined identifier. Otherwise derive an ID from canonical entity kind plus canonical source name and retain the source URL as evidence.

Mutable fields such as location, description, contact information, current hours and status do not define identity.

Course identity should prefer the official course code. Academic-program identity should prefer the official program code when present. Never merge two groups, services, programs, courses or associations because their acronyms or names resemble one another.

## Comparison

Read `academic/uqam/catalog/state/admitted-baseline.json` when present and load its referenced immutable `normalized.json`.

- no pointer -> `bootstrap`;
- compatible baseline -> `comparable`;
- incompatible/unusable baseline -> `invalidated`.

Compare entities by stable entity ID and relations by stable relation ID.

Classify additions, material entity changes, removals, relation additions/changes/removals. Treat disappearance conservatively: do not remove a previously admitted entity unless required acquisition is complete and an authoritative source establishes that the entity is no longer current, or the relevant required directory no longer lists it after a complete traversal.

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
group categories traversed
source gaps, if any
run id
```
