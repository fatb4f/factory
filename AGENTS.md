
# AGENTS.md

Implementation prompt: [prompt.txt](prompt.txt)

## Upstream issue transport

Issue #104 is the stable implementation-unit authority. Routine cross-session
progress belongs in its single maintained comment marked
`<!-- factory-progress:v1 -->`, not in the issue body. Work resumes on the
GitHub-linked issue branch by reading this file, `prompt.txt`, the stable issue
bodies, the designated progress comment, the working tree, and validated
workflow evidence. A user may therefore request continuation without pasting
issue content into `UserPromptSubmit`.

Treat authority and tracking as separate transports. The authority transport
contains the issue body, explicit authority revision when declared, and body
digest. The tracking transport contains the progress-comment ID, comment update
time, current node, statuses, last stable commit, validations, blockers, and
next action. GitHub issue `updatedAt` is not an authority revision because
comment activity may change it.

At session end, edit the same progress comment instead of adding comments or
changing the issue body. Change the #104 body only through an explicit authority
revision. Regenerate authority transport only after an authority-body change;
refresh tracking context after progress-comment changes. Regenerate #103 only
when its upstream authority revision changes.

Offline JSON, plans, and tracking projections are machine-local, transient
context: do not commit them or disclose them as repository authority. Admission
evidence remains confined to
`${XDG_RUNTIME_DIR:-/tmp}/factory-bdd/<execution-id>/`.

## Scope

This directory owns Factory’s Marimo execution surfaces and their integration with the repository-root `.kb` control plane.

The admitted Python implementation surfaces are:

```text
marimo/profiles/context-resolver/context_resolver.py
marimo/workflows/bdd/validate_implementation_unit.py
```

Their responsibilities are distinct:

```text
context_resolver.py
    legacy inline-managed UserPromptSubmit resolver
    preserved until the root-.kb resolver migration passes RM-08

validate_implementation_unit.py
    project-managed BDD execution surface
    validates implementation units and produces transient evidence
```

Do not add additional Python runtimes, adapters, generators, hook scripts, or workflow engines without first adding the corresponding architectural requirement to issue #103.

Python implementation must remain inside admitted Marimo workbooks.

---

## Authority model

```text
Issue #103
    canonical architectural requirements,
    acceptance criteria, and dependency topology

root <repo>/.kb
    canonical repository identity,
    graph catalog, registries, views, bindings,
    validation declarations, and KG disclosure

versioned BDD CUE contract
    canonical scenario, workflow, fixture,
    evidence, bootstrap, and admission semantics

architecture KG
    canonical decisions, references, derivations,
    insights, provenance, and rejected or deferred alternatives

Marimo workbooks
    Python execution boundaries

Pydantic and Hypothesis
    transport and adversarial validation tools

kg command
    read-only projection and discovery interface

just recipes and procedural skills
    thin operator-facing wrappers

generated evidence, reports, packets, caches, and environments
    non-authoritative transient outputs
```

No Marimo workbook, Python model, shell command, skill, issue comment, or generated report may become an independent source of architectural authority.

---

## Core invariants

1. Except for the sole UV/BD bootstrap unit declared by issue #104, read repository authority from `<repo>/.kb` before resolving subordinate resources. The bootstrap unit is bounded by its pinned #103 snapshot, bootstrap workbook decision, and minimal CUE validator.
2. Follow only graphs, registries, views, bindings, and KG packages disclosed by the admitted root.
3. Validate each CUE or graph boundary independently before consuming its export.
4. Preserve the distinction between:

   * architectural requirement graphs;
   * semantic knowledge graphs;
   * materialization and validation DAGs;
   * runtime execution state.
