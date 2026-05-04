# Ambitions Product Experience Pack Final File-Boundary Approval

Status: Batch 1E final handoff gate; planning-only
Date: 2026-05-04

## 1. Purpose

This document is the final file-boundary approval artifact for Product
Experience Pack implementation planning. It closes the Batch 0 through Batch 1E
handoff map by naming which files may be inspected, which docs may remain
editable for planning, and which implementation areas require explicit future
approval.

This is not approval to edit app code. It does not start Product Depth, resume
the global train, create Batch 2, create an implementation prompt, edit SwiftUI
feature surfaces, edit navigation, edit design tokens, edit persistence, edit
runtime, edit CI/config, finalize Candidate items, or remove caveats.

## 2. Boundary Status Summary

| Category | Status | Meaning |
| --- | --- | --- |
| A. Green inspect-only | Green | Safe to read for evidence and planning; do not edit in early Product Experience Pack work. |
| B. Yellow docs-only editable | Yellow | Safe to edit only for docs/planning artifacts when a batch explicitly allows them. |
| C. Yellow approval-gated future implementation candidates | Yellow | Possible future source owners after Product Depth or a separately approved implementation scope. |
| D. Red forbidden early implementation files | Red | Do not edit during early Product Experience Pack handoff or planning. |
| E. Red generated/config-sensitive files | Red | Do not edit casually; generated, build, project, or platform-sensitive. |
| F. Stop / user-decision files | Stop | Legitimate future targets only after explicit user approval, named scope, owner gate, and validation plan. |

## 3. Final Boundary Table

