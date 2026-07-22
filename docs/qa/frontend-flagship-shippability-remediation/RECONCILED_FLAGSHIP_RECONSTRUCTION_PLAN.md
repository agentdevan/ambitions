# Reconciled Flagship Reconstruction Plan

Status: Current planning authority; implementation entry is closed
Date: 2026-07-22
Baseline: `0e894407a38759f69d2a3e48111bae67720794b0` or later on `main`
Owner control: `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md`

## Purpose and boundary

This plan replaces the active sequencing in the historical frontend execution
ledger. It consumes the reconciled canon and ADRs; it does not authorize an
implementation packet. Figma authorization, SwiftUI approval, and
implementation authorization are false.

## Dependency graph

```text
Canon/architecture authority
  -> identity and owner migrations
  -> shell/navigation/restoration
  -> truth-state and mutation contracts
  -> Goals/Today/Time projections
  -> Search/Capture owner transfer
  -> You capability pruning
  -> persistence/recovery capability gates
  -> accessibility/localization infrastructure
  -> reconciled visual closure studies
  -> VC-14 matched baseline
  -> Figma authorization
  -> Figma journey specification
  -> SwiftUI approval
  -> clean frontend implementation
  -> legacy authority deletion after parity proof
```

No milestone may treat a later arrow as evidence for an earlier dependency.

## Milestones

| Milestone | Scope | Exit evidence | Current posture |
| --- | --- | --- | --- |
| R1 Canon and architecture authority | Accepted ADRs, canonical specifications, UX Blueprint, traceability | Canon compiler/check, links, authority register | Established by documentation; runtime unproven |
| R2 Identity and owner migrations | Life Area, Event, Schedule Placement, Goal/Step bridge designs and migration implementation | Migration/replay/parity/rollback tests | Planning only |
| R3 Shell/navigation/restoration | One shell owner, four root paths, global origin, versioned restoration | State, path, restore, stale-target, Back/focus tests | Planning only |
| R4 Truth and mutation | Shared algebra, registry closure, settlement, Receipt, Undo | Lifecycle, dedupe, replay, inverse, failure tests | Planning only |
| R5 Root projections | Life Area Goals, Start Here/Also Fits Now Today, Time truth distinctions | Identity/lineage/local-action/handoff tests | Planning only |
| R6 Search and Capture | Bounded Capture and owner-routed Search | Failure, provenance, transfer, restoration tests | Planning only |
| R7 You pruning | Nine-group local/no-account surface; accent migration | Capability inventory, absence, preference migration tests | Planning only |
| R8 Persistence/recovery gates | Only approved durable drafts/outboxes/recovery | Interruption, retry, cancel, publication, conflict tests | Planning only |
| R9 Accessibility/localization | Focus, announcements, catalogs, RTL and input equivalence | Automated plus direct device matrix | Planning only |
| R10 Visual closure studies | Reconciled directions only | Updated closure records; no implementation claim | Blocked by R1–R9 contracts/proof definitions |
| R11 VC-14 matched baseline | Cross-direction matched reference baseline | Owner review of matched study | Not authorized |
| R12 Figma entry | Owner explicitly declares `SELECTED FOR FIGMA` | Separate owner record | Authorization false |
| R13 Figma journeys | Journey-level design/QA | Authorized Figma proof | Blocked |
| R14 SwiftUI entry | Owner explicitly declares `APPROVED FOR SWIFTUI` | Separate owner record | Approval false |
| R15 Clean implementation | New frontend consumes proven contracts | Scoped implementation/test/device proof | Authorization false |
| R16 Legacy deletion | Remove replaced product/frontend authority | Parity, rollback, archive, deletion proof | Blocked by cutover |

## Migration plan

| Migration | Required preparation | Cutover proof | Rollback |
| --- | --- | --- | --- |
| Fixed enum Life Areas → records | Stable `LifeAreaRecord`, deterministic default mapping, Goal membership rule | Idempotent migration, count/reference/history parity, replay | Preserve source encoding until verified cutover |
| `TimeBlock` observations → Event/Placement authority | Event source/series/occurrence identity; Placement truth state | Accepted/proposed/external distinction, import reconciliation, deletion/history | Dual-read diagnostics only; no dual mutation authority |
| Goal/Step identity bridge | Stable translation and collision policy | Projection, Search, Receipt, restoration identity tests | Retain legacy IDs as migration aliases |
| Duplicate Search projections | Canonical owner/ID/projection cursor | Deduplication and failure-state tests | Rebuild index from canonical owners |
| Custom shell duplication | Single shell model and root-path store | Root/depth/Back/dock/global/focus/restoration parity | Retain old rail behind a bounded cutover gate |
| Inactive-root route depth | Selected-root depth derivation | Four-root independent path matrix | Restore previous shell only if no state loss |
| Direct repository writes | Mutation registry and typed owner commands | Registry closure and replay/Receipt proof | No cutover until each path has an owner |
| Unsupported You surfaces | Current capability inventory and absence policy | Route/row absence plus migration of valid preferences | Preserve data, not fictional rows |
| Synthetic labels/Receipts | Runtime result and Receipt registry | No label without matching state record | Hide unsupported presentation |
| Stale architecture checkers | Current owner/path/target manifest | Checker parity against accepted ADRs | Keep old output historical, never blocking current work |
| Obsolete visual/frontend authority | Supersession register and matched replacement | Link/authority scan and owner acceptance | Archive historical evidence |

