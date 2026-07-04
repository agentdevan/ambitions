# AMB-1647 - Repo Current State Taxonomy (2026-07-01)

## 1. Title and commit/branch context
- Issue: AMB-1647 - Repo Current State Taxonomy
- Parent: AMB-1646 - Full Repo Current-State Linear Mirror Acceptance
- Branch: main
- Commit inspected: 1cb9ba867
- Worktree before generation: clean
- Artifact status: Yellow control-plane evidence pending validation closeout. This is not implementation work.

## 2. Method and commands used
This pass used current repo inspection, targeted text search, read-only Linear search, and read-only subagent analysis. Subagents did not write files; the lead agent reconciled findings into this packet.

Commands and searches used:
- `pwd`
- `git status --short`
- `git branch --show-current`
- `git rev-parse --short HEAD`
- `find Native -maxdepth 4 -type d | sort`
- `find docs -maxdepth 4 -type f | sort`
- `find scripts -maxdepth 2 -type f | sort`
- `find tools -maxdepth 3 -type f | sort || true`
- `find Native/AmbitionsTests -maxdepth 4 -type d | sort || true`
- `find Native/AmbitionsUITests -maxdepth 4 -type d | sort || true`
- `find Native/AmbitionsWidgetExtension -maxdepth 4 -type d | sort || true`
- `find Native/AmbitionsShareExtension -maxdepth 4 -type d | sort || true`
- `rg -n "Private Life Runtime|LocalRuntimeOS|Private Life Orchestration|Command|Event|Projection|Receipt|Replay|Today|Goals|Time|You|Capture|Search|Trust|Proof|Source|Privacy|History|WidgetKit|App Intent|Share Extension|Notification|EventKit|Reminders|Deep Link|Live Activit|VoiceOver|Dynamic Type|Reduce Motion|Screenshot|TestFlight|App Store|Source Atlas|R2|Known Issue|AMB-ISSUE|Ready For Codex|Green" README.md AGENTS.md docs Native scripts tools project.yml Package.swift || true`
- `rg -n "AMB-1647|AMB-1648|Repo Current State Taxonomy|Linear Coverage Map|Full Repo Current-State Linear Mirror|Repo Current State|current-state" README.md AGENTS.md docs Native scripts tools project.yml Package.swift || true`
- `Linear read-only search: AMB-1647 Repo Current State Taxonomy`
- `Linear read-only search: AMB-1648 Linear Coverage Map`
- `Linear read-only search: LocalRuntimeOS`
- `Linear read-only search: Ambitions Native iPhone App Control Plane`
- `Linear read-only search: VSP-08 and iOS external boundary objects`

Validation results after artifact generation:

1. Command:

```bash
git diff --check
```

Exit code: 0
Summary: Passed with no output.

2. Command:

```bash
python3 - <<'PY'
import json
from pathlib import Path
for p in [
    Path("docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json"),
    Path("docs/linear/current-state/2026-07-01-linear-coverage-map.json"),
]:
    json.loads(p.read_text())
    print(f"JSON OK: {p}")
PY
```

Exit code: 0
Summary: Printed `JSON OK` for both current-state JSON artifacts.

3. Command:

```bash
python3 scripts/ambitions-architecture-inventory.py || true
```

Exit code: 0
Summary: Reported `canonical_required_files=207`, `entries=207`, `blocking_entries=0`, `implemented=207`, and final-tree parity achieved. This is architecture-tree parity only, not app Green.

4. Command:

```bash
python3 scripts/ambitions-green-standard-audit.py || true
```

Exit code: 0
Summary: Reported no disallowed architecture-as-UI strings in active primary UI source. This is not a Visual, Runtime, Accessibility, Release, TestFlight, App Store, privacy/legal, or known issue closure claim.

5. Command:

```bash
python3 scripts/ambitions-vsp-provenance-audit.py || true
```

Exit code: 0
Summary: VSP provenance audit passed with `Warnings: 0` and `Yellow proof gaps: 85`; the script wrote `docs/design/provenance/generated/provenance-audit-report.generated.md` but produced no working-tree diff.

## 3. Private Life Orchestration canon
- Private Life Orchestration is the primary classification layer. Folder ownership and UI surface names are secondary evidence.
- Top-level persistent surfaces are exactly Today, Goals, Time, and You. Capture is the global composer. Motion is cross-surface behavior, not a destination.
- The Private Life Runtime moat is local, inspectable, user-controlled, and offline usable without account sign-in.
- No meaningful Ambitions state change is valid unless it follows Command -> Event -> Projection -> Receipt -> Replay.
- Source Atlas and R2 are public/reference/freshness infrastructure only. They must not store the private life graph.
- External adapters may display, enqueue, deep-link, or write outside the app only as downstream adapters. They are never core authority.
- No Visual Green, Runtime Green, Accessibility Green, Release Green, TestFlight readiness, App Store readiness, privacy/legal approval, or known issue closure is claimed by this packet.

Canonical orchestration layers applied in the rows: Intent/capture intake; Identity direction/life area/ambition/goal thread; Context/capacity/protected time/time reality/recovery; Recommended step/planning/reflow; Command authority; Event journal; Projection/read model; Receipt/replay; Proof/source/privacy/history/trust inspection; Closure/reflection/adaptation/recovery; Local-first storage/migration/repair; Life-data boundary; External adapter, never core authority; QA/validation/release proof gate.

