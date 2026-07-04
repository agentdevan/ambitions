# AMB-1648 - Linear Coverage Map (2026-07-01)

## 1. Title and commit/branch context
- Issue: AMB-1648 - Linear Coverage Map
- Parent: AMB-1646 - Full Repo Current-State Linear Mirror Acceptance
- Branch: main
- Commit inspected: 1cb9ba867
- Artifact status: Yellow control-plane evidence pending validation closeout. This map derives from AMB-1647 and does not mutate Linear.

## 2. Inputs consumed from AMB-1647
- `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.md`
- `docs/linear/current-state/2026-07-01-repo-current-state-taxonomy.json`
- Existing reconciliation inputs under `docs/linear/reconciliation/`
- Read-only Linear search results for AMB-1647, AMB-1648, AMB-1646, AMB-1639, AMB-1640, AMB-1641, AMB-1480 through AMB-1489 references, AMB-1544, AMB-1414 through AMB-1419, AMB-1400, VSP-08, LocalRuntimeOS, and app control-plane initiatives.

## 3. Linear coverage rules
- Private Life Orchestration role is the primary ownership lens; folder ownership and VSP names are secondary evidence.
- Existing Linear objects are recorded only where found in current repo docs or read-only Linear search. Ambiguous or unfetched ownership is marked partial or missing rather than invented.
- VSP provenance can seed design ownership but cannot satisfy implementation, runtime, visual, accessibility, legal, privacy, release, or known issue closure proof.
- LocalRuntimeOS scoped proof can seed runtime ownership but cannot satisfy app-wide Runtime Green.
- Account, paywall, sync, R2/Source Atlas production, privacy/legal, TestFlight, and App Store areas are DO_NOT_PROMOTE until their authority and proof gates exist.

