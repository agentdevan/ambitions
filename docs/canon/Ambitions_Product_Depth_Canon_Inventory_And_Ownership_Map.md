# Ambitions Product Depth Canon, Inventory, And Ownership Map
<!-- markdownlint-disable MD013 -->

Status: PD01 source-truth map; PD02 accepted Yellow as bounded Today Step Detail implementation; PD03 accepted Yellow as bounded Today Step Session implementation; PD04 accepted Yellow as bounded Today recovery/closure implementation; PD05 Green as bounded Goals Mission Control detail architecture implementation; PD06 Green as bounded Goal Lifecycle and Path Visualization implementation; PD07 accepted Yellow as bounded Goal Proof and Decision History implementation; PD08 accepted Yellow as bounded Goal Alternate Path and Tradeoff implementation; PD09 accepted Yellow as bounded Capture Placement Review implementation; PD10 accepted Yellow as bounded Capture Correction Review implementation; PD11 accepted Yellow as bounded Grow Into Goal implementation; PD12 accepted Yellow as bounded Plan Reflow Decision implementation; PD13 accepted Yellow as bounded Plan Recovery and Pressure Review implementation; PD14 Green as bounded Life Shape Drill-Down implementation; PD15 Green as bounded You Trust History implementation
Date: 2026-05-04

## Purpose

This is the formal Product Depth source-truth map created by PD01. It
reconciles the Product Experience Pack handoff packet with the existing Product
Depth plan, PXOS Product Depth rules, SI18 handoff, global order, gate matrix,
batch registry, and repo architecture.

This document authorizes planning and ownership only. It does not implement app
code, edit navigation, edit design tokens, edit persistence, edit sync, edit
auth, edit network, edit AI/LDI runtime, edit CI/config, add dependencies,
change routes/raw values, retire compatibility seams, create release claims, or
claim Product Depth implementation.

## Source Truth Hierarchy

Future Product Depth work must use this stack:

1. Direct user instructions for the selected batch.
2. `AGENTS.md`.
3. Product Experience Pack source-truth packet and final boundary approval.
4. Ambitions 3.0 source-truth override and front-end parent canon.
5. PXOS Product Depth and drilldown rules.
6. This PD01 canon, inventory, and ownership map.
7. SI18 handoff evidence.
8. Global order, gate matrix, batch registry, context index, and run-state docs.
9. Current native SwiftUI repo evidence.

When this map conflicts with the locked Product Experience Pack source truth,
the locked Product Experience Pack source truth wins and the conflict must be
reported before implementation.

## Product Depth Definition

Product Depth is the Ambitions 4.0 lane for deepening the existing top-level
surfaces without widening the app.

Product Depth may add or improve owned drill-downs, sheets, lanes, detail
routes, proof/review surfaces, receipts/history, setup/defaults flows, and
cross-surface proof/review links behind:

- Today.
- Goals.
- Capture.
- Plan.
- You.
- Cross-surface proof/review where it remains subordinate to the five surfaces.

Product Depth must not add a sixth top-level destination, generic dashboard,
chatbot-first surface, inbox, notes app, habit tracker mode, calendar clone,
analytics wall, OKR/KPI tracker, enterprise project-management system, or
stacked-card top-level composition.

## Locked Product Experience Pack Alignment

| Locked source truth | PD01 mapping |
| --- | --- |
| Today -> Reality Rail | Today Product Depth belongs behind Reality Rail through Step Detail, Step Session, closure/recovery, proof peek, and source detail. |
| Goals -> LifePath View | Goals Product Depth belongs behind LifePath View through Goal Detail, MissionControlTimeSpine, proof/history, lifecycle, and alternate-path details. |
| Capture -> Text-first Capture Atmosphere Composer | Capture Product Depth belongs behind text-first capture through placement review, correction, Grow into Goal, and source detail after content exists. |
| Plan -> LifeShape Map | Plan Product Depth belongs behind LifeShape Map through reflow decisions, pressure review, and capacity-lens LifeShape drill-downs. |
| You -> Personal System Center | You Product Depth belongs behind Personal System Center through trust history, receipts, memory/privacy controls, setup/defaults, and Appearance Studio. |
| MissionControlTimeSpine order | Goals depth must reconcile to Completed, Now, Friction, Next, Horizon before implementation. |
| Appearance Studio rules | Accent work remains a Yellow conflict and design-token/default migration gate; Gold default and launch taxonomy are locked. |
| Proof/source/privacy/receipt semantics | Proof is evidence; source is freshness/conflict/review boundary; privacy is user control; receipt is consequence and reversibility. |
| Accessibility / Reduced Motion | Every invented visual object requires non-visual, Dynamic Type, VoiceOver, no-color-only, and Reduced Motion equivalents. |

