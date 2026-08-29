# Factory Tracker and ChatGPT Runtime Architecture

Status: proposed

## 1. Objective

Factory should evolve from a scheduler that records opaque task outcomes into a dispatcher operating over normalized runs and durable, per-unit issue state.

The target control loop is:

```text
shared clock
    ↓
registry
    ↓
task admission
    ↓
environment resolution
    ↓
task-native execution
    ↓
normalized run
    ↓
domain correlation
    ↓
project issue projection
    ↓
tracker reconciliation
    ↓
dispatcher decision
    ↓
next execution
```

The tracker does not replace project or profile semantic authority.

The ChatGPT container environment does not become semantic authority.

Both are execution/control substrates operating downstream of contracts.

---

## 2. Authority boundaries

The architecture distinguishes six layers.

```text
Factory registry
    ↓
task/profile authority
    ↓
execution environment
    ↓
task-native observations
    ↓
normalized run + domain correlation
    ↓
project issue + dispatcher state
```

### 2.1 Factory registry

`registry.cue` remains responsible for:

- unit identity;
- task identity;
- semantic-authority location where applicable;
- agent/procedure location;
- enabled state;
- scheduling cadence.

It does not define project semantics.

### 2.2 Task/profile authority

Normative semantics remain at the narrowest authoritative layer.

Examples:

```text
contracts/workers/upstream-monitor/
    shared upstream-monitor vocabulary/invariants

contracts/workers/upstream-monitor/profiles_ctrl/
    ctrl-specific intelligence contract

contracts/workers/upstream-monitor/profiles_epistemic_plant_bootstrap/
    epistemic-specific intelligence contract

contracts/world/industrial-constraints/
    industrial-constraints relational/domain authority
```

A task determines:

- what can be observed;
- which sources are admissible;
- which relations are meaningful;
- which claims may be established;
- what constitutes qualification;
- what constitutes a project-relevant issue.

### 2.3 Execution environment

The ChatGPT runtime environment supplies executable capabilities.

It may contain:

- CUE;
- Go;
- OpenSSF and adjacent software-supply-chain tooling;
- GUAC;
- SBOM tooling;
- SLSA/Sigstore tooling;
- Python;
- Ibis;
- DuckDB;
- Arrow;
- Polars;
- BigQuery libraries and adapters;
- document/data acquisition utilities.

Tool availability establishes only execution capability.

It establishes no semantic fact.

### 2.4 Observations

Tool outputs are observations.

Examples include:

```text
GitHub response
SBOM
GUAC relation
Scorecard result
SLSA verification
analyzer output
BigQuery result
DuckDB query result
Ibis relation
GDELT record
document extraction
API response
runtime probe
```

They become usable Factory evidence only through task-defined normalization and admission.

### 2.5 Normalized runs

A normalized run is the immutable dispatcher-facing representation of one completed task execution.

It preserves task-native semantics rather than replacing them.

### 2.6 Project issues

A project issue is durable operational state describing a continuing project concern derived from one or more normalized runs.

An issue is not itself evidence that its claims are true.

---

# 3. State model

Factory should distinguish three major state classes.

```text
Run ledger
    immutable execution history

Issue substrate
    durable project concerns

Dispatch state
    executable next actions
```

## 3.1 Run

A run represents one execution.

```cue
#NormalizedRun: {
    id:       string
    task:     string
    unit:     string
    started:  string
    finished: string

    environment?: #EnvironmentRef

    observations: [...#ObservationRef]
    evidence:     [...#EvidenceRef]
    claims:       [...#ClaimRef]

    outcome: #TaskOutcome

    coverage?: [...#CoverageState]
}
```

The exact task outcome remains task-defined.

Normalization supplies a common envelope for correlation and tracking.

A normalized run must preserve sufficient provenance to recover:

```text
source
+ channel
+ revision/ref
+ observed surface
+ acquiring tool/environment
+ evidence object
```

Runs are immutable once admitted.

## 3.2 Issue candidate

Correlation produces candidates rather than directly mutating tracker state.

```cue
#IssueCandidate: {
    unit: string

    key: string

    class: string

    subject: #SubjectRef

    runs: [...#RunRef]

    evidence: [...#EvidenceRef]

    claims: [...#ClaimRef]

    correlation: #CorrelationProof

    proposed: {
        state:    string
        severity: string
    }
}
```

