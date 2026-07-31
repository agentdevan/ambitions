<!-- markdownlint-disable MD013 -->

# Reconciled Flagship Reconstruction Plan

Status: Current planning authority; `CAPTURE_NATIVE_CALIBRATION_PROVISIONALLY_CLOSED / FLAGSHIP_ENRICHMENT_AND_CROSS_ROOT_SYNTHESIS_NEXT_NOT_BEGUN / PRODUCTION_RECONSTRUCTION_BLOCKED`
Date: 2026-07-31
Baseline: `e028eefbc18f9af2deb1b14beacd2a0eb0e5b40c` or later on `main`
Owner control: `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md`

## Purpose and boundary

This plan replaces the active sequencing in the historical frontend execution
ledger. It consumes the reconciled canon and ADRs; it does not authorize an
implementation packet. Search and Capture calibration are provisionally
closed. The phase immediately after synchronized Capture closeout is
**FLAGSHIP ENRICHMENT AND CROSS-ROOT SYNTHESIS**, which supersedes the narrower
planned phrase **Cross-Root Synthesis**.

Figma authorization = false.
`APPROVED_FOR_SWIFTUI = false`.
Production reconstruction authorization = false.
Legacy cutover authorization = false.
Foundry SwiftUI is permitted only for fixture-driven provisional calibration
and enrichment evidence. That evidence is not production SwiftUI approval,
production runtime proof, a component-library contract, or implementation
authorization.

Broad production reconstruction remains blocked until:

1. Capture remains closed under its accepted bounded proof ceiling.
2. Flagship Enrichment and Cross-Root Synthesis completes.
3. The enriched direction is reconciled with the completed architecture and
   flagship-reconstruction baseline.
4. A production reconstruction contract is approved.

The earlier parallel documentation-only operating-plan update did not modify
the then-active Capture campaign. Capture has now reconciled onto that updated
baseline and closed without changing its accepted UI, tests, fixtures,
screenshots, or proof ceiling.

## Current calibration status

- Today native calibration: provisionally closed.
- Goals native calibration: provisionally closed.
- Time native calibration: provisionally closed.
- You native calibration: provisionally closed.
- Search native calibration: provisionally closed.
- Capture native calibration: provisionally closed with accepted bounded R01 evidence.
- Flagship Enrichment and Cross-Root Synthesis: next phase; not begun.

The provisionally closed roots and global journeys are accepted bounded
Foundry calibration evidence, not production approval. No isolated native
calibration campaign remains active.

## Dependency graph

```text
Completed architecture and flagship-reconstruction baseline
  -> reconciled visual closure and Native Visual Foundry
  -> Today native calibration [PROVISIONALLY CLOSED]
  -> Goals native calibration [PROVISIONALLY CLOSED]
  -> Time native calibration [PROVISIONALLY CLOSED]
  -> You native calibration [PROVISIONALLY CLOSED]
  -> Search native calibration [PROVISIONALLY CLOSED]
  -> Capture native calibration [PROVISIONALLY CLOSED]
  -> Capture owner acceptance and synchronized closeout [COMPLETE]
  -> Flagship Enrichment and Cross-Root Synthesis [NEXT; NOT BEGUN]
  -> owner-selected enriched provisional visual direction
  -> reconciliation against completed architecture and reconstruction baseline
  -> production reconstruction contract
  -> real production Today vertical slice
  -> production Goals / Time / You / Search / Capture / shell reconstruction
  -> legacy cutover
  -> physical-device refinement
  -> complete accessibility proof
  -> release validation
```

No broad production frontend implementation, production wiring, component
finalization, or legacy cutover may begin before Flagship Enrichment and
Cross-Root Synthesis and the following reconciliation gate are complete.

No later arrow provides evidence for an earlier dependency.

## Active Frontend Reconstruction Critical Path