## Drill-Down Inventory By Surface

| Surface | Primary object | Allowed depth homes | Top-level must preserve | Must not become |
| --- | --- | --- | --- | --- |
| Today | Reality Rail | Step Detail, Step Session, closure/recovery sheet, proof peek, source detail | One recommended step, Now/Next/Later orientation, calm recovery, proof as evidence | Task list, dashboard, timer-first focus app, productivity score |
| Goals | LifePath View | Goal Detail, MissionControlTimeSpine, proof/history, alternate paths, lifecycle/path detail | LifePath direction, goal orientation, visible trust/proof boundary | Kanban, OKR/KPI tracker, habit tracker, roadmap/Gantt |
| Capture | Text-first Capture Atmosphere Composer | Placement review, correction, Grow into Goal, source detail, receipt detail | Text-first capture, secondary voice/add/attachment, placement only after content | Inbox, notes app, automatic goal factory, route confidence theater |
| Plan | LifeShape Map | Reflow Decision, pressure review, Day/Week/Month capacity lenses, protected-time explanation | LifeShape-first capacity and defaults | Calendar clone, event grid, silent rearrangement, shame loop |
| You | Personal System Center | Trust history, receipts center, privacy/memory controls, schedule/defaults, Appearance Studio | Trust/control-first, copy-density guard, user control | Settings clone, admin console, surveillance dashboard, vanity analytics |
| Cross-surface | Proof / review / receipts | Proof detail, receipt history by meaning, source detail, review links | Subordinate to the owning surface | New review tab, activity feed, notification feed, achievement layer |

## Feature-Depth Candidate Map