5. Semantic graphs may contain cycles unless their contract explicitly defines a DAG.
6. Validation and materialization workflows must be acyclic and preserve declared dependency ordering.
7. Python may calculate or transport observations, but it may not assert them as admitted graph or repository facts.
8. Externally computed topology remains untrusted evidence until validated through the applicable CUE/Apercue contract.
9. Generated packets, evidence, observations, reports, and check state are transient projections, never authority.
10. Admission is computed by CUE from concrete validator projections and admitted evidence.
11. Workbooks and runners must not accept claimant-supplied validity or admission booleans.
12. Every ordinary project-managed execution is bound to the admitted Factory `pyproject.toml` and `uv.lock`. The sole UV/BD bootstrap unit may use its candidate project and lock identities only after minimal-bootstrap verification and only through the bounded transition defined below.
13. Compatibility aliases express replacement and must never be ranked as active semantic profiles.
14. The mandatory repository view is selected before optional semantic profiles.
15. Architectural decisions made during implementation must be captured as candidate KG records and later admitted through the architecture-KG workflow.

---

## Python and uv policy

Factory intentionally uses a locked root `uv` project for project-managed Marimo workbooks.

The root project files are:

```text
pyproject.toml
uv.lock
```

They own:

* supported Python constraints;
* direct Python dependencies;
* locked dependency resolution;
* platform markers;
* project and lockfile identity.

### Project-managed BDD workbook

The canonical BDD workbook is:

```text
marimo/workflows/bdd/validate_implementation_unit.py
```

It must:

* use the root Factory `uv` project;
* contain no PEP 723 inline dependency metadata;
* run under locked and exact project execution;
* receive provider and consumer repository coordinates explicitly;
* emit evidence only through the declared transient evidence boundary.

The following metadata is forbidden in the project-managed workbook:

```text
# /// script
...
# ///
```

Inline script metadata would bypass the surrounding Factory project and create a competing dependency authority.

### Legacy resolver workbook

The existing resolver remains:

```text
marimo/profiles/context-resolver/context_resolver.py
```

It may retain PEP 723 inline metadata only while it has explicit legacy migration status.

The active `UserPromptSubmit` hook must remain operational until its project-managed root-`.kb` replacement passes the migration-preservation requirement `RM-08`.

Do not:

* remove the resolver’s inline metadata prematurely;
* convert the resolver to project mode during BDD bootstrap;
* replace the active hook before the migration gate passes;
* treat the resolver workbook as the canonical BDD workbook.

### Execution

Project-managed workbook execution must use the admitted binding equivalent of:

```bash
uv run \
  --project "$factory_provider_root" \
  --locked \
  --exact \
  -- \
  python "$factory_provider_root/marimo/workflows/bdd/validate_implementation_unit.py" \
  --provider-root "$factory_provider_root" \
  --repo-root "$consumer_root" \
  --evidence-root "$evidence_root"
```

The exact command is binding-owned.

The contract-owned operator command allocates a unique execution ID and creates
`$evidence_root` below `${XDG_RUNTIME_DIR:-/tmp}/factory-bdd/<execution-id>/`
before invoking the workbook. A direct caller must perform the same allocation
and pass the resulting absolute coordinate explicitly; the workbook must not
invent or infer its evidence location.

Use absolute paths or explicit root arguments. `--project` selects the project environment but does not establish repository path semantics by itself.

Mutation and exact-sync fixtures must use a disposable environment:

```bash
UV_PROJECT_ENVIRONMENT="$temporary_environment"
```

Tests must never destructively synchronize an undeclared developer, consumer, or shared repository environment.

`--locked` prevents lockfile changes.

`--exact` removes undeclared environment packages.

`--offline` is a separate cache-dependent property and must not be implied by locked execution.

---

## BDD implementation-unit workflow

The canonical BDD workflow is declared in CUE and, after the AK substrate is admitted, captured through admitted KG references. The sole bootstrap unit uses its pinned issue snapshot and bootstrap CUE decision directly; it does not claim nonexistent KG admission.

The Marimo workbook executes only the nodes assigned to the Python boundary.

The required sequence is:

