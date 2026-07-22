# ADR-2026-07-22: Local-First Recovery, Accessibility, and Platform Scope

Status: Accepted
Date: 2026-07-22
Audit: RP-06 through RP-08 in `docs/audits/rp-01-08-evidence-audit/`
Owner decision: `docs/audits/rp-01-08-evidence-audit/13-owner-reconciliation-decisions.md`
Directions: `AVF-YOU-D07-R02`, `AVF-RECOVERY-S07-R01`, `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`

## Local-first and no-account decision

The current flagship is local/no-account. Local canonical stores remain
authoritative without network or sign-in. Local-first does not imply that every
external observation, external mutation, Search domain, draft, pending action,
or ecosystem surface works offline.

| Capability class | Offline read | Offline write | Authority and limitation |
| --- | --- | --- | --- |
| Local canonical Goal/Step/preferences/history | Yes after successful local store open | Yes through registered owner commands | Local store is authoritative. |
| Local Event/Placement target records | Yes when implemented and persisted | Yes when implemented and registered | Target architecture, not present capability merely because canon defines it. |
| Today/Search derived projections | Yes for materialized local data | Rebuilt from owner commits; never directly written as canonical truth | May be stale or unavailable and must say so. |
| Capture session | In session | In session; durability is separately gated | No relaunch promise without a draft store. |
| External calendar/reminder observations | Last verified snapshot only when persisted | No direct source write without adapter capability | Show source and verification time. |
| External mutation | Prepared locally where safe | Only through supported adapter/permission | Offline acceptance requires a durable operation contract. |
| Receipts/history | Yes for registry-covered durable records | Owner mutation pipeline only | Not universal coverage. |
| Account/cloud continuity | Not in current flagship scope | Not in current flagship scope | No account UI or disabled rows. |

## Source priority and freshness

Canonical local truth wins for Ambitions-owned objects. A named external source
is authoritative for its own source record; an imported/minimized projection
does not overwrite local meaning without an explicit reconciliation command.
Every external observation carries source, source revision when available,
verified-at time, freshness class, and failure state. Once its domain threshold
passes it becomes stale, not current. `Unknown` is used when no reliable value
exists.

## Pending operation contract

Pending may be displayed only after an operation has been accepted and has:

- a durable operation ID and serialized owner payload;
- a known owner and source scope;
- persisted expected revisions and idempotency identity;
- interruption/relaunch behavior matching the claim;
- retry/backoff and cancellation semantics;
- terminal and reconciliation-required states;
- a later result publication path and user recovery entry;
- Receipt linkage when policy requires it.

No generic queue is approved by this ADR. A domain may introduce a bounded
outbox only with its own ADR/contract and proof. Queue processing must never
replay an already completed scope.

| Concern | Required contract |
| --- | --- |
| Owner | The canonical domain or external adapter, never shell/UI. |
| Persistence | Atomic with acceptance or clearly “not accepted.” |
| Retry | Idempotent, bounded exponential backoff, next-attempt visibility. |
| Cancellation | Typed command; states whether external work can still complete. |
| Terminal result | Changed, unchanged, blocked, failed, cancelled, or reconciliation required. |
| Publication | Local owner projection plus optional supported notification. |
| Recovery | Resume, retry, cancel, reauthenticate, repair permission, or inspect conflict as actually supported. |

“Will finish later” and “we’ll notify you” are forbidden without this contract
and a proven publication surface.

## Recovery presentation thresholds

| Mechanism | Required runtime data | Placement |
| --- | --- | --- |
| Contextual Truth Margin | Object state plus provenance/uncertainty that affects the current decision | Attached to the affected object/action |
| Local Truth Horizon | Source, verified-at time, freshness rule, and current reachability | At the external or stale projection |
| Coherence Seam | A modeled conflict with competing claim IDs and an owner/review route | At the relationship between claims |
| Focused Recovery Passage | A named failed/blocked operation, consequence, available recovery commands, and return target | Smallest owning surface |
| System-wide recovery | Shell-owned condition makes safe local operation broadly impossible | App-level gate, never for a local row failure |

Whole-result state replaces simulated Settlement Ledger richness when typed
scope data does not exist. Receipts and Undo follow their registries.

## You capability boundary

The active You hierarchy is:

1. Identity & Local Data
2. Personalization
3. Privacy & Data
4. Appearance
5. Notifications & Attention
6. Connections & Permissions
7. Accessibility & Interaction
8. App Behavior
9. About Ambitions

Current or approved planned rows are limited to evidence-backed display name,
local profile identity, default root, review cadence, on-device status,
supported App Lock inspection, implemented preferences, local history/Receipt
inspection, supported visibility/retention actions, System/Light/Dark, approved
accents, current notification authorization/categories/actions, Calendar,
Reminders, Notifications, local authentication where used, system Settings
handoff, app-specific privacy behavior, version/build/local-first posture,
policies, licenses, and a truthful support route when one exists.

The active baseline excludes sign-in, account recovery, devices, subscriptions,
sign-out, account deletion, cloud-account continuity, cross-device controls,
“What Ambitions Knows,” dedicated Help center, Search preferences, unsupported
permissions, source add/remove, broad reset/export/delete/erase, unsupported
notification controls, density, typography/material customization, and
cross-device appearance. They do not appear as disabled rows.