## 4. App aspect taxonomy table
| app_aspect | private_life_orchestration_role | orchestration_layer | proof_ceiling | gap_classification |
| --- | --- | --- | --- | --- |
| Repo authority / product canon | Defines Ambitions as a premium native iPhone-first local-first Personal Life OS and makes Private Life Orchestration the top classification layer. | QA / validation / release proof gate | CONTROL_PLANE_ONLY | COVERED_CURRENT |
| App root / launch / environment / dependencies | Defines native iOS target graph, extension embedding, XcodeGen ownership, and package surfaces used by the local-first app shell. | QA / validation / release proof gate | YELLOW_REPO_EVIDENCE | MISSING_PROOF_GATE |
| App root / launch / environment / dependencies | Composes app services, projection stores, command paths, search, trust, capture, and runtime dependencies for the local Personal Life OS. | Command authority | YELLOW_REPO_EVIDENCE | MISSING_CODEX_LEAVES |
| Stage / shell / chrome / routing / continuity | Provides the persistent four-surface shell, route continuity, overlays, and non-root cross-surface behaviors that let orchestration stay inspectable. | Projection / read model | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| Motion | Implements cross-surface behavior for re-entry, completion, blockage, recovery, time-shift, undo, and protected-boundary state changes without becoming a destination. | Closure / reflection / adaptation / recovery | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Today | Turns current reality, capacity, protected time, and recommended step into the flagship Start here decision object. | Context / capacity / protected time / time reality / recovery | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Goals | Owns identity direction, life areas, ambition paths, goal threads, and goal-to-step interpretation. | Identity direction / life area / ambition / goal thread | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_PARENT_REPAIR |
| Time | Models time reality, capacity, protected time, placement, and reflow for recommended steps that fit actual life. | Context / capacity / protected time / time reality / recovery | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_PARENT_REPAIR |
| You | Owns user system profile, preferences, identity context, and adaptation settings that personalize orchestration without cloud profiling. | Identity direction / life area / ambition / goal thread | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_PARENT_REPAIR |
| Capture | Global composer and durable intake path that turns messy intent into command-backed candidate objects without becoming a tab or inbox. | Intent / capture intake | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Search | Provides local recall over projections, memory lens context, and search indexes without becoming core authority. | Projection / read model | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Trust / Proof / Source / Privacy / History / Receipts | Provides inspectable proof, source, privacy, history, receipt, replay, and undo/recovery views over local runtime changes. | Proof / source / privacy / history / trust inspection | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| LocalRuntimeOS / Private Life Runtime | Local, inspectable, user-controlled life graph moat that converts intent to reality-fit action and preserves proof-backed change over time. | Local-first storage / migration / repair | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_LEAF_REPAIR |
| Command / transaction authority | Authorizes and commits user-meaningful mutations through deterministic local commands and transactions. | Command authority | YELLOW_SCOPED_RUNTIME | COVERED_CURRENT |
| Event journal | Records the durable local event history that makes Ambitions state replayable, inspectable, and recoverable. | Event journal | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_LEAF_REPAIR |
| Projection / read model | Materializes read models for Today, Goals, Time, You, Search, Widget, App Intent, Receipt, and Privacy views. | Projection / read model | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_LEAF_REPAIR |
| Receipt / replay | Verifies lineage, replayability, local-only receipts, and user-inspectable proof over runtime mutations. | Receipt / replay | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_LEAF_REPAIR |
| Planning and recommendation | Turns intent, identity, context, and time reality into recommended steps and reflow candidates. | Recommended step / planning / reflow | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Time/capacity/reflow | Computes capacity, protected time, conflicts, recovery moves, placement, and reflow against life reality. | Context / capacity / protected time / time reality / recovery | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_PARENT_REPAIR |
| Capture routing / durable intake | Routes raw capture intent to durable intake, classification, promotion candidates, and command-backed object creation. | Intent / capture intake | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Storage / migration / repair | Stores events, object state, projections, search indexes, blobs, snapshots, backups, and migration state while keeping mutation authority in LocalRuntimeOS. | Local-first storage / migration / repair | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_PARENT_REPAIR |
| Diagnostics / repair | Inspects local runtime health, previews repairs, and supports recovery without destructive or unreviewed graph mutation. | Local-first storage / migration / repair | YELLOW_REPO_EVIDENCE | MISSING_PROOF_GATE |
| PrivacySecurity / life-data boundary | Defines the hard boundary that keeps private life graph state local and permits only approved external adapter contracts. | Life-data boundary | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| Sync / continuity | Optional continuity scaffolding; never core authority and never required for offline core value. | External adapter, never core authority | DO_NOT_PROMOTE | DO_NOT_PROMOTE |
| Side effects | Mediates external writes, notifications, calendar/reminder operations, and other effects so they remain downstream of local commits. | External adapter, never core authority | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Widget extension | External glance adapter that displays a verified local projection snapshot without owning private life graph state. | External adapter, never core authority | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Share extension | External intake adapter for URL/text that stages incoming intent into local durable capture intake. | External adapter, never core authority | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| App Intents / Shortcuts / Siri | External command surface that should enqueue or open confirmed actions without silently mutating core state. | External adapter, never core authority | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Notifications | External reminder and response adapter downstream of local orchestration, never core authority. | External adapter, never core authority | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| EventKit / Reminders | External calendar/reminder adapter that may write outside Ambitions only after local commit evidence. | External adapter, never core authority | OWNER_REVIEW_REQUIRED | OWNER_REVIEW_REQUIRED |
| Deep links / URL routing | External route adapter that opens the right local projection, trust detail, or confirmation surface without owning state. | External adapter, never core authority | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Live Activities | External glance adapter for active local projection state; never a mutation or authority surface. | External adapter, never core authority | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Design system / tokens / materials / typography / spacing / motion / haptics | Gives orchestration surfaces a premium native iPhone presentation, consistent materials, readable hierarchy, calm motion, and haptic affordances. | QA / validation / release proof gate | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| VoiceOver / Dynamic Type / Reduce Motion / contrast / hit targets / focus behavior | Ensures the local Personal Life OS remains usable, non-shaming, and inspectable across accessibility settings. | QA / validation / release proof gate | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| Screenshot matrix / visual QA / screenshot diffing | Provides visual inspection and regression evidence for the orchestration shell and surfaces without claiming runtime truth by itself. | QA / validation / release proof gate | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| Visual specification provenance | Maps intended premium native visual behavior to source-owner paths and owner-review packets for orchestration surfaces. | QA / validation / release proof gate | YELLOW_VISUAL_PROVENANCE_ONLY | PARTIAL_NEEDS_LEAF_REPAIR |
| Tests / scripts / architecture audits / validation gates | Provides source, runtime, UI, accessibility, and proof-honesty checks for local-first orchestration claims. | QA / validation / release proof gate | CONTROL_PLANE_ONLY | MISSING_PROOF_GATE |
| Known issues / risk register | Tracks known app risks, remediation dossiers, and issue-to-proof gaps that can block implementation, Green, release, or closure. | QA / validation / release proof gate | CONTROL_PLANE_ONLY | MISSING_KNOWN_ISSUE_MAPPING |
| Release gates / TestFlight / App Store | Defines release proof gates and blocks TestFlight/App Store claims until current runtime, visual, accessibility, privacy/legal, and owner-review proof exists. | QA / validation / release proof gate | RED_RELEASE | DO_NOT_PROMOTE |
| PrivacySecurity / Source Atlas / R2 | Public/reference/freshness infrastructure that may inform local reference packs but must never store or process the private life graph. | External adapter, never core authority | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| Account / optional sign-in / entitlement / paywall / pricing | Optional identity and entitlement layer that must not be required for offline core orchestration. | Life-data boundary | DO_NOT_PROMOTE | DO_NOT_PROMOTE |
| Import / export / reset / erasure | Controls user-owned data portability, reset, sign-out cleanup, erasure, and repair flows for local private graph data. | Life-data boundary | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| Privacy manifest / legal/privacy policy evidence | Supplies platform privacy declarations and legal release evidence for local-first life-data boundaries. | QA / validation / release proof gate | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| Tools / developer adapters | Supports repo analysis, Source Atlas operations, development automation, and proof generation, but is outside app runtime authority. | QA / validation / release proof gate | CONTROL_PLANE_ONLY | OWNER_REVIEW_REQUIRED |
| Superpowers docs / agent workflow controls | Documents agent/runbook workflows that can shape implementation but cannot override product truth or proof gates. | QA / validation / release proof gate | OWNER_REVIEW_REQUIRED | OWNER_REVIEW_REQUIRED |
| Linear mirror / existing ownership map | Provides prior repo-to-Linear reconciliation packets that seed this repo-current mirror but do not replace full Private Life Orchestration taxonomy. | QA / validation / release proof gate | CONTROL_PLANE_ONLY | PARTIAL_NEEDS_LEAF_REPAIR |
| Packages / reusable UI and experience kernel | Reusable package layer for design system, widget UI, and experience-kernel scaffolding consumed by app targets. | Projection / read model | YELLOW_REPO_EVIDENCE | MISSING_SOURCE_OWNER_PATH |

