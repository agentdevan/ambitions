# VSP-01 through VSP-10 Review Analysis

## Executive verdict

VSP-01 through VSP-10 are partially coherent as a Yellow Figma/visual-system proof package, but unsafe to execute as-is as a source implementation sequence.

The coherent part is clear:

- VSP-01 is the immutable approved shell authority.
- VSP-02 through VSP-10 are candidate content, component, proof, or anatomy layers that must be mounted inside that shell or rejected.
- The current VSP evidence package explicitly avoids shell mutation and keeps all later packets Yellow.

The unsafe part is also clear:

- No later packet has owner approval, Visual Green, runtime proof, device proof, manual accessibility proof, or SwiftUI parity proof.
- There is no stronger repo-local canonical VSP packet spec for VSP-05 through VSP-10 beyond the Figma proof package and owner-supplied packet labels captured there.
- Several implementation areas exist in source, but source presence is not VSP implementation proof.
- Some adjacent component-kit source still contains stale compatibility vocabulary such as `plan` context naming and generated names that could be misread as root ownership if promoted without cleanup.

Decision: treat the packet family as a Yellow design/implementation-shaping inventory. Do not mark any VSP complete. Do not implement any VSP without a bounded leaf that preserves VSP-01 shell authority and states its proof ceiling.

## Canonical interpretation

Based only on repo evidence, VSP appears to mean Visual System Packet, governed by the VSP North Star Production Quality Gate.

Repo evidence:

- `docs/truth/FIGMA_PRODUCTION_GATE_ADDENDUM.md` applies to Ambitions Figma files, VSP, SwiftUI UI, screenshots, and marketing-render work. It identifies the related validation gate as the `VSP North Star Production Quality Gate`.
- `docs/qa/evidence/2026-06-29-vsp-north-star-figma/manifest.json` defines a Figma prep package named `Ambitions iOS 26 Design System - North Star Production Kit`.
- `docs/qa/evidence/2026-06-29-vsp-north-star-figma/authority-map.md` records VSP-01 as approved shell authority and VSP-02 through VSP-10 as content-only candidate frames.

What VSP does not mean, based on current repo evidence:

- It is not a release milestone.
- It is not source implementation completion.
- It is not Visual Green.
- It is not owner approval.
- It is not permission to change shell, navigation, root IA, account architecture, Source Atlas boundaries, or local-first runtime law.

## VSP inventory table

