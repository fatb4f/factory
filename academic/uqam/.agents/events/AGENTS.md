# UQAM + Montréal technical events

This is the contracted daily condition-watch procedure for `academic.uqam.events`.

Semantic authority is `contracts/academic/uqam/events/`. Shared comparison-state vocabulary is in `contracts/state/comparison.cue`. Public pages, search results, organizer posts, acquired records, and prior run bundles are observations until admitted by this task contract.

## Scope

Look for newly announced or materially updated events relevant to UQAM and the surrounding Montréal technical/scientific community. Prioritize:

- computing, Python, Linux, open source, data, AI, security, science, and research;
- student clubs, recurring technical communities, hackathons, workshops, seminars, open houses, commercialization events, and technically relevant career/networking opportunities;
- UQAM central events, Cœur des sciences, Pavillon Président-Kennedy, Faculté des sciences, Département d'informatique, AGEEI, AESSUQAM, SIA-UQAM, and other relevant student groups;
- Montréal-Python, PyData Montréal, Linux/OSS communities, Montreal Machine Learning, and other high-signal local technical groups.

Required UQAM discovery surfaces are the central event calendar, `numerique.uqam.ca`, and `uqam.ca/information/diffusion/`. Prefer organizer or institutional primary sources over aggregators when available.

## Run protocol

1. Read the current semantic contract before acquisition.
2. Acquire the required discovery surfaces plus useful optional organizer/community sources. Preserve source, channel, ref, observed surface, acquisition time, and content digest for each observation.
3. Normalize the current event set according to `#NormalizedEvent`. Stable identity must not include mutable date/time, location, registration, or scope fields. Prefer source event ID, then canonical primary URL, then the declared organizer/title/source fallback.
4. Read `academic/uqam/events/state/admitted-baseline.json` when present, then load the referenced immutable normalized run.
5. Determine comparison state:
   - no pointer: `bootstrap`;
   - same admitted schema and valid referenced run: `comparable`;
   - incompatible schema or unusable referenced run: `invalidated`.
6. Apply the profile comparison policy:
   - same stable identity with changed date/time, location, registration, scope, or decision-relevant details is `changed`;
   - a newly observed stable identity is `added`;
   - a missing listing is `removed` state, but is not reportable unless a primary source confirms cancellation or another material change.
7. Derive the task outcome:
   - complete acquisition + `bootstrap` -> `baseline_established`;
   - complete acquisition + comparable state + no reportable delta -> `no_change`;
   - complete acquisition + comparable state + added/materially changed matches -> `new_matches`;
   - materially incomplete required acquisition -> `source_gap`;
   - invalidated comparison state -> `comparison_gap`;
   - failed compare-and-swap caused by an overlapping baseline advance -> `state_conflict`.
8. Persist the immutable run bundle under `academic/uqam/events/runs/<run-id>/`. Never replace an existing run directory.
9. Advance `academic/uqam/events/state/admitted-baseline.json` only when the decision says `advance`. Re-read the pointer immediately before publication and require the expected pointer generation and current file revision. Publish the run bundle and pointer in one fast-forward repository update when advancing. If another run advanced the pointer, do not overwrite it; return `state_conflict`.
10. Do not classify absence of a prior baseline as `source_gap`, and do not claim an empty delta on bootstrap.

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