## 5. Repo directory taxonomy table
| path | app_aspect | source_owner_system | existing_linear_object | missing_linear_object | validation_gate |
| --- | --- | --- | --- | --- | --- |
| README.md; AGENTS.md; docs/truth/ | Repo authority / product canon | Truth authority plus agent front door; docs/truth wins when conflicts exist. | AMB-1646 parent; AMB-1647 leaf; AMB-1648 leaf; initiative: Ambitions Native iPhone App Control Plane. | No missing control-plane object for this taxonomy packet; implementation leaves must still be mapped by aspect below. | Truth-file inspection plus proof-honesty audits. |
| project.yml; Package.swift | App root / launch / environment / dependencies | XcodeGen project source plus Swift Package source declarations. | initiative: Ambitions Native iPhone App Control Plane; project: Ambitions Full-App Design Documentation + Linear Coverage Map. | Missing current build/device proof leaf tying launch graph to AMB-1646 mirror acceptance. | XcodeGen/build validation and extension entitlement proof required before promotion. |
| Native/Ambitions/App/ | App root / launch / environment / dependencies | Final Architecture Tree owner: App. | initiative: Ambitions Native iPhone App Control Plane; AMB-1646 current-state mirror acceptance. | Missing app-root current-state Codex leaf for launch, dependency graph, offline boot, and account-optional proof. | architecture inventory; app container focused tests; offline launch proof. |
| Native/Ambitions/Stage/; Native/Ambitions/Stage/Chrome/; Native/Ambitions/Stage/Overlays/ | Stage / shell / chrome / routing / continuity | Final Architecture Tree owner: Stage. | project: Ambitions Flagship Visual Specification Layer - Pre-Codex; VSP-01/02/03/04/06/07/09/10 mirror leaves. | Missing parent/leaf set for current Stage shell runtime proof beyond VSP provenance. | visual screenshot matrix, UI tests, accessibility proof, stage route tests. |
| Native/Ambitions/Stage/Motion/ | Motion | Final Architecture Tree owner: Stage/Motion. | VSP-07 and VSP-09 provenance references; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing current parent Feature for Stage/Motion runtime behavior and recovery proof. | motion behavior tests plus Reduce Motion and haptics validation. |
| Native/Ambitions/Surfaces/Today/; Native/Ambitions/Surfaces/Today/Projection/ | Today | Final Architecture Tree owners: Surfaces/Today and Projection. | AMB-1481 VSP-02 leaf; AMB-1381 Today Reality Window Acceptance; initiative: Today Surface. | Missing current implementation leaves for Today runtime receipt, reflow, accessibility, and screenshot proof. | Today scenario gate; LocalRuntimeOS receipt replay tests; UI/accessibility screenshots. |
| Native/Ambitions/Surfaces/Goals/; Native/Ambitions/Surfaces/Goals/Projection/ | Goals | Final Architecture Tree owners: Surfaces/Goals and Projection. | AMB-1482 VSP-03 leaf; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing repo-current parent Feature and leaves for goal creation, path planning, receipt replay, Life Capital, and runtime proof. | Goals scenario gate; runtime contract tests; accessibility and visual proof. |
| Native/Ambitions/Surfaces/Time/; Native/Ambitions/Core/LocalRuntimeOS/Scheduling/; Native/Ambitions/Surfaces/Time/Projection/Time* | Time | Final Architecture Tree owners: Surfaces/Time, Core/LocalRuntimeOS/Scheduling, Projection. | AMB-1483 VSP-04 leaf; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing repo-current parent Feature and Codex leaves for time/capacity/reflow runtime proof. | Time scenario gate; EventKit boundary tests; runtime replay proof. |
| Native/Ambitions/Surfaces/You/; Native/Ambitions/Surfaces/You/Projection/ | You | Final Architecture Tree owners: Surfaces/You and Projection. | AMB-1485 VSP-06 leaf; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing repo-current parent Feature and Codex leaves for profile preferences, Life Capital, adaptation, receipt, and privacy proof. | You scenario gate; preference receipt tests; privacy boundary proof. |
| Native/Ambitions/Composer/Capture/; Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/ | Capture | Final Architecture Tree owners: Composer/Capture and Core/LocalRuntimeOS/CaptureRouting. | AMB-1484 VSP-05 leaf; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing repo-current parent Feature and leaves for durable intake, promotion routing, failure recovery, and accessibility proof. | capture routing tests; app-wide capture invocation UI tests; privacy proof. |
| Native/Ambitions/Core/LocalRuntimeOS/SearchRecall/; Native/Ambitions/Interaction/MemoryLens*; Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/*Search* | Search | Final Architecture Tree owners: Core/LocalRuntimeOS/SearchRecall, Interaction, Projection. | AMB-1400 Local Search Index Acceptance; project: iOS system and full-app coverage references. | Missing repo-current Search parent/leaf map linking FTS, memory lens, trust inspection, and privacy proof. | Search recall tests; projection rebuild tests; privacy inspection gate. |
| Native/Ambitions/Trust/; Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/; Native/Ambitions/Trust/Projection/ | Trust / Proof / Source / Privacy / History / Receipts | Final Architecture Tree owners: Trust and Core/LocalRuntimeOS/TrustSystem. | AMB-1486 VSP-07 leaf; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing repo-current Codex leaves for live trust inspection, ledger UI, undo/replay recovery, and accessibility proof. | runtime trust-system tests; receipt replay tests; UI/accessibility inspection proof. |
| Native/Ambitions/Core/LocalRuntimeOS/ | LocalRuntimeOS / Private Life Runtime | Final Architecture Tree owner: Core/LocalRuntimeOS. | initiative: Private Life Runtime; AMB-1544 LocalRuntimeOS Architecture Canon + Migration Spine Acceptance. | Missing app-wide runtime mirror leaves linking every surface mutation and adapter path to LocalRuntimeOS ownership. | local runtime proof plus app-wide mutation-path coverage audit. |
| Native/Ambitions/Core/LocalRuntimeOS/CommandSpine/; Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/ | Command / transaction authority | Final Architecture Tree owner: Core/LocalRuntimeOS/CommandSpine and TransactionKernel. | AMB-1544; LocalRuntimeOS Runtime Spine dossier references. | Missing per-surface mutation coverage leaves for every command entry point. | runtime contract tests; architecture inventory; mutation path audit. |
| Native/Ambitions/Core/LocalRuntimeOS/EventJournal/ | Event journal | Final Architecture Tree owner: Core/LocalRuntimeOS/EventJournal. | AMB-1544; initiative: Private Life Runtime. | Missing per-surface event lineage leaves and repair/rebuild proof objects. | event append failure tests; replay rebuild tests; migration repair proof. |
| Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/; Native/Ambitions/Projection/ | Projection / read model | Final Architecture Tree owners: Core/LocalRuntimeOS/ProjectionEngine and Projection. | AMB-1544; VSP-02 through VSP-10 leaves for visual/projection aspects. | Missing projection-read-model coverage leaves for all app aspects and external adapters. | projection materializer tests; rebuild tests; screenshot/semantic audits. |
| Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/ | Receipt / replay | Final Architecture Tree owner: Core/LocalRuntimeOS/TrustSystem. | AMB-1544; AMB-1486 VSP-07. | Missing leaf coverage for every receipt surface, undo path, and replay inspection workflow. | receipt replay tests; trust ledger UI tests; privacy redaction proof. |
| Native/Ambitions/Core/LocalRuntimeOS/Planning/ | Planning and recommendation | Final Architecture Tree owner: Core/LocalRuntimeOS/Planning. | initiative: Private Life Runtime; AMB-1544 partial owner. | Missing dedicated Planning/Recommendation parent Feature and Codex leaves for step selection, reflow, and proof. | planning scenario tests; deterministic recommendation tests; proof-inspection gate. |
| Native/Ambitions/Core/LocalRuntimeOS/Scheduling/ | Time/capacity/reflow | Final Architecture Tree owner: Core/LocalRuntimeOS/Scheduling. | AMB-1483 VSP-04; AMB-1544 partial runtime owner. | Missing current TimeEngine parent Feature and Codex leaves for capacity/reflow proof. | time engine tests; EventKit boundary tests; scenario gates. |
| Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/ | Capture routing / durable intake | Final Architecture Tree owner: Core/LocalRuntimeOS/CaptureRouting. | AMB-1484 VSP-05; AMB-1544 partial runtime owner. | Missing durable intake parent/leaf set for queue repair, failure recovery, and promotion proof. | durable intake tests; replay/idempotency tests; privacy redaction proof. |
| Native/Ambitions/Core/LocalRuntimeOS/Storage/; Native/Ambitions/Core/LocalRuntimeOS/ObjectState/; Native/Ambitions/Core/Persistence/; Native/Ambitions/Core/Runtime/ | Storage / migration / repair | Final Architecture Tree owner: Core/LocalRuntimeOS/Storage and ObjectState; legacy scaffolding in Core/Persistence and Core/Runtime. | initiative: Private Life Runtime; AMB-1544. | Missing storage migration/repair leaves to close legacy scaffolding and app-wide storage proof. | migration dry-run tests; repair-preview tests; storage boundary audit. |
| Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/; Native/Ambitions/Core/LocalRuntimeOS/Diagnostics/ | Diagnostics / repair | Final Architecture Tree owners: Core/LocalRuntimeOS/MigrationRepair and Diagnostics. | AMB-1544 partial runtime owner. | Missing diagnostics/repair parent leaves for user-visible recovery and support proof. | diagnostics tests; repair dry-run tests; privacy export gate. |
| Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/; Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/ | PrivacySecurity / life-data boundary | Final Architecture Tree owner: Core/LocalRuntimeOS/RuntimeBoundary and PrivacySecurity. | initiative: Private Life Runtime; VSP-08 external boundary dossier references. | Missing dedicated privacy boundary proof leaves for account, source atlas, extensions, export, reset, and support diagnostics. | privacy boundary tests; legal/privacy review; release proof gate. |
| Native/Ambitions/Core/LocalRuntimeOS/Continuity/; entitlements in project.yml | Sync / continuity | Final Architecture Tree owner: Core/LocalRuntimeOS/Continuity plus project entitlements. | initiative: Ambitions Native iPhone App Control Plane; VSP-08 external boundary references. | Missing optional sync/account boundary project with privacy/legal authority; no approved private graph sync architecture found. | privacy/legal gate; release gate; user-owned sync architecture approval before promotion. |
| Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ | Side effects | Final Architecture Tree owner: Core/LocalRuntimeOS/SideEffectSystem. | iOS System Integrations initiative; AMB-1417/AMB-1418 partial external-adapter parents. | Missing side-effect system parent/leaf coverage tying notifications, EventKit, Reminders, and app intents to receipts. | side-effect policy tests; adapter UI tests; privacy boundary gate. |
| Native/AmbitionsWidgetExtension/; AppUI/Sources/AmbitionsWidgetUI/; Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/*Widget* | Widget extension | Widget extension target, AppUI widget package, and LocalRuntimeOS projection snapshot owner. | AMB-1414 WidgetKit Boundary Acceptance; iOS System Integrations initiative. | Missing current widget device/gallery/timeline/accessibility proof leaf. | WidgetKit device proof; snapshot verification tests; privacy redaction review. |
| Native/AmbitionsShareExtension/; Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/; app group queue paths in project.yml | Share extension | Share extension target plus CaptureRouting/local intake owner. | AMB-1416 Share Extension Boundary Acceptance; iOS System Integrations initiative. | Missing failure-safe share queue drain/idempotency/recovery proof leaf. | share extension simulator/device proof; queue recovery tests; privacy gate. |
| Native/Ambitions/AppIntents*; Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/*AppIntent*; project.yml | App Intents / Shortcuts / Siri | App Intents source owner plus LocalRuntimeOS projection/side-effect boundaries. | AMB-1415 App Intents Boundary Acceptance; iOS System Integrations initiative. | Missing device invocation, Siri/Shortcuts, confirmation, receipt, and privacy proof leaf. | App Intent tests; Shortcut/Siri device proof; privacy inspection. |
| Native/Ambitions/Interaction/*Notification*; Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/; project.yml usage strings | Notifications | Interaction notification source plus SideEffectSystem policy. | AMB-1417 Notifications Boundary Acceptance; iOS System Integrations initiative. | Missing notification delivery, action response, privacy copy, receipt, and focus-mode proof leaf. | notification device proof; side-effect tests; privacy copy review. |
| Native/Ambitions/Interaction/*EventKit*; Native/Ambitions/Interaction/*Reminder*; Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ | EventKit / Reminders | Interaction adapter source plus SideEffectSystem policy. | AMB-1418 EventKit/Reminders Boundary Acceptance; iOS System Integrations initiative. | Missing leaf proving all user paths supply commit-backed variants and recover from external write failures. | EventKit/Reminder adapter tests; permission/device proof; side-effect recovery proof. |
| Native/Ambitions/App/URL routing; Native/Ambitions/Stage routing; widgetURL/deep link adapters | Deep links / URL routing | App/Stage route registry and external-origin translators. | AMB-1419 Deep Links Boundary Acceptance; iOS System Integrations initiative. | Missing current URL route matrix, external-origin privacy, and device proof leaf. | deep link route tests; privacy URL audit; device proof. |
| Native/AmbitionsWidgetExtension/ Live Activity source; ActivityKit search hits; project.yml capabilities | Live Activities | Widget extension/ActivityKit source plus projection snapshot boundary. | iOS System Integrations initiative; no specific Live Activities parent found in current Linear search. | Missing Live Activities parent Feature and proof leaf for device, Dynamic Island, privacy, and lifecycle behavior. | ActivityKit device proof; snapshot privacy review; route tests. |
| Native/Ambitions/DesignSystem/; Sources/AmbitionsDesignSystem/ | Design system / tokens / materials / typography / spacing / motion / haptics | Final Architecture Tree owner: DesignSystem plus Swift package AmbitionsDesignSystem. | VSP-01, VSP-09, VSP-10 provenance leaves; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing implementation leaves proving current SwiftUI surfaces consume tokens correctly across device sizes and modes. | visual QA; screenshot diffing; accessibility audit; owner approval. |
| Native/Ambitions/Interaction/; Native/Ambitions/Quality/; docs/design/provenance/VSP-09* | VoiceOver / Dynamic Type / Reduce Motion / contrast / hit targets / focus behavior | Interaction, Quality, DesignSystem, and VSP-09 proof-gate owners. | VSP-09 Accessibility/Motion/Haptics Matrix; visual specification project. | Missing current accessibility proof leaves for each major surface and external adapter. | accessibility audit; simulator/device screenshots; exported hierarchy proof; owner review. |
| Native/Ambitions/Rendering/; Native/Ambitions/Quality/; Native/AmbitionsUITests/ | Screenshot matrix / visual QA / screenshot diffing | Rendering, Quality, and UI test owners. | VSP provenance leaves; AFEP/visual QA references in docs/design/provenance. | Missing current full-surface screenshot matrix and screenshot diffing proof leaf. | screenshot matrix script; UI tests; visual diff audit; sanitized fixture review. |
| docs/design/provenance/ | Visual specification provenance | Design provenance docs, proof registry, and VSP generated inventories. | AMB-1480 through AMB-1489 VSP leaves; project: Ambitions Flagship Visual Specification Layer - Pre-Codex. | Missing repo-current implementation leaves that turn provenance into runtime/visual/accessibility proof. | ambitions-vsp-provenance-audit plus current rendered SwiftUI proof before promotion. |
| Native/AmbitionsTests/; Native/AmbitionsUITests/; scripts/ | Tests / scripts / architecture audits / validation gates | Native tests, UI tests, and retained scripts. | AMB-1544; AMB-1646/1647/1648; QA/release governance references in reconciliation docs. | Missing current unified proof-gate parent for architecture, runtime, visual, accessibility, known-issue, release, and legal gates. | required commands in this packet plus focused app gates in follow-up leaves. |
| docs/qa/KNOWN_ISSUES.md; docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md; docs/qa/risk-register-imports/ | Known issues / risk register | QA known issue docs and risk-register imports. | Existing reconciliation packets mention known issue mapping but no app-wide current-state issue closure object was found. | Missing app-wide known-issue-to-Linear coverage map and closure proof leaves. | known issue crosswalk; proof index; current verification for each closure. |
| docs/truth/RELEASE_TRUTH.md; docs/quality/; scripts/*green*; scripts/*release* | Release gates / TestFlight / App Store | Release truth, quality docs, and retained release/Green scripts. | initiative/project references in Ambitions Native iPhone App Control Plane; no release-ready object found for current packet. | Missing release governance parent with TestFlight/App Store, privacy/legal, device proof, accessibility, and known-issue closure leaves. | release checklist, app build/archive, privacy manifest/legal review, device proof, accessibility proof. |
| Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/; tools/source-atlas/; docs/qa/source-atlas/ | PrivacySecurity / Source Atlas / R2 | LocalRuntimeOS SourceAtlas boundary, tools/source-atlas, and Source Atlas QA ledgers. | VSP-08 external boundary dossier; Source Atlas/R2 evidence docs; no private graph backend authority. | Missing current production R2/legal/privacy boundary approval object for any promotion beyond public/reference packs. | source atlas privacy boundary audit; production R2 gate only for public/reference packs; legal review. |
| project.yml entitlements; Native/Ambitions/Surfaces/You/ account copy; Native/Ambitions/Core/LocalRuntimeOS/Continuity/ | Account / optional sign-in / entitlement / paywall / pricing | Account/entitlement scaffolding where present plus truth docs; no core runtime authority. | VSP-08 external boundary references; Ambitions Native iPhone App Control Plane initiative. | Missing account/paywall/pricing/legal parent project and implementation/proof leaves. | privacy/legal gate; account/no-account acceptance tests; release gate. |
| Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/ export/reset sources; docs/truth/RELEASE_TRUTH.md | Import / export / reset / erasure | PrivacySecurity, MigrationRepair, and release/privacy truth owners. | Privacy boundary references in VSP-08 and Private Life Runtime initiative. | Missing import/export/reset/erasure parent Feature and legal/privacy/recovery proof leaves. | privacy/legal review; reset/restore tests; support diagnostics redaction gate. |
| Native/Ambitions/Resources/PrivacyInfo.xcprivacy; docs/truth/RELEASE_TRUTH.md; docs/legal/privacy policy evidence if present | Privacy manifest / legal/privacy policy evidence | Resource privacy manifest plus release/privacy truth; legal docs only where present. | Release/privacy references in control-plane initiatives; no privacy/legal approval object found in current search. | Missing privacy/legal approval parent and leaves for app, extensions, account, Source Atlas/R2, export/reset, and App Store disclosures. | privacy manifest audit; legal review; App Store privacy questionnaire review. |
| tools/; tools/openai/; tools/source-atlas/; tools/mcp*/ | Tools / developer adapters | Retained tools tree; Source Atlas generated/tooling owners. | Source Atlas/R2 evidence objects; control-plane initiatives. | Missing source-owner map for developer tools that can affect proof, R2, or generated artifacts. | tool inventory; credential audit; Source Atlas privacy boundary checks. |
| docs/superpowers/ | Superpowers docs / agent workflow controls | Docs/superpowers workflow documentation. | No specific current Linear object found for docs/superpowers ownership. | Missing source-owner mapping or archive decision for superpowers docs in current-state Linear mirror. | docs authority review; historical policy check. |
| docs/linear/reconciliation/ | Linear mirror / existing ownership map | Linear reconciliation docs generated before this current-state packet. | AMB-1639; AMB-1640; AMB-1641; prior VSP/Linear reconciliation packet references. | Missing AMB-1647/AMB-1648 current-state artifacts were absent before this packet. | current-state taxonomy and coverage map validation. |
| Packages/AmbitionsExperienceKernel/; Sources/; AppUI/Sources/ | Packages / reusable UI and experience kernel | SwiftPM package owners declared in Package.swift plus package directories. | No dedicated package ownership object found; VSP/design and widget coverage partially touch these paths. | Missing package source-owner map connecting reusable packages to app aspects and proof gates. | SwiftPM build/test gate; source-owner review; widget/design proof. |