```text
resolve normalized #103 requirement snapshot
→ resolve implementation-unit declaration
→ consume the CUE-exported complete local dependency closure
→ query admitted KG workflow context when the AK substrate is available
→ resolve returned references to authoritative CUE declarations
→ vet and export the declared validation workflow
→ validate acceptance-criterion scenario coverage
→ execute assigned Marimo/Pydantic/Hypothesis scenarios
→ write transient revision-bound evidence
→ vet evidence through the declared CUE ingress
→ compute implementation-unit admission in CUE
→ verify the exported admission value is literally true
```

### Acceptance coverage

Every directly satisfied acceptance criterion must be covered by at least one scenario.

Coverage must reference stable acceptance-criterion IDs, not only requirement IDs.

Scenario references must remain inside the implementation unit’s dependency closure.

Prerequisite requirements already admitted by an earlier unit do not need their full scenario suites rerun. Their admission identity and snapshot coordinates must be verified.

### Workflow refinement

An implementation unit declares its validation DAG.

The validator must prove:

* every node reference resolves;
* the workflow is acyclic;
* requirement dependency order is preserved;
* every scenario has an execution node;
* required artifacts are produced before consumption;
* evidence admission follows scenario execution;
* unit admission is terminal;
* no unrelated architectural ordering is introduced.

The workbook must not invent alternate workflow nodes when the declared workflow is incomplete.

Missing or invalid workflow projections fail closed.

### Evidence identity

Evidence must bind to:

* issue #103 transport revision;
* issue-body digest;
* normalized requirement-snapshot schema and digest;
* implementation-unit ID;
* requirement and acceptance-criterion IDs;
* repository revision;
* clean or deterministic working-tree identity;
* provider and consumer repository roots;
* BDD contract digest;
* workflow digest;
* project metadata digest;
* `uv.lock` digest;
* workbook digest;
* fixture digest;
* runner protocol version;
* scenario IDs;
* execution platform and interpreter identity.

Python runner success is evidence only.

It is not admission.

---

## BDD bootstrap exception

Exactly one implementation unit may use provisional BDD admission:

```text
UV-01 UV-02 UV-03 UV-04
BD-01 BD-02 BD-03 BD-04
BD-05 BD-06 BD-07 BD-08
```

Its project and lock identities transition through these explicit states:

```text
candidate project/lock identity
→ minimal-bootstrap verification
→ bounded provisional use
→ self-conformance
→ admitted project/lock identity
```

Candidate identities may be used only by this bootstrap unit after the minimal
validator has verified their declared metadata, lock consistency, and digests.
They remain provisional evidence until self-conformance admission succeeds.
Every ordinary unit requires already-admitted project and lock identities.

The bootstrap sequence is:

```text
establish root pyproject.toml
→ establish and verify uv.lock
→ establish project-managed BDD workbook
→ preserve legacy inline resolver
→ vet/export minimal bootstrap contracts
→ run positive and negative bootstrap fixtures
→ compute bounded provisional admission
→ execute canonical BDD suite against itself
→ admit self-conformance evidence through CUE
→ verify self-conformance admission == true
→ retire provisional admission
```

The minimal bootstrap validator may prove only:

* required packages close and export;
* required definitions exist;
* positive fixtures pass;
* negative fixtures fail;
* project and lockfile identity is valid;
* locked/exact execution succeeds;
* claimant-supplied validity booleans are rejected.

It must not claim full BDD conformance.

No later implementation unit may use provisional admission.

---

## Architecture KG integration

Architecture knowledge must be captured as typed records rather than unordered document facts.

Applicable record classes include:

```text
decision
reference
derivation
insight
pattern
rejected
deferred
superseded
observation
provenance
```

Do not encode every source paragraph as a decision.

Use the classification flow:

```text
document, issue, comment, or implementation observation
→ candidate claim
→ typed classification
→ deduplication and adjudication
→ stable KG identity
→ requirement and acceptance-ID linkage
→ CUE validation
→ admitted KG record
```

KG records may reference issue #103 requirements and acceptance criteria.

They must not redefine the canonical requirement matrix.