| Area | Status | Exact files or categories | Reason | Future treatment | Required approval | Validation requirement | Stop condition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Product Experience Pack handoff docs | Yellow docs-only editable | `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md`, `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md`, `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`, this final boundary doc | These are handoff artifacts, not source implementation. | Docs-only updates for evidence, references, or user-decision state. | Batch prompt must explicitly allow docs edits. | `git diff --check`, touched-doc whitespace scan, docs QA as advisory. | Any change that rewrites locked product source truth or implies implementation approval. |
| Audits / reports | Yellow docs-only editable | `docs/audits/ambitions-product-experience-pack-batch-1a-boundary-report.md`, `docs/audits/ambitions-product-experience-pack-batch-1b-reconciliation-report.md`, `docs/audits/ambitions-product-experience-pack-batch-1c-copy-boundary-scan.md`, `docs/audits/ambitions-product-experience-pack-batch-1d-readiness-gate-report.md`, `docs/audits/ambitions-product-experience-pack-batch-1e-implementation-planning-gate.md` | These record evidence and gate outcomes. | Append-only or narrowly updated evidence references. | Docs-only batch approval. | Same docs-only validation; no build required unless source changes occur in another batch. | Any claim that Product Depth, global train, or app implementation started. |
| `docs/canon` | Green inspect-only / Stop for edits | `docs/canon/**` | Canon controls source truth and must not be rewritten by a handoff gate. | Inspect for source-truth hierarchy and conflicts. | Explicit source-truth reconciliation approval for any edit. | Canon diff review, doc QA, and conflict report. | Caveat removal, Candidate finalization, or source-truth conflict. |
| `docs/codex` | Green inspect-only / Stop for train state | `docs/codex/**` including batch trains, registry, global order, and gate matrices | Codex OS and train files control execution state. | Inspect for gates and approval phrases. | Explicit train/governance update approval. | Batch train gate and docs QA. | Product Depth/global train state change without approval. |
| AGENTS / README / architecture docs | Green inspect-only | `AGENTS.md`, `README.md`, `docs/README.md`, architecture docs found by repo recon | These describe repo behavior and architecture. | Inspect for governing rules. | Explicit repo-governance docs scope for edits. | Docs QA and direct diff review. | Any rewrite of IA, roadmap, or repo behavior without decision. |
| Train manifests | Stop / user-decision | `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`, other train manifests | Product Depth and global train sequencing are gated. | Read-only until exact approval or explicit train-maintenance task. | Exact phrase for PD01; explicit user approval for train edits. | Batch train gate plus train-state evidence. | Starting or modifying train state without approval. |
| Batch registry / global order files | Stop / user-decision | `docs/codex/BATCH_REGISTRY.md`, `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`, `docs/codex/GLOBAL_BATCH_CONTINUATION_PROTOCOL.md`, `.codex/reports/current-run-state.md`, `.codex/reports/current-batch-train-state.md` | These are operational truth. | Inspect only for handoff gates. | Explicit operational-status task. | Batch train gate and status proof. | Marking Product Depth/global continuation active without approval. |
| AppTab / navigation / shell | Stop / user-decision | `Native/Ambitions/App/AppTab.swift`, `AppNavigation.swift`, `AmbitionsRootView.swift`, `AppShellView.swift`, `AppMeridianShell.swift`, `AppShellPresentationMode.swift`, `ShellCommandRouter.swift` | Top-level IA is locked and navigation changes have high blast radius. | Future edits only with named shell/navigation scope. | Explicit implementation scope and file boundary. | Build, navigation tests, UI tests as applicable, copy scan. | New top-level destination, tab rename, or route compatibility break. |
| Today files | Yellow approval-gated future candidates | `Native/Ambitions/Features/Today/**` | Today owns Reality Rail, Step Detail, Step Session, and closure surfaces. | Product Depth Today sequence or separately approved narrow Today batch. | Product Depth approval or explicit object scope. | Focused build/test, Today view-model tests, accessibility and copy scans. | Step Session upgraded silently or timer made primary. |
| Goals files | Yellow approval-gated future candidates | `Native/Ambitions/Features/Goals/**` | Goals owns LifePath and Mission Control. | Future edits after MissionControlTimeSpine reconciliation. | Product Depth approval or narrow Goals scope. | Focused build/test, Goals UI evidence, copy scan. | Implementing unresolved lane order or KPI/OKR drift. |
| Capture files | Yellow approval-gated future candidates | `Native/Ambitions/Features/Captures/**`, `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`, capture placement services | Capture must stay text-first and placement appears after content. | Future edits after text-first and placement gates are named. | Explicit Capture object scope. | Focused build/test, copy/privacy scan, accessibility labels. | Voice/add becomes primary or candidate placement becomes silent upgrade. |
| Plan files | Yellow approval-gated future candidates | `Native/Ambitions/Features/Plan/**` | Plan owns LifeShape Map and Reflow Decision. | Future edits after LifeShape capacity-lens scope is explicit. | Explicit Plan scope or Product Depth approval. | Focused build/test, Plan projection tests, copy scan. | Month lens becomes calendar clone or reflow becomes silent automation. |
| You / Profile files | Yellow approval-gated future candidates | `Native/Ambitions/Features/Profile/**`, `Sources/Components/PersonalSystemCenterPrimitives.swift` | You owns Personal System Center, trust, memory, receipts, and Appearance Studio. | Future edits after copy-density and privacy/trust boundary review. | Explicit You/Profile scope. | Focused build/test, privacy copy scan, accessibility labels. | Privacy tone becomes surveillance/admin or settings clone. |
| Mission Control files | Stop / user-decision | `GoalMissionControlLanePrimitives.swift`, `GoalComponents.swift`, `GoalDetailScreen.swift`, `GoalsFeatureService.swift`, related shared lane primitives | Locked order remains unresolved: Completed, Now, Friction, Next, Horizon. | PD01 mapping or narrow docs-only MissionControlTimeSpine plan before code. | Explicit user decision before source edits. | Goals tests, UI evidence, copy scan, accessibility order proof. | Now/Next collapse, Horizon becomes roadmap/Gantt, or proof becomes chronology-only. |
| Appearance Studio / theme / accent files | Stop / user-decision | `Sources/Theme/AmbitionTheme.swift`, `Native/Ambitions/Persistence/PersistenceContracts.swift`, `AppPreferencesStore.swift`, `ProfileScreen.swift`, `ProfileFeatureService.swift`, `ProfileViewModel.swift` | Pack locks Gold default and launch accents, while repo uses sage-style taxonomy. | Docs-only alias/migration plan before token or persistence edits. | Explicit design-token/default migration approval. | Build, snapshot/preview evidence, persistence migration tests if defaults change. | Accent recolors semantic state or saved preferences are broken. |
| Semantic mark files | Yellow approval-gated / Stop by semantics | `Sources/Components/TrustReceiptLayerPrimitives.swift`, `LoadingDegradedStatePrimitives.swift`, `IconographyStatusPrimitives.swift`, `AccessibilityAdaptiveInterfacePrimitives.swift`, source/privacy/receipt domain models | Proof, source, privacy, and receipt semantics are locked. | Future edits only with semantic owner and copy/accessibility validation. | Explicit source/privacy/receipt scope. | Copy scan, accessibility label scan, focused tests. | AI certification, trophy, feed, or surveillance language appears. |
| Copy / fixture / preview files | Yellow approval-gated | `Native/Ambitions/PreviewSupport/**`, `Sources/Previews/**`, `Native/AmbitionsTests/**`, `Native/AmbitionsUITests/**`, visible copy in feature files | Batch 1C showed broad user-facing and evidence-copy risk. | Staged copy remediation only. | Explicit copy-boundary batch and allowed files. | Risky-copy scan, fixture/preview review, UI/accessibility evidence. | Bulk rename of internal compatibility cases or raw values. |
| Tests | Red forbidden early implementation | `Native/AmbitionsTests/**`, `Native/AmbitionsUITests/**` except explicitly scoped test-only batches | Tests can encode product contracts and should not be casually rewritten. | Test edits only with named source behavior or copy-remediation stage. | Explicit test scope. | Relevant test suite and diff rationale. | Weakening tests to fit unresolved product conflict. |
| Accessibility helper files | Yellow approval-gated | `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`, accessibility helpers, labels, UI tests | Every visual object needs non-visual and Reduced Motion equivalents. | Future edits only with object-level accessibility scope. | Explicit accessibility implementation or remediation scope. | Accessibility scan, VoiceOver label review, Dynamic Type/Reduced Motion evidence. | Public accessibility readiness claim without evidence. |
| Persistence / sync / auth / network files | Red forbidden early / Stop | `Native/Ambitions/Persistence/**`, sync capability contracts, auth/network-adjacent services | These can affect data, migration, privacy, and local-first behavior. | No early Product Experience Pack handoff edits. | Explicit data/runtime scope and tests. | Migration tests, persistence tests, build, privacy review. | Schema/default change without migration proof. |
| AI / LDI runtime files | Red forbidden early / Stop | `Native/Ambitions/Runtime/**`, intelligence/model services, LDI/recommendation/runtime boundaries | Product truth forbids AI theater and silent automation. | No runtime edits in planning gates. | Explicit runtime scope and source-truth approval. | Runtime tests, copy scan, no-unsupported-AI-claim scan. | AI certification, confidence, or automation claim leaks into UX. |
| CI / config / generated project files | Red generated/config-sensitive | `.github/workflows/**`, `project.yml`, `Package.swift`, `Ambitions.xcodeproj/**`, `output/**`, `DerivedData/**`, `.swiftpm/**`, `*.xcresult`, assets/config support files | Build/project files are XcodeGen or generated/config-sensitive. | Inspect only unless explicitly scoped. | Explicit CI/config/project approval. | XcodeGen, build/test, workflow validation as applicable. | Config churn, generated-file edits, or dependency change without approval. |
| Validation scripts | Green inspect-only / Yellow tooling scope | `scripts/**` | Scripts define gates and advisory checks. | Inspect for commands; edit only in tooling batch. | Explicit tooling scope. | Script self-checks, docs QA, batch gate. | Inventing validation commands or weakening gates. |