| Milestone | Current posture | Scope and exit evidence |
| --- | --- | --- |
| **FR-1 — Complete Capture native calibration and closeout** | **PROVISIONALLY_CLOSED** | Owner-accepted bounded Capture evidence, protected characteristics, non-frozen boundaries, architecture-sensitive assumptions, exact proof ceiling, synchronized `main`, `CAPTURE_NATIVE_CALIBRATION = PROVISIONALLY_CLOSED`, and `APPROVED_FOR_SWIFTUI = false` are recorded. |
| **FR-2 — Flagship Enrichment and Cross-Root Synthesis** | **NEXT_NOT_BEGUN** | Entry follows synchronized Capture closeout. Exit requires all charter deliverables; an owner-selected enriched direction; a unified system direction; a reconstruction handoff packet; and no production authorization. |
| **FR-3 — Enriched-direction architecture and baseline reconciliation** | **BLOCKED_BY_FR-2** | Reconcile the enriched visual and behavioral direction against completed architecture, UX Blueprint and navigation ownership, capability boundaries, current runtime reality, flagship-reconstruction baseline, and accepted Foundry evidence. Exit requires conflicts resolved or explicitly deferred; production-relevant assumptions classified; no duplicate route, object, state, or mutation authority; and owner acceptance of the reconciled direction. |
| **FR-4 — Production reconstruction contract** | **BLOCKED_BY_FR-3** | Exit requires exact production scope; source and runtime owners; migration and deletion boundaries; fixture-to-production separation; implementation sequencing; state, navigation, accessibility, device, and rollback proof; and explicit owner authorization. |
| **FR-5 — Real production Today vertical slice** | **BLOCKED_BY_FR-4** | This is the first production reconstruction implementation. It must prove real production ownership, routing, persistence, mutation, settlement, restoration, accessibility, device behavior, and visual fidelity. Foundry acceptance alone is not sufficient. |
| **FR-6 — Full production frontend reconstruction** | **BLOCKED_BY_FR-5** | Extend the proven production reconstruction model across Goals, Time, You, Search, Capture, Crowned Edge Dock and global shell, plus shared state, materials, motion, accessibility, and return behavior. |
| **FR-7 — Cutover, refinement, accessibility, and release** | **BLOCKED_BY_FR-6** | Scope is legacy frontend authority deletion; migration and rollback; physical-device refinement; Crowned Edge Dock viability; complete assistive-technology proof; localization and RTL; performance and energy; and release/App Store validation. |

FR-1 closeout must also preserve the information required for FR-2:

- global presentation behavior;
- expression and original-word retention;
- interpretation and clarification boundaries;
- review and owner handoff;
- cancellation and return;
- keyboard and accessibility behavior;
- visual strengths and sterile or unresolved areas;
- architecture-sensitive assumptions.

This requirement does not expand the active Capture implementation scope.

## Historical R1–R16 traceability

These records remain historical traceability. They are not a competing active
queue and are not renumbered or deleted.

| Milestone | Scope | Exit evidence | Historical posture |
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
| R14 SwiftUI entry | Owner explicitly declares `APPROVED FOR SWIFTUI` | Separate owner record | **Superseded by FR-1 through FR-7; approval false** |
| R15 Clean implementation | New frontend consumes proven contracts | Scoped implementation/test/device proof | **Superseded by FR-1 through FR-7; authorization false** |
| R16 Legacy deletion | Remove replaced product/frontend authority | Parity, rollback, archive, deletion proof | **Superseded by FR-1 through FR-7; cutover authorization false** |

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

## Operating status language

- **PROVISIONALLY_CLOSED** — accepted bounded Foundry calibration; not
  production.
- **ACTIVE** — current authorized campaign.
- **NEXT_NOT_BEGUN** — next dependency-satisfied phase; no work has started.
- **BLOCKED_BY_FR-N** — dependency not complete.
- **READY_FOR_OWNER_SELECTION** — complete proposal awaiting Devan.
- **SELECTED_FOR_SYNTHESIS** — owner-selected exploration input.
- **SELECTED_AS_PROVISIONAL_VISUAL_DIRECTION** — accepted provisional
  direction.
- **PRODUCTION_AUTHORIZED** — may be used only after explicit owner approval
  and the production reconstruction contract.

During FR-1 and FR-2, `SELECTED FOR FIGMA`, `APPROVED FOR SWIFTUI`,
production ready, flagship complete, and release ready are not positive
statuses.

## Future campaign queue

| Order | Campaign | Status | Entry dependency |
| --- | --- | --- | --- |
| 1 | Capture native calibration and closeout | **PROVISIONALLY_CLOSED** | Accepted bounded R01 evidence and synchronized closeout |
| 2 | Flagship Enrichment and Cross-Root Synthesis | **NEXT_NOT_BEGUN** | Accepted and synchronized Capture closeout |
| 3 | Enriched-direction architecture and reconstruction reconciliation | **BLOCKED_BY_FR-2** | Owner-selected enriched direction and handoff |
| 4 | Production reconstruction contract | **BLOCKED_BY_FR-3** | Reconciled direction |
| 5 | Production Today vertical slice | **BLOCKED_BY_FR-4** | Approved production contract |
| 6 | Goals, Time, You, Search, Capture, and shell reconstruction | **BLOCKED_BY_FR-5** | Successful production Today slice |
| 7 | Legacy cutover, device refinement, accessibility proof, and release validation | **BLOCKED_BY_FR-6** | Full replacement parity |

