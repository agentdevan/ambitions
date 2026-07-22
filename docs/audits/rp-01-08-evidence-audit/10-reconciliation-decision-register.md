<!-- markdownlint-disable MD013 MD060 -->

# Reconciliation Decision Register

## Purpose

This register records decisions the repository cannot make on its own. Evidence IDs refer to the eight packets and the cross-packet register. D-DEV-01 through D-DEV-10 retain their original audit questions and evidence below, but are now resolved by the later controlling owner record. Architecture, UX Blueprint, Runtime, Reconstruction planning, and Accessibility/platform decisions remain unresolved and unchanged.

## Devan

| ID | Original unresolved decision | Evidence | Packets / directions | Original downstream dependency | Resolution status | Selected decision | Owner record |
| --- | --- | --- | --- | --- | --- | --- | --- |
| D-DEV-01 | Whether the locked right-edge six-control Crowned Edge Dock may supersede the current four-root bottom-navigation canon, or remains a separate visual branch pending a later canon change. | X-01; RP-01 E-RP01-011 | RP-01, RP-08; `AVF-SHELL-S07-R00` | Shell architecture, UX Blueprint, Figma later | `RESOLVED_BY_OWNER` | Preserve Crowned Edge Dock as the target flagship shell; require native-compatible semantics and `AVF-SHELL-S07-R01`; return to Devan if architecture proves it infeasible. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-02 | Whether the provisional Goal-led root or current canon’s editable Life-Area-led root is the intended future product authority. | X-06; RP-04 E-RP04-02 | RP-02, RP-04; `AVF-GOALS-S07-R01` | Life Area ontology, Goals reconstruction | `RESOLVED_BY_OWNER` | Goals becomes Life-Area-led; preserve Goal-owned Linked Goal Lens depth in `AVF-GOALS-S08-R00`. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-03 | Whether Today retains the locked maximum-three “What Matters Today” region or reconciles to canon’s one dominant `Start here` plus at most one suggestion. | X-07; RP-04 E-RP04-04 | RP-04; `AVF-TODAY-S09-R00` | Today priority ontology and first viewport | `RESOLVED_BY_OWNER` | Use one dominant Start Here projection and zero or one earned Also Fits Now projection in `AVF-TODAY-S10-R00`. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-04 | Whether a Today priority is always a projection of an existing canonical object or a new day-specific relation/object. | RP-02 canonical inventory; RP-04 Required decisions | RP-02, RP-04; `AVF-TODAY-S09-R00` | Identity, history, mutation owner | `RESOLVED_BY_OWNER` | A Today priority is a day-specific projection/admission relation against a canonical object, never a copied canonical object. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-05 | Whether Week is only the first-use default while last-used view is retained, or a stronger reset/root rule. | X-09 | RP-04; `AVF-TIME-S07-R00` | Time preference contract | `RESOLVED_BY_OWNER` | Week is the first-use default; restore the last-used supported scale later; record `AVF-TIME-S07-R01`. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-06 | Whether Search “Act” must feel in-place or may visibly transfer to an owning root while preserving Search identity and return context. | X-15; RP-05 Find/Understand/Act matrix | RP-05; `AVF-SEARCH-D07-R00` | Global action transfer UX | `RESOLVED_BY_OWNER` | Search is not a mutation owner; Act prepares and transfers to the canonical owner under `AVF-SEARCH-D07-R01`. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-07 | Whether multi-scope partial settlement is an essential protected behavior or remains explicitly provisional/omitted until runtime representation exists. | X-12 | RP-03, RP-05, RP-07; `AVF-RECOVERY-S07-R00` | Settlement architecture and visual states | `RESOLVED_BY_OWNER` | Show partial settlement only for genuinely independent typed scopes; otherwise split owner commits or use whole-result outcomes. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-08 | Whether restrained violet-indigo replaces or augments the current accent families, or remains future visual intent. | X-18; RP-06 Y07–Y08 | RP-06; `AVF-DNA-S07-R00`, `AVF-YOU-D07-R01` | Appearance migration and token work | `RESOLVED_BY_OWNER` | Restrained violet-indigo becomes the default action accent with deterministic preference migration and accessibility constraints. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-09 | Whether optional account/continuity/subscription capabilities belong in the selected You baseline. | RP-06 Y04, Y06, Y14 | RP-06; `AVF-YOU-D07-R01` | Account/entitlement IA and runtime scope | `RESOLVED_BY_OWNER` | Current flagship You is local/no-account; remove account, continuity, subscription, and cross-device administration; record `AVF-YOU-D07-R02`. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |
| D-DEV-10 | Whether Ambitions remains strictly iPhone/portrait or any iPad, Mac, landscape, multi-window, or other platform adaptation becomes product scope. | X-21; RP-08 E-RP08-012 | RP-08; `AVF-COHERENCE-S07-R00` | Platform architecture and proof matrix | `RESOLVED_BY_OWNER` | Current flagship scope is iPhone, portrait, single scene; other platforms remain future-only and external surfaces require direct proof. | [13-owner-reconciliation-decisions.md](13-owner-reconciliation-decisions.md) |