## 4. First Implementation-Planning Boundary

A future first implementation-planning step may:

- Start Product Depth PD01 only if the user gives the exact approval phrase:
  `Start Product Depth Train`.
- Perform docs/source-truth reconciliation using the Batch 0 through Batch 1E
  handoff packet.
- Produce a narrow docs-only implementation plan for one named object if the
  user explicitly asks for that planning scope.
- Inspect source files named by this boundary map.

A future first implementation-planning step may not:

- Edit app code unless Product Depth or a separately approved implementation
  batch explicitly names the object, files, and validation.
- Edit navigation, tab definitions, shell files, design tokens, theme/accent
  files, Mission Control, persistence, sync, auth, network, AI/LDI runtime,
  CI/config, generated files, tests, previews, or fixtures without explicit
  scope.
- Claim Product Depth approval, implementation readiness, release readiness, or
  accessibility readiness without evidence.
- Create Batch 2 or implementation prompts from Batch 1E alone.
- Finalize Candidate items or remove caveats.

## 5. Approval-Gated Risk Areas

These areas remain approval-gated after Batch 1E:

- Accent taxonomy/default migration: Yellow conflict; Gold default and launch
  accents are locked, but repo taxonomy still uses sage-style values.
- MissionControlTimeSpine order: Yellow conflict/unknown; Completed, Now,
  Friction, Next, Horizon remains the required order.
- User-facing copy remediation: requires staged inventory and explicit copy
  boundary; internal compatibility vocabulary may remain when not user-facing.
- Step Session depth: not proven complete; timer must remain secondary.
- Month LifeShape lens: highest calendar-clone risk.
- You / Privacy / Receipts density: must remain trust/control-first and
  privacy-safe.
- Candidate objects: Horizon Detail, Capture Correction,
  Privacy-Sensitive Capture Review, Pressure Review, Planning Defaults,
  Source / Trust Preferences, Correction Sheet, and Undo Sheet remain
  Candidate.
- Product Depth gate: Stop until exact approval phrase is given.
- Global train gate: Stop until explicitly approved and allowed by train rules.

## 6. Final Boundary Decision

The Product Experience Pack repo handoff packet is complete enough for a user
decision between parking, additional named docs-only cleanup, a narrow
implementation-planning request, or Product Depth PD01 using the exact approval
phrase.

Batch 1E does not authorize app implementation. Product Depth remains stopped
until the exact approval phrase is provided. Broad app implementation remains
Red.