A candidate is a projection from evidence and graph/relational state.

It is not yet a tracker mutation.

## 3.3 Admitted project issue

Each project/profile defines admission from its candidates into project issues.

A small Factory-wide envelope may be shared:

```cue
#ProjectIssue: {
    id:   string
    unit: string
    key:  string

    class: string

    state: "open" | "blocked" | "actionable" |
           "resolved" | "suppressed"

    runs: [...#RunRef]

    evidence: [...#EvidenceRef]

    disposition?: {
        action: "dispatch" | "hold" | "close" | "ignore"
        reason: string
    }
}
```

Project-specific meaning remains outside this generic structure.

For example, `ctrl` may define:

```text
upstream semantic change
qualification regression
release-watch event
forecast divergence
coverage gap
```

while industrial constraints may define:

```text
constraint emergence
capacity expansion
procurement signal
funding opportunity
facility delay
evidence conflict
coverage gap
```

These should not be prematurely unified.

---

# 4. Correlation architecture

Correlation must be contractual.

Factory must not merge runs because:

- titles look similar;
- repository paths overlap;
- channel names match;
- package names appear related;
- a model infers an undeclared relationship.

The required chain is:

```text
normalized observation
    ↓
declared graph/relational subject
    ↓
declared relationship
    ↓
local consumer or obligation
    ↓
issue candidate
```

## 4.1 Software supply-chain correlation

For software-oriented projects, GUAC is the preferred first correlation backend.

```text
source / repository
       ↓
SBOM / provenance / analyzer observations
       ↓
GUAC ingestion
       ↓
typed supply-chain graph
       ↓
project-defined traversal
       ↓
issue candidate
```

Factory should not make the GUAC schema its semantic authority.

Instead:

```text
Factory relation vocabulary
       ↓ adapter
GUAC graph/query representation
```

A profile declares which graph relations are admissible and what a traversal means.

For example:

```cue
#CorrelationProjection: {
    root: #SubjectRef

    relations: [...#AdmittedRelation]

    obligation: #ObligationRef

    terminal: #SubjectRef

    issueClass: string
}
```

The graph backend demonstrates topology.

The profile determines significance.

## 4.2 Relational/domain correlation

GUAC must not become the universal Factory graph.

Industrial constraints and similar projects use their own relational model.

```text
documents / APIs / datasets
        ↓
acquisition
        ↓
typed relational observations
        ↓
Ibis expression model
        ↓
DuckDB / BigQuery execution
        ↓
canonical relational state
        ↓
graph / constraint projection
        ↓
issue candidate
```

Ibis provides the logical relational interface.

DuckDB and BigQuery are execution backends.

```text
               Ibis
                 │
        ┌────────┴────────┐
        ↓                 ↓
     DuckDB            BigQuery
 local/bounded       remote/large
```

A result from either backend must normalize into the same domain relation before it can affect issue admission.

---

# 5. Issue identity

Issue identity must be deterministic and independent of the external tracker.

Do not use:

```text
GitHub issue number
```

as semantic identity.

Prefer:

```text
unit
+ issue class
+ canonical subject
+ obligation/relation identity
```

or another project-defined deterministic projection.

Example:

```text
projects.ctrl
+ qualification-regression
+ package:pypi/foo
+ obligation:runtime-compatibility
```

produces a stable Factory issue key.

Multiple runs can converge on the same issue:

```text
run A ─┐
run B ─┼─→ correlation ─→ issue X
run C ─┘
```

A later run may resolve it:

```text
issue X
   ↑
run A: failing
run B: failing
run C: passing + sufficient resolution evidence
```

Resolution semantics must be project-defined.

Absence of a repeated observation is not automatically resolution.

---

# 6. Tracker substrate

GitHub Issues is the initial operational tracker substrate.

```text
#ProjectIssue
      ↓
tracker projection
      ↓
GitHub Issue
```

GitHub owns operational collaboration state such as:

- issue number;
- comments;
- assignment;
- human discussion;
- external links;
- open/closed UI state.

Factory owns:

- deterministic issue identity;
- semantic issue class;
- source run references;
- evidence references;
- admission decision;
- project-defined disposition.

Each generated issue should carry a machine-readable marker.

Example:

```text
factory-unit: projects.ctrl
factory-issue-key: qualification-regression:package:pypi/foo:runtime
factory-schema: tracker/v1
```