## 6. Runtime mutation authority map
| authority | owner | role | required_gate |
| --- | --- | --- | --- |
| Command | Core/LocalRuntimeOS/CommandSpine and TransactionKernel | Validate and authorize meaningful local state changes. | No direct surface/repository mutation outside command-backed service. |
| Event | Core/LocalRuntimeOS/EventJournal | Durably record local history before projection mutation succeeds. | Append failure must fail closed. |
| Projection | Core/LocalRuntimeOS/ProjectionEngine and Projection | Derive read models for surfaces, search, widgets, app intents, receipts, and privacy. | Projection rebuild/staleness repair proof. |
| Receipt | Core/LocalRuntimeOS/TrustSystem | Bind command/event/projection lineage into inspectable proof. | Every user-meaningful mutation returns replayable proof. |
| Replay | Core/LocalRuntimeOS/TrustSystem and MigrationRepair | Recover and inspect state from local event/receipt lineage. | Replay and repair scenario proof. |
| External adapters | Widget, Share, App Intents, Notifications, EventKit/Reminders, Deep Links, Live Activities | Display, enqueue, deep-link, or write only downstream of local authority. | Adapter privacy, permission, device, and commit-evidence proof. |

## 7. Local-first/privacy boundary map
| boundary | repo_evidence | risk | classification |
| --- | --- | --- | --- |
| Offline core | Truth docs and app/runtime source owners preserve no-account core. | Account/sync/paywall cannot become required for core value. | DO_NOT_PROMOTE where proof incomplete. |
| Private life graph | LocalRuntimeOS and Storage/ObjectState owners exist. | Goals, captures, time, receipts, preferences, projections, and history must not leave device. | RED_PRIVACY_LEGAL for release/legal gaps. |
| R2/Source Atlas | SourceAtlas owner plus tools/source-atlas and QA ledgers exist. | Public/reference only; no private graph storage or processing. | DO_NOT_PROMOTE beyond public/reference authority. |
| External surfaces | Widget/share/app-intent/notification/EventKit/deep-link/live-activity source evidence exists. | Adapters can reveal private data outside app UI. | PARTIAL_NEEDS_LEAF_REPAIR or OWNER_REVIEW_REQUIRED. |
| Diagnostics/export/reset | PrivacySecurity/MigrationRepair source areas exist. | Support/export artifacts can expose full graph. | DO_NOT_PROMOTE until legal/privacy proof. |