## Owner-authorized provisional direction outcomes

| Direction record | Treatment | Remaining decision authority / downstream dependency |
| --- | --- | --- |
| `AVF-GOALS-S08-R00 — Life Area Linked Goal Lens` | New structural branch authorized by D-DEV-02; supersedes `AVF-GOALS-S07-R01` only for Goals root structure. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |
| `AVF-TODAY-S10-R00 — Start Here Contextual Command` | New structural branch authorized by D-DEV-03; supersedes `AVF-TODAY-S09-R00` only for first-viewport hierarchy. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |
| `AVF-SHELL-S07-R01` | Targeted shell reconciliation revision authorized by D-DEV-01. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |
| `AVF-CAPTURE-S07-R01` | Targeted bounded Capture revision authorized by the owner reconciliation. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |
| `AVF-TIME-S07-R01` | Targeted capability-bounded Time revision authorized by D-DEV-05. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |
| `AVF-SEARCH-D07-R01` | Targeted owner-routed Search revision authorized by D-DEV-06. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |
| `AVF-YOU-D07-R02` | Targeted local/no-account You revision authorized by D-DEV-09. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |
| `AVF-RECOVERY-S07-R01` | Targeted capability-negotiated recovery revision authorized by D-DEV-07. | Architecture, UX Blueprint, Runtime, Reconstruction planning, Accessibility/platform planning |

Figma authorization remains false. SwiftUI approval remains false. Implementation authorization remains false.

## Architecture

| ID | Unresolved decision | Evidence | Packets / directions | Downstream dependency |
| --- | --- | --- | --- | --- |
| D-ARC-01 | Select the root-container model and single owner of root selection, root-local paths, global presentations, crown state, and selected-root-aware depth. | X-01, X-03; RP-01 E-RP01-004–006 | RP-01 | Shell reconstruction |
| D-ARC-02 | Define one persistable, versioned navigation/restoration record and stale-target validation boundary. | X-04 | RP-01, RP-05, RP-07, RP-08 | Runtime restoration and accessibility focus |
| D-ARC-03 | Decide the native-versus-custom ownership boundary for title, Back, safe areas, gestures, toolbars, focus, and dock. | RP-01 crown/dock analysis; X-02 | RP-01, RP-08 | UX Blueprint and SwiftUI later |
| D-ARC-04 | Define canonical Life Area identity, persistence, membership, lifecycle, and migration from enum-derived values. | X-05, X-06; RP-02 E-RP02-04 | RP-02, RP-04 | Goals root and Search consolidation |
| D-ARC-05 | Define how canonical Event, series, occurrence, Schedule Placement, and current `TimeBlock` identities relate and migrate. | X-05, X-10; RP-02 E-RP02-03 | RP-02, RP-04, RP-07 | Calendar/Time reconstruction |
| D-ARC-06 | Resolve String Goal/Step IDs and UUID temporal-context/occurrence IDs, with one explicit bridge or separation law. | RP-02 unsupported identity risks | RP-02, RP-04 | Projection routing and deduplication |
| D-ARC-07 | Define a shared fit/capacity contract used by Today and Time without creating a second schedule owner. | RP-04 shared-concept table and RP04-C08 | RP-04 | Today admission and Time availability |
| D-ARC-08 | Define the accepted/proposed/external/current truth contract for every temporal projection. | X-08 | RP-03, RP-04 | Runtime models and visual semantics |
| D-ARC-09 | Define canonical Settlement Ledger ownership and whether it projects `RuntimeCommitReceipt` plus side-effect records or introduces a new record. | X-11, X-12; RP-03 Settlement Ledger analysis | RP-03, RP-05, RP-07 | Partial settlement, receipts, recovery |
| D-ARC-10 | Decide between one product-wide truth-state algebra and explicitly capability-negotiated domain-specific state models. | RP-03 state matrix | RP-03, RP-07 | Copy/state language and tests |
| D-ARC-11 | Select or layer the canonical active Search projection: FTS authority, repository aggregation, or another explicitly owned projection. | RP-05 E05-09–E05-10 | RP-02, RP-05 | Search provenance, freshness, identity |
| D-ARC-12 | Define a global action-transfer envelope containing object identity, owner, revision, preview, confirmation, result, Receipt, and return context. | X-15; RP-05 authority boundary | RP-01, RP-03, RP-05 | Search/Capture owner transfer |
| D-ARC-13 | Define durable pending-operation ownership and whether local commands, external side effects, and future sync share an envelope or remain separate. | X-16; RP-07 pending matrix | RP-03, RP-07 | Retry, cancellation, later settlement |
| D-ARC-14 | Define source priority, verification/freshness, conflict ownership, and the threshold for contextual versus system-wide recovery. | RP-07 synchronization/conflict matrices | RP-05, RP-07 | Recovery and Local Truth Horizon |
| D-ARC-15 | Reconcile personal context/learning ownership with canon’s no-knowledge-dashboard law and prohibit a second memory authority. | X-17; RP-06 Y02, Y12 | RP-02, RP-06 | You IA and data actions |
| D-ARC-16 | Define canonical command owners for export/delete/reset, backup/restore, source removal, account continuity, and preference density if approved. | RP-06 Y03, Y07, Y12–Y14 | RP-06, RP-07 | You destructive actions |
| D-ARC-17 | Select the runtime accessibility-focus owner and localization infrastructure, including external-surface privacy ownership. | X-20; RP-08 E-RP08-003, 006–008 | RP-01, RP-08 | Accessibility gates and shell input |