The `kg` command is read-only and may be used to:

* discover the admitted BDD workflow;
* resolve decision and reference IDs;
* locate authoritative CUE packages;
* export bounded workflow context;
* retrieve rationale and rejected alternatives.

The `kg` command must not:

* compute admission;
* mutate authority;
* replace CUE validation;
* execute workflow nodes;
* supply pass or failure claims.

A thin BDD skill may invoke `kg`, but it must follow returned references to their authoritative declarations and then run the declared CUE/Marimo workflow.

---

## Root-.kb resolver architecture

The target resolver flow is:

```text
locate <repo>/.kb
→ export and validate root admission
→ resolve only root-disclosed graph descriptors
→ validate each child graph independently
→ verify registry and runtime-binding identity
→ select the mandatory repository view
→ activate optional semantic profiles
→ execute the verified runtime binding
→ validate the generated packet
→ classify the packet as transient and non-authoritative
```

The resolver must fail closed on:

* missing root identity;
* missing mandatory graph;
* unresolved reference;
* invalid package;
* path escape;
* missing mandatory view;
* registry mismatch;
* stale or invalid digest;
* unsupported binding protocol;
* unsupported platform;
* ambiguous provider/consumer roots;
* profile-only output without the mandatory repository view.

Legacy `self`, `self/bootstrap`, and `self/turn` aliases are compatibility redirects only.

Never rank them as semantic profiles.

---

## Context-resolver preservation rules

Until the root-`.kb` resolver migration is admitted:

1. Preserve the direct `UserPromptSubmit` bridge.
2. Preserve `app.run(defs={"workbook_request": ...})` compatibility where currently required.
3. Preserve the active hook command and bounded packet behavior.
4. Preserve legacy inline dependency metadata.
5. Do not inject the BDD workbook into the hook path.
6. Do not treat the existing resolver’s nested `.kb` as the future repository-root authority.
7. Do not add later lifecycle events solely because their Codex event forms are documented.

The resolver migration must be performed through the applicable `RM`, `RB`, `RS`, `EV`, and `HK` requirements.

---

## KB and AK candidate development

During the BDD bootstrap, candidate KB and AK work may proceed concurrently.

Candidate artifacts are not authority.

They must:

* live under explicitly declared candidate roots;
* carry candidate or provisional status;
* remain excluded from root `.kb` disclosure;
* remain excluded from admitted graph catalogs;
* remain excluded from runtime bindings;
* remain excluded from authoritative exports;
* not satisfy downstream dependencies;
* not be imported by UV or BD authority packages.

Before the bootstrap issue closes, every candidate artifact must be:

```text
retained for a named later implementation unit
superseded
rejected
or removed
```

Historical document-to-KG migration begins only after the architecture-KG substrate is admitted.

New BD, KB, and AK decisions should still be captured immediately as candidate records to avoid reconstructing their rationale later.

---

## Procedural skills and just recipes

Skills and `just` recipes are procedural wrappers only.

They may:

* locate the implementation unit;
* invoke `kg` read-only queries;
* invoke CUE vet/export commands;
* invoke the admitted Marimo workbook;
* verify generated evidence;
* verify the CUE-exported admission result.

They must not contain copied:

* CUE schemas;
* requirement matrices;
* acceptance criteria;
* workflow-node definitions;
* digest values;
* registry inventories;
* view definitions;
* profile definitions;
* admission logic.

The desired operator flow is:

```text
skill
→ just recipe
→ kg read-only workflow projection
→ CUE vet/export
→ uv locked/exact Marimo execution
→ CUE evidence admission
→ literal true gate verification
```

A successful shell exit alone is not admission.

---

## Change protocol

When modifying the BDD surface:

1. Resolve and verify the #103 requirement snapshot.
2. Update CUE declarations and workflow contracts first.
3. Update KG candidate or admitted records for architectural decisions.
4. Update fixtures and acceptance-criterion coverage.
5. Update the project-managed Marimo workbook only for Python-assigned workflow nodes.
6. Regenerate transient evidence.
7. Validate evidence through CUE.
8. Verify the CUE-exported admission value is literally `true`.