## 8. External adapter map
| path | app_aspect | private_life_orchestration_role | runtime_mutation_path | local_first_boundary | gap_classification |
| --- | --- | --- | --- | --- | --- |
| Native/Ambitions/Core/LocalRuntimeOS/Continuity/; entitlements in project.yml | Sync / continuity | Optional continuity scaffolding; never core authority and never required for offline core value. | Sync cannot become source of truth; any future sync must replay local events under explicit future canon. | Offline core must be complete without account, CloudKit, or network. | DO_NOT_PROMOTE |
| Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ | Side effects | Mediates external writes, notifications, calendar/reminder operations, and other effects so they remain downstream of local commits. | Side effects must be downstream of command/event/receipt; they cannot create Ambitions state directly. | External side effects must not leak private graph details beyond user-approved adapter payloads. | PARTIAL_NEEDS_LEAF_REPAIR |
| Native/AmbitionsWidgetExtension/; AppUI/Sources/AmbitionsWidgetUI/; Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/*Widget* | Widget extension | External glance adapter that displays a verified local projection snapshot without owning private life graph state. | Widget reads projection snapshot or deep-links into app; it cannot mutate core state directly. | Widget payload must be minimized and derived from local verified projection only. | PARTIAL_NEEDS_LEAF_REPAIR |
| Native/AmbitionsShareExtension/; Native/Ambitions/Core/LocalRuntimeOS/CaptureRouting/; app group queue paths in project.yml | Share extension | External intake adapter for URL/text that stages incoming intent into local durable capture intake. | Share extension must enqueue external creation request; app-side command path must promote it into state. | Shared payloads remain local and are not uploaded for classification. | PARTIAL_NEEDS_LEAF_REPAIR |
| Native/Ambitions/AppIntents*; Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/*AppIntent*; project.yml | App Intents / Shortcuts / Siri | External command surface that should enqueue or open confirmed actions without silently mutating core state. | External intents should enqueue intake or open app confirmation; meaningful state changes require command/event/receipt. | Intent payloads and suggested shortcuts cannot expose private graph beyond explicit user action. | PARTIAL_NEEDS_LEAF_REPAIR |
| Native/Ambitions/Interaction/*Notification*; Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/; project.yml usage strings | Notifications | External reminder and response adapter downstream of local orchestration, never core authority. | Notification responses must route into app/command-backed action; notification scheduling is a side effect. | Notification bodies must minimize private context and remain user-controlled. | PARTIAL_NEEDS_LEAF_REPAIR |
| Native/Ambitions/Interaction/*EventKit*; Native/Ambitions/Interaction/*Reminder*; Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ | EventKit / Reminders | External calendar/reminder adapter that may write outside Ambitions only after local commit evidence. | External calendar/reminder writes must follow local command receipt and cannot establish core state. | Calendar/reminder context must stay local unless user explicitly grants external write. | OWNER_REVIEW_REQUIRED |
| Native/Ambitions/App/URL routing; Native/Ambitions/Stage routing; widgetURL/deep link adapters | Deep links / URL routing | External route adapter that opens the right local projection, trust detail, or confirmation surface without owning state. | Deep links route or request confirmation; no core mutation without command/event/receipt. | Routes must not encode sensitive graph payloads in URLs. | PARTIAL_NEEDS_LEAF_REPAIR |
| Native/AmbitionsWidgetExtension/ Live Activity source; ActivityKit search hits; project.yml capabilities | Live Activities | External glance adapter for active local projection state; never a mutation or authority surface. | Live Activity displays derived snapshot and deep-links; no core mutation authority. | Live Activity content must be minimized and derived from local projection only. | MISSING_PARENT_FEATURE |
| Native/Ambitions/Core/LocalRuntimeOS/SourceAtlas/; tools/source-atlas/; docs/qa/source-atlas/ | PrivacySecurity / Source Atlas / R2 | Public/reference/freshness infrastructure that may inform local reference packs but must never store or process the private life graph. | Source Atlas is an external reference adapter; it cannot mutate core state or receive private graph data. | R2 is public/reference/freshness only; private goals, captures, schedules, receipts, preferences, and graph data stay local. | DO_NOT_PROMOTE |

## 9. QA/release proof-gate map
| path | app_aspect | proof_or_recovery_gap | validation_gate | proof_ceiling | gap_classification |
| --- | --- | --- | --- | --- | --- |
| README.md; AGENTS.md; docs/truth/ | Repo authority / product canon | Truth files are authority, not proof of current runtime, visual, accessibility, legal, or release readiness. | Truth-file inspection plus proof-honesty audits. | CONTROL_PLANE_ONLY | COVERED_CURRENT |
| project.yml; Package.swift | App root / launch / environment / dependencies | No current build-for-testing, install, entitlement, or device launch proof in this packet. | XcodeGen/build validation and extension entitlement proof required before promotion. | YELLOW_REPO_EVIDENCE | MISSING_PROOF_GATE |
| Native/Ambitions/DesignSystem/; Sources/AmbitionsDesignSystem/ | Design system / tokens / materials / typography / spacing / motion / haptics | VSP/Figma provenance is not SwiftUI parity, device, accessibility, or release proof. | visual QA; screenshot diffing; accessibility audit; owner approval. | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| Native/Ambitions/Interaction/; Native/Ambitions/Quality/; docs/design/provenance/VSP-09* | VoiceOver / Dynamic Type / Reduce Motion / contrast / hit targets / focus behavior | Manual VoiceOver audio, Dynamic Type, Reduce Motion, contrast, motor, focus, and external-surface proof are not current. | accessibility audit; simulator/device screenshots; exported hierarchy proof; owner review. | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| Native/Ambitions/Rendering/; Native/Ambitions/Quality/; Native/AmbitionsUITests/ | Screenshot matrix / visual QA / screenshot diffing | Existing screenshot/provenance artifacts are not current app-wide device proof or accessibility proof. | screenshot matrix script; UI tests; visual diff audit; sanitized fixture review. | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| docs/design/provenance/ | Visual specification provenance | Do not call VSP/Figma provenance SwiftUI parity proof or Visual Green. | ambitions-vsp-provenance-audit plus current rendered SwiftUI proof before promotion. | YELLOW_VISUAL_PROVENANCE_ONLY | PARTIAL_NEEDS_LEAF_REPAIR |
| Native/AmbitionsTests/; Native/AmbitionsUITests/; scripts/ | Tests / scripts / architecture audits / validation gates | No single current Green gate; this packet only records command results and Yellow evidence. | required commands in this packet plus focused app gates in follow-up leaves. | CONTROL_PLANE_ONLY | MISSING_PROOF_GATE |
| docs/qa/KNOWN_ISSUES.md; docs/qa/KNOWN_ISSUES_REMEDIATION_DOSSIERS.md; docs/qa/risk-register-imports/ | Known issues / risk register | Known issue closure cannot be claimed from stale or partial evidence. | known issue crosswalk; proof index; current verification for each closure. | CONTROL_PLANE_ONLY | MISSING_KNOWN_ISSUE_MAPPING |
| docs/truth/RELEASE_TRUTH.md; docs/quality/; scripts/*green*; scripts/*release* | Release gates / TestFlight / App Store | No current TestFlight, App Store, device, release, or legal approval proof in this packet. | release checklist, app build/archive, privacy manifest/legal review, device proof, accessibility proof. | RED_RELEASE | DO_NOT_PROMOTE |
| Native/Ambitions/Resources/PrivacyInfo.xcprivacy; docs/truth/RELEASE_TRUTH.md; docs/legal/privacy policy evidence if present | Privacy manifest / legal/privacy policy evidence | No current legal/privacy approval or extension manifest proof recorded. | privacy manifest audit; legal review; App Store privacy questionnaire review. | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| tools/; tools/openai/; tools/source-atlas/; tools/mcp*/ | Tools / developer adapters | No complete tools authority/credential/privacy proof map in current Linear coverage. | tool inventory; credential audit; Source Atlas privacy boundary checks. | CONTROL_PLANE_ONLY | OWNER_REVIEW_REQUIRED |
| docs/superpowers/ | Superpowers docs / agent workflow controls | Ownership and currentness require review against truth hierarchy. | docs authority review; historical policy check. | OWNER_REVIEW_REQUIRED | OWNER_REVIEW_REQUIRED |
| docs/linear/reconciliation/ | Linear mirror / existing ownership map | Prior packets are VSP-heavy and insufficient for full repo-current Private Life Orchestration coverage. | current-state taxonomy and coverage map validation. | CONTROL_PLANE_ONLY | PARTIAL_NEEDS_LEAF_REPAIR |

