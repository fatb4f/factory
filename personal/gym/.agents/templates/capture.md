# In-session capture

Accept terse natural language. Preserve the user's fact/interpretation boundary.

Example input:

> GHR first set 6. Blue band. Clean until final inch; medial ham was limiter. No lumbar pickup.

Normalize only supported observations:

- exercise and set sequence;
- repetitions;
- assistance;
- ROM stage/qualifier when mappable;
- mechanical constraint states;
- limiter region/kind/onset when stated;
- linked measurements/media.

Do not emit `right-adductor-weak`, `neurological-recruitment-problem`, `pelvis-fixed`, readiness, or adaptation assertions from capture text.

If a value is approximate, mark `provenance.certainty: approximate` rather than inventing precision.

If the user corrects a prior value, append the replacement record and a `#Supersession` link. Do not silently rewrite history.