| Candidate | Owning surface | PD batch | Status after PD01 | Required gates before implementation | Caveat / conflict |
| --- | --- | --- | --- | --- | --- |
| Step Detail depth | Today | PD02 | Accepted Yellow implementation evidence | PX02, PX07/PX08 where proof/recovery appears, SI04/SI05/SI10/SI13/SI17, ME Today | Lightweight drill-down behind Reality Rail; no card expansion. |
| Step Session depth | Today | PD03 | Accepted Yellow implementation evidence | PD02 accepted Yellow, SI05/SI10/SI12/SI13/SI17, ME Today/TodayPanels, accessibility/copy | Step-first execution environment implemented; timer remains secondary and no persistence/runtime claim is added. |
| Recovery and closure depth | Today / Recovery | PD04 | Accepted Yellow implementation evidence | PD02 accepted Yellow, PX07/PX09, SI10/SI13, AOS if runtime recovery logic changes | Closure sheet now exposes humane consequence/recovery copy and receipt boundary; no runtime recovery or silent plan mutation claim. |
| MissionControlTimeSpine | Goals | PD05 | Green implementation evidence | PX03/PX14, SI06/SI07/SI10/SI14/SI17, ME Goals, CS if routes/raw values touched | Visible Goal Detail lane order reconciled to Completed -> Now -> Friction -> Next -> Horizon while preserving internal lane-kind compatibility. |
| Goal lifecycle/path visualization | Goals | PD06 | Green implementation evidence | PD05 Green, SI06/SI07/SI12/SI17, visual/accessibility gates | Goal Detail path stages now expose text-plus-symbol lifecycle, progress, proof, risk, and route markers with non-color accessibility summaries. Must not become KPI/OKR or decorative path. |
| Goal proof/decision history | Goals / Proof | PD07 | Accepted Yellow implementation evidence | PD05 Green, PX08, SI10/SI14, AOS proof if runtime/data logic touched | Goal Detail now includes a presentation-derived review trail for proof, decisions, assumptions, and receipts. Proof remains evidence, not achievement; no proof runtime/data logic was touched. |
| Goal alternate path/tradeoff | Goals | PD08 | Accepted Yellow implementation evidence | PD05 Green, PX03/PX15, AOS alternate-path if runtime logic touched | Goal Detail now includes a presentation-derived tradeoff review for route options, effort/time/energy comparison, recovery labels, and user-review requirements. No automated reroute, route mutation, plan mutation, or AOS runtime logic was touched. |
| Capture placement review | Capture | PD09 | Accepted Yellow implementation evidence | PX04/PX13, SI09/SI10/SI13/SI17, privacy/copy gates, ME Capture if large owner touched | Captured items now include presentation-derived destination, consequence, privacy, user-confirmation, and archive/discard labels after content exists. No silent placement, inbox/feed mode, persistence/schema, or AOS runtime change was made. |
| Capture correction | Capture | PD10 | Accepted Yellow implementation evidence | PD09 accepted Yellow, privacy/copy, AOS adaptation/source truth if learning touched | Captured items now include presentation-derived correction options, correction receipt language, and local/no-hidden-memory boundaries. No user-facing confidence language, hidden learning, personalization, or AOS runtime change was made. |
| Grow into Goal | Capture / Goals | PD11 | Candidate remains gated | PD09/PD10 Green, PX03/PX04/PX15, CS navigation if route touched, AOS goal path if runtime touched | Candidate items must not be silently upgraded. |
| Reflow Decision depth | Plan | PD12 | Complete / accepted Yellow after validation and commit | PX05/PX07/PX08, SI08/SI10/SI13/SI17, ME Plan, AOS if commitment/runtime logic touched | User-owned, non-silent consequence review; no calendar write, silent rearrangement, persistence/schema, route/raw-value, or AOS runtime change. |
| Pressure review | Plan | PD13 | Complete / accepted Yellow after validation and commit | PD12 accepted Yellow, accessibility/copy, Plan pressure evidence | Plan pressure/recovery review now explains overload, recovery space, protected-time conflict, late-start adjustment, recovery-day review, and qualitative capacity without shame framing, fake precision, calendar writes, silent rearrangement, persistence/schema, route/raw-value, or AOS runtime change. |
| Month LifeShape Lens | Plan | PD14 | Complete / Green after validation and commit | PX05/PX10/PX12, SI08/SI12/SI13/SI17, ME Plan/PlanScreen | Life Shape drill-down now explains life areas, pressure weeks, milestones, protected time, free-time bands, recovery space, commitment load, and long-range rhythm from existing Plan state without calendar clone behavior, event-grid posture, silent rearrangement, persistence/schema, route/raw-value, or AOS runtime change. |
| Trust history and receipts center | You | PD15 | Complete / Green after validation and commit | PX06/PX08, SI10/SI11/SI13/SI14, ME You/Profile, privacy/trust | You/Profile now includes a Trust History Center for receipts, proof, changes, source review, privacy labels, and automation boundaries. Receipt remains consequence/reversibility, not feed. |
| Schedule, availability, defaults | You | PD16 | Candidate remains gated | PX06/PX11, REC claim boundaries, privacy/permission copy, CS if route/default touched | Plan-owned calendar permission; no unsupported integration claim. |
| Cross-surface proof/review | Cross-surface | PD17 | Candidate remains gated | Earlier PD proof/reflow/You history, PX15, CS route/navigation, AOS proof if data touched | Must not create new review tab or activity feed. |
| Product Depth handoff | Cross-surface | PD18 | Handoff owner mapped | PD01-PD17 resolved or deferred | Must not claim release/app implementation beyond evidence. |

## Implementation Dependency Map

| Dependency lane | PD01 decision | Future implementation impact |
| --- | --- | --- |
| PXOS | PX01-PX20 are complete as future canon/roadmap evidence; PX14/PX18 satisfy PD formalization prerequisites. | Each PD implementation still names its surface-specific PXOS gates. |
| SI | SI01-SI18 are complete as Signature Interface evidence with accepted Yellow advisories. | PD should compose SI primitives where relevant, but SI evidence does not authorize routes, persistence, runtime, or implementation completion claims. |
| ME | ME01-ME12 are complete or not triggered by their documented gates. | Large owner files remain implementation-time gates; PD batches must name exact owner files and validation. |
| CS | CS01, CS07, CS08, CS02A/B, CS03A/B, CS04A/B, CS05A/B, CS06A/B, CS09A/B, and CS10 evidence preserves compatibility; CS02C-CS06C and CS09C remain deferred. | Do not retire route/raw/external/import/export/persistence seams without explicit CS proof. |
| AOS | AOS01 is complete as docs/protocol runtime-contract source truth; AOS02 is complete as additive Life Graph domain foundation; AOS03-AOS30 remain queued/blocked. | Runtime intelligence, source truth, proof logic, adaptation, alternate path, and reality-drift changes remain blockers until the relevant AOS gates pass. |
| REC / release | REC02-REC06 claim boundaries are complete as evidence. | No release/platform/accessibility/device/TestFlight/App Store claims without matching proof. |
| LDI | LDI01-LDI22 are future/post-AOS by default. | LDI review homes may be marked future drill-downs only; no new top-level destination or runtime claim. |