## 10. Missing or absent paths
| path | finding |
| --- | --- |
| docs/linear/current-state/ | Absent before this packet; created for AMB-1647/AMB-1648 artifacts only. |
| Native/Ambitions/Features/ | Absent; consistent with Final Architecture Tree rule that Features is not a canonical owner for new architecture. |
| Native/Ambitions/Surfaces/Capture/ | Absent; Capture remains Composer/Capture and global composer, not a persistent surface. |
| Native/Ambitions/Surfaces/Motion/ | Absent; Motion remains Stage/Motion behavior, not a tab/destination. |
| Native/Ambitions/Projection/Commands/ | Absent; runtime mutation authority belongs under Core/LocalRuntimeOS, not Projection/Commands. |
| Native/Ambitions/RootTab.swift | Absent; no evidence of old root-tab product IA. |
| docs/proof/ | Absent in inspected tree even though some visual-proof materials reference proof concepts. |
| Extension-specific PrivacyInfo.xcprivacy files | No current extension privacy manifest proof identified for widget/share extensions. |
| Active StoreKit/paywall/sign-in provider implementation proof | No active implementation proof identified in inspected native targets; account/paywall remains DO_NOT_PROMOTE. |

## 11. Gap summary
Gap classifications:
| gap_classification | count |
| --- | --- |
| COVERED_CURRENT | 2 |
| DO_NOT_PROMOTE | 7 |
| MISSING_CODEX_LEAVES | 1 |
| MISSING_KNOWN_ISSUE_MAPPING | 1 |
| MISSING_PARENT_FEATURE | 3 |
| MISSING_PROOF_GATE | 7 |
| MISSING_SOURCE_OWNER_PATH | 1 |
| OWNER_REVIEW_REQUIRED | 3 |
| PARTIAL_NEEDS_LEAF_REPAIR | 17 |
| PARTIAL_NEEDS_PARENT_REPAIR | 5 |