The adapter reconciles by this key.

It must not correlate by issue title.

## 6.1 Tracker actions

The reconciliation surface should be deliberately small:

```text
create
update
append-evidence
resolve
reopen
suppress
no-op
```

Each action is produced by comparison between:

```text
admitted ProjectIssue
        vs
current tracker projection
```

The GitHub adapter is procedural compatibility code.

It does not determine whether an issue deserves to exist.

---

# 7. Dispatcher integration

The current due-task scheduler remains conceptually separate from issue processing.

The dispatcher becomes two coupled loops.

## 7.1 Scheduled execution loop

```text
clock
  ↓
registry
  ↓
enabled + due
  ↓
execute task
  ↓
normalize run
  ↓
record run checkpoint
```

## 7.2 Post-run tracker loop

```text
normalized run
  ↓
domain correlation
  ↓
issue candidates
  ↓
project admission
  ↓
tracker reconciliation
  ↓
dispatch decisions
```

The first loop answers:

> What task should execute now?

The second answers:

> What durable project concerns exist after this execution?

These concerns may themselves produce future dispatches.

```text
issue
  ↓
project disposition
  ↓
dispatch request
  ↓
task/run plan
  ↓
execution
  ↓
normalized run
  ↓
issue update
```

This creates the control loop without making the tracker semantic authority.

---

# 8. ChatGPT execution environment

## 8.1 Distribution model

The execution environment is distributed as a **tar + Zstandard archive** available to ChatGPT as project source.

Conceptually:

```text
Factory repository/project source
        ↓
factory-chatgpt-env.tar.zst
        ↓
digest verification
        ↓
ephemeral ChatGPT container
        ↓
archive extraction
        ↓
environment qualification
        ↓
task execution
```

The archive is an immutable environment artifact.

It is not runtime state.

It contains no credentials.

It contains no task observations.

It contains no tracker state.

## 8.2 Proposed repository location

Keep the shared artifact outside individual project semantic-authority directories.

```text
.agents/
├── dispatcher/
│   └── executions/
└── environments/
    └── chatgpt/
        ├── environment.cue
        ├── environment.lock.cue
        ├── factory-chatgpt-env.tar.zst
        └── SHA256SUMS
```

`environment.cue` defines required capabilities.

`environment.lock.cue` records the resolved implementation/version set used to construct the archive.

The archive is the materialized runtime source.

`SHA256SUMS` allows the actuator to verify the selected archive before extraction.

If repository size later makes direct Git storage undesirable, the same contract can project to a release artifact or object store without changing environment identity semantics.

## 8.3 Environment archive layout

The extracted archive should expose a deterministic prefix.

Example:

```text
factory-chatgpt-env/
├── bin/
├── go/
├── python/
├── lib/
├── share/
├── manifests/
│   ├── environment.json
│   ├── tools.json
│   ├── sbom.spdx.json
│   └── provenance.json
└── adapters/
```

Avoid depending on host-global installation when possible.

The runtime may activate it through environment variables such as:

```text
PATH
PYTHONPATH / virtual environment
GOROOT / GOPATH where required
library search paths
```

The exact activation mechanism is implementation detail generated from the environment contract.

---

# 9. Environment capability model

Contracts should request capabilities rather than implementation package names.

Example:

```cue
#EnvironmentCapability:
    "cue-eval" |
    "git-acquire" |
    "http-acquire" |
    "sbom-compose" |
    "provenance-verify" |
    "supply-chain-analyze" |
    "supply-chain-correlate" |
    "relational-query" |
    "warehouse-query" |
    "columnar-io" |
    "document-extract"
```

An environment plan then resolves those capabilities.

```cue
#EnvironmentPlan: {
    id: string

    capabilities: [...#EnvironmentCapability]

    archive: {
        source: string
        digest: string
    }

    tools: [...#ResolvedTool]
}
```

A run records the environment used:

```cue
#EnvironmentRef: {
    id:     string
    digest: string
}
```

This makes results traceable to the executable environment without making that environment semantic authority.

---

# 10. Baseline toolkit

The first archive can intentionally be a broad Factory intelligence environment.

Optimization into smaller images/archives can happen after execution patterns are known.

## 10.1 Base

```text
CUE
git
curl
jq
tar
zstd
common certificate/network utilities
```

## 10.2 Go and software-supply-chain stack