## Blocked / Unblocked Status

| Batch | Status after PD01 | Continuation note |
| --- | --- | --- |
| PD01 | Complete / accepted Yellow after validation and commit | Docs/planning only; no app code changed. |
| PD02 | Complete / accepted Yellow after validation and commit | Bounded Today implementation; Step Detail is a lightweight drill-down behind Reality Rail. |
| PD03 | Complete / accepted Yellow after validation and commit | Bounded Today implementation; Step Session is step-first, timer-secondary, and receipt/proof-boundary aware. |
| PD04 | Complete / accepted Yellow after validation and commit | Bounded Today implementation; closure/recovery depth is presentation-bounded and does not claim AOS runtime recovery or plan mutation. |
| PD05 | Complete / Green after validation and commit | Bounded Goals implementation; Goal Detail Mission Control visible lane order now follows Completed -> Now -> Friction -> Next -> Horizon without navigation/raw-value changes. |
| PD06 | Complete / Green after validation and commit | Bounded Goals implementation; Goal Detail lifecycle/path visualization now exposes current position, progress shape, proof, risk, and route markers without navigation/raw-value changes. |
| PD07 | Complete / accepted Yellow after validation and commit | Bounded Goals implementation; Goal Detail review trail surfaces proof, decision, assumption, and receipt history from existing mission-control state without runtime proof model changes. |
| PD08 | Complete / accepted Yellow after validation and commit | Bounded Goals implementation; Goal Detail tradeoff review surfaces route comparison, recovery, and review requirements from existing path-builder state without automated reroute or AOS runtime changes. |
| PD09 | Complete / accepted Yellow after validation and commit | Bounded Capture implementation; captured items surface placement review with destination, consequence, privacy, user confirmation, and archive/discard posture without inbox/feed mode or silent placement. |
| PD10 | Complete / accepted Yellow after validation and commit | Bounded Capture implementation; captured items surface correction options, receipt language, and local/no-hidden-memory boundaries without hidden learning or user-facing confidence copy. |
| PD11 | Complete / accepted Yellow after validation and commit | Bounded Capture/Goals implementation; Create Goal surfaces a goal seed review with why-this-might-be-a-goal, starting position, first milestone, first recommended step, proof/source seed, and explicit confirmation before promotion without automatic goal creation, route/raw-value changes, persistence/schema changes, or AOS runtime changes. |
| PD12 | Complete / accepted Yellow after validation and commit | Bounded Plan implementation; Reflow Decision options now name what changed, why, impacted steps, capacity impact, protected-time impact, and accept/edit/decline choices without silent rearrangement, calendar writes, persistence/schema changes, route/raw-value changes, or AOS runtime changes. |
| PD13 | Complete / accepted Yellow after validation and commit | Bounded Plan implementation; Pressure/recovery review now names overload relief, recovery space, protected-time conflict, late-start adjustment, recovery-day review, and qualitative capacity review without shame framing, fake precision, calendar writes, persistence/schema changes, route/raw-value changes, or AOS runtime changes. |
| PD14 | Complete / Green after validation and commit | Bounded Plan implementation; Life Shape drill-down now explains life areas, pressure weeks, milestones, protected time, free-time bands, recovery space, commitment load, and long-range rhythm without calendar clone behavior, dense event-grid posture, silent rearrangement, persistence/schema, route/raw-value, or AOS runtime change. |
| PD15 | Complete / Green after validation and commit | Bounded You implementation; Trust History Center surfaces receipts, proof, changes, source review, privacy labels, and automation boundaries from existing local state without feed posture, vanity analytics, route/raw-value changes, persistence/schema, sync/account claims, or AOS/LDI runtime changes. |
| PD16-PD18 | Queued / Blocked | Each waits for predecessor and named PXOS/ME/CS/SI/AOS-if-needed gates. |
| Global train outside PD | Stopped / not resumed | Requires its own explicit approval and gate path. |

