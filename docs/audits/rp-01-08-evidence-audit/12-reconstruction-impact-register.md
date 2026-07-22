<!-- markdownlint-disable MD013 MD060 -->

# Reconstruction Impact Register

## Boundary

This register identifies consequences for the existing flagship reconstruction effort. It is not an implementation plan, sequence commitment, roadmap rewrite, deletion authorization, or permission to change source. Every action remains conditional on the decision register.

## Required architecture work

| ID | Likely reconstruction implication | Evidence | Depends on | Proof required before closure |
| --- | --- | --- | --- | --- |
| R-ARC-01 | Reconcile root-container, dock, crown, Back, global presentation, and selected-root-aware depth ownership. | X-01–X-04 | D-DEV-01, D-ARC-01–03 | Source ownership tests, root/path behavior, native/assistive gesture proof |
| R-ARC-02 | Introduce a versioned navigation/restoration contract only if exact return remains required. | X-04 | D-ARC-02, D-UX-02 | Relaunch/interruption/stale-object matrices; accessibility focus return |
| R-ARC-03 | Establish stable editable Life Area identity and migration before relying on a canon-complete Goals root. | X-05, X-06 | D-DEV-02, D-ARC-04 | Migration, identity retention, deletion/restore, projection tests |
| R-ARC-04 | Reconcile `TimeBlock` with canonical Event/series/occurrence/Schedule Placement authority. | X-05, X-08–X-10 | D-ARC-05–08 | Identity/recurrence/source/placement/replay/migration proof |
| R-ARC-05 | Define one object-owner routing contract across Today, Time, Search, Capture, You, Trust/history, and external entry. | X-05, X-11, X-15 | D-ARC-06, D-ARC-12 | Typed route/action tests with current revision and return context |
| R-ARC-06 | Define Receipt, Settlement Ledger, Undo, external result, and pending-operation relationships without making projections a second authority. | X-11–X-13, X-16 | D-ARC-09–10, D-ARC-13–14 | Atomicity/replay/crash/compensation/retention proof |
| R-ARC-07 | Reconcile FTS and repository-aggregated Search into an explicitly owned projection. | X-15 | D-ARC-11 | Coverage, ranking, provenance, freshness, failure, rebuild proof |
| R-ARC-08 | Reconcile You personal-context/learning projections with the no-knowledge-dashboard law and data-action ownership. | X-17, X-19 | D-ARC-15–16 | One-owner, privacy, correction, deletion/export/Receipt proof |
| R-ARC-09 | Establish runtime accessibility focus and app localization ownership before claiming adaptive semantic continuity. | X-20 | D-ARC-17 | Direct focus, localization, RTL, long-text, sensitive-output evidence |

## Required runtime work

| ID | Likely reconstruction implication | Current floor | Gap that must not be hidden | Evidence |
| --- | --- | --- | --- | --- |
| R-RUN-01 | Migrate registry-unproven meaningful writes one owner at a time. | 121 registered rows; durable SQLite authority for bounded paths | 50 production write paths remain unproven | RP-03 E03-01; RP-07 E07-05 |
| R-RUN-02 | Encode accepted/proposed/external/current temporal truth. | Local TimeBlocks and week projection | Goal timing can appear as ordinary accepted-looking block | X-08 |
| R-RUN-03 | Add approved canonical Event/Placement/Life Area/full Goal-lifecycle behavior. | Goal/Step identity, TimeBlocks, static Life Areas | Full canonical graph and lifecycle absent | X-05, X-06, X-10 |
| R-RUN-04 | Add durable drafts/session restoration if exact Capture/Search return remains required. | In-memory draft/query | Relaunch/interruption/focus/keyboard not restored | X-04, U-06 |
| R-RUN-05 | Add owner-routed Search proposals and truthful error/index/freshness states if Search Act remains in scope. | Local deterministic Find/Open/Inspect | Act absent; failures collapse to no-result | X-15 |
| R-RUN-06 | Add approved Capture input adapters, multi-operation grouping, conflict checks, and owner settlement only where product authority requires them. | Text proposal, bounded quick create and Goal handoff | Voice, broad attachments/routes, partial settlement, Undo absent/unproven | X-14 |
| R-RUN-07 | Add typed per-scope settlement only if approved. | Whole-operation command and side-effect results | Completed/failed/deferred/uncertain/reversible/irreversible scopes absent | X-12 |
| R-RUN-08 | Implement executable inverse or compensating commands per mutation before showing Undo. | Bounded durable Time Undo | Generic rollback metadata/labels exceed proof | X-13 |
| R-RUN-09 | Add durable queue/retry/cancel/later-publication/notification contracts only for approved owners. | Narrow external ledger/identity primitives | No generic scheduler; CloudKit default outbox in memory | X-16 |
| R-RUN-10 | Implement only approved You commands/preferences/permissions and preserve system-owned boundaries. | Narrow saved preferences; Calendar/Reminders/Notifications seams | Broad account/data/permission/notification/appearance controls absent | X-18, X-19 |
| R-RUN-11 | Bind focus/announcements and privacy-safe external-state changes to runtime outcomes. | Policy/helper types | No applied focus owner; direct proof absent | X-20, X-21 |