## 4. Current Linear coverage table by repo aspect
| repo_aspect | private_life_orchestration_role | orchestration_layer | existing_linear_project | existing_parent_feature | existing_leaf_issues | missing_linear_object | recommended_action | proof_ceiling | gap_classification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Repo authority / product canon | Defines top-level Private Life Orchestration product law and proof honesty for every repo and Linear object. | QA / validation / release proof gate | Ambitions Full-App Design Documentation + Linear Coverage Map; Ambitions Native iPhone App Control Plane initiative. | AMB-1646 Full Repo Current-State Linear Mirror Acceptance. | AMB-1647 Repo Current State Taxonomy; AMB-1648 Linear Coverage Map. | None for the foundation packet itself. | Attach these four current-state artifacts to AMB-1646/1647/1648 as control-plane evidence; do not claim implementation completion. | CONTROL_PLANE_ONLY | COVERED_CURRENT |
| App root / launch / environment / dependencies | Composes native app target, dependencies, app boot, and local runtime services. | Command authority | Ambitions Native iPhone App Control Plane. | AMB-1646 partially covers mirror acceptance; no dedicated launch/dependency parent found. | AMB-1647/AMB-1648 control-plane leaves only. | Parent Feature plus Codex leaves for offline boot, dependency graph, XcodeGen/build, extension embedding, and no-account launch proof. | Create app-root current-state parent under Native iPhone App Control Plane before implementation work. | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Stage / shell / chrome / routing / continuity | Hosts Today/Goals/Time/You and route continuity while keeping Capture and Motion non-root. | Projection / read model | Ambitions Flagship Visual Specification Layer - Pre-Codex. | VSP mirror covers design intent; no current Stage implementation parent found. | AMB-1480 VSP shell/chrome; related VSP leaves. | Stage shell implementation parent and leaves for route continuity, safe-area, accessibility, and screenshot proof. | Repair hierarchy by creating Stage shell parent that consumes VSP evidence but requires current SwiftUI/device proof. | YELLOW_VISUAL_PROVENANCE_ONLY | PARTIAL_NEEDS_PARENT_REPAIR |
| Today | Start here decision object combining reality, time, capacity, recovery, and recommended step. | Context / capacity / protected time / time reality / recovery | Ambitions Flagship Visual Specification Layer - Pre-Codex; Today Surface initiative. | AMB-1381 Today Reality Window Acceptance. | AMB-1481 VSP-02; current-state taxonomy leaf AMB-1647 references it. | Codex leaves for Today runtime receipt, reflow, accessibility, and screenshot proof. | Attach source-owner paths to AMB-1381 and create proof leaves before any Ready For Codex promotion. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Goals | Identity direction, life areas, ambition graph, goal threads, and path planning. | Identity direction / life area / ambition / goal thread | Ambitions Flagship Visual Specification Layer - Pre-Codex. | No current repo-grounded Goals parent found in inspected Linear results; VSP parent is partial. | AMB-1482 VSP-03. | Goals implementation parent plus leaves for creation, path planning, receipt/replay, Life Capital, and proof. | Create Goals parent under Private Life Orchestration lens before implementation leaves. | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Time | Time reality, capacity, protected time, placement, conflict resolution, and reflow. | Context / capacity / protected time / time reality / recovery | Ambitions Flagship Visual Specification Layer - Pre-Codex. | No current repo-grounded Time parent found beyond VSP/partial runtime coverage. | AMB-1483 VSP-04. | Time implementation parent and leaves for TimeEngine, capacity/reflow, EventKit boundary, and proof. | Create Time/TimeEngine parent linked to AMB-1483 and AMB-1544. | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| You | User system profile, preferences, adaptation, identity context, and no-cloud personalization. | Identity direction / life area / ambition / goal thread | Ambitions Flagship Visual Specification Layer - Pre-Codex. | No current repo-grounded You parent found beyond VSP partial coverage. | AMB-1485 VSP-06. | You implementation parent and leaves for preferences, adaptation, Life Capital, account-optional behavior, and proof. | Create You/Profile parent linked to privacy boundary and LocalRuntimeOS receipt requirements. | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Capture | Global composer and durable intake for messy intent, not a tab or inbox. | Intent / capture intake | Ambitions Flagship Visual Specification Layer - Pre-Codex. | No current durable-intake parent found beyond VSP partial coverage. | AMB-1484 VSP-05. | Capture durable intake parent and leaves for global invocation, queue recovery, promotion receipts, privacy, and accessibility. | Create CaptureRouteGraph/durable intake parent under Private Life Runtime and Composer/Capture. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_PARENT_REPAIR |
| Motion | Cross-surface behavior for recovery/re-entry/closure/reflow/undo, not a destination. | Closure / reflection / adaptation / recovery | Ambitions Flagship Visual Specification Layer - Pre-Codex. | No current Stage/Motion runtime parent found. | VSP-07/VSP-09 related leaves only. | Stage/Motion behavior parent and leaves for Reduce Motion, haptics, recovery, undo, and replay proof. | Create Stage/Motion parent and explicitly mark no Motion tab/destination. | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Search | Local recall over projections and memory lens context. | Projection / read model | iOS System Integrations and Private Life Runtime partial coverage. | AMB-1400 Local Search Index Acceptance. | No current repo-current Search leaves found beyond AMB-1400 references. | SearchRecall/MemoryLens leaves for FTS rebuild, redaction, trust inspection, and accessibility. | Attach SearchRecall paths to AMB-1400 and create projection/rebuild proof leaves. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Trust / Proof / Source / Privacy / History / Receipts | Inspectable proof layer for sources, privacy, history, receipts, replay, and undo. | Proof / source / privacy / history / trust inspection | Ambitions Flagship Visual Specification Layer - Pre-Codex; Private Life Runtime. | VSP-07 partial trust inspection coverage; AMB-1544 runtime spine partial coverage. | AMB-1486 VSP-07. | Trust implementation parent/leaves for live ledger UI, receipt replay, source/privacy inspection, and accessibility. | Create Trust/Receipt parent that joins VSP-07 to LocalRuntimeOS TrustSystem. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| LocalRuntimeOS / Private Life Runtime | Local moat and private life graph authority. | Local-first storage / migration / repair | Private Life Runtime initiative. | AMB-1544 LocalRuntimeOS Architecture Canon + Migration Spine Acceptance. | AMB-1545/AMB-1550/AMB-1553 and local-runtime proof references found in Linear search; exact app-wide set requires owner reconciliation. | Leaves for app-wide mutation path coverage across all surfaces/adapters. | Use AMB-1647 taxonomy to create per-owner runtime coverage leaves under AMB-1544. | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_LEAF_REPAIR |
| Planning and recommendation | Recommended step planning and reflow from intent/context/time/identity. | Recommended step / planning / reflow | Private Life Runtime initiative partially covers runtime spine. | No dedicated PlanningEngine parent found. | No current repo-grounded planning leaves found. | Planning/Recommendation parent plus deterministic recommendation, fallback, recovery, and proof leaves. | Create parent mapped to Planning, TimeEngine, Goals, Today, and Trust receipt owners. | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Command / transaction / event / projection / receipt / replay | Canonical runtime mutation spine for every meaningful state change. | Command authority | Private Life Runtime initiative. | AMB-1544. | LocalRuntimeOS proof leaves present in docs/qa/local-runtime-proof; Linear leaf inventory partial from search. | Per-surface mutation entry leaves and legacy direct-repository debt leaves. | Create mutation-path coverage batch from AMB-1647 rows for Today, Goals, Time, You, Capture, Search, Trust, and adapters. | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_LEAF_REPAIR |
| Storage / migration / repair | Local event/object/projection/search/blob storage plus migration and repair protections. | Local-first storage / migration / repair | Private Life Runtime initiative. | AMB-1544 partial storage/migration coverage. | No complete storage/migration/repair leaf set found. | Storage/migration/repair parent leaves for legacy Core/Runtime/Core/Persistence debt, repair preview, backup/restore, corrupt-store recovery. | Repair parent hierarchy under AMB-1544 and mark legacy scaffolding as migration debt. | YELLOW_SCOPED_RUNTIME | PARTIAL_NEEDS_PARENT_REPAIR |
| PrivacySecurity / Source Atlas / R2 | Hard life-data boundary plus public/reference/freshness Source Atlas adapter. | Life-data boundary | Source Atlas/R2 evidence docs; VSP-08 external boundary; Native iPhone App Control Plane. | No current privacy/legal approval parent found; VSP-08 is partial design/control-plane evidence. | AMB-1487 VSP-08; Source Atlas evidence train docs. | Privacy/legal boundary parent and leaves for R2 production, app Source Atlas, extension privacy, account, export/reset, and legal approvals. | Create DO_NOT_PROMOTE privacy/legal parent before any cloud/account/release promotion. | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| Sync / continuity | Optional continuity scaffolding that cannot be required for core Ambitions value. | External adapter, never core authority | Native iPhone App Control Plane partial coverage. | No approved private graph sync architecture parent found. | No current sync continuity implementation-proof leaves found. | Optional sync/account continuity parent with privacy/legal gates or explicit archive/hold decision. | Mark DO_NOT_PROMOTE until user-owned sync canon and legal/privacy proof exist. | DO_NOT_PROMOTE | DO_NOT_PROMOTE |
| Side effects | Downstream external writes and notifications governed by local commit evidence. | External adapter, never core authority | iOS System Integrations initiative partial coverage. | AMB-1417 and AMB-1418 partially cover notification/calendar side effects. | No unified SideEffectSystem leaves found. | SideEffectSystem parent covering notifications, EventKit, Reminders, App Intents, recovery, rollback, and privacy. | Create side-effect boundary batch under iOS System Integrations and Private Life Runtime. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_PARENT_REPAIR |
| Diagnostics | Runtime inspection and repair support without unreviewed destructive mutation or private-data export. | Local-first storage / migration / repair | Private Life Runtime partial coverage. | No dedicated diagnostics/repair parent found. | No current diagnostics proof leaves found. | Diagnostics/repair parent and leaves for local doctor, support export redaction, repair preview, and recovery. | Create owner-review batch before support/export/release claims. | OWNER_REVIEW_REQUIRED | OWNER_REVIEW_REQUIRED |
| Widget extension | External glance projection adapter. | External adapter, never core authority | iOS System Integrations initiative. | AMB-1414 WidgetKit Boundary Acceptance. | No current widget device/gallery proof leaf found. | Widget snapshot/timeline/device/accessibility/privacy leaves. | Create leaves under AMB-1414 linked to projection snapshot owner. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Share extension | External intake adapter for user-shared text/URL. | External adapter, never core authority | iOS System Integrations initiative. | AMB-1416 Share Extension Boundary Acceptance. | No current share queue recovery proof leaf found. | Queue idempotency/failure/retry/privacy/device leaves. | Create leaves under AMB-1416 and link to CaptureRouteGraph. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| App Intents / Shortcuts / Siri | External command surface requiring confirmation or local intake. | External adapter, never core authority | iOS System Integrations initiative. | AMB-1415 App Intents Boundary Acceptance. | No current Siri/Shortcuts device proof leaf found. | Invocation/confirmation/receipt/privacy/device leaves. | Create leaves under AMB-1415 with no-silent-mutation audit. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Notifications | External reminder/response adapter downstream of local orchestration. | External adapter, never core authority | iOS System Integrations initiative. | AMB-1417 Notifications Boundary Acceptance. | No current delivery/action proof leaf found. | Delivery/action/redaction/focus-mode/privacy leaves. | Create leaves under AMB-1417 linked to SideEffectSystem. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| EventKit / Reminders | External calendar/reminder write adapter after local commit evidence. | External adapter, never core authority | iOS System Integrations initiative. | AMB-1418 EventKit/Reminders Boundary Acceptance. | No current proof leaf for all user paths supplying commit-backed variants. | Commit-evidence audit, permissions, external failure recovery, and device leaves. | Owner-review all public overloads and create side-effect recovery leaves. | OWNER_REVIEW_REQUIRED | OWNER_REVIEW_REQUIRED |
| Deep links / URL routing | External routing adapter into local projections or confirmation surfaces. | External adapter, never core authority | iOS System Integrations initiative. | AMB-1419 Deep Links Boundary Acceptance. | No current malformed route/privacy/device proof leaf found. | Route matrix, malformed URL recovery, object-id privacy, and device leaves. | Create route matrix leaves under AMB-1419. | YELLOW_REPO_EVIDENCE | PARTIAL_NEEDS_LEAF_REPAIR |
| Live Activities | External glance surface over current local projection state. | External adapter, never core authority | iOS System Integrations initiative partial coverage. | No dedicated Live Activities parent found. | No current ActivityKit proof leaves found. | Live Activities parent and leaves for lifecycle, Dynamic Island, redaction, deep link, and device proof. | Create Live Activities parent or explicitly mark out of current release scope. | YELLOW_REPO_EVIDENCE | MISSING_PARENT_FEATURE |
| Design system / tokens / materials / typography / spacing / motion / haptics | Premium native design language for orchestration surfaces. | QA / validation / release proof gate | Ambitions Flagship Visual Specification Layer - Pre-Codex. | VSP-09/VSP-10 partial coverage; no current design-system implementation parent found. | VSP leaves and owner approvals in docs/design/provenance. | Design-system implementation proof parent/leaves for token consumption and device rendering. | Create design-system proof batch linked to screenshots/accessibility leaves. | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| VoiceOver / Dynamic Type / Reduce Motion / contrast / hit targets / focus behavior | Accessibility guarantees for local-first orchestration surfaces and adapters. | QA / validation / release proof gate | Ambitions Flagship Visual Specification Layer - Pre-Codex partial VSP-09 coverage. | No current app-wide accessibility proof parent found. | VSP-09 provenance/approval only. | Accessibility parent and per-surface/per-adapter proof leaves. | Create accessibility proof batch before any Green/release claim. | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| Screenshot matrix / visual QA / screenshot diffing | Current rendered evidence for surfaces, shell, states, and accessibility modes. | QA / validation / release proof gate | VSP provenance project partial coverage. | No current screenshot matrix parent found. | Visual QA/scenario gate references only. | Full screenshot matrix parent and per-surface diff leaves. | Create screenshot proof batch using sanitized fixtures and explicit proof ceilings. | YELLOW_VISUAL_PROVENANCE_ONLY | MISSING_PROOF_GATE |
| Tests / scripts / architecture audits / validation gates | Validation harness for source truth, runtime contracts, visual provenance, Green standard, and proof honesty. | QA / validation / release proof gate | Control-plane and Private Life Runtime partial coverage. | AMB-1646/1647/1648 for this mirror; AMB-1544 for runtime partial gate. | Current artifact leaves only; no unified QA/release gate parent found. | Unified validation proof-gate parent with leaves for architecture, runtime, visual, accessibility, release, legal, and known issues. | Create QA/release governance batch and attach command results from AMB-1647/1648. | CONTROL_PLANE_ONLY | MISSING_PROOF_GATE |
| Known issues / risk register | Maps known risks and remediation dossiers to proof blockers and closure evidence. | QA / validation / release proof gate | Prior reconciliation docs mention known issue mapping; no complete current coverage found. | No app-wide known issue mapping parent found. | Source Atlas known issue crosswalk docs; app known issue docs. | Known issue to Linear coverage parent and closure proof leaves. | Create known-risk/known-issue mapping batch before closure or release claims. | CONTROL_PLANE_ONLY | MISSING_KNOWN_ISSUE_MAPPING |
| Release gates / TestFlight / App Store | Blocks release claims until all required proof, legal, privacy, accessibility, device, and known-issue gates pass. | QA / validation / release proof gate | Native iPhone App Control Plane partial coverage. | No current release-ready parent found. | Release truth and green-standard scripts only; no release proof leaf found. | Release governance parent and leaves for TestFlight, App Store, privacy/legal, device, accessibility, and known issue closure. | Create release DO_NOT_PROMOTE parent and gate all readiness language. | RED_RELEASE | DO_NOT_PROMOTE |
| Account / optional sign-in / entitlement / paywall / pricing | Optional account/entitlement layer that cannot be required for core app value. | Life-data boundary | Native iPhone App Control Plane; VSP-08 partial boundary. | No account/paywall/pricing implementation parent found. | No active auth/paywall proof leaves found. | Account/paywall/pricing/legal parent plus no-account parity leaves. | Mark DO_NOT_PROMOTE until implementation and legal/privacy proof exist. | DO_NOT_PROMOTE | DO_NOT_PROMOTE |
| Import / export / reset / erasure | User data control, erase/reset, portability, recovery, and support cleanup for local graph. | Life-data boundary | Private Life Runtime and privacy boundary partial coverage. | No dedicated import/export/reset/erasure parent found. | No current legal/recovery proof leaves found. | Data rights/control parent and leaves for export, import, reset, erase, restore, support diagnostics, legal review. | Create privacy/legal gated parent before release or account promotion. | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| Privacy manifest / legal/privacy policy evidence | Platform declarations and legal approval for private life data boundaries. | QA / validation / release proof gate | Native iPhone App Control Plane partial coverage. | No privacy/legal approval parent found. | PrivacyInfo.xcprivacy source evidence only. | Privacy/legal parent and App Store privacy questionnaire/extension manifest/legal approval leaves. | Create RED_PRIVACY_LEGAL repair batch; block release/account/cloud promotion. | RED_PRIVACY_LEGAL | DO_NOT_PROMOTE |
| Packages / reusable UI and experience kernel | Reusable design/widget/experience scaffolding consumed by app surfaces. | Projection / read model | No dedicated package ownership project found; partial design/widget coverage. | No package ownership parent found. | No package proof leaves found. | Package source-owner parent or explicit mapping under design/widget/runtime owners. | Owner-review package paths and attach to design/widget/aspect parents. | OWNER_REVIEW_REQUIRED | MISSING_SOURCE_OWNER_PATH |
| Tools / developer adapters | Development, Source Atlas, MCP, generated, and proof automation outside runtime authority. | QA / validation / release proof gate | Source Atlas/R2 evidence projects and control-plane initiatives partially cover tools. | No complete tools source-owner parent found. | Source Atlas evidence train docs only. | Tools ownership/credential/privacy/generated-artifact parent. | Owner-review tools tree and mark production R2/private data paths DO_NOT_PROMOTE where applicable. | CONTROL_PLANE_ONLY | OWNER_REVIEW_REQUIRED |
| docs/superpowers and workflow docs | Workflow/runbook guidance that must stay subordinate to truth hierarchy and proof gates. | QA / validation / release proof gate | No specific current project found. | No owner found. | None found. | Source-owner mapping, archive decision, or owner-review object for docs/superpowers. | Owner-review for currentness and historical-policy compliance. | OWNER_REVIEW_REQUIRED | OWNER_REVIEW_REQUIRED |