## Conflict Register

| Conflict | Severity | Owner | PD01 decision |
| --- | --- | --- | --- |
| Accent taxonomy/default mismatch | Yellow | Appearance Studio / theme / You | Preserve as Yellow. Do not edit design tokens or persistence defaults in PD01. Future docs-only alias/migration plan or approved implementation needed. |
| MissionControlTimeSpine order mismatch / unknown | Green for Goal Detail visible lane order; internal compatibility preserved | Goals / PD05 | PD05 reconciled visible Goal Detail Mission Control lane order to Completed/Now/Friction/Next/Horizon and kept internal lane-kind compatibility cases intact. Remaining future Goals depth must preserve this order. |
| User-facing copy boundary | Yellow | Cross-surface copy / PD implementation batches | Preserve staged remediation model from Batch 1C. Future PD batches must avoid forbidden copy and run copy scans. |
| Step Session depth previously unknown | Accepted Yellow | Today / PD03 | PD03 adds bounded implementation proof; no broader Step Session persistence/runtime claim is made. |
| Month LifeShape calendar-clone risk | Green for bounded PD14 presentation; future Plan expansion remains Yellow | Plan / PD14 | PD14 proves a capacity-lens Life Shape drill-down from existing Plan state. Future Month/LifeShape expansion must preserve the anti-calendar-clone boundary. |
| You / Privacy / Memory / Receipts density | Yellow | You / PD15-PD16 | Preserve copy-density and trust/control-first guardrails. |
| Candidate items | Yellow | Object owners | PD08 deepens the Goal alternate path/tradeoff detail as a bounded presentation layer. Other Candidate items remain Candidate until a named batch explicitly finalizes or defers them. |
| Broad app implementation | Red | Cross-surface | Remains Red and unauthorized. |

## Product Depth Acceptance Rules

Every future PD batch must prove:

- the owning surface is Today, Goals, Capture, Plan, You, or cross-surface
  proof/review;
- the top-level surface keeps orientation and one-primary-object hierarchy;
- secondary detail moves behind an owned drill-down, lane, sheet, review
  surface, proof detail, setup flow, or receipt/history view;
- no new top-level destination or generic product mode is introduced;
- proof, source, privacy, and receipt semantics match the Product Experience
  Pack;
- accessibility, Dynamic Type, VoiceOver, no-color-only meaning, and Reduced
  Motion equivalents are named and validated;
- ME, CS, AOS, REC, SI, and PXOS dependencies are classified before code;
- validation strength matches the batch type.

## Non-Claims

PD01 does not prove Product Depth implementation. PD02 proves only bounded
Today Step Detail implementation. PD03 proves only bounded Today Step Session
implementation. PD04 proves only bounded Today recovery/closure presentation
depth. PD05 proves only bounded Goal Detail Mission Control visible lane-order
depth. PD06 proves only bounded Goal Detail lifecycle/path visualization
depth. PD07 proves only bounded Goal Detail proof/decision-history
presentation depth. PD08 proves only bounded Goal Detail alternate
path/tradeoff presentation depth. PD09 proves only bounded Capture placement
review presentation depth. PD10 proves only bounded Capture correction review
presentation depth. PD11 proves only bounded Capture/Goals grow-into-goal seed
review depth. PD12 proves only bounded Plan Reflow Decision presentation depth.
PD13 proves only bounded Plan pressure/recovery review presentation depth.
PD14 proves only bounded Plan Life Shape drill-down presentation depth.
PD15 proves only bounded You Trust History presentation depth.
These batches do not prove later PD readiness beyond
continuation eligibility, release readiness, TestFlight readiness, App Store
readiness, physical-device proof, public accessibility conformance, signed
archive validation, App Store Connect validation, external-platform rendering,
PXOS implementation, AmbitionsOS implementation, LDI runtime, sync/auth/network
behavior, persistence migration, personalization, hidden learning, or AI/model
runtime behavior.