## Required UX Blueprint work

| ID | Blueprint question | Why reconstruction cannot infer it | Evidence |
| --- | --- | --- | --- |
| R-UX-01 | Edge dock or canonical bottom navigation; exact dock posture and accessibility equivalents. | Source/canon and protected intent conflict. | X-01, X-02 |
| R-UX-02 | Crown/title/action ownership across root, object, edit, conflict, and recovery context. | Current ownership is mixed; selected program excludes Search/Capture from crown. | RP-01 crown matrix |
| R-UX-03 | Exact meaning of context restoration and acceptable degradation. | Several requested fields are absent or OS-owned and cannot be guaranteed from current state. | X-04 |
| R-UX-04 | Life-Area-led versus Goal-led root, and owner-depth location of Linked Goal Lens. | Current canon and provisional root diverge. | X-06 |
| R-UX-05 | One versus three Today objects and whether “priority” is a projection or relation. | Canon, provisional intent, and live residue disagree. | X-07 |
| R-UX-06 | Proposed/accepted/external/protected/flexible/conflict/recovery temporal language and “personally usable opening.” | Runtime representations are incomplete and owner boundaries matter. | X-08, RP04-C08 |
| R-UX-07 | Capability-gated Receipt/Undo/pending/partial/failure/recovery treatments. | Presentation enums can overclaim executable support. | X-11–X-13, X-16 |
| R-UX-08 | Capture ambiguity/input/owner-transfer and Search failure/evidence/Act-return behavior. | Current active journeys cover only bounded subsets. | X-14, X-15 |
| R-UX-09 | You hierarchy after removing/reconciling knowledge-dashboard, Help, unavailable account/data/permission/appearance rows. | Current canon/source/provisional inventories conflict. | X-17–X-19 |
| R-UX-10 | VoiceOver groups, keyboard order, RTL, long text, sensitive previews, delayed result announcements. | Policies exist without direct behavior proof. | X-20 |

## Required test and evidence infrastructure

| Lane | Required proof | Current ceiling | Affected packets |
| --- | --- | --- | --- |
| Source ownership | Static owner map, no duplicate mutation owner, schema/manifest parity | Useful registries exist; 50 paths unproven | RP-02–RP-07 |
| Mutation durability | Atomic event/projection/Receipt, restart/replay, duplicate command, crash boundaries | Bounded paths only; current XCTest batch executed zero | RP-03, RP-05, RP-07 |
| Identity/migration | Stable IDs, merge/dedup, recurrence, Trash/restore, old-store migration | Missing canonical object families | RP-02, RP-04 |
| Navigation/restoration | Root/path/object/selection/focus/query/expression interruption/relaunch and stale target | No durable restoration record | RP-01, RP-05, RP-07, RP-08 |
| Search | Index rebuild/coverage/ranking/provenance/freshness/error/no-result/offline/owner transfer | Local Find source, no current execution | RP-05, RP-07 |
| Capture | Input lifecycle, clarification, correction preservation, owner commit, attachment failure, external entry, offline/restart | Text/bounded Goal handoff source only | RP-05, RP-07 |
| Time/calendar | Proposed-versus-accepted, Event/recurrence/source, view retention, conflict, external effects | Week/TimeBlock substrate | RP-02, RP-04, RP-07 |
| You/privacy | Setting persistence, unsupported-state honesty, permission-manifest parity, destructive preview/result/Receipt, privacy reset | Narrow preference/permission source | RP-06, RP-07 |
| Accessibility | Direct VoiceOver, Voice Control, Switch Control, FKA, focus/announcement, Dynamic Type, effects, contrast, motor | Current quality records explicitly withhold proof | RP-01, RP-08 |
| Localization/RTL | Catalog validation, long strings, RTL order/gesture, dates/times/calendars/units | No localization resources/tests | RP-08 |
| Platform/external | iPhone device matrix, widget, Live Activity, notification, intents/Shortcuts/Siri, locked-device privacy | Source exists; platform readiness withheld | RP-08 |

