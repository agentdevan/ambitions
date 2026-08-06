+++
initiative = "grounded-generative-destination-proposals"
document_type = "scope"
status = "approved"
upstream = "research.md"
+++

## Outcome

A user can describe an ambition in ordinary language, review/correct Ambitions'
interpretation, and receive a small set of meaningfully different, source-
grounded career, education and hobby/life destination proposals. Every proposal
shows reasons, evidence, unknowns and route form; generation failure retains
manual/deterministic discovery. Nothing becomes a Goal without downstream
explicit adoption.

## In scope

- Revisioned ambition statement and user-visible Interpretation Draft.
- Explicit/edited/unknown/not-included facets and clarification alternatives.
- Deterministic retrieval from admitted domain corpora and relationship profiles.
- Optional user-approved capability/context bindings through private runtime.
- Registered structured proposal generation over a fixed candidate bundle.
- Domain/route-preserving cross-domain sets, adjacent/aspirational labels and
  option-preserving complements.
- Exact source/evidence/unknown/constraint/model provenance and validation.
- Edit, retry, alternate, reorder, dismiss, report, save-draft, clear/delete and
  handoff to existing adoption owner.
- Offline/model/source sparse states, accessibility and quality/user evidence.

## Out of scope

- Invented destinations, universal mixed taxonomy, universal fit/person score,
  personality/aptitude/employability inference, success prediction or ranking by
  prestige/popularity alone.
- Goal Path/Step generation, multi-Goal portfolio selection, scheduling,
  automatic Goal creation/adoption or external action.
- Hosted private free-text search, arbitrary web results, unsourced model facts,
  implicit feedback profiles or training on user data.
- Claiming qualification, admission, transfer, licensure, affordability,
  availability, safety or outcome.

## Requirements

### REQ-001 — Ambition and interpretation are separate revisions
The exact user statement remains visible. Derived facets are individually marked
explicit, edited, unknown or not included, with assumptions/questions editable.

### REQ-002 — No hidden person inference
Only user-approved task fields, explicit corrections and approved Capability/
Proof bindings may inform proposals. Sensitive or personality traits cannot be
inferred, persisted or used from behavior/absence.

### REQ-003 — Retrieval precedes generation
Candidate IDs must come from exact admitted corpus releases and approved
relationship purposes. Generated or unresolved IDs cannot enter a proposal.

### REQ-004 — Route/domain semantics remain intact
Career, education and hobby/life forms, evidence lanes and authority limits stay
distinct. Cross-domain relationships never imply equivalence or qualification.

### REQ-005 — Proposals are diverse and reason-bound
Return a small configurable set of meaningfully different supported options or
the truthful smaller set. Adjacent/aspirational/complement labels bind to exact
reasons; no universal score orders the user.

### REQ-006 — Every factual field is grounded
Identity, description, prerequisites, route characteristics, public relations
and current facts bind to source claims/releases/purpose/freshness. Generated
prose renders only validated semantics.

### REQ-007 — Capability transfer is evidence-limited
Only user-approved capabilities and exact public relationships may support a
transfer explanation. It must distinguish preserved progress, plausible
relevance, missing proof and authority-owned qualification.

### REQ-008 — Constraints and unknowns stay explicit
Included time/money/location/equipment/access/relationship/other constraints are
user-controlled and local. Unknown, stale, conflicting, unsupported and not
included cannot become negative fit or invented values.

### REQ-009 — Current facts are optional separate evidence
Current opportunities may decorate a proposal only through current-purpose
bindings. Missing/expired current data does not erase a destination or imply no
opportunity exists.

### REQ-010 — Generation is private-runtime bound
Use a registered task, minimal context, enabled mode, read-only tools, structured
envelope and deterministic validators. No direct provider/source network path.

### REQ-011 — Users control presentation and correction
Users can inspect interpretation/reasons/sources/limits, edit inputs, retry,
choose alternatives, change dimension ordering, dismiss/report/save/clear. A
correction never silently becomes a stable profile.

