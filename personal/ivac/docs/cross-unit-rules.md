# Cross-unit review rule qualification

Status: adapter qualification seam; no production rule or reviewer approval is
included. Case applicability and the reviewed regulatory compendium remain open.

Rules retain independent IDs and semantic versions. A rule matches only when
every typed value condition is supported by an authorized linked observation.
Conflicting authorized values remain an explicit review condition. A missing or
withheld required observation produces no flag and no description of the missing
observation. A flag is a review prompt, not a diagnosis, causation finding,
statutory qualification, entitlement, or adjudication.

Test rules require a synthetic snapshot. Unreviewed candidate rules also require
a synthetic snapshot and a verified basis. `synthetic=True` is a trusted host
assertion; the adapter cannot determine whether case facts are invented. A
reviewed rule carries a source URL and digest plus separate clinical and legal
review receipt references. The CUE
contract checks their shape, not their authenticity or professional authority.
The trusted host must provide both verifiers: `verify_basis` must verify the
pinned source bytes and the rule's stated basis; `verify_reviews` must verify the
actual independent professional reviews, qualifications, exact rule version,
legal-unit mapping, reviewed source version and any review limitations. The
host must separately address case-specific legal applicability; a rule review
does not establish it.
Neither callback is supplied by this repository. A caller-provided `True` is not
evidence of review, and the illustrative test callbacks are not deployment code.

The host must also authenticate the caller, bind `ScopeProvider` to the account
and exact snapshot, and enforce disclosure authorization before evaluation. The
Python adapter cannot authenticate callers. Review Desk gateway parity and
account integration are independently tracked; do not enable reviewed rules in
the portal until those checks, source verification and professional reviews pass.

## Research lead

Mucha et al., [A Brief Vestibular/Ocular Motor Screening Assessment to Evaluate
Concussions](https://pmc.ncbi.nlm.nih.gov/articles/PMC4209316/), describes a
preliminary screen for acute sport-related concussion in a mostly adolescent
sample. It is a possible research lead for visual and vestibular assessment; it
does not establish a permanent sequela or a link between legal units. The
article's source bytes, applicability, limitations, and legal mapping have not
been admitted or independently reviewed for a production rule.