## Legacy and duplicate authority likely requiring removal after proof

These are candidates for later reconciliation, not deletion instructions.

| Candidate | Why it is risky | Required precondition |
| --- | --- | --- |
| Custom shell owners that duplicate native title/Back/focus behavior | They can conflict with selected native-default semantics and future edge-dock ownership. | D-ARC-01–03 resolved; behavior/accessibility parity proved |
| Direct/repository write paths marked unproven by `MeaningfulMutationRegistry` | They can bypass durable semantic event/Receipt/replay authority. | Equivalent canonical command path and restart/replay proof |
| Synthetic receipt/source/replay identifiers used as explanatory labels | They can visually imply durable records that are not resolved. | Replace with actual record linkage or visibly non-authoritative trace labels |
| Split Search projection paths (FTS versus repository aggregation) | They can disagree on coverage, ranking, provenance, freshness, and identity. | D-ARC-11 and parity/rebuild proof |
| Computed Goal timing rendered as ordinary Time blocks | It can present proposal as current truth. | Explicit accepted/proposed model and migration |
| Static enum-derived Life Areas if editable canon remains | They cannot supply editable/history/deletion identity. | Stored Life Area migration and compatibility proof |
| `What Ambitions Knows`/memory-dashboard presentation if current canon remains | It conflicts with normative no-knowledge-model law and risks second ownership. | D-ARC-15 and D-UX-10 |
| Policy-only or preview/fixture capability rows | They can be mistaken for production support. | Live owner, manifest parity, runtime proof, or removal/quarantine |
| Simulated/in-memory CloudKit defaults if continuity is later enabled | They do not satisfy private-graph sync, queue, conflict, or privacy claims. | Explicit approval plus full continuity architecture and proof |

## Migration risks

| Risk | Consequence | Required containment |
| --- | --- | --- |
| Identity split while introducing Life Area/Event/Placement records | Duplicate objects, broken owner return, lost history, incorrect Search consolidation | Stable migration keys, dedup rules, reversible migration testing |
| Changing shell container/dock before restoration ownership | Lost paths/context and inconsistent Back/focus | Fix ownership/schema first; parity tests before replacement |
| Replacing TimeBlock semantics without event/source lineage | Calendar drift, recurrence loss, incorrect external edits | Explicit source/series/occurrence/placement mapping |
| Moving writes before Receipt/replay parity | Lost idempotency, duplicate effects, false Undo | Row-by-row atomic/restart/replay proof |
| Enabling CloudKit/continuity from scaffolding | Private-data conflict, non-durable queue, migration/recovery failure | Keep disabled until consent/privacy/conflict/recovery contract is proven |
| Removing unavailable/status UI prematurely | Loss of honest boundaries and user recovery information | Preserve truthful status until replacement behavior exists |
| Adopting violet-indigo without migration/accessibility validation | Preference drift and contrast/semantic inconsistency | Product decision, persistence migration, measured contrast/effects proof |
| Broadening platforms through responsive code alone | Unsupported layouts, focus/input/privacy behavior | Explicit product scope and platform-specific proof matrix |

## Sequencing dependencies, not an implementation plan

```text
Product/canon decisions
  -> canonical identity and ownership
    -> truth, mutation, receipt, pending and restoration contracts
      -> projection and UX Blueprint reconciliation
        -> source reconstruction
          -> runtime/restart/migration proof
            -> accessibility/localization/platform proof
              -> Figma/SwiftUI closure consideration later
```

The dependency order prevents visual reconstruction from cementing duplicate ownership or unsupported behavior. It does not authorize any step, set dates, or assign implementation work.
