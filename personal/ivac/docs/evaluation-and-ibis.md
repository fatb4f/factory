# IVAC evaluation and Ibis projection model

Status: executable contract surface.

## Boundary

The IVAC unit now has four distinct layers:

\`\`\`text
canonical evidence / review state
        ↓
relational projections
        ↓
graph-edge + logical-index transforms
        ↓
factory.analytics-ir
        ↓
Ibis
        ↓
evaluation-specific assessment
\`\`\`

CUE owns semantic meaning, authority boundaries, transform identity, evaluation questions, required dependencies and output constraints. Ibis is a lazy relational execution target. A DuckDB, Arrow or other backend may execute/materialize the Ibis expression, but no backend becomes IVAC semantic authority.

## Graph-edge projection

Clinical relations and normalized link relations project into one disposable \`graphEdges\` surface:

\`\`\`text
edgeID
edgeClass
subjectKind / subjectID
predicate
objectKind / objectID
assertionMode
attributedByID
temporal*
\`\`\`

The projection is derived from canonical records. It is not a second graph authority.

\`graphEdgeBindings\` describes how canonical relational surfaces contribute edge rows. The bindings cover clinical relations, episode membership, evidence provenance, capacity-support links and finding-evidence links.

## Logical indices

An IVAC index is a relation, not a backend physical index:

\`\`\`text
indexID
keyName
keyValue
memberKind
memberID
edgeID?
\`\`\`

The index contract is deliberately backend-neutral. Ibis may keep it lazy; DuckDB or another execution backend may choose its own physical indexing strategy without altering Factory semantics.

Initial index transforms are:

- \`edge-by-subject\`
- \`edge-by-object\`
- \`edge-by-predicate\`
- \`edge-by-evidence\`

## Edge transform primitives

The primitive vocabulary is intentionally small:

- \`select\` — retain edges by typed selector/runtime parameters;
- \`reverse\` — invert orientation without changing source authority;
- \`compose\` — join compatible edge endpoints into a derived relation;
- \`bounded-expand\` — repeated finite edge expansion with an explicit maximum depth;
- \`deduplicate\` — set-normalize a derived edge relation.

Named evaluation transforms are compositions/instances of those primitives:

- \`temporal-window\`
- \`episode-membership\`
- \`capacity-impact\`
- \`contradiction-surface\`
- \`causal-attribution-only\`
- \`evidence-neighborhood\`

The evidence transform is deliberately called a bounded neighborhood rather than an unqualified transitive closure. Portable Ibis execution does not assume recursive SQL support.

## Analytics IR lowering

\`factory.analytics-ir/v1\` now includes the relational operations needed by graph/index work:

\`\`\`text
project
rename
filter
join
semi-join
anti-join
distinct
union
intersect
difference
group
aggregate
grain-change
order
window
derive
\`\`\`

The Ibis adapter lowers those operations to Ibis expressions. Domain transform contracts declare which analytical operations are required but do not embed backend-specific SQL.

## Evaluation contracts

Each evaluation contract now declares:

- semantic version;
- selected normalized profile partitions;
- required relational surfaces;
- edge transforms;
- logical indices;
- evaluation questions;
- transform/index dependency for each question;
- evaluator authority;
- allowed and forbidden output kinds;
- invariants.

The four current contracts are:

\`\`\`text
permanent-sequela
gp-addendum
neuroscience-expertise
legal-review
\`\`\`

Clinical contracts may emit clinical assessments, finding candidates and coverage gaps. The legal-review contract may emit legal-ground candidates and coverage gaps but is structurally forbidden from emitting clinical assessments/findings.

## Private case binding

Personally identifying case state does not belong in this repository. The private case bundle should bind:

\`\`\`text
EvidenceWorld
NormalizedSubjectProfile
evaluation instance parameters
source artifact identifiers
\`\`\`

to this public schema. Evaluation-specific cutoffs and question parameters remain evaluation-instance data and never rewrite canonical longitudinal history.