## 5. Coverage verdicts
| gap_classification | count |
| --- | --- |
| COVERED_CURRENT | 1 |
| DO_NOT_PROMOTE | 6 |
| MISSING_KNOWN_ISSUE_MAPPING | 1 |
| MISSING_PARENT_FEATURE | 7 |
| MISSING_PROOF_GATE | 4 |
| MISSING_SOURCE_OWNER_PATH | 1 |
| OWNER_REVIEW_REQUIRED | 4 |
| PARTIAL_NEEDS_LEAF_REPAIR | 10 |
| PARTIAL_NEEDS_PARENT_REPAIR | 4 |

Overall verdict: Yellow control-plane evidence. Linear has useful VSP, LocalRuntimeOS, iOS integration, Source Atlas, and prior reconciliation objects, but the repo-current mirror still needs parent repair, leaf repair, proof gates, and DO_NOT_PROMOTE blockers for release/legal/cloud/account/sync.

## 6. Missing project/parent/leaf map
| repo_aspect | missing_linear_object | recommended_action | source_owner_paths | gap_classification |
| --- | --- | --- | --- | --- |
| App root / launch / environment / dependencies | Parent Feature plus Codex leaves for offline boot, dependency graph, XcodeGen/build, extension embedding, and no-account launch proof. | Create app-root current-state parent under Native iPhone App Control Plane before implementation work. | project.yml; Package.swift; Native/Ambitions/App/ | MISSING_PARENT_FEATURE |
| Goals | Goals implementation parent plus leaves for creation, path planning, receipt/replay, Life Capital, and proof. | Create Goals parent under Private Life Orchestration lens before implementation leaves. | Native/Ambitions/Surfaces/Goals/; Native/Ambitions/Projection/SurfaceLenses/Goals*; Native/Ambitions/Projection/StageScenes/Goals* | MISSING_PARENT_FEATURE |
| Time | Time implementation parent and leaves for TimeEngine, capacity/reflow, EventKit boundary, and proof. | Create Time/TimeEngine parent linked to AMB-1483 and AMB-1544. | Native/Ambitions/Surfaces/Time/; Native/Ambitions/Core/LocalRuntimeOS/TimeEngine/; Projection Time owners | MISSING_PARENT_FEATURE |
| You | You implementation parent and leaves for preferences, adaptation, Life Capital, account-optional behavior, and proof. | Create You/Profile parent linked to privacy boundary and LocalRuntimeOS receipt requirements. | Native/Ambitions/Surfaces/You/; Projection You owners | MISSING_PARENT_FEATURE |
| Motion | Stage/Motion behavior parent and leaves for Reduce Motion, haptics, recovery, undo, and replay proof. | Create Stage/Motion parent and explicitly mark no Motion tab/destination. | Native/Ambitions/Stage/Motion/ | MISSING_PARENT_FEATURE |
| Planning and recommendation | Planning/Recommendation parent plus deterministic recommendation, fallback, recovery, and proof leaves. | Create parent mapped to Planning, TimeEngine, Goals, Today, and Trust receipt owners. | Native/Ambitions/Core/LocalRuntimeOS/Planning/ | MISSING_PARENT_FEATURE |
| Live Activities | Live Activities parent and leaves for lifecycle, Dynamic Island, redaction, deep link, and device proof. | Create Live Activities parent or explicitly mark out of current release scope. | Native/AmbitionsWidgetExtension live activity source; ActivityKit usage; projection snapshots | MISSING_PARENT_FEATURE |
| Packages / reusable UI and experience kernel | Package source-owner parent or explicit mapping under design/widget/runtime owners. | Owner-review package paths and attach to design/widget/aspect parents. | Package.swift; Sources; AppUI/Sources; Packages/AmbitionsExperienceKernel | MISSING_SOURCE_OWNER_PATH |