| Packet id | Discovered title/name | Intended ownership | Expected output | Source evidence paths | Current repo evidence | Likely Linear/project relationship | Status | Confidence | Blocking questions or missing authority |
|---|---|---|---|---|---|---|---|---|---|
| VSP-01 | Root Shell / Stage / Chrome | Shell authority | Approved shell frame and screenshot; immutable shell boundary for later packets | `docs/qa/evidence/2026-06-29-vsp-north-star-figma/authority-map.md`; `manifest.json`; `screenshot-index.md`; `images/vsp-01-authority-1-2.png` | `Native/Ambitions/Stage/AmbitionsStage.swift`; `Native/Ambitions/Stage/AmbitionsSurface.swift`; `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift`; `Native/Ambitions/Stage/Chrome/StageDockRail.swift`; `Native/AmbitionsTests/App/AppShellNavigationTests.swift` | AMB-1480 | Needs Repair | High | Owner approval is absent. No rendered SwiftUI parity proof that current shell matches approved VSP-01. |
| VSP-02 | Today Reality Window | Today surface content layer | Current selected R6 direction: Rail-Attached Time Bands as the base with Current Aperture behavior, content-only inside VSP-01 shell | `docs/design/provenance/figma-frames/VSP-02-rail-attached-time-bands-current-aperture-R6.md`; `docs/qa/evidence/2026-06-30-vsp-02-r6-rail-aperture/manifest.md`; R6 readable viewport PNG | `Native/Ambitions/Surfaces/Today/TodaySurface.swift`; `TodayObjectView.swift`; `TodayAccessibility.swift`; `Sources/Components/RealityMeridianTimeBand.swift` as existing horizontal source anchor plus new vertical rail/current-aperture primitive requirement | AMB-1481 | Ready For Review / Yellow | High | Missing owner approval for implementation handoff, rendered SwiftUI parity proof, manual a11y proof, Dynamic Type screenshot proof, and runtime mutation/proof evidence. |
| VSP-03 | Goals Life Area Atlas | Goals surface content layer | Content-only Goals hero/state/a11y/anatomy/marketing candidate frames mounted inside VSP-01 shell | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-03-goals-hero-r1-repaired.png` | `Native/Ambitions/Surfaces/Goals/GoalsSurface.swift`; Goals object/projection source; shell tests | AMB-1482 | Partial | High | Missing owner approval, rendered parity proof, manual a11y proof, and source proof that the candidate is not a dashboard/project-board pattern. |
| VSP-04 | Time / LifeShape Week | Time surface content layer | Content-only Time hero/state/a11y/anatomy/marketing candidate frames mounted inside VSP-01 shell | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-04-time-hero-r1-repaired.png`; `docs/design/targets/time/lifeshape_field_visual_target.md` | `Native/Ambitions/Surfaces/Time/TimeSurface.swift`; Time object/projection source; Time visual target audit source | AMB-1483 | Partial | High | Missing owner approval, rendered parity proof, manual a11y proof, and confirmation that LifeShape does not become a calendar clone. |
| VSP-05 | Capture Open Field Composer | Global composer content layer | Content-only Capture composer candidate; global composer only, not root tab | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-05-capture-hero-r1.png` | `Native/Ambitions/Composer/Capture/CaptureSurface.swift`; `Native/Ambitions/Stage/StageStore.swift`; `Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift`; Capture tests/source | AMB-1484 | Needs Repair | Medium-high | Repo-local packet definition depth is limited. Must not become tab, inbox, chatbot, category wall, or persistent floating button. Missing owner approval and rendered/global route proof. |
| VSP-06 | You Native Settings | You surface content layer | Content-only You/settings candidate mounted inside VSP-01 shell | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-06-you-hero-r1.png` | `Native/Ambitions/Surfaces/You/YouSurface.swift`; You detail routes; notification/account/local settings source | AMB-1485 | Partial | Medium-high | Missing owner approval, rendered parity proof, manual a11y proof, and exact boundary between user settings, account support, privacy controls, and private runtime data. |
| VSP-07 | Trust Inspection Seams | Trust inspection detail layer | Content-only Proof/Source/Privacy/History/Receipts inspection seams; not a root surface | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-07-trust-hero-r1.png` | `Native/Ambitions/Trust/**`; `Native/Ambitions/Stage/SurfaceOwnershipRegistry.swift`; Source Atlas/trust source; tests where present | AMB-1486 | Needs Repair | Medium-high | Missing owner approval and rendered proof. Must stay contextual inspection detail, not a fifth persistent surface. |
| VSP-08 | External Boundaries | Source Atlas/account/R2/offline boundary layer | Boundary candidate for external dependencies, account, R2, and local-first limits | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-08-boundaries-hero-r1.png` | `docs/truth/PRODUCT_DESIGN_TRUTH.md`; `docs/truth/PRODUCT_EXPERIENCE_CANON.md`; `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`; account/R2/Source Atlas scripts and source inventories | AMB-1487 | Needs Repair | Medium | Packet scope is underdefined. Must not require sign-in for core value, store private life graph in R2, or introduce cloud LLM core architecture. Needs explicit design authority before implementation. |
| VSP-09 | Motion / Haptics / Accessibility Matrix | Cross-surface behavior and proof layer | Motion, haptics, Reduce Motion, accessibility matrix candidate; behavior only, not destination | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-09-motion-hero-r1.png` | `Native/Ambitions/Stage/Motion/StageMotionLayer.swift`; `Native/Ambitions/Interaction/**`; `Sources/Accessibility/**`; `Native/AmbitionsTests/App/StageMotionRoutingTests.swift`; `Native/Ambitions/Quality/ShellPreviewMatrix.swift` | AMB-1488 | Needs Repair | Medium-high | Missing manual VoiceOver, Dynamic Type, Reduce Motion walkthrough, contrast, motor, haptic, and rendered screenshot proof. Must not create Motion root destination. |
| VSP-10 | Implementation Anatomy | Design-system/source anatomy and implementation map | Implementation anatomy candidate; component/source mapping, not product surface | `manifest.json`; `screenshot-index.md`; `visual-audit-ledger.md`; `images/vsp-10-anatomy-hero-r1.png` | `Sources/Components/**`; `Sources/Previews/**`; `Native/Ambitions/Quality/**`; `Native/AmbitionsTests/App/FE09ComponentSystemTests.swift`; `docs/truth/PRODUCT_DESIGN_TRUTH.md` Final Architecture Tree | AMB-1489 | Needs Repair | Medium | The candidate is not a product hero substitute. Needs repo-local source-owner map, stale vocabulary cleanup plan, and proof linkage before implementation. |

## Shell authority finding

The approved VSP-01 shell boundary is the Figma frame recorded in `docs/qa/evidence/2026-06-29-vsp-north-star-figma/authority-map.md` and `manifest.json`:

- approved shell file key: `hnVi8KV2SAuWP3V5hV160W`
- approved frame: `1:2`
- durable screenshot: `docs/qa/evidence/2026-06-29-vsp-north-star-figma/images/vsp-01-authority-1-2.png`
- mutation status in the package: not mutated

The later VSP package explicitly says VSP-02 through VSP-10 are content-only candidates inside the exact approved VSP-01 shell authority. It also says they must not invent shell chrome, dock, Context Crown, Capture/search affordance, tab bar, status/nav approximation, shell material, or root trust destination.

Current SwiftUI shell source is directionally aligned with product law:

- `AmbitionsSurface` exposes only `today`, `goals`, `time`, and `you`.
- `StageDockRail` derives destinations from those canonical surfaces.
- `StageStore` opens Capture as overlay/global composer behavior, not as a root tab.
- `SurfaceOwnershipRegistry` marks Capture as `globalComposer`, Motion as `motionBehavior`, and Proof/Source/Privacy/History/Receipts as contextual inspection.
- shell tests explicitly reject `capture`, `motion`, `plan`, `profile`, `habits`, and `insights` as root surface raw values.

However, this is not enough to call VSP-01 implemented. The missing proof is a direct rendered SwiftUI parity audit between the approved VSP-01 shell frame and the live app shell.

## Packet-by-packet findings

### VSP-01

Intended ownership: Root shell, Stage, chrome, root dock, safe-area behavior, and shell authority.

Evidence found:

- `authority-map.md` declares VSP-01 as the approved shell authority and says it was not rebuilt or mutated.
- `manifest.json` records VSP-01 as `AUTHORITY`, not candidate content.
- `FIGMA_PRODUCTION_GATE_ADDENDUM.md` says VSP-02 through VSP-10 may only use shell treatment if it is content-only inside exact VSP-01 authority.

Implementation evidence:

- `Native/Ambitions/Stage/AmbitionsSurface.swift` exposes Today, Goals, Time, You only.
- `Native/Ambitions/Stage/AmbitionsStage.swift` hosts the Stage shell, root dock, Capture overlay, and search seam.
- `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift` mounts Today, Goals, Time, and You.
- `Native/AmbitionsTests/App/AppShellNavigationTests.swift` rejects stale or non-canonical roots.

Risks:

- Current shell may be product-law aligned but still visually different from approved VSP-01.
- `AppShellContextualToolbarCatalog` includes Capture fallback actions; this needs shell-authority review so it does not become duplicated persistent Capture access.
- Source comments and internal names still use some tab terminology.

Missing proof:

- Rendered VSP-01 SwiftUI screenshot proof.
- Direct visual parity review against the approved Figma frame.
- Owner approval for any changed shell interpretation.

Recommended next action:

Run an analysis-only VSP-01 shell parity packet first. Do not change shell unless that packet produces explicit defects and a separate implementation leaf is approved.

Recommended status: Needs Repair.

### VSP-02

Intended ownership: Today surface content, specifically the Reality Window / Start Here / Recommended step experience.

Evidence found:

- `manifest.json` names VSP-02 `Today Reality Window`.
- `screenshot-index.md` records hero, crop, and launch-board images.
- `visual-audit-ledger.md` says the candidate was repaired and reviewed as Figma proof only.
- R6 now records the selected direction as Rail-Attached Time Bands with Current Aperture behavior at Figma node `134:44` / viewport `134:48`.

Implementation evidence:

- `Native/Ambitions/Surfaces/Today/TodaySurface.swift` exists and is hosted inside the approved four-surface shell.
- Today source uses Dynamic Type and Reduce Motion environment inputs.
- `Sources/Components/RealityMeridianTimeBand.swift` exists as a horizontal time-band source anchor, but the R6 vertical rail-attached day bands and Current Aperture require a new or repaired SwiftUI primitive.

Risks:

- A Today implementation could drift into dashboard, task-list, calendar clone, KPI panel, or stacked CTA patterns.
- Figma candidate proof is not runtime proof.
- Figma PNG export currently drops SF Pro/system-font text; the readable R6 proof uses a temporary Inter-font export clone and does not prove SwiftUI typography.

Missing proof:

- SwiftUI parity to the VSP-02 R6 visual candidate.
- VoiceOver order, large Dynamic Type, Reduce Motion, contrast, and motor proof.
- Runtime mutation proof for meaningful Today actions.
- Full R6 state/accessibility matrix beyond the selected base viewport.

Recommended next action:

Proceed only after explicit owner approval for implementation handoff. Then implement as a Today content-only rail/aperture leaf with no shell, nav, account, Capture-root, or Motion-root changes.

Recommended status: Ready For Review / Yellow.

### VSP-03

Intended ownership: Goals surface content, specifically Life Area Atlas / Direction Field / Constellation Atlas behavior.

Evidence found:

- `manifest.json` names VSP-03 `Goals Life Area Atlas`.
- `visual-audit-ledger.md` records repaired Figma candidate proof and remaining Yellow ceiling.

Implementation evidence:

- `Native/Ambitions/Surfaces/Goals/GoalsSurface.swift` exists.
- shell tests bind Goals to the Constellation Atlas primary object and reject stale root IA.

Risks:

- Goals can drift into KPI dashboard, project board, ranking layer, analytics surface, or productivity scorecard.
- Existing object/source naming must be checked against locked user-facing language.

Missing proof:

- Rendered Goals parity proof.
- Runtime mutation/proof receipt behavior for goal actions.
- Accessibility and state-matrix proof.

Recommended next action:

Proceed as a content-only Goals leaf after VSP-01 and VSP-10 source-owner mapping. Keep it inside the existing Goals surface.

Recommended status: Partial.

### VSP-04

Intended ownership: Time surface content, specifically LifeShape Week / LifeShape Field / protected time and reflow behavior.

Evidence found:

- `manifest.json` names VSP-04 `Time / LifeShape Week`.
- `docs/design/targets/time/lifeshape_field_visual_target.md` provides a Time-specific visual target, but it is not enough by itself to prove VSP-04 implementation.

Implementation evidence:

- `Native/Ambitions/Surfaces/Time/TimeSurface.swift` exists.
- Time source has protected placement and mutation announcement paths.
- `Native/Ambitions/Quality/VisualTargetArtifactAudit.swift` focuses on Time visual target artifacts.

Risks:

- Time can drift into a generic calendar clone.
- Component-kit source includes stale `plan` context vocabulary around LifeShape-related primitives; this should not become top-level Plan IA.

Missing proof:

- Rendered Time parity proof.
- Conflict/reflow receipt proof.
- Accessibility proof for week layout and Dynamic Type collapse.

Recommended next action:

Proceed after VSP-01 and VSP-10. This packet has relatively strong adjacent design evidence, but still needs a bounded content-only implementation leaf.

Recommended status: Partial.

### VSP-05

Intended ownership: Capture global composer, specifically Open Field / Atmosphere Composer behavior.

Evidence found:

- `manifest.json` names VSP-05 `Capture Open Field Composer`.
- `authority-map.md` says VSP-02 through VSP-10 are content-only and do not invent shell affordances.

Implementation evidence:

- `Native/Ambitions/Composer/Capture/CaptureSurface.swift` hosts Capture as global composer.
- `StageStore` opens Capture through overlay/global composer routes.
- `SurfaceOwnershipRegistry` marks Capture as `globalComposer`, with no canonical tab.

Risks:

- Highest IA risk after VSP-01: Capture must not become a tab, inbox, notes feed, generic plus surface, chatbot, root destination, or persistent floating button.
- Packet definition depth is limited outside the evidence package.

Missing proof:

- Global route graph proof.
- Capture mutation receipt proof.
- Accessibility proof for composer field, review, undo, and fallback states.

Recommended next action:

Needs design clarification before source implementation. If implemented later, scope it to `Composer/Capture` and Stage overlay routing only.

Recommended status: Needs Repair.

### VSP-06

Intended ownership: You surface content and native settings/profile support.

Evidence found:

- `manifest.json` names VSP-06 `You Native Settings`.
- screenshot index records candidate hero, crop, and launch board.

Implementation evidence:

- `Native/Ambitions/Surfaces/You/YouSurface.swift` exists.
- You detail routing exists through Stage-hosted navigation.
- Product canon allows You as the User System Profile surface.

Risks:

- You can drift into old Profile IA, account-required settings, or a generic admin/settings dashboard.
- Optional account support must not weaken offline no-account core value.

Missing proof:

- Owner approval.
- Rendered parity proof.
- Proof that account support, privacy controls, and local settings are separated correctly.

Recommended next action:

Proceed after account/offline boundary questions are clarified. Keep work inside You and local settings/details; do not introduce account-gated core value.

Recommended status: Partial.

### VSP-07

Intended ownership: Trust inspection details: Proof, Source, Privacy, History, Receipts.

Evidence found:

- `manifest.json` names VSP-07 `Trust Inspection Seams`.
- product truth says Proof/Source/Privacy/History/Receipts are inspection details, not persistent surfaces.

Implementation evidence:

- `Native/Ambitions/Trust/**` exists.
- `SurfaceOwnershipRegistry` marks trust inspection as contextual inspection.

Risks:

- Trust could become a fifth root destination or dashboard if implemented as a surface.
- Source Atlas references could become visible product center instead of invisible/reference infrastructure.

Missing proof:

- Inspection entry/exit proof.
- Receipt/proof/source/privacy/history object proof.
- Accessibility proof for inspection details and focus restoration.

Recommended next action:

Proceed only as a contextual inspection leaf after VSP-02 through VSP-06 have stable object anchors.

Recommended status: Needs Repair.

### VSP-08

Intended ownership: External boundaries, likely account/R2/Source Atlas/offline boundary communication and states.

Evidence found:

- `manifest.json` names VSP-08 `External Boundaries`.
- product truth and experience canon define account, R2, Source Atlas, and offline law.

Implementation evidence:

- Truth docs explicitly say core value must work without account.
- Truth docs say R2/Source Atlas are public/reference/freshness infrastructure only and must not receive private life graph or private user context.
- Implementation truth says account/R2 app-side proof is not established.

Risks:

- This packet is the most underdefined.
- It could accidentally introduce account-gated core use, R2 private data storage, Source Atlas as a visible product center, or cloud LLM assumptions.

Missing proof:

- Exact VSP-08 design authority.
- Request/egress privacy proof if any network behavior is involved.
- Offline no-account scenario proof.
- Clear non-goals for AI/cloud services.

Recommended next action:

Keep analysis-only until design authority is clarified. If later implemented, begin with boundary-state copy, local fallbacks, and no-private-egress validation.

Recommended status: Needs Repair.

### VSP-09

Intended ownership: Motion behavior, haptics, accessibility, and proof matrix across surfaces.

Evidence found:

- `manifest.json` names VSP-09 `Motion / Haptics / Accessibility Matrix`.
- `FIGMA_PRODUCTION_GATE_ADDENDUM.md` requires Reduce Motion equivalents and accessibility stress evidence before Visual Green.

Implementation evidence:

- `Native/Ambitions/Stage/Motion/StageMotionLayer.swift` exists.
- `Native/AmbitionsTests/App/StageMotionRoutingTests.swift` proves Motion routes through behavior and overlays, not a root destination.
- `Native/Ambitions/Quality/ShellPreviewMatrix.swift` includes Dynamic Type and Reduce Motion variants.

Risks:

- Motion could be misread as a destination, feed, score, XP layer, or analytics surface.
- Haptics policy may exist in source without user-perceivable or accessibility-safe proof.

Missing proof:

- Manual VoiceOver proof.
- Dynamic Type screenshot proof.
- Reduce Motion walkthrough.
- Reduce Transparency and Increase Contrast proof.
- Haptic policy and device proof.

Recommended next action:

Run as a cross-cutting proof and policy packet before surface polish. It can define acceptance requirements before VSP-02 through VSP-07 implementation leaves.

Recommended status: Needs Repair.

### VSP-10

Intended ownership: Implementation anatomy, source-owner mapping, design-system primitive mapping, and component kit structure.

Evidence found:

- `manifest.json` names VSP-10 `Implementation Anatomy`.
- `visual-audit-ledger.md` says VSP-10 is an anatomy packet and not a product hero substitute.

Implementation evidence:

- `Sources/Components/**` includes Ambitions semantic tokens and component-system primitives.
- `Sources/Previews/**` includes component preview matrix work.
- `Native/Ambitions/Quality/**` includes snapshot and shell preview matrix source.
- `Native/AmbitionsTests/App/FE09ComponentSystemTests.swift` validates parts of the component system.

Risks:

- Anatomy artifacts can drift into product UI if treated as a surface.
- Existing component-kit naming contains stale compatibility traces, including `plan` context vocabulary around LifeShape-related primitives.
- Component proof can be mistaken for app-level rendered proof.

Missing proof:

- Direct VSP-to-source-owner map.
- Component preview matrix exported screenshots.
- Visual target and screenshot proof for all VSPs.
- Stale vocabulary audit tied to VSP implementation leaves.

Recommended next action:

Run early as a component/source-owner mapping packet. It should shape later implementation leaves but not change product UI by itself.

Recommended status: Needs Repair.

## Cross-packet conflicts

No direct conflict was found inside the current VSP evidence package because it explicitly preserves VSP-01 shell authority and marks VSP-02 through VSP-10 as content-only candidates.

The conflicts are conditional implementation risks:

- VSP-05 conflicts with product law if it makes Capture a tab, root surface, inbox, notes feed, category grid, chatbot, or persistent floating action button.
- VSP-09 conflicts with product law if it makes Motion a destination, analytics surface, score, streak, XP layer, activity feed, or dashboard.
- VSP-07 conflicts with product law if Proof/Source/Privacy/History/Receipts become root surfaces instead of inspection details.
- VSP-08 conflicts with product law if it requires account sign-in for core app value, sends private life graph data to R2, makes Source Atlas a visible product center, or introduces external/cloud LLMs as core runtime architecture.
- VSP-10 conflicts with product law if implementation anatomy becomes user-facing product UI or is treated as product hero proof.
- Any VSP-02 through VSP-10 source implementation conflicts with VSP-01 if it adds shell chrome, replaces root navigation, changes safe-area shell behavior, adds a new persistent surface, or duplicates Capture/Search shell access.

Stale or drift-prone naming found during review:

- `Plan`, `Profile`, `Habits`, and `Insights` appear in source/search contexts, but current root-surface tests reject them as top-level product areas.
- Component-kit source includes a `plan` context mapping around LifeShape primitives. That should be repaired or explicitly quarantined before it is used as implementation authority.
- Generated `capture_root_*` naming appears in some component/proof contexts. It must not be interpreted as Capture root navigation authority.

## Missing evidence

Before implementation can safely proceed, the repo is missing:

- Owner approval for VSP-02 through VSP-10 candidates.
- Direct owner confirmation that VSP-01 shell authority remains approved and unchanged after the current review.
- A VSP-01-to-live-SwiftUI shell parity audit.
- A VSP-to-source-owner map for all packets.
- Explicit packet definitions for VSP-05 through VSP-10 outside the Yellow evidence package.
- Rendered SwiftUI screenshot proof for each packet.
- Component preview matrix exports tied to each VSP.
- Dynamic Type screenshot proof.
- VoiceOver order and label proof.
- Reduce Motion walkthrough proof.
- Reduce Transparency and Increase Contrast proof.
- Haptic policy proof, especially for VSP-09.
- Device proof for haptics and platform feel.
- Validation commands that specifically bind VSP manifest entries to canonical source owners.
- Known-issue or risk-register links for unresolved VSP risks.
- Proof that VSP-08 external boundary behavior preserves offline no-account core value.
- Proof that any Source Atlas/R2 access avoids private life graph, goals, captures, schedules, receipts, proof, personalization, behavior patterns, and private user context.
- Cleanup or quarantine plan for stale `plan`, `profile`, `habits`, `insights`, and generated `capture_root` terminology before those artifacts become implementation authority.

## Recommended execution order

Strict order:

1. VSP-01 Shell Authority Readback
2. VSP-10 Implementation Anatomy and Source-Owner Map
3. VSP-09 Motion, Haptics, and Accessibility Acceptance Matrix
4. VSP-02 Today Reality Window
5. VSP-03 Goals Life Area Atlas
6. VSP-04 Time / LifeShape Week
7. VSP-05 Capture Open Field Composer
8. VSP-06 You Native Settings
9. VSP-07 Trust Inspection Seams
10. VSP-08 External Boundaries

Why this order:

- VSP-01 must lead because later packets are only valid inside the approved shell.
- VSP-10 should run early because it maps candidates to canonical source owners and prevents accidental implementation in legacy or "equivalent" folders.
- VSP-09 should run before surface polish because motion, haptics, accessibility, Dynamic Type, Reduce Motion, contrast, and proof standards affect every visual packet.
- VSP-02 through VSP-04 should run before Capture/You/Trust because Today, Goals, and Time are the primary object surfaces and define the core object language.
- VSP-05 should run after the core surfaces so Capture can mutate real object paths without becoming a root surface.
- VSP-06 should run after core object surfaces and Capture so You can inspect preferences, identity, privacy, and history without becoming a generic profile dashboard.
- VSP-07 should run after object surfaces because trust inspection needs real object anchors.
- VSP-08 should run last because it is underdefined and carries the highest architecture/privacy risk.

Safe to proceed now:

- VSP-01 analysis-only parity readback.
- VSP-10 analysis/source-owner map.
- VSP-09 acceptance matrix definition, if kept proof/policy-only.

Needs repair before implementation:

- VSP-05, VSP-07, VSP-08, VSP-09, VSP-10.
- VSP-02 through VSP-04 also need proof repair before any Green claim, but can become bounded content-only implementation leaves sooner than the less-defined packets.

Analysis-only for now:

- VSP-08.
- Any VSP that proposes shell changes, new root surfaces, Capture-as-tab, Motion-as-destination, account-gated core value, or R2/private graph behavior.

Close as stale/duplicate:

- Do not close any VSP as stale based on current evidence.
- Close or reject only future packet interpretations that duplicate shell authority, use stale root names, or promote old Plan/Profile/Habits/Insights/Capture/Motion root IA.

## Codex-ready follow-up packet shapes

### VSP-01 Shell Authority Readback and SwiftUI Parity Audit

Title: VSP-01 shell authority readback and live SwiftUI parity audit.

Scope: Map the approved VSP-01 frame to current Stage, shell, dock, safe-area, Capture/Search access, and root navigation source without changing behavior.

Files likely affected: `docs/qa/vsp-review/**`; possibly proof-only updates under `docs/qa/evidence/**` if explicitly authorized later. Source to inspect: `Native/Ambitions/Stage/**`; `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift`; `Native/Ambitions/Stage/Chrome/**`; shell tests.

Non-goals: shell redesign, new nav model, Capture tab, Motion destination, owner approval claims, Visual Green.

Acceptance criteria: approved VSP-01 shell is mapped to live source; all differences are listed; no source changes unless separately authorized; no new root surfaces; no "equivalent" folder interpretation.

Validation commands: `git diff --check`; `python3 scripts/ambitions-architecture-inventory.py`; `python3 scripts/ambitions-green-standard-audit.py`; focused shell tests only if source changes are later authorized.

Proof artifacts: shell parity map; screenshot references; missing-proof list.

### VSP-02 Today Reality Window Content Leaf

Title: VSP-02 Today Rail-Attached Time Bands + Current Aperture content-only implementation leaf.

Scope: Align Today content/object presentation with the approved VSP-02 R6 direction while preserving VSP-01 shell: vertical rail-attached day bands, centered Current Aperture, integrated condition ribbon, and proof seam.

Files likely affected: `Native/Ambitions/Surfaces/Today/**`; Today view models/projections; `Sources/Components/RealityMeridianTimeBand.swift`; a new or repaired vertical rail/current-aperture primitive; Today tests/previews.

Non-goals: shell chrome, root navigation, Capture routing, Motion destination, dashboard/task-list/calendar clone/KPI panel conversion.

Acceptance criteria: Today remains one of four root surfaces; non-current events are rail-attached duration bands rather than cards; the centered current step opens into a Current Aperture with repair/proof affordances; analytics remain integrated into the object; `Start here`, `Recommended step`, `Step`, `Start now`, and `Open step` language is preserved; meaningful actions mutate runtime state, visible stage state, accessible state, fallback, and proof artifacts where scoped.

Validation commands: `git diff --check`; `python3 scripts/ambitions-architecture-inventory.py`; `python3 scripts/ambitions-green-standard-audit.py`; focused Today tests; screenshot/a11y matrix if UI changes are authorized.

Proof artifacts: approved R6 Figma frame IDs, readable R6 screenshot, rendered Today screenshot, Dynamic Type screenshot, VoiceOver note, Reduce Motion note, proof ceiling.

### VSP-03 Goals Life Area Atlas Content Leaf

Title: VSP-03 Goals Life Area Atlas content-only implementation leaf.

Scope: Align Goals content with Life Area Atlas / Direction Field candidate without introducing dashboard or project-board IA.

Files likely affected: `Native/Ambitions/Surfaces/Goals/**`; Goals projection/view-model source; relevant design-system components; Goals tests/previews.

Non-goals: KPI dashboard, score/ranking system, project board, shell changes, new root surfaces.

Acceptance criteria: Goals remains canonical root surface; Life Area Atlas object behavior is visible; language avoids generic task/project framing; no stale Plan/Profile/Habits/Insights root naming.

Validation commands: `git diff --check`; architecture inventory; green standard audit; focused Goals tests; screenshot/a11y matrix if UI changes are authorized.

Proof artifacts: rendered Goals screenshot, Dynamic Type screenshot, VoiceOver note, Reduce Motion note, mutation/proof note.

### VSP-04 Time / LifeShape Week Content Leaf

Title: VSP-04 Time LifeShape Week content-only implementation leaf.

Scope: Align Time content with LifeShape Field / protected time / reflow candidate without becoming a calendar clone.

Files likely affected: `Native/Ambitions/Surfaces/Time/**`; Time projection/view-model source; `docs/design/targets/time/**`; Time tests/previews.

Non-goals: calendar clone, generic planner, shell changes, Plan root terminology.

Acceptance criteria: Time remains canonical root surface; protected time and reflow states are inspectable; week layout has Dynamic Type and VoiceOver handling; stale `plan` vocabulary is not promoted.

Validation commands: `git diff --check`; architecture inventory; green standard audit; focused Time tests; visual target artifact audit; screenshot/a11y matrix if UI changes are authorized.

Proof artifacts: rendered Time screenshot, protected/reflow proof, Dynamic Type screenshot, VoiceOver note, Reduce Motion note.

### VSP-05 Capture Open Field Composer Leaf

Title: VSP-05 Capture Open Field Composer global-composer leaf.

Scope: Align global Capture composer content and state behavior with VSP-05 while preserving overlay/global composer routing.

Files likely affected: `Native/Ambitions/Composer/Capture/**`; Stage overlay routing; Capture runtime/projection tests; Capture previews.

Non-goals: Capture tab, Capture root surface, inbox, notes feed, category grid, chatbot, persistent floating action button, cloud LLM core behavior.

Acceptance criteria: Capture opens through approved global composer paths; mutations produce visible and accessible state changes; undo/review/fallback states are present; no shell duplication.

Validation commands: `git diff --check`; architecture inventory; green standard audit; focused Capture tests; shell navigation tests; screenshot/a11y matrix if UI changes are authorized.

Proof artifacts: composer screenshot, route proof, mutation/receipt proof, VoiceOver note, Reduce Motion note.

### VSP-06 You Native Settings Leaf

Title: VSP-06 You Native Settings content-only implementation leaf.

Scope: Align You surface settings/profile/privacy/account presentation with VSP-06 while preserving offline core value.

Files likely affected: `Native/Ambitions/Surfaces/You/**`; settings/detail source; account/local preference source; You tests/previews.

Non-goals: old Profile tab, generic settings dashboard, account-gated core app, private graph sync.

Acceptance criteria: You remains canonical root surface; account is optional; no-account offline core remains usable; privacy and local-data controls are visible and accessible.

Validation commands: `git diff --check`; architecture inventory; green standard audit; focused You tests; account/offline boundary checks if available; screenshot/a11y matrix if UI changes are authorized.

Proof artifacts: rendered You screenshot, offline/no-account note, privacy settings note, VoiceOver note, Dynamic Type note.

### VSP-07 Trust Inspection Seams Leaf

Title: VSP-07 Trust Inspection Seams contextual-inspection leaf.

Scope: Implement or align Proof/Source/Privacy/History/Receipts inspection seams as contextual details inside owning surfaces.

Files likely affected: `Native/Ambitions/Trust/**`; relevant surface detail routes; proof/receipt/source projections; tests/previews.

Non-goals: Trust tab, Proof root surface, Source Atlas dashboard, analytics feed.

Acceptance criteria: trust seams open contextually; inspection has clear entry/exit/focus restoration; proof/source/privacy/history/receipt language is user-facing and non-shaming; no new root destination.

Validation commands: `git diff --check`; architecture inventory; green standard audit; focused Trust/source tests; shell navigation tests; screenshot/a11y matrix if UI changes are authorized.

Proof artifacts: inspection screenshot, focus restoration note, VoiceOver note, source/privacy no-private-egress note.

### VSP-08 External Boundaries Analysis and Boundary-State Leaf

Title: VSP-08 External Boundaries analysis-first packet.

Scope: Define and, only after approval, implement boundary states for account, R2, Source Atlas freshness, offline behavior, and no-private-egress rules.

Files likely affected: `docs/qa/vsp-review/**`; boundary docs/proof; later `Native/Ambitions/Surfaces/You/**`, Source Atlas/account boundary source, and validation scripts if explicitly scoped.

Non-goals: account-required core app, private life graph sync, R2 user-data backend, visible Source Atlas product center, external/cloud LLM core runtime.

Acceptance criteria: no-account offline core is preserved; R2/Source Atlas never receive private life graph/user context; any network request shape is documented; unavailable/freshness states are local-first and accessible.

Validation commands: `git diff --check`; architecture inventory; green standard audit; Source Atlas boundary scripts if available; no-private-egress grep/audit.

Proof artifacts: boundary matrix, request/egress proof, offline no-account scenario proof, risk register entries.

### VSP-09 Motion, Haptics, and Accessibility Matrix Leaf

Title: VSP-09 Motion, Haptics, and Accessibility acceptance matrix.

Scope: Define and validate cross-surface motion, haptics, Reduce Motion, VoiceOver, Dynamic Type, contrast, and motor proof expectations.

Files likely affected: `Native/Ambitions/Stage/Motion/**`; `Native/Ambitions/Interaction/**`; `Sources/Accessibility/**`; `Native/Ambitions/Quality/**`; tests/previews.

Non-goals: Motion tab, Motion feed, score, streak, XP, analytics dashboard, Visual Green self-certification.

Acceptance criteria: Motion remains behavior layer; Reduce Motion equivalent exists for every animated claim; haptics are policy-bound; accessibility proof requirements are explicit and testable.

Validation commands: `git diff --check`; architecture inventory; green standard audit; `StageMotionRoutingTests`; component-system tests; shell preview matrix tests; screenshot/a11y matrix if UI changes are authorized.

Proof artifacts: a11y matrix, haptic policy note, Reduce Motion walkthrough, Dynamic Type screenshot, VoiceOver note.

### VSP-10 Implementation Anatomy and Component Map Leaf

Title: VSP-10 Implementation Anatomy source-owner and component map.

Scope: Map each VSP to canonical architecture owners, design-system primitives, previews, tests, and proof artifacts.

Files likely affected: `docs/qa/vsp-review/**`; `Sources/Components/**`; `Sources/Previews/**`; `Native/Ambitions/Quality/**`; component-system tests if source changes are later approved.

Non-goals: product hero, product surface, shell change, broad refactor, architecture-as-user-UI.

Acceptance criteria: every packet has canonical owner, likely files, non-goals, proof requirements, and validation commands; stale naming is identified; no "equivalent" folder interpretation is used.

Validation commands: `git diff --check`; architecture inventory; green standard audit; component-system tests if source changes are later authorized.

Proof artifacts: VSP-to-source-owner map, component preview inventory, stale vocabulary list, proof gap matrix.

## Code-Connect-free provenance system

A Git-owned Code-Connect-free provenance system now lives at `docs/design/provenance/`.

- Start at `docs/design/provenance/README.md`.
- Use `docs/design/provenance/VSP-SwiftUI-Provenance-Map.md` for the VSP-to-source-owner handoff.
- The Git provenance registry is canonical: `docs/design/provenance/vsp-provenance.json`, `component-registry.json`, `figma-node-index.json`, `proof-registry.json`, and `linear-map.json`.
- Linear is a mirror/spec target, not the source of truth, and this review does not create or update Linear objects.
- Figma annotations are generated/manual because Figma Code Connect is unavailable in the current workspace.
- No VSP moves beyond Yellow without current proof artifacts, owner approval where required, and the applicable render/accessibility/privacy validation evidence.
- This system does not implement VSP UI surfaces or change SwiftUI runtime behavior.

## Risk register additions

The following issues should be added to known issues or risk register later, but this review does not edit those files:

- VSP package is Yellow evidence only; none of VSP-01 through VSP-10 should be marked Done, Visual Green, Release Green, or implementation complete.
- VSP-01 approved shell lacks direct live SwiftUI rendered parity proof.
- VSP-02 through VSP-10 lack owner approval.
- VSP-05 can easily violate product law by becoming Capture-as-tab or Capture-as-root.
- VSP-07 can easily violate product law by making trust inspection a fifth persistent surface.
- VSP-08 is underdefined and carries account/R2/Source Atlas/private-data risk.
- VSP-09 lacks manual accessibility and device haptics proof.
- VSP-10 can be misused as product UI or product hero proof.
- Stale vocabulary including Plan/Profile/Habits/Insights and generated `capture_root` naming should be quarantined before future VSP implementation.
- No VSP-specific validation command currently proves Figma-to-source parity, source-owner mapping, screenshot proof, and accessibility proof together.

## Closeout

Status: Yellow

Scope completed: Read-only inventory, reconciliation, risk analysis, dependency analysis, future execution shaping for VSP-01 through VSP-10, and Code-Connect-free provenance-system addendum.

Files changed: `docs/qa/vsp-review/VSP01-VSP10-review-analysis.md`; `docs/design/provenance/**`; `scripts/ambitions-component-inventory-generate.py`; `scripts/ambitions-provenance-report-generate.py`; `scripts/ambitions-vsp-provenance-audit.py`.

Product law preserved: Yes. No source code, truth canon, Linear objects, completion status, shell authority, account/R2 law, Capture root law, or Motion root law was changed.

Validation run: `python3 scripts/ambitions-component-inventory-generate.py` passed; `python3 scripts/ambitions-provenance-report-generate.py` passed; `python3 scripts/ambitions-vsp-provenance-audit.py` passed with 0 blocking failures, 0 warnings, and 95 Yellow proof gaps; `git diff --check` passed. Prior analysis validation also recorded `python3 scripts/ambitions-green-standard-audit.py` and `python3 scripts/ambitions-architecture-inventory.py`.

Validation not run: Build, test, simulator, device, visual screenshot capture, Figma API mutation, Figma owner review, Linear mutation, and accessibility/device proof were intentionally not run for this docs/governance review.

Proof artifacts: This report; existing Yellow evidence package at `docs/qa/evidence/2026-06-29-vsp-north-star-figma/**`; provenance registry and generated audit report at `docs/design/provenance/**`.

Known risks: VSP package remains Yellow; owner approval absent; VSP-01 live SwiftUI parity unproven; VSP-08 underdefined; manual accessibility, haptics, screenshot, and device proof missing; stale naming remains in adjacent source contexts.

Follow-up required: Run VSP-01 shell parity readback, owner review, VSP-09 accessibility/motion/haptics proof, and live SwiftUI/device proof before any VSP moves beyond Yellow or into implementation Green.

Rollback plan: Remove the `## Code-Connect-free provenance system` report section, delete `docs/design/provenance/**`, and delete the three provenance scripts.