```text
Go toolchain

GUAC tooling
OpenSSF Scorecard
bom
bomctl
cosign
slsa-verifier
```

Exact tools and versions belong in the lock representation.

Organizational ownership of individual tools does not imply Factory semantic ownership.

## 10.3 Python relational stack

```text
Python
uv

Ibis
DuckDB
PyArrow
Polars

google-cloud-bigquery
Ibis BigQuery backend
required BigQuery datatype/auth adapters
```

Additional Python packages should be admitted only for demonstrated acquisition or transformation requirements.

## 10.4 BigQuery

The archive should provide BigQuery query capability but no credentials.

Authentication is injected at execution time by the actuator/environment.

```text
environment
    supplies client/backend

runtime
    supplies authorized credential

contract
    supplies admitted dataset/query scope
```

Possession of BigQuery credentials must not imply unrestricted acquisition authority.

The project contract still constrains permitted datasets and observations.

---

# 11. Self-description and provenance

The environment should be capable of describing itself.

The build should emit:

```text
environment lock
tool/version inventory
SBOM
archive checksum
build provenance
```

Ideally:

```text
environment.cue
      ↓
resolved lock
      ↓
build
      ↓
SBOM + provenance
      ↓
tar.zst
      ↓
digest
```

A run therefore records:

```text
run
 ├── task/profile contract identity
 ├── environment digest
 ├── source observations
 ├── normalized evidence
 └── decision
```

This closes an important provenance gap: executable analysis can later be associated with the exact environment that produced it.

---

# 12. Source versus authority

The archive is a **project source**, not an authority.

This distinction is explicit:

```text
environment archive
    = executable source artifact

tool manifest
    = description of artifact contents

tool output
    = observation

normalized tool output
    = admitted observation if contract permits

project contract
    = semantic authority
```

Likewise:

```text
GUAC
BigQuery
DuckDB
Ibis
Scorecard
SBOM tools
```

are execution/acquisition/correlation implementations.

None become semantic authority by being bundled in the runtime.

---

# 13. Proposed repository shape

```text
/
├── .agents/
│   ├── dispatcher/
│   │   └── executions/
│   └── environments/
│       └── chatgpt/
│           ├── environment.cue
│           ├── environment.lock.cue
│           ├── factory-chatgpt-env.tar.zst
│           └── SHA256SUMS
│
├── contracts/
│   ├── dispatcher/
│   │   ├── contract.cue
│   │   ├── run.cue
│   │   ├── tracker.cue
│   │   └── environment.cue
│   │
│   ├── workers/
│   │   └── upstream-monitor/
│   │       ├── contract.cue
│   │       ├── profiles_ctrl/
│   │       │   └── tracker.cue
│   │       └── profiles_epistemic_plant_bootstrap/
│   │           └── tracker.cue
│   │
│   └── world/
│       └── industrial-constraints/
│           ├── contract.cue
│           └── tracker.cue
│
├── docs/
│   └── architecture/
│       ├── factory-daily-dispatcher.md
│       ├── factory-unit-registry-refactor.md
│       └── factory-tracker-runtime.md
│
└── registry.cue
```

The names are provisional.

The structural rule is not:

> every project must have `tracker.cue`.

The rule is:

> a task participating in issue projection must expose the project-specific semantics necessary to derive and admit its issues.

Pure procedural tasks may remain outside the tracker model until there is a concrete reason to track durable concerns.

---

# 14. Sequenced implementation milestones

## Milestone 0 — Freeze the authority boundary

Document the revised dispatcher model before changing execution behavior.

Establish:

```text
scheduler != tracker
tracker != semantic authority
environment != semantic authority
tool output != admitted fact
```

Revise `factory-daily-dispatcher.md` so its previous statement that the dispatcher never provisions an execution environment is replaced by the narrower rule:

> the dispatcher does not invent execution environments; it selects and activates environments explicitly admitted by the relevant execution contract.

**Exit condition**

The architecture documents describe one non-contradictory control model.

---

## Milestone 1 — Normalize completed runs

Define the smallest shared `#NormalizedRun` envelope.

Do not redesign existing project run bundles.

Write projection adapters from:

```text
ctrl admitted run bundle
epistemic admitted run bundle
UQAM procedural result
eventually industrial-constraints run bundle
```

into the common dispatcher envelope.