## UX Blueprint

| ID | Unresolved decision | Evidence | Packets / directions | Downstream dependency |
| --- | --- | --- | --- | --- |
| D-UX-01 | Define right/left/RTL dock placement, Hidden/Peek/Expanded semantics, keyboard posture, reach, scroll/gesture arbitration, and equivalent labeled/opaque/lower-reach modes. | X-02 | RP-01, RP-08 | Shell feasibility and accessibility proof |
| D-UX-02 | Define the exact meaning of “same place” for overlay dismissal, owner transfer, interruption, and relaunch. | X-04 | RP-01, RP-05, RP-07, RP-08 | Restoration schema and tests |
| D-UX-03 | Reconcile the Goals root hierarchy and specify where the inline Linked Goal Lens lives without becoming a second owner. | X-06; RP-04 AVF-GOALS evaluation | RP-02, RP-04 | Goals reconstruction |
| D-UX-04 | Reconcile Today label/count/hierarchy and specify whether priority is a projection or relation. | X-07 | RP-04 | Today runtime projection |
| D-UX-05 | Define local narrow action versus owner handoff for Goal, Step, Event, Placement, and personal-context projections. | RP-02 editing matrix; RP-04 boundary matrix | RP-02, RP-04, RP-05 | Cross-root action behavior |
| D-UX-06 | Define “personally usable opening” versus calendar-open time and the visual distinctions among proposed, accepted, external, protected, flexible, conflict, and recovery states. | X-08; RP04-C08 | RP-04, RP-07 | Time/Today semantic language |
| D-UX-07 | Define unavailable Undo, no-op, pending, failure, partial outcomes, post-authority recovery, and irreversible action disclosure. | RP-03 matrices | RP-03, RP-06, RP-07 | Receipt/settlement presentation |
| D-UX-08 | Define Capture ambiguity, correction preservation, conflict/no-conflict disclosure, and constraints for unsupported interpretation/input modes. | X-14; RP-05 Capture matrices | RP-05 | Capture journey |
| D-UX-09 | Define Search failure versus no-result, evidence/freshness/uncertainty, owner transfer, and return behavior. | X-15; RP-05 Search matrices | RP-05, RP-07 | Search journey |
| D-UX-10 | Resolve `What Ambitions Knows` against the no-knowledge-model law and dedicated Help against current You canon. | X-17; RP-06 Y01–Y02 | RP-06 | You navigation and content |
| D-UX-11 | Decide which unsupported You rows disappear versus remain as honest unavailable/status-only information; define Receipt thresholds for preference, permission, external, and destructive actions. | RP-06 Y03–Y13 | RP-06 | You reconstruction |
| D-UX-12 | Define VoiceOver grouping/order, focus return, keyboard traversal, RTL order, long-text behavior, and sensitive-content speech/preview behavior. | X-20; RP-08 risk matrices | RP-01, RP-08 | Accessibility/platform proof scripts |

## Runtime

