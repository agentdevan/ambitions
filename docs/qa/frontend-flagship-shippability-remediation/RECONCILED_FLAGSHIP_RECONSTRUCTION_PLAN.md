<!-- markdownlint-disable MD013 -->

# Reconciled Flagship Reconstruction Plan

Status: Current planning authority; `POST_VC14_NATIVE_CALIBRATION / PRE_CROSS_ROOT_PROPAGATION`; implementation entry is closed
Date: 2026-07-28
Baseline: `5ba9814f2636f148eb5e455b0a791299dcab0849` or later on `main`
Owner control: `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md`

## Purpose and boundary

This plan replaces the active sequencing in the historical frontend execution
ledger. It consumes the reconciled canon and ADRs; it does not authorize an
implementation packet. Figma authorization, SwiftUI approval, and
implementation authorization are false. Native SwiftUI previews and the
Native Visual Foundry are the current proving environment; Figma remains
optional documentation and is not visual authority or a sequencing gate.

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
  -> R10 Wave 1 shared visual foundation [COMPLETE]
  -> R10 Wave 2 surfaces and journeys [COMPLETE]
  -> R10 Wave 3 stress and matched baseline / VC-13 [COMPLETE]
  -> VC-14 reconciled native-matched closure [COMPLETE]
  -> Native Visual Foundry bootstrap [COMPLETE]
  -> Today native calibration [ACCEPTED PROVISIONALLY]
  -> cross-root native calibration [NEXT]
  -> separate SwiftUI approval [FALSE]
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
| R10 / Wave 1 shared visual foundation | Typography, appearance, crown, dock, state, and foundational grammar | `VC_WAVE_1_FOUNDATION_CLOSURE.md`, JSON peer, compiler validation, generated manifest | **COMPLETE** |
| R10 / Wave 2 surfaces and journeys | Surface and journey studies using the closed foundation | VC-07 through VC-12 closure records with matched target/capability boundaries | **COMPLETE** |
| R10 / Wave 3 stress and matched baseline | Cross-surface stress, accessibility transformation, and matched-baseline preparation | VC-13 stress closure and matched reference input | **COMPLETE** |
| R11 VC-14 reconciled matched-baseline closure | Cross-direction matched reference baseline | Completed VC-14 record and owner review of the matched study | **COMPLETE** |
| R12 Figma entry | Optional documentation only when separately authorized | Separate owner record | Authorization false; not a sequencing gate |
| R13 Figma journeys | Optional journey documentation | Separately authorized Figma proof | Not required for current native proving path |
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

R10 / Wave 1 shared visual foundation is **COMPLETE**. The source-owned
`VC_WAVE_1_FOUNDATION_CLOSURE.md` and JSON peer install the closed VC-01 through
VC-06 typography, appearance, crown, dock, state, and foundational grammar
decisions beneath the unchanged active AVF direction set. This is documentation
and authority closure only. It is not a final design system, component library,
Figma artifact, rendered baseline, runtime capability claim, or implementation
approval.

R10 / Wave 2 surfaces and journeys is **COMPLETE**: VC-07 through VC-12 are
closed. R10 / Wave 3 accessibility and content stress is **COMPLETE**: VC-13 is
closed. VC-14 and the visual-closure planning program are **COMPLETE**, the
Native Visual Foundry bootstrap is complete, and Today R14 is accepted as
provisional Today calibration evidence. The current position is
`POST_VC14_NATIVE_CALIBRATION / PRE_CROSS_ROOT_PROPAGATION`.

Native Foundry calibration proves visual and interaction direction against
synthetic fixtures. It does not prove production runtime ownership,
persistence, migration, settlement, restoration, or cutover. It does not
complete R2 through R9 or R15 through R16. Exact tokens, component APIs, final
component-library structure, production screenshot baselines, runtime
integration, and production cutover remain deferred and unauthorized.

### Figma

Figma remains optional documentation only. It is not visual authority and does
not gate the current package-backed native preview and cross-root calibration
sequence. Any future Figma work still requires separate owner authorization.

### SwiftUI and implementation

`APPROVED FOR SWIFTUI` remains false. Production implementation requires a
separate owner approval after cross-root synthesis and an explicit bounded work
packet with current source/tests, migration plan, proof lane, and rollback.
This plan intentionally contains no task-level production SwiftUI steps or
component APIs.

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
| Canon/UX direction | Ready for reconciled specification use | Normative owners and active direction IDs are aligned. |
| R10 / Wave 1 shared visual foundation | Complete | VC-01 through VC-06 are closed in the source-owned human and machine package and projected into generated authority. |
| R10 / Wave 2 surfaces and journeys | Complete | VC-07 through VC-12 are closed by the active Wave 2 closure authority. |
| R10 / Wave 3 stress and matched baseline | Complete | VC-13 is closed by the active Wave 3 closure authority. |
| VC-14 | Complete | Native matched closure and the bounded Native Foundry bootstrap are complete. |
| Today native calibration | Accepted provisionally | R14 is accepted as Today calibration evidence; it is not production-final. |
| Identity migrations | Not implementation-ready | Designs exist; schemas/migrations/tests do not. |
| Runtime capability | Not implementation-ready | Registry closure, typed states, and proof are incomplete. |
| Accessibility/localization | Ready for infrastructure planning | Proof plan exists; implementation/direct evidence absent. |
| Figma | Not authorized | Optional documentation only; it is not visual authority or a sequencing gate. |
| SwiftUI | Not approved | Cross-root synthesis, production proof, and separate owner approval remain absent. |
| Legacy deletion | Not ready | Replacement parity does not exist. |

## Integrity

This plan authorizes architecture, UX Blueprint, runtime, reconstruction, and
accessibility planning. It authorizes no Figma artifact, SwiftUI work, frontend
implementation, migration, source deletion, target change, or product-code
modification. Broad reconstruction, runtime integration, production cutover,
and `APPROVED FOR SWIFTUI` remain false. Foundry fixture evidence must not be
used as proof of production persistence, settlement, restoration, migration,
or cutover.