## 7. Partial coverage map
| repo_aspect | existing_linear_project | existing_parent_feature | existing_leaf_issues | missing_linear_object | gap_classification |
| --- | --- | --- | --- | --- | --- |
| Stage / shell / chrome / routing / continuity | Ambitions Flagship Visual Specification Layer - Pre-Codex. | VSP mirror covers design intent; no current Stage implementation parent found. | AMB-1480 VSP shell/chrome; related VSP leaves. | Stage shell implementation parent and leaves for route continuity, safe-area, accessibility, and screenshot proof. | PARTIAL_NEEDS_PARENT_REPAIR |
| Today | Ambitions Flagship Visual Specification Layer - Pre-Codex; Today Surface initiative. | AMB-1381 Today Reality Window Acceptance. | AMB-1481 VSP-02; current-state taxonomy leaf AMB-1647 references it. | Codex leaves for Today runtime receipt, reflow, accessibility, and screenshot proof. | PARTIAL_NEEDS_LEAF_REPAIR |
| Capture | Ambitions Flagship Visual Specification Layer - Pre-Codex. | No current durable-intake parent found beyond VSP partial coverage. | AMB-1484 VSP-05. | Capture durable intake parent and leaves for global invocation, queue recovery, promotion receipts, privacy, and accessibility. | PARTIAL_NEEDS_PARENT_REPAIR |
| Search | iOS System Integrations and Private Life Runtime partial coverage. | AMB-1400 Local Search Index Acceptance. | No current repo-current Search leaves found beyond AMB-1400 references. | SearchRecall/MemoryLens leaves for FTS rebuild, redaction, trust inspection, and accessibility. | PARTIAL_NEEDS_LEAF_REPAIR |
| Trust / Proof / Source / Privacy / History / Receipts | Ambitions Flagship Visual Specification Layer - Pre-Codex; Private Life Runtime. | VSP-07 partial trust inspection coverage; AMB-1544 runtime spine partial coverage. | AMB-1486 VSP-07. | Trust implementation parent/leaves for live ledger UI, receipt replay, source/privacy inspection, and accessibility. | PARTIAL_NEEDS_LEAF_REPAIR |
| LocalRuntimeOS / Private Life Runtime | Private Life Runtime initiative. | AMB-1544 LocalRuntimeOS Architecture Canon + Migration Spine Acceptance. | AMB-1545/AMB-1550/AMB-1553 and local-runtime proof references found in Linear search; exact app-wide set requires owner reconciliation. | Leaves for app-wide mutation path coverage across all surfaces/adapters. | PARTIAL_NEEDS_LEAF_REPAIR |
| Command / transaction / event / projection / receipt / replay | Private Life Runtime initiative. | AMB-1544. | LocalRuntimeOS proof leaves present in docs/qa/local-runtime-proof; Linear leaf inventory partial from search. | Per-surface mutation entry leaves and legacy direct-repository debt leaves. | PARTIAL_NEEDS_LEAF_REPAIR |
| Storage / migration / repair | Private Life Runtime initiative. | AMB-1544 partial storage/migration coverage. | No complete storage/migration/repair leaf set found. | Storage/migration/repair parent leaves for legacy Core/Runtime/Core/Persistence debt, repair preview, backup/restore, corrupt-store recovery. | PARTIAL_NEEDS_PARENT_REPAIR |
| Side effects | iOS System Integrations initiative partial coverage. | AMB-1417 and AMB-1418 partially cover notification/calendar side effects. | No unified SideEffectSystem leaves found. | SideEffectSystem parent covering notifications, EventKit, Reminders, App Intents, recovery, rollback, and privacy. | PARTIAL_NEEDS_PARENT_REPAIR |
| Widget extension | iOS System Integrations initiative. | AMB-1414 WidgetKit Boundary Acceptance. | No current widget device/gallery proof leaf found. | Widget snapshot/timeline/device/accessibility/privacy leaves. | PARTIAL_NEEDS_LEAF_REPAIR |
| Share extension | iOS System Integrations initiative. | AMB-1416 Share Extension Boundary Acceptance. | No current share queue recovery proof leaf found. | Queue idempotency/failure/retry/privacy/device leaves. | PARTIAL_NEEDS_LEAF_REPAIR |
| App Intents / Shortcuts / Siri | iOS System Integrations initiative. | AMB-1415 App Intents Boundary Acceptance. | No current Siri/Shortcuts device proof leaf found. | Invocation/confirmation/receipt/privacy/device leaves. | PARTIAL_NEEDS_LEAF_REPAIR |
| Notifications | iOS System Integrations initiative. | AMB-1417 Notifications Boundary Acceptance. | No current delivery/action proof leaf found. | Delivery/action/redaction/focus-mode/privacy leaves. | PARTIAL_NEEDS_LEAF_REPAIR |
| Deep links / URL routing | iOS System Integrations initiative. | AMB-1419 Deep Links Boundary Acceptance. | No current malformed route/privacy/device proof leaf found. | Route matrix, malformed URL recovery, object-id privacy, and device leaves. | PARTIAL_NEEDS_LEAF_REPAIR |