Restrained violet-indigo is the default action accent for new/reset state.
Existing accents remain only after contrast and state-separation review.
Migration maps every persisted value deterministically and preserves a valid
selection; unknown values fall back to violet-indigo without corrupting the
preference store. Accent never identifies roots or semantic state alone.

### Capability inventory and ownership

| Capability | Audit posture | Current planning treatment |
| --- | --- | --- |
| Display name, default root, review cadence | Supported/partial implementation evidence | Retain with canonical preference owner. |
| System/Light/Dark and accent persistence | Supported implementation evidence | Retain; add violet-indigo through later migration. |
| Local history/Receipt inspection | Partial, operation-specific | Show only covered local records. |
| App Lock/protected inspection | Partial, system-owned authentication | Show only where a protected local route uses it. |
| Calendar and Reminders | Supported permission seams | System authorizes; Time owns invocation/effect. |
| Notifications | Supported bounded authorization/category/action evidence | You owns opt-in; iOS owns authorization/delivery. |
| Personalization/learning corrections | Partial | Route correction to canonical owner; no second memory store. |
| Account, cloud continuity, broad data administration | Absent or future-gated | Remove from current baseline. |

| Permission | System owner | Ambitions owner | Current treatment |
| --- | --- | --- | --- |
| Calendar | iOS authorization | Time permission coordinator and calendar adapter | Approved current row; reflect denied/restricted/not-determined truth. |
| Reminders | iOS authorization | Time/reminder adapter for proven writes | Approved current row. |
| Notifications | iOS authorization and delivery | You opt-in plus notification runtime | Approved current row and Settings recovery. |
| Local authentication | LocalAuthentication | Protected local inspection/App Lock owner | Contextual only. |
| Speech, microphone, photos, files, contacts, location, health | Relevant framework | No current shipping owner | Absent, not disabled. |

### Destructive and data actions

| Action | Current posture | Required before exposure |
| --- | --- | --- |
| Reset a supported preference | Bounded current target | Exact scope, preview, owner command, result, and recovery. |
| Delete/archive/restore a canonical object | Object-owner capability | Governing object contract, confirmation, history, and proof. |
| Delete local data permanently | Not current You baseline | Defined scope, irreversibility, protected-data behavior, interruption/relaunch proof, and truthful terminal result. |
| Export/backup/restore | Not current You baseline | Format, privacy, completeness, encryption, cancellation, compatibility, and device proof. |
| Remove external source | Not current You baseline | Source authority, consequence preview, retained local history, and reconciliation proof. |
| Privacy reset or account deletion | Absent | Separate product/architecture decision. |

System permission changes do not automatically create Ambitions Receipts. A You
operation creates a Receipt only when its registry row records a meaningful
durable app-owned mutation, destructive result, external effect, recovery, or
time-bounded inverse. Navigation, system Settings handoff, inspection, preview,
and cancelled permission prompts create none.

## Current platform scope

| Surface | Current flagship status | Required proof before claim |
| --- | --- | --- |
| iPhone portrait | In scope | Source, automated, simulator, and physical-device proof |
| Single scene | In scope | Launch/restoration/interruption proof |
| iOS 26 or approved successor floor | In scope | Project/SDK inspection and oldest-device proof |
| Landscape, iPad, Mac/Catalyst, visionOS, multiple windows, external display | Out of current flagship scope | New product/platform decision |
| Widget, Live Activity, Notification, App Intent, Siri/Shortcuts, Share extension | Separate source-backed surfaces | Direct target and device proof per surface |
| Spotlight | Planned only | Architecture, privacy, indexing, and device proof before enablement |

Cross-device principles remain constitutional direction and do not authorize an
account, sync, target, or frontend implementation.

## Accessibility ownership

| Concern | Owner |
| --- | --- |
| System text size, contrast, transparency, motion, VoiceOver, Voice Control, Switch Control, Full Keyboard Access | iOS frameworks and user settings |
| Semantic labels/values/hints/actions and reading order | Owning surface; shell owns shell order |
| Cross-presentation focus return | Shell/navigation |
| In-surface focus | Owning surface |
| Mutation/recovery announcement | Mutation/recovery owner |
| Sensitive speech and locked-device preview | Privacy policy plus presenting surface |
| Keyboard traversal and root/global commands | Shell for global; surface for local |
| Dock grouping and equivalent actions | Shell |

The implementation must provide unique Voice Control names, reachable Switch
Control elements, Full Keyboard Access order, root-switch shortcuts, global
Search/Capture commands, and non-gesture equivalents. Dynamic changes announce
object, outcome, consequence, recovery/Undo availability, and destination as
applicable without exposing sensitive content.

## Localization architecture

User-facing copy moves to String Catalogs by owning module. Keys are stable,
semantic, namespaced, and contain translator context. Formatting uses locale-
aware pluralization, dates, times, durations, units, calendars, and relative
language; no concatenated sentence fragments or hard-coded directional
symbols. RTL mirrors directional geometry while preserving semantic order.

The plan requires an inventory of hard-coded strings, extraction ownership,
pseudolocalization, long-language stress, plural cases, non-Gregorian calendar
inspection where supported, RTL tests, and screenshot/manual proof. This ADR
does not implement localization.

## Non-claims

No queue, persistence, recovery, permission, appearance, localization,
accessibility, platform, or product runtime behavior was implemented. Figma,
SwiftUI, and implementation authorization remain false.