There is no additional isolated root campaign after Capture. Any new
structural proposal belongs inside FR-2 as an explicit new branch with a new
stable ID.

## Readiness scorecard

| Area | Readiness | Reason |
| --- | --- | --- |
| Today | Accepted provisional calibration | Bounded Foundry evidence; not production-final. |
| Goals | Accepted provisional calibration | Bounded Foundry evidence; not production-final. |
| Time | Accepted provisional calibration | Bounded Foundry evidence; not production-final. |
| You | Accepted provisional calibration | Bounded Foundry evidence; not production-final. |
| Search | Accepted provisional calibration | Bounded Foundry evidence; not production-final. |
| Capture | Accepted provisional calibration | Bounded R01 Foundry evidence; not production-final. |
| Flagship Enrichment and Cross-Root Synthesis | Next; not begun | Capture entry dependency is satisfied; no FR-2 work began in closeout. |
| Production reconstruction | Blocked | FR-2, FR-3, FR-4, and owner authorization remain incomplete. |
| `APPROVED_FOR_SWIFTUI` | False | Foundry evidence remains provisional. |
| Legacy deletion | Blocked | FR-6 parity and FR-7 proof are incomplete. |

## Risk register

| Risk | Consequence | Control |
| --- | --- | --- |
| Visual target outruns runtime | Fictional state/action | Capability manifest and proof-gated rows. |
| Identity migration duplicates objects | Lost linkage/history | Stable aliases, idempotency, parity/replay tests. |
| Custom dock breaks native behavior | Back/focus/gesture exclusion | Framework boundary plus physical-device gate. |
| Projection becomes owner | Divergent cross-root truth | ID lineage and owner-only mutation. |
| Multi-owner operation fakes settlement | Misleading trust | Atomic commits until typed scope model. |
| Generic queue overclaims offline | Lost/premature work | Domain-specific pending contract only. |
| UX Blueprint legacy rows look current | Wrong design scope | Explicit reconciliation overlay and supersession register. |
| Historical code removed early | Irrecoverable regression | R16 only after parity/rollback proof. |
| Premature production reconstruction | The app hardens an under-enriched, sterile, or inconsistent Foundry state. | FR-2, FR-3, and FR-4 are mandatory before production Today implementation. |
| Superficial enrichment | A late restyle adds ornament without improving hierarchy, anatomy, continuity, or emotional quality. | Text directions precede rendering; structural differences remain explicit; enrichment is judged across complete journeys and states. |
| Cross-root divergence | Each root becomes locally polished but no longer feels like one product. | FR-2 compares all roots and global experiences together and produces one shared direction with root-specific expression. |
| Decorative complexity | Glass, cards, gradients, pills, rounding, metrics, or motion reduce clarity, performance, or accessibility. | Use the charter anti-goals and semantic-material requirements. |
| Premature component library | Component APIs freeze before complete journey semantics and production reconciliation. | FR-2 produces only a provisional shared-system inventory. Final APIs follow FR-3 and FR-4. |

## Capture closeout handoff

Capture reconciled onto the updated `main` baseline without changing accepted
UI, screenshots, fixture truth, source behavior, tests, or accessibility
composition. Its closeout records the evidence, protected characteristics,
unresolved visual opportunities, architecture-sensitive assumptions, and
proof ceiling needed as FR-2 inputs. The next campaign is FR-2, but no FR-2
implementation began here. Broad production wiring and isolated root campaigns
remain prohibited.

## Entry and proof boundary

R10 / Wave 1 shared visual foundation, R10 / Wave 2 surfaces and journeys,
R10 / Wave 3 accessibility and content stress, VC-14, and the Native Visual
Foundry bootstrap remain completed authority and evidence packages. Their
closure is documentation and bounded visual-direction evidence only.

Native Foundry calibration proves visual and interaction direction against
synthetic fixtures. It does not prove production runtime ownership,
persistence, migration, settlement, restoration, or cutover. Exact tokens,
component APIs, final component-library structure, production screenshot
baselines, runtime integration, and production cutover remain deferred and
unauthorized.

The UX Blueprint, navigation and surface ownership, capability boundaries,
architecture-sensitive assumption registers, and current runtime reality must
all be reconciled before a production contract is proposed. No fixture,
screenshot, or preview can substitute for that reconciliation.

## Integrity

This plan authorizes only the documentation-defined planning and provisional
enrichment evidence described above. It authorizes no Figma artifact, SwiftUI
approval, frontend implementation, migration, source deletion, target change,
production wiring, component finalization, or product-code modification.
Foundry fixture evidence must not be used as proof of production persistence,
settlement, restoration, migration, or cutover. Capture calibration is
provisionally closed; FR-2 is next and not begun. Production reconstruction
remains blocked.