## 8. DO_NOT_PROMOTE map
| repo_aspect | existing_linear_project | missing_linear_object | status_correction | proof_ceiling |
| --- | --- | --- | --- | --- |
| PrivacySecurity / Source Atlas / R2 | Source Atlas/R2 evidence docs; VSP-08 external boundary; Native iPhone App Control Plane. | Privacy/legal boundary parent and leaves for R2 production, app Source Atlas, extension privacy, account, export/reset, and legal approvals. | R2/Source Atlas must remain public/reference only and never private graph storage. | RED_PRIVACY_LEGAL |
| Sync / continuity | Native iPhone App Control Plane partial coverage. | Optional sync/account continuity parent with privacy/legal gates or explicit archive/hold decision. | Never treat account/sync as required for offline core. | DO_NOT_PROMOTE |
| Release gates / TestFlight / App Store | Native iPhone App Control Plane partial coverage. | Release governance parent and leaves for TestFlight, App Store, privacy/legal, device, accessibility, and known issue closure. | Do not claim TestFlight/App Store/readiness/Release Green. | RED_RELEASE |
| Account / optional sign-in / entitlement / paywall / pricing | Native iPhone App Control Plane; VSP-08 partial boundary. | Account/paywall/pricing/legal parent plus no-account parity leaves. | Offline core cannot require account sign-in. | DO_NOT_PROMOTE |
| Import / export / reset / erasure | Private Life Runtime and privacy boundary partial coverage. | Data rights/control parent and leaves for export, import, reset, erase, restore, support diagnostics, legal review. | Do not promote erasure/export readiness from source existence. | RED_PRIVACY_LEGAL |
| Privacy manifest / legal/privacy policy evidence | Native iPhone App Control Plane partial coverage. | Privacy/legal parent and App Store privacy questionnaire/extension manifest/legal approval leaves. | No privacy/legal approval claimed. | RED_PRIVACY_LEGAL |

