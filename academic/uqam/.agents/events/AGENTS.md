# UQAM + Montréal student/community/technical events

This is the contracted daily condition-watch procedure for `academic.uqam.events`.

Semantic authority is `contracts/academic/uqam/events/`. Shared comparison-state vocabulary is in `contracts/state/comparison.cue`. Public pages, search results, organizer posts, acquired records, prior run bundles, and the admitted UQAM catalog are observations/context until admitted by this task contract. `academic.uqam.catalog` owns institutional/community entity identity; it does not decide event identity, relevance, comparison, or publication.

## Scope

Look for newly announced or materially updated events relevant to UQAM students and the surrounding Montréal technical/scientific community. Prioritize:

- student/community life: association and group fairs, rentrée activities, café/community programming, student-media events, workshops, assemblies, networking, volunteering, cultural and social activities with broad student relevance;
- computing, Python, Linux, open source, data, AI, security, science, research and digital-skills events;
- student clubs and groups, recurring technical communities, hackathons, seminars, open houses, commercialization events and technically relevant career/networking opportunities;
- UQAM central events, Portail étudiant student-life surfaces, Cœur des sciences, Pavillon Président-Kennedy, Faculté des sciences, Département d'informatique, AESSUQAM, AGEEI, SIA-UQAM, ElleCode ACM-WS UQAM, Sciences 101 and other current UQAM groups;
- student cafés, student media, Centre sportif/Citadins and other campus-community surfaces when they publish event-like activity;
- Montréal-Python, PyData Montréal, Linux/OSS communities, Montreal Machine Learning and other high-signal local technical groups.

Required UQAM discovery surfaces remain the central event calendar, `numerique.uqam.ca`, and `uqam.ca/information/diffusion/`. Keeping these required sources stable preserves continuity of the admitted event comparison contract.

For each run, also acquire useful optional primary surfaces where reachable:

- Portail étudiant `vie-etudiante`, activities/news and services;
- official associations, student-group category pages, student cafés and student-media directories;
- Faculté des sciences and Département d'informatique events/news;
- Centre sportif activities/events;
- organizer-owned pages for current associations/groups/media/cafés;
- other UQAM unit or Montréal community primary sources justified by the event scope.

Prefer organizer or institutional primary sources over aggregators.

## Catalog context

When `academic/uqam/catalog/state/admitted-baseline.json` exists and resolves to a valid admitted catalog run, it may be read as stable identity context.

Use catalog context only to:

- resolve an explicitly evidenced organizer to `organizer_entity_id`;
- resolve an explicitly evidenced venue/resource to `venue_entity_id`;
- discover organizer-owned primary surfaces already admitted by the catalog.

Do not infer an organizer/venue edge from name similarity. Do not suppress an otherwise valid event because it has no catalog projection. Catalog changes never directly produce an event delta.

## Run protocol

1. Read the current semantic event contract before acquisition.
2. Acquire the required discovery surfaces plus relevant optional primary organizer/community/student-life sources. Preserve source, channel, ref, observed surface, acquisition time and content digest for each observation.
3. Read the admitted UQAM catalog when valid and use it only as the bounded context described above.
4. Normalize the current event set according to `#NormalizedEvent`. Stable identity must not include mutable date/time, location, registration, scope or catalog projection fields. Prefer source event ID, then canonical primary URL, then the declared organizer/title/source fallback.
5. Read `academic/uqam/events/state/admitted-baseline.json` when present, then load the referenced immutable normalized run.
6. Determine comparison state:
   - no pointer: `bootstrap`;
   - same admitted schema and valid referenced run: `comparable`;
   - incompatible schema or unusable referenced run: `invalidated`.
7. Apply the profile comparison policy:
   - same stable identity with changed date/time, location, registration, scope, organizer/venue projection or other decision-relevant details is `changed`;
   - a newly observed stable identity is `added`;
   - a missing listing is `removed` state, but is not reportable unless a primary source confirms cancellation or another material change.
8. Derive the task outcome:
   - complete acquisition + `bootstrap` -> `baseline_established`;
   - complete acquisition + comparable state + no reportable delta -> `no_change`;
   - complete acquisition + comparable state + added/materially changed matches -> `new_matches`;
   - materially incomplete required acquisition -> `source_gap`;
   - invalidated comparison state -> `comparison_gap`;
   - failed compare-and-swap caused by an overlapping baseline advance -> `state_conflict`.
9. Persist the immutable run bundle under `academic/uqam/events/runs/<run-id>/`. Never replace an existing run directory.
10. Advance `academic/uqam/events/state/admitted-baseline.json` only when the decision says `advance`. Re-read the pointer immediately before publication and require the expected pointer generation and current file revision. Publish the run bundle and pointer in one fast-forward repository update when advancing. If another run advanced the pointer, do not overwrite it; return `state_conflict`.
11. Do not classify absence of a prior baseline as `source_gap`, and do not claim an empty delta on bootstrap.

## Bootstrap behavior

The first complete normalized acquisition establishes state only:

```text
acquisition
  -> normalized event set
  -> no admitted predecessor
  -> bootstrap
  -> immutable run bundle
  -> admitted baseline pointer
  -> baseline_established
```

`baseline_established` produces no event notification. It prevents the first comparable run from falsely reporting the entire current calendar as new.

## Output

Use `academic/uqam/.agents/events/report-template.md` for each admitted added or materially changed event.

Return a concise task-native outcome:

- `baseline_established`: first admitted comparison baseline created; do not notify;
- `no_change`: valid comparison completed with no reportable delta; do not notify;
- `new_matches`: report only admitted additions/material changes;
- `source_gap`: required acquisition was materially incomplete;
- `comparison_gap`: prior admitted comparison state is invalid/unusable;
- `state_conflict`: another run advanced state before this run could commit.

Do not write any other publication surface unless the contract is extended explicitly.