Preserve the original task-native outcome as a referenced or embedded object where necessary.

**Exit condition**

The dispatcher can read multiple task-native results through one normalized run interface without erasing their task-specific semantics.

---

## Milestone 2 — Define tracker primitives

Add only genuinely shared operational tracker vocabulary:

```text
RunRef
EvidenceRef
IssueCandidate envelope
ProjectIssue envelope
TrackerAction
TrackerRef
```

Do not define universal project issue classes.

Do not generalize `ctrl` issue semantics into dispatcher core.

**Exit condition**

A project can define its own issue candidate and constrain it against the generic tracker envelope.

---

## Milestone 3 — Implement deterministic issue identity

Define project-owned key projections.

For `ctrl`, select one narrow first issue class such as:

```text
qualification regression
```

Derive its key mechanically from declared subject and obligation identity.

Do not use titles or GitHub issue numbers as correlation keys.

**Exit condition**

Repeated equivalent normalized runs produce the same issue key.

Distinct declared obligations produce distinct issue keys.

---

## Milestone 4 — Implement tracker reconciliation

Implement a GitHub Issues adapter in dry-run mode.

Input:

```text
ProjectIssue[]
+
current GitHub tracker state
```

Output:

```text
TrackerAction[]
```

Start with:

```text
create
update
resolve
no-op
```

Add reopen, suppression, assignment, and richer workflow only after the first loop is stable.

**Exit condition**

The adapter produces deterministic tracker actions without itself deciding issue semantics.

---

## Milestone 5 — Define the ChatGPT environment contract

Introduce the shared environment vocabulary.

Model:

```text
capability
resolved tool
archive source
archive digest
environment identity
environment qualification
```

Keep tool versions out of generic task contracts unless version identity is itself semantically required.

**Exit condition**

A task can request capabilities and resolve them to one immutable environment archive.

---

## Milestone 6 — Build the first tar.zst environment

Produce:

```text
factory-chatgpt-env.tar.zst
```

with the baseline:

```text
CUE
Go
GUAC/tooling
Scorecard
SBOM tooling
SLSA/Sigstore tooling

Python
uv
Ibis
DuckDB
Arrow
Polars
BigQuery support

basic acquisition utilities
```

Generate alongside it:

```text
environment.lock.cue
SHA256SUMS
SBOM
tool manifest
build provenance
```

**Exit condition**

A clean ChatGPT container can receive the project-source archive, verify its digest, extract it, activate it, and execute qualification probes successfully.

---

## Milestone 7 — Add environment qualification

Before any contracted execution, validate required capabilities.

Example:

```text
archive digest valid?
        ↓
activation succeeds?
        ↓
required binaries import/run?
        ↓
required Python modules import?
        ↓
backend probe succeeds?
        ↓
environment admitted
```

Failure produces an explicit execution coverage gap.

Never silently install a missing tool and continue under the same environment identity.

**Exit condition**

A run can prove which qualified environment it used or terminate with a typed environment coverage gap.

---

## Milestone 8 — Add software graph correlation

Use `ctrl` as the first substantial correlation realization.

Pipeline:

```text
normalized software observations
        ↓
SBOM/provenance projection as applicable
        ↓
GUAC ingestion/query
        ↓
profile-declared traversal
        ↓
IssueCandidate
        ↓
profile admission
        ↓
ProjectIssue
```

Do not attempt to encode all upstream-monitor semantics in GUAC.

GUAC supplies graph topology and correlation where its domain fits.

**Exit condition**

One real `ctrl` issue can be reconstructed from:

```text
source observation
→ graph relation
→ local obligation
→ issue candidate
→ admitted issue
```

with complete provenance.

---

## Milestone 9 — Connect tracker reconciliation to the dispatcher

Extend post-run processing:

```text
execute
   ↓
normalize
   ↓
correlate
   ↓
admit issues
   ↓
reconcile tracker
   ↓
record tracker result
```

The existing cadence scheduler remains unchanged unless tracker disposition explicitly creates a new admitted dispatch request.

**Exit condition**

A scheduled `ctrl` run can deterministically create/update/resolve its project tracker issue.

---

## Milestone 10 — Add issue-driven dispatch

Introduce the reverse path:

```text
ProjectIssue
     ↓
project disposition
     ↓
DispatchRequest
     ↓
admission
     ↓
RunPlan
```