Proof ceilings:
| proof_ceiling | count |
| --- | --- |
| CONTROL_PLANE_ONLY | 5 |
| DO_NOT_PROMOTE | 2 |
| OWNER_REVIEW_REQUIRED | 2 |
| RED_PRIVACY_LEGAL | 4 |
| RED_RELEASE | 1 |
| YELLOW_REPO_EVIDENCE | 22 |
| YELLOW_SCOPED_RUNTIME | 6 |
| YELLOW_VISUAL_PROVENANCE_ONLY | 5 |

Primary blockers: missing implementation parent Features for Goals, Time, You, Motion, Planning, Live Activities, account/paywall/sync, release, privacy/legal, diagnostics, and tools ownership; missing per-surface Codex leaves for runtime receipt/replay, accessibility, screenshots, external adapters, known issue closure, and release proof.

## 12. Non-claims
- This packet does not claim Visual Green, Runtime Green, Accessibility Green, Release Green, TestFlight readiness, App Store readiness, privacy/legal approval, device proof, production R2 authority, or known issue closure.
- VSP/Figma provenance is treated as Yellow visual provenance only, not SwiftUI parity proof.
- Scoped LocalRuntimeOS proof is treated as scoped runtime evidence only, not app-wide Runtime Green.
- External integrations are adapters and never core authority.
- Account sign-in, sync, paywall, R2, and Source Atlas are not required for offline core value.

