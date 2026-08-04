+++
initiative = "grounded-generative-destination-proposals"
document_type = "design"
status = "approved"
upstream = "scope.md"
+++

## Design summary

Add `DestinationProposalCoordinator` with two immutable private drafts:
`AmbitionInterpretationDraft` and `GroundedDestinationProposalSet`. The
coordinator retrieves a finite public `DestinationCandidateBundle` through
domain read clients, submits a registered composition task to
`PrivateGenerationClient`, validates identities/evidence/route semantics through
deterministic domain validators, and renders a source-bound set. It exposes only
a `DestinationAdoptionInput` to the existing adoption owner.

## User flows

1. User enters an ambition or selects an existing draft.
2. Ambitions shows its Interpretation Draft: exact statement, explicit facets,
   unknowns, alternate meanings and optional context categories.
3. User edits/accepts the interpretation and chooses generate; on-device mode
   and progress are disclosed by the private runtime.
4. Deterministic domain retrievers assemble candidate identities and exact
   source/relationship/current/capability bindings.
5. The model composes structured alternatives from that closed bundle.
6. Validators remove/block unsupported candidates and render a truthful set.
7. User inspects sources/assumptions, compares dimensions, edits, retries,
   reorders, dismisses, reports or saves.
8. “Explore this path” creates an adoption preview; user confirms under the
   destination-adoption owner. No action occurs in this flow.

Sparse/unavailable results show what sources/routes were checked and offer
manual destination entry, domain forms and deterministic v1 recommendations.
Changing the interpretation or included context cancels/discards older work.

## States and recovery

Interpretation: `editing`, `needsClarification`, `ready`, `superseded`, `deleted`.
Proposal: `notRequested`, `retrieving`, `generating`, `validating`, `ready`,
`partial`, `sparse`, `sourceNeeded`, `modelUnavailable`, `invalid`, `canceled`,
`superseded`, `saved`, `deleted`. Candidate evidence independently reports
current/stale/conflicting/unsupported/unknown/not-included.

One actor serializes each initiative draft. Every async stage captures ambition,
interpretation, context, corpus, relationship, current-authority, capability,
task/model/prompt/schema/policy and locale revisions. Mismatch discards output.
Retry creates a child attempt; it never overwrites a saved set. Interrupted
save/delete uses idempotent journals. Downstream adoption rechecks all evidence.

## Architecture and data

### Domain models and services

Add under `Native/Ambitions/Core/LocalRuntimeOS/Planning/DestinationProposals/`:

- ambition statement/facet/interpretation/question models and repository;
- candidate identity/route/evidence/reason/bundle models;
- domain candidate providers for career, education and hobby/life;
- relationship/current/capability evidence adapters;
- retrieval policy, diversity policy and bundle assembler;
- registered task request/output models;
- identity/source/route/transfer/constraint/current/prohibited-claim validators;
- proposal candidate/set/provenance models and repository;
- coordinator, invalidation, migration and purge;
- comparison projection, inspection projection and adoption-input builder.

`DestinationCandidateProvider` returns public identities and source evidence for
one route. It cannot see private context. `DestinationCandidateBundleAssembler`
applies local interpretation/context matching and emits an ephemeral closed
bundle with opaque candidate aliases for the model. Capability evidence enters
only through the private context capsule and exact Relationship Registry edges.

### Structured contracts

The registered generation output contains interpretation revision, selected
candidate aliases, proposal role (`primary`, `adjacent`, `aspirational`,
`complement`), reason dimension IDs, evidence claim IDs, known unknown IDs,
tradeoff IDs and alternate-set grouping. It contains no free destination name,
source URL, eligibility assertion, numeric fit score or command.

Validation resolves aliases against the captured bundle, checks route-specific
requirements, source purposes/freshness, reason support, capability-transfer
semantics, diversity policy and prohibited claims. Final prose is deterministic
local rendering from semantic values plus bounded generated wording that cannot
introduce facts.

### Persistence and ownership