### REQ-012 — Adoption is explicit and downstream
Selection creates a revision-bound adoption preview input only. Destination
adoption revalidates and owns any Goal mutation/receipt/undo.

### REQ-013 — Failures preserve value
Model/source/corpus/relationship/current-data unavailable, sparse, invalid,
canceled or changed states retain manual entry, route forms, deterministic v1
recommendations and saved canonical truth.

### REQ-014 — Draft lifecycle is recoverable and deletable
Async results bind all revisions and discard stale work. Save/restore/migrate/
clear/delete are idempotent; deletion removes interpretation, candidate,
explanation, feedback and evidence snapshots without deleting source/canonical
owners.

### REQ-015 — Evaluation is slice and claim bound
Measure intent fidelity, ID/source grounding, unsupported claims, diversity,
transfer accuracy, unknown comprehension, sensitive inference, bias/dignity,
correction and usefulness by domain/route/coverage/model/task version.

### REQ-016 — The experience is accessible and non-shaming
Interpretation, alternatives, sources, unknowns and controls are textual,
ordered and assistive-technology usable. Copy never frames distance or missing
evidence as personal failure.

## Acceptance criteria

- AC-001/REQ-001: editing any facet creates a new visible interpretation revision.
- AC-002/REQ-002: sensitive/behavior/absence canaries never affect outputs.
- AC-003/REQ-003: unknown/minted/stale-version candidate IDs fail validation.
- AC-004/REQ-004: cross-domain fixtures preserve route labels and reject false
  equivalency/qualification.
- AC-005/REQ-005: sets show meaningful reasons or fewer results, never filler.
- AC-006/REQ-006: every rendered fact traces to an allowed current source claim.
- AC-007/REQ-007: transfer fixtures distinguish evidence/relevance/authority gaps.
- AC-008/REQ-008: unknown constraints never act as negative/zero/default values.
- AC-009/REQ-009: expired current evidence changes only its dependent decoration.
- AC-010/REQ-010: runtime boundary/privacy/security suites pass.
- AC-011/REQ-011: edits/retries/reorders/dismissals/reports remain local and clear.
- AC-012/REQ-012: no proposal path invokes a command; downstream revalidates.
- AC-013/REQ-013: every failure preserves manual/deterministic discovery.
- AC-014/REQ-014: concurrency/fault/purge tests prove stale discard and deletion.
- AC-015/REQ-015: hard-gate failures cannot be averaged away.
- AC-016/REQ-016: accessibility/device/user-language evidence passes.

## Frontend impact contract

- Surface impact: new-child
- IA/navigation: none
- Assets/iconography: system-only
- Visual language: unchanged
- Motion: unchanged
- Copy/localization: The approved requirements, acceptance criteria, and user flows own visible terminology and non-claims; implementation must localize that meaning without inventing promotional, score, authority, or outcome language.
- Accessibility: Every new child view and action must preserve the approved semantic order, Dynamic Type/reflow, assistive-input parity, non-color meaning, focus, announcements, and reduced-effects behavior.
- Visual proof: One production-intended native fixture and viewport requires owner visual approval before implementation, followed by changed-state runtime, screenshot, accessibility, and named-device evidence required by Verification.

## Canon impact

Add Grounded Destination Proposals canon; update recommendation/destination,
Capability, Source Atlas/current authority, private runtime, trust/degraded,
Receipts/History and adoption handoff specifications as applicable.

## Risks and open decisions

No hard fork remains. Corpus breadth and capability evidence may constrain the
number of supported options; the required behavior is a smaller truthful set,
not delayed Scope or fabricated breadth.

Review verdict: **PASS** after two reconciliation rounds. Review added explicit
interpretation revisions, route preservation, no-filler behavior, optional
current evidence and adoption isolation. Devan delegated approval; Scope was
approved on 2026-08-04.