## 9. OWNER_REVIEW_REQUIRED map
| repo_aspect | missing_linear_object | recommended_action | proof_or_recovery_gap | proof_ceiling |
| --- | --- | --- | --- | --- |
| Diagnostics | Diagnostics/repair parent and leaves for local doctor, support export redaction, repair preview, and recovery. | Create owner-review batch before support/export/release claims. | Repair/support export proof missing. | OWNER_REVIEW_REQUIRED |
| EventKit / Reminders | Commit-evidence audit, permissions, external failure recovery, and device leaves. | Owner-review all public overloads and create side-effect recovery leaves. | Owner review required for commit evidence coverage. | OWNER_REVIEW_REQUIRED |
| Tools / developer adapters | Tools ownership/credential/privacy/generated-artifact parent. | Owner-review tools tree and mark production R2/private data paths DO_NOT_PROMOTE where applicable. | Credential/privacy/tool authority map incomplete. | CONTROL_PLANE_ONLY |
| docs/superpowers and workflow docs | Source-owner mapping, archive decision, or owner-review object for docs/superpowers. | Owner-review for currentness and historical-policy compliance. | Ownership/currentness ambiguous. | OWNER_REVIEW_REQUIRED |

## 10. Recommended next Linear object repair/create batches
| batch | action | proof_ceiling |
| --- | --- | --- |
| A - Runtime mutation ownership | Create/repair leaves under AMB-1544 for app-wide Command/Event/Projection/Receipt/Replay coverage across Today, Goals, Time, You, Capture, Search, Trust, and adapters. | YELLOW_SCOPED_RUNTIME |
| B - Surface parent repair | Create repo-grounded parent Features for Goals, Time, You, Motion, Capture durable intake, Planning, and Live Activities where only VSP or partial coverage exists. | YELLOW_REPO_EVIDENCE |
| C - External adapter proof | Create Widget, Share, App Intents, Notifications, EventKit/Reminders, Deep Links, and Live Activities leaves with commit-evidence, privacy, permission, and device proof gates. | YELLOW_REPO_EVIDENCE |
| D - Accessibility/visual proof | Create screenshot matrix, SwiftUI parity, Dynamic Type, VoiceOver, Reduce Motion, contrast, hit target, haptic, and owner-review leaves. | YELLOW_VISUAL_PROVENANCE_ONLY |
| E - Privacy/legal/release DO_NOT_PROMOTE | Create privacy/legal, account/paywall, sync, R2/Source Atlas, import/export/reset, PrivacyInfo, TestFlight/App Store, and known issue closure gate parents before promotion. | DO_NOT_PROMOTE |
| F - Tools/packages/source-owner review | Create owner-review map for packages, tools, docs/superpowers, generated Source Atlas tooling, and credential-sensitive developer adapters. | OWNER_REVIEW_REQUIRED |