When modifying the resolver surface:

1. Preserve the current hook path unless the migration unit explicitly replaces it.
2. Update root and binding contracts before runtime behavior.
3. Keep repository-view selection mandatory.
4. Keep optional profiles subordinate to the repository view.
5. Preserve packet non-authority.
6. Validate migration compatibility through the golden `UserPromptSubmit` fixture.

When changing Python dependencies:

1. Update `pyproject.toml`.
2. Regenerate `uv.lock`.
3. Run `uv lock --check`.
4. Verify project and lockfile digests.
5. Run locked/exact execution in a disposable environment.
6. Verify unsupported or stale environments fail closed.

---

## Validation

Run the authoritative commands declared by the applicable BDD workflow and runtime binding.

At minimum, validation must cover:

```bash
uv lock --check
```

```bash
cue vet <bdd-contract-package>
cue export <bdd-contract-package> -e <bootstrap-or-unit-admission>
```

```bash
UV_PROJECT_ENVIRONMENT="$temporary_environment" \
uv run \
  --project "$factory_provider_root" \
  --locked \
  --exact \
  -- \
  python "$factory_provider_root/marimo/workflows/bdd/validate_implementation_unit.py" \
  --provider-root "$factory_provider_root" \
  --repo-root "$consumer_root" \
  --evidence-root "$evidence_root"
```

For the preserved resolver:

```bash
cue vet ./marimo/profiles/context-resolver/.kb
cue export ./marimo/profiles/context-resolver/.kb -e output --out json
```

```bash
printf '%s\n' \
  '{"hook_event_name":"UserPromptSubmit","prompt":"inspect context resolver"}' |
  uv run --script \
    marimo/profiles/context-resolver/context_resolver.py \
    --codex-hook \
    --repo-root "$PWD"
```

The exact BDD command must be exposed through the contract-owned command projection, optionally through a thin `just` recipe.

---

## Admission conditions

A change is admitted only when:

* the normalized #103 requirement snapshot matches the implementation unit;
* the complete dependency closure is valid;
* every directly satisfied acceptance criterion has required scenario coverage;
* the validation workflow is an admitted acyclic refinement;
* all authoritative CUE boundaries validate independently;
* project metadata and `uv.lock` are current and verified;
* the project-managed BDD workbook contains no inline dependency metadata;
* locked and exact execution succeeds in a disposable environment;
* legacy resolver behavior remains intact unless its migration is admitted;
* evidence is bound to the correct repository, workspace, fixture, workflow, project, lockfile, and contract identities;
* claimant-supplied pass booleans are rejected;
* CUE computes admission;
* the exported admission result is literally `true`;
* provisional admission is unavailable to ordinary units;
* no Python implementation exists outside admitted Marimo workbooks;
* candidate KB and AK artifacts remain visibly non-authoritative;
* generated evidence and packets remain transient projections.

---

## Forbidden changes

Do not:

* add standalone Python scripts as runtime or validation implementations;
* create a second context resolver;
* use the legacy resolver as the canonical BDD workbook;
* remove resolver inline metadata before `RM-08`;
* add inline dependency metadata to the project-managed BDD workbook;
* edit `uv.lock` manually;
* run destructive exact-sync fixtures against an undeclared shared environment;
* reconstruct CUE/Apercue graph authority in Python;
* make `kg`, Marimo, skills, `just`, or shell exit codes admission authority;
* copy requirement matrices or CUE schemas into skills or workbooks;
* treat semantic profiles as replacements for the mandatory repository view;
* rank legacy `self` aliases as active profiles;
* promote generated evidence, reports, packets, caches, or materialized plugin files to authority;
* allow KB or AK candidates to satisfy dependencies before ordinary BDD admission;
* introduce new architecture without updating issue #103 and the applicable KG records.