Interpretations/proposal sets are protected private drafts. Public corpus data
stays in Source Atlas/registry owners; canonical Goals stay in Goal repositories.
A saved draft stores exact public evidence IDs/hashes and no copied source body
beyond permitted display excerpts. Model raw envelopes are transient per the
runtime; the proposal set retains validation/provenance, not chain of thought.

Legacy deterministic recommendation artifacts are linked, not recast as
generated. Migration preserves their source/version claim ceiling. Clear one
draft removes its interpretation, proposal, generated wording, feedback and
evidence snapshots. Deleting an adopted Goal does not silently delete an
independently saved proposal; the UI offers explicit linked cleanup.

### Typed adoption handoff

`DestinationAdoptionInput` includes proposal/set/revision, exact destination and
route, evidence bindings, user-selected intent/context, unknowns and provenance.
It contains no authorized command. Adoption fetches current versions, shows its
own preview, and may reject stale/unsupported input. A return receipt binds the
new Goal to the proposal without making the proposal canonical authority.

## Privacy and accessibility

All ambition text, interpretations, capability/context filters and behavior stay
private/on-device by default. Public retrieval uses fixed local releases.
Private runtime context uses only registered fields. Dismiss/report/reorder
events are not implicit learning inputs. Search/model/network diagnostics contain
no private text or stable user ID.

Interpretation facets are ordinary controls, not a chat transcript dependency.
Cards have headings, route labels, source/unknown lists and consistent action
order. Comparisons have list/table alternatives, textual rank/reason semantics,
largest Dynamic Type reflow, VoiceOver summaries plus detail, Voice Control,
Switch Control, keyboard, Reduced Motion, RTL and non-color states. Focus returns
to the changed facet/candidate after edit/dismiss/retry.

## Requirement traceability

| Scope | Design decision |
|---|---|
| REQ-001 | Separate revisioned statement and facet draft |
| REQ-002 | Registered explicit fields and no behavioral profile input |
| REQ-003 | Closed public candidate bundle and alias validation |
| REQ-004 | Per-domain providers and route validators |
| REQ-005 | Role/reason/diversity policy without universal score |
| REQ-006 | Exact evidence bindings and semantic rendering |
| REQ-007 | Capability adapter and transfer validator |
| REQ-008 | User-controlled local context and typed unknowns |
| REQ-009 | Optional current-evidence adapter and narrow invalidation |
| REQ-010 | Registered private-runtime task only |
| REQ-011 | Revisioned edit/retry/reorder/dismiss/report controls |
| REQ-012 | Non-authoritative adoption input and owner revalidation |
| REQ-013 | Sparse/manual/deterministic recovery states |
| REQ-014 | Actor, revision capture, repositories and scoped purge |
| REQ-015 | Evaluation bindings on set/candidate/claim slices |
| REQ-016 | Structured accessible non-shaming projections |

## Verification design

- Interpretation tests for ambiguity, correction, sensitive fields and no hidden
  facet inference.
- Closed-bundle tests rejecting minted IDs, stale aliases, false equivalence,
  unsupported facts, citations, current claims and transfer reasons.
- Cross-domain golden cases spanning adjacent/aspirational/complement, sparse
  coverage and truthful fewer-results behavior.
- Private runtime/provider/network canaries and no command-path audit.
- Concurrency/change/replay/migration/purge/adoption-staleness fault tests.
- Slice evaluation for fidelity, grounding, diversity, transfer, unknowns,
  sensitive inference, bias/dignity, correction and usefulness.
- Accessibility/UI/device evidence plus latency/memory/energy for retrieval,
  generation, validation, comparison and cancellation at representative scale.

## Open decisions

None. Initial corpus breadth limits are handled by sparse/source-needed states,
not by inventing destinations or delaying the architecture.

Review verdict: **PASS** after two reconciliation rounds. Review made the model
bundle alias-only, isolated private/public retrieval, constrained prose, and
made adoption a separate revalidation. Devan delegated approval; Design was
approved on 2026-08-04.
