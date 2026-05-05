# Ambitions WidgetKit Strategy And Object Map
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Owner: Widgets / Platform / Privacy
Status: PFC13 source truth

## Purpose

This document defines which Ambitions objects are allowed to appear in WidgetKit
surfaces and what each may expose. It is a strategy and privacy matrix, not
permission to add new widget runtime behavior, new entitlements, new widget
families, App Store claims, TestFlight claims, public accessibility claims, or
release readiness claims.

## Controlling Source Truth

- Ambitions remains Today / Goals / Capture / Plan / You.
- Widgets are external surface mirrors, not new destinations.
- Widgets must be glanceable, focused, and privacy-safe.
- Widget content comes from lightweight local snapshots.
- Widgets must deep-link to exact app scenes when possible and fall back safely.
- Stale or unavailable state must ask the user to open Ambitions before acting.
- Mutation-capable actions must route through shared command policy and receipt
  posture where mutation occurs.
- Widgets must not become dashboards, feeds, inboxes, calendars, analytics, AI
  confidence surfaces, or hidden automation channels.

## Current Repo Evidence

- `ExternalSurfaceContractRegistry.contract(for: .widgets)` allows Now, Next
  Step, protected block, plan status, and stale state.
- `ExternalWidgetProjection` hides sensitive detail by default, exposes stale /
  unavailable labels, uses safe deep links with widget origin, and falls back to
  Today.
- `NextStepWidget` supports system and accessory families using the shared
  projection.
- `ExternalSurfaceVerificationChecklist` keeps rendered widget gallery and
  device behavior as manual-proof gates.
- `PFC12` documents the app-group/shared-storage boundary; widgets may read
  lightweight external snapshots but may not own a separate store.

## Allowed Widget Object Map

| Object | Status | Allowed widget role | Allowed exposure | Required route | Forbidden exposure |
| --- | --- | --- | --- | --- | --- |
| Today / Reality Rail | Allowed primary | Show the current local next-step posture and rail orientation. | Glance-safe title, short detail, stale/local state, protected-block hint. | Today fallback or goal detail when a safe goal reference exists. | Full day dashboard, every step, private calendar detail, pressure scoring. |
| Start Here | Allowed primary | Point to the recommended user-startable step. | Start label, short fit proof, source freshness label. | Today or goal detail with widget origin. | AI certainty, productivity score, silent start, hidden mutation. |
| Receipt Drawer / Proof | Allowed secondary | Show that a proof/receipt state exists or needs in-app review. | Receipt-safe label, source/review state, undo/correction availability. | Today or You receipt/history surface when scoped later. | Notification-feed posture, trophy language, private proof detail by default. |
| Source Fold | Allowed secondary | Show stale/conflict/review boundary. | Source may be stale, review needed, local state unavailable. | Owning app surface for review. | AI verified, confidence percentage, certification posture. |
| Plan / LifeShape | Allowed secondary | Show capacity or plan posture only. | Doable/not-doable posture, protected pocket hint, open Plan action. | Plan. | Calendar clone, raw calendar entries, automatic scheduling, full month grid. |
| Capture | Allowed entry | Offer capture/open action and safe draft reminder. | Capture affordance, text-first posture, placement waits for content. | Capture. | Inbox/feed, attachment-first flow, auto-placement, source classification. |
| Goals / LifePath | Allowed secondary | Show one safe goal reference or progress posture. | Goal count/posture, safe open goal route, proof/blocker hint. | Goals or goal detail. | Project-management board, KPI/OKR score, every goal by default. |
| You / Personal System Center | Allowed limited | Show trust/privacy/defaults status only after explicit future scope. | Privacy-safe status or setup reminder. | You. | Settings dump, surveillance tone, sensitive detail exposure. |
| MissionControlTimeSpine | Deferred | Not a widget object until FCP10 resolves implementation order. | None until scoped. | Goals after FCP10 evidence. | Unresolved lane order, roadmap/Gantt, proof-as-chronology-only. |
| Memory Lens | Deferred | Not a widget object until FCP23/PFC strategy approves it. | None until scoped. | You/Memory after future evidence. | Private memory snippets by default, monitored/tracked tone. |

## Privacy Matrix

| Data class | Widget default | Allowed label | Required behavior |
| --- | --- | --- | --- |
| Sensitive goal or step detail | Hidden | Details stay private until you open Ambitions. | Never expose by default; route into app. |
| Stale local snapshot | Hidden behind stale label | This may be behind. Open Ambitions to refresh. | Do not invite action from stale data. |
| Unavailable snapshot | Hidden behind unavailable label | Open Ambitions to confirm the latest local state. | Fall back to Today. |
| Protected block | Glanceable only | Protected block / plan status. | Avoid raw calendar or private event names. |
| Proof / receipt | Summary only | Proof saved / receipt available / review source. | No trophy, feed, or notification posture. |
| Capture draft | Entry only | Open Capture / add text. | Placement appears only after content exists. |
| Plan capacity | Summary only | Week looks doable / open Plan to adjust. | No calendar clone or automatic reschedule claim. |
| Goal reference | Safe route only | Open Goal / goal posture. | Hide names when privacy policy requires it. |

## Widget Family Guidance

| Family | Allowed content | Constraint |
| --- | --- | --- |
| Accessory inline | Short title plus freshness/trust label. | No private detail. |
| Accessory circular | Symbolic pressure or continuity cue. | No color-only meaning. |
| Accessory rectangular | Title, stale/unavailable label, safe route. | Keep copy short. |
| System small | One primary object. | No multi-object dashboard. |
| System medium | Primary object plus at most two safe variant rows. | No feed or grid. |
| System large | Primary object plus bounded variants. | Must remain glanceable and not become the app. |

## Accessibility And Reduced Motion Requirements

- Every widget family needs concise accessibility labels.
- No widget state may rely on color alone.
- Accessory families need text or symbol meaning that survives small sizes.
- Widget animations, if added later, must have static equivalents.
- Public accessibility conformance remains blocked until rendered device proof.

## Performance And Battery Requirements

- Widget timelines must remain lightweight.
- Reload cadence must avoid heavy recompute and background churn.
- Widget snapshots must be pre-projected by the app.
- Widget rendering must not query persistence, sync, account, AI, or LDI
  runtime directly.

## Future Implementation Boundary

PFC14 may implement or repair widget runtime only inside a scoped WidgetKit
implementation batch. It must not edit entitlements, signing, project
generation, persistence/schema, sync/account, AI/LDI runtime, privacy manifest,
workflow, or release claim files without explicit scope and evidence.