| ID | Unresolved decision or required contract | Evidence | Packets / directions | Downstream dependency |
| --- | --- | --- | --- | --- |
| D-RUN-01 | Implement or explicitly decline durable root/path/selection/focus/query/expression restoration and stale-target recovery. | X-04 | RP-01, RP-05, RP-07 | Exact-context claims |
| D-RUN-02 | Implement actual accessibility focus/announcement transitions; logical policy types alone are insufficient. | X-20 | RP-01, RP-08 | Direct assistive proof |
| D-RUN-03 | Implement/prove editable Life Areas, canonical Events/Placements, complete Goal lifecycle/history, and exact owner routing if current canon remains authoritative. | X-05, X-06, X-10 | RP-02, RP-04 | Visual continuity claims |
| D-RUN-04 | Encode accepted/proposed placement authority and complete selected Time scale/last-used-view behavior. | X-08, X-09 | RP-04 | Time/Today truth display |
| D-RUN-05 | Close registry-unproven Goal, Step, Time, Capture, Search-action, and external-write rows before universal Receipt/owner claims. | X-11 | RP-02–RP-07 | Proof gates |
| D-RUN-06 | Add typed per-scope settlement outcomes or explicitly constrain approved operations to whole-result settlement. | X-12 | RP-03, RP-05, RP-07 | Settlement Ledger |
| D-RUN-07 | Define executable inverse/compensating commands, persistence window, and external limitations for every Undo-capable operation. | X-13 | RP-03, RP-07 | Undo affordances |
| D-RUN-08 | Define Capture multi-operation grouping, input adapters, durable draft, conflict check, and owner acceptance only where approved. | X-14 | RP-05, RP-07 | Capture capability |
| D-RUN-09 | Add truthful Search error/index-health/freshness states and owner-routed action preparation if Search Act remains in scope. | X-15 | RP-05, RP-07 | Search capability |
| D-RUN-10 | Add approved durable queue, cancellation, retry/backoff, later-result publication, notification, and conflict/merge semantics; do not infer them from storage types. | X-16 | RP-03, RP-07 | Recovery promises |
| D-RUN-11 | Implement only approved You correction/reset/export/delete/source/account/notification/appearance commands and permission adapters, with explicit result/Receipt semantics. | X-18, X-19 | RP-06, RP-07 | You active rows |
| D-RUN-12 | Establish privacy-aware external-surface state and failure announcements for widgets, Live Activities, notifications, and intents before platform-ready claims. | X-20, X-21 | RP-08 | External-surface proof |

## Reconstruction planning

| ID | Unresolved planning decision | Evidence | Packets / directions | Dependency |
| --- | --- | --- | --- | --- |
| D-REC-01 | Sequence identity/owner migrations before rebuilding projections and roots. | X-05–X-10 | RP-02, RP-04 | D-ARC-04–08 |
| D-REC-02 | Decide how to migrate/remove duplicate custom shell, direct repository writes, synthetic receipt/source labels, split Search projections, and obsolete You knowledge-dashboard presentation after parity proof. | X-03, X-11, X-15, X-17 | RP-01, RP-02, RP-03, RP-05, RP-06 | Architecture decisions and row proof |
| D-REC-03 | Establish capability gates so Receipt, Undo, partial settlement, offline queue, and owner-return visuals cannot appear from enum/type presence. | X-11–X-16 | RP-03, RP-05, RP-07 | Runtime contracts |
| D-REC-04 | Decide migration/proof sequencing for current TimeBlock/calendar observations into canonical Event/Placement authority. | X-08–X-10 | RP-02, RP-04, RP-07 | D-ARC-05, D-RUN-03–04 |
| D-REC-05 | Define source, runtime, simulator/device, accessibility, localization/RTL, external-surface, restart/replay, and migration gates for reconstruction closure. | X-20, X-21 | All packets | Accessibility/platform plan |

## Accessibility/platform planning

| ID | Unresolved planning decision | Evidence | Packets / directions | Dependency |
| --- | --- | --- | --- | --- |
| D-APL-01 | Select device/OS/orientation coverage within the explicitly approved platform scope. | RP-08 E-RP08-012 | RP-08 | D-DEV-10 |
| D-APL-02 | Define direct scripts and evidence capture for VoiceOver, Voice Control, Switch Control, Full Keyboard Access, hardware keyboard, Dynamic Type, reduced effects, contrast, motor/reach, RTL, long text, and locked-device privacy. | RP-08 E-RP08-008, 017 | RP-01, RP-08 | D-UX-01, D-UX-12, D-RUN-02 |
| D-APL-03 | Define separate device gates for widget gallery, ActivityKit lifecycle, notification delivery/actions, App Intent/Shortcuts/Siri discovery, and any later Spotlight contract. | RP-08 E-RP08-013–016 | RP-08 | External-surface runtime readiness |
| D-APL-04 | Define delayed/failure/permission/later-settlement announcements and focus return across Search, Capture, Time, You, and recovery states. | RP-05, RP-07, RP-08 | RP-05, RP-07, RP-08 | D-RUN-01–02, D-RUN-10 |

## Figma later

Figma has no current decision authority in this audit. D-DEV-01 through D-DEV-10 are resolved by `13-owner-reconciliation-decisions.md`; later design work must still wait for D-ARC-01–17, D-UX-01–12, the applicable Runtime/Reconstruction/Accessibility decisions, and explicit Figma authorization. It must not depict unsupported capability as current.

## SwiftUI implementation later

SwiftUI implementation has no current decision authority. It must wait for the applicable architecture/runtime/UX decisions and proof gates. This audit authorizes no shell, root, Search, Capture, Time, You, recovery, accessibility, or platform implementation.