## Deletion plan

Deletion occurs only after replacement parity and rollback evidence. Candidate
classes—not authorized deletions—are the bottom-rail visual authority, duplicate
shell/path stores, enum Life Area authority, observation-as-placement aliases,
duplicate Search projection ownership, fictional You rows/routes, synthetic
Receipt/Undo labels, stale architecture checkers, and superseded visual
campaign control text. Historical audit evidence remains intact.

For each deletion, record exact source owner, replacement owner, data migration,
behavior parity, proof artifacts, fallback window, and repository search showing
no remaining live references.

## Proof-gate matrix

| Gate | Required evidence |
| --- | --- |
| Source/canon/compiler | `ambitions-canon build --check`, `check`, generated parity, schema and link validation |
| Object migration | Fixture corpus, idempotency, interrupted migration, replay digest, count/reference/history parity |
| Runtime replay | Duplicate command, stale revision, pre/post-commit failure, projection rebuild, external retry |
| Shell restoration | Four root paths, selected-root depth, version migration, stale target, global origin, Back/focus |
| Mutation registry | Every active mutation path has owner, command, settlement, Receipt policy, Undo capability, proof IDs |
| Receipt/Undo | Durable linkage/retention plus actual inverse execution; no rollback-ID inference |
| Search/Capture | Bounded extraction, ambiguity, failure distinction, owner revalidation, settlement, return |
| Accessibility | Matrix in `RP_RECONCILIATION_ACCESSIBILITY_PLATFORM_PLAN.md` |
| Localization | Catalog completeness, plural/date/time/unit formatting, RTL, pseudolocalization, long text |
| Simulator visual | Named OS/device/build and reference comparison; geometry/copy only |
| Physical device | Back-edge/dock, keyboard, focus/speech, locked privacy, performance, external surfaces |
| External surface | Per-target source, adapter, privacy, failure, stale/offline, device proof |
| Visual reference | Reconciled direction ID and matched state/appearance/accessibility matrix |
| Legacy deletion | Replacement parity, no live references, migration/rollback, historical preservation |

## Entry criteria

### Reconciled visual closure and VC-14

R1–R9 contracts must be stable enough to prevent visual work from depicting an
unsupported owner, object, state, platform, permission, restoration promise, or
settlement. The two authorized branches and six revisions are the only current
direction IDs.

### Figma

Figma remains closed until owner authorization after the reconciled Goals and
Today branches, shell contract, identity/ownership matrix, truth/mutation/
Receipt/Undo contract, Search/Capture transfer contract, supported You
inventory, persistence/recovery matrix, accessibility/localization plan,
updated closure studies, and VC-14 matched baseline all exist and agree.

### SwiftUI and implementation

SwiftUI remains closed until a separate owner approval after authorized Figma
journey specification and QA. Implementation requires an explicit bounded work
packet with current source/tests, migration plan, proof lane, and rollback. This
plan intentionally contains no task-level SwiftUI steps or component APIs.

## Risk register

| Risk | Consequence | Control |
| --- | --- | --- |
| Visual target outruns runtime | Fictional state/action | Capability manifest and proof-gated rows |
| Identity migration duplicates objects | Lost linkage/history | Stable aliases, idempotency, parity/replay tests |
| Custom dock breaks native behavior | Back/focus/gesture exclusion | Framework boundary plus physical-device gate |
| Projection becomes owner | Divergent cross-root truth | ID lineage and owner-only mutation |
| Multi-owner operation fakes settlement | Misleading trust | Atomic commits until typed scope model |
| Generic queue overclaims offline | Lost/premature work | Domain-specific pending contract only |
| UX Blueprint legacy rows look current | Wrong design scope | Explicit reconciliation overlay and supersession register |
| Historical code removed early | Irrecoverable regression | R16 only after parity/rollback proof |

## Readiness scorecard

| Area | Readiness | Reason |
| --- | --- | --- |
| Owner choices | Ready | D-DEV-01 through D-DEV-10 are controlling and closed. |
| Architecture contracts | Ready for implementation planning | Accepted ADRs define owners and boundaries; runtime proof absent. |
| Canon/UX direction | Ready for reconciled specification use | Normative owners and provisional direction IDs are aligned. |
| Identity migrations | Not implementation-ready | Designs exist; schemas/migrations/tests do not. |
| Runtime capability | Not implementation-ready | Registry closure, typed states, and proof are incomplete. |
| Accessibility/localization | Ready for infrastructure planning | Proof plan exists; implementation/direct evidence absent. |
| Figma | Not authorized | Required closure/VC-14 gate and owner declaration absent. |
| SwiftUI | Not approved | Figma journey authority and owner approval absent. |
| Legacy deletion | Not ready | Replacement parity does not exist. |

## Integrity

This plan authorizes architecture, UX Blueprint, runtime, reconstruction, and
accessibility planning. It authorizes no Figma artifact, SwiftUI work, frontend
implementation, migration, source deletion, target change, or product-code
modification.