An issue must not automatically generate work merely because it is open.

The project contract determines which issue states are actionable.

**Exit condition**

At least one tracker issue can create an admitted follow-up execution without bypassing registry/task authority.

---

## Milestone 11 — Add relational correlation

After the software path proves the tracker abstraction, implement the independent relational path for industrial constraints.

```text
acquired datasets/documents
        ↓
Ibis normalization
        ↓
DuckDB / BigQuery
        ↓
canonical relational state
        ↓
constraint/graph projection
        ↓
industrial IssueCandidate
```

Do not reuse GUAC vocabulary merely to make the implementations look symmetrical.

The common boundary is only:

```text
normalized run
→ domain correlation
→ IssueCandidate
```

**Exit condition**

A relational industrial signal can reach the same tracker substrate without importing software-supply-chain semantics.

---

## Milestone 12 — Qualify industrial-constraints dispatcher admission

Only after its domain contract, relational state, evidence semantics, and tracker projection are independently qualified should:

```text
world.industrial-constraints.monitor
```

be admitted to normal dispatcher execution.

Its existing disabled registry state should not be changed merely because the shared runtime now contains Ibis/BigQuery tooling.

**Exit condition**

Industrial monitoring can produce an immutable admitted run and deterministic issue projection.

---

## Milestone 13 — Evaluate remaining units independently

Evaluate:

```text
epistemic-plant-bootstrap
academic.uqam
future units
```

against the tracker abstraction.

Do not force every scheduled task into issue tracking.

For a simple event watch, a task-native:

```text
new_matches
no_change
source_gap
```

may remain sufficient until durable issue semantics provide actual value.

**Exit condition**

Tracker adoption remains explicit per task/unit.

---

## Milestone 14 — Harden reproducibility

Once the loop works end-to-end:

- pin environment tool versions;
- pin/archive source digests;
- emit the environment SBOM;
- preserve build provenance;
- verify archive integrity before activation;
- record environment identity in normalized runs;
- make graph/query projections deterministic;
- make tracker reconciliation idempotent;
- add fixtures for repeated-run correlation;
- test issue resolution and reopening;
- represent unavailable validation explicitly;
- prohibit mutation of admitted run bundles.

**Exit condition**

A tracker decision can be replayed from immutable inputs and produce the same projected issue state.

---

# 15. Initial implementation slice

The smallest useful vertical slice is:

```text
ctrl upstream-monitor run
        ↓
NormalizedRun
        ↓
one contracted correlation rule
        ↓
one deterministic issue key
        ↓
one ProjectIssue
        ↓
GitHub dry-run reconciliation
```

in parallel with:

```text
environment.cue
        ↓
environment.lock.cue
        ↓
factory-chatgpt-env.tar.zst
        ↓
ChatGPT extraction/qualification
```

Then join them:

```text
qualified ChatGPT environment
        ↓
ctrl execution
        ↓
normalized run
        ↓
GUAC-assisted correlation
        ↓
ProjectIssue
        ↓
GitHub tracker
```

This proves all major architectural boundaries without first implementing a generalized dispatcher platform.

---

# 16. Target steady state

The intended Factory control plane is:

```text
                          Factory contracts
                                 │
                 ┌───────────────┴───────────────┐
                 ↓                               ↓
          EnvironmentPlan                     RunPlan
                 ↓                               ↓
       project-source tar.zst ───────→ ChatGPT execution
                                                 ↓
                                         raw observations
                                                 ↓
                                          NormalizedRun
                                                 ↓
                               ┌─────────────────┴──────────────┐
                               ↓                                ↓
                       GUAC/software graph              relational/domain
                               │                                │
                               └──────────────┬─────────────────┘
                                              ↓
                                       IssueCandidate
                                              ↓
                                      project admission
                                              ↓
                                        ProjectIssue
                                              ↓
                                      GitHub projection
                                              ↓
                                    dispatcher disposition
                                              ↓
                                      admitted next work
```

The durable design rule is:

```text
heterogeneous execution
        ↓
source-qualified observations
        ↓
normalized immutable runs
        ↓
contracted domain correlation
        ↓
project-owned issue semantics
        ↓
thin tracker projection
        ↓
admitted dispatch
```

The tracker exists to maintain continuity across runs.

The environment exists to make execution reproducible.

Neither is permitted to manufacture semantic authority.