## 11. Non-claims
- This map does not mutate Linear and does not claim any issue/project is complete beyond control-plane evidence.
- This map does not claim Visual Green, Runtime Green, Accessibility Green, Release Green, TestFlight readiness, App Store readiness, privacy/legal approval, production R2 authority, or known issue closure.
- This map does not treat external adapters as core authority or account sign-in as required for offline core value.
- This map does not invent missing Linear objects; it names missing/partial ownership so Linear can be repaired.

## 12. Closeout block
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

Status: Yellow
Scope completed: AMB-1648 Linear coverage map generated from AMB-1647 taxonomy, current repo evidence, existing reconciliation docs, and read-only Linear search inputs; validation completed for the requested commands.
Files changed: docs/linear/current-state/2026-07-01-linear-coverage-map.md; docs/linear/current-state/2026-07-01-linear-coverage-map.json
Product law preserved: Today/Goals/Time/You only persistent surfaces; Capture global composer; Motion behavior; local-first no-account core; Source Atlas/R2 public/reference only; external adapters never core authority.
Private Life Orchestration canon applied: Yes; coverage rows classify each repo aspect by orchestration role and layer before Linear ownership.
Validation run: `git diff --check`; JSON parse for both current-state JSON files; `python3 scripts/ambitions-architecture-inventory.py || true`; `python3 scripts/ambitions-green-standard-audit.py || true`; `python3 scripts/ambitions-vsp-provenance-audit.py || true`.
Validation not run: No build, simulator/device, UI automation, accessibility manual proof, TestFlight, App Store, privacy/legal, production R2, or known-issue closure validation was run.
Proof artifacts: This markdown and JSON coverage map; AMB-1647 taxonomy input; validation results above; existing docs/linear/reconciliation artifacts.
Known risks: Linear fetch detail was partial for long objects; missing/partial ownership is explicitly classified for owner reconciliation.
Follow-up required: Create/repair the recommended Linear object batches before implementation or release promotion.
Rollback plan: Remove the four new docs/linear/current-state artifacts or revert the final commit.
Commit: To be recorded by final repository commit.