## 13. Closeout block
Status: Yellow
Scope completed: AMB-1647 repo-current taxonomy generated from current repo inspection and read-only Linear search inputs; validation completed for the requested commands.
Files changed: docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.md; docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json
Product law preserved: Today/Goals/Time/You only persistent surfaces; Capture global composer; Motion behavior; local-first no-account core; Source Atlas/R2 public/reference only; no cloud LLM core; command/event/projection/receipt/replay law preserved.
Private Life Orchestration canon applied: Yes; every row classifies role and orchestration layer, not folder only.
Validation run: `git diff --check`; JSON parse for both current-state JSON files; `python3 scripts/ambitions-architecture-inventory.py || true`; `python3 scripts/ambitions-green-standard-audit.py || true`; `python3 scripts/ambitions-vsp-provenance-audit.py || true`.
Validation not run: No build, simulator/device, UI automation, accessibility manual proof, TestFlight, App Store, privacy/legal, production R2, or known-issue closure validation was run.
Proof artifacts: This markdown and JSON taxonomy; validation results in section 2; current repo discovery command outputs; existing docs/qa and docs/design provenance references.
Known risks: Linear object fetches were read-only and partial where long issue bodies exceeded context; ownership gaps are classified explicitly instead of invented.
Follow-up required: Create/repair the Linear parent/leaf batches named by AMB-1648 before implementation promotion.
Rollback plan: Remove the four new docs/linear/current-state artifacts or revert the final commit.
Commit: To be recorded by final repository commit.
