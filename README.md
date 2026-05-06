# Ambitions Native iOS App

Ambitions is a native iOS SwiftUI app and premium life execution system.

Ambitions helps raw intent become placed structure, placed structure become believable plans, believable plans become one clear step, real life become closure, and progress become proof.

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

---

## Current source of truth

Start Ambitions 3.0 work from this read order:

1. [Ambitions_3_0_Source_Of_Truth_Override.md](docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md)
2. [Ambitions_3_0_Front_End_Redesign_Index.md](docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md)
3. [Ambitions_3_0_Rebuild_Operating_Model.md](docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md)
4. [Ambitions_3_0_Documentation_System_Index.md](docs/canon/Ambitions_3_0_Documentation_System_Index.md)
5. [Ambitions_3_0_Primitive_Architecture.md](docs/canon/Ambitions_3_0_Primitive_Architecture.md)
6. [Ambitions_3_0_Product_Language_System.md](docs/canon/Ambitions_3_0_Product_Language_System.md)
7. The target primitive, surface, state-machine, privacy, accessibility, or QA doc for the work being done.

Use [docs/codex/BATCH_REGISTRY.md](docs/codex/BATCH_REGISTRY.md) for implementation status truth.

Older docs are supporting context unless an active 3.0 doc explicitly keeps them binding for a domain that 3.0 does not replace.

---

## Ambitions 4.0 execution program

[Ambitions 4.0 Execution Program](docs/canon/Ambitions_4_0_Execution_Program.md) is the active post-3.0 implementation and canon-execution program. It is not a shipped product version, release-readiness claim, App Store claim, TestFlight claim, physical-device proof, platform proof, or public accessibility proof.

Ambitions 3.0 remains the completed baseline after F30. Ambitions 4.0 currently
means the repo has a 113-batch global execution order after SI insertion; REC02-REC06,
PX01-PX20, ME01, HPS01-HPS12, AOS01, AOS02, and AOS03 are complete as
docs/evidence/canon/audit/domain work, while AOS04-AOS30 remain gated by
predecessor, HPS, Source Atlas where relevant, and AOS proof gates. Future canon
remains future canon until implemented and proven.

---

## Ambitions 3.0 rebuild model

Ambitions 3.0 is primitive-led. Build work should be scoped through 3.0 primitives, state machines, language rules, and evidence gates.

Primary rebuild docs:

- [Product Strategy Brief](docs/canon/Ambitions_3_0_Product_Strategy_Brief.md)
- [Primitive Architecture](docs/canon/Ambitions_3_0_Primitive_Architecture.md)
- [Product Language System](docs/canon/Ambitions_3_0_Product_Language_System.md)
- [Plan Life Suite Endgame](docs/canon/Ambitions_3_0_Plan_Life_Suite_Endgame.md)
- [Ambitions Operating Shell](docs/canon/Ambitions_3_0_Ambitions_Operating_Shell.md)
- [Information Architecture And Routing Model](docs/canon/Ambitions_3_0_Information_Architecture_And_Routing_Model.md)
- [State Machines And Domain Flows](docs/canon/Ambitions_3_0_State_Machines_And_Domain_Flows.md)
- [Recommendation Eligibility Engine](docs/canon/Ambitions_3_0_Recommendation_Eligibility_Engine.md)
- [Evidence Hierarchy](docs/canon/Ambitions_3_0_Evidence_Hierarchy.md)
- [Personalization Consent Model](docs/canon/Ambitions_3_0_Personalization_Consent_Model.md)
- [Codex-Only Implementation And Testing Strategy](docs/canon/Ambitions_3_0_Codex_Only_Implementation_And_Testing_Strategy.md)
- [Release Readiness And Evidence Gates](docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md)
- [Repo Hygiene And Active Canon Policy](docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md)
- [As Current Baseline Policy](docs/canon/Ambitions_3_0_As_Current_Baseline_Policy.md)
- [Human-Made Codebase Standard](docs/canon/Ambitions_3_0_Human_Made_Codebase_Standard.md)
- [Active History Archive Policy](docs/canon/Ambitions_3_0_Active_History_Archive_Policy.md)

The complete active doc map lives in [Ambitions_3_0_Documentation_System_Index.md](docs/canon/Ambitions_3_0_Documentation_System_Index.md).

---

## Canonical destinations

Ambitions has five canonical destinations inside the Ambitions Operating Shell:

- Today
- Goals
- Capture
- Plan
- You

These destinations are stable for routing, accessibility, App Intents, deep links, and tests.

The visual shell direction is defined in [Ambitions_3_0_Ambitions_Operating_Shell.md](docs/canon/Ambitions_3_0_Ambitions_Operating_Shell.md).

---

## Product language

Core language:

- Start here
- What needs a place?
- Does this hold together?
- Close the loop
- Still Counts
- What changed?
- What counted?
- Proof saved
- You are in control

Language rules live in:

- [Product Language System](docs/canon/Ambitions_3_0_Product_Language_System.md)
- [Content QA And Copy Guard](docs/canon/Ambitions_3_0_Content_QA_And_Copy_Guard.md)
- [Migration And Deprecation Plan](docs/canon/Ambitions_3_0_Migration_And_Deprecation_Plan.md)

---

## Native structure

- `Native/Ambitions/App` — app entry, dependency container, environment injection, and root routing.
- `Native/Ambitions/Domain` — native domain models, state contracts, recommendation, receipt, proof, planning, and execution models.
- `Native/Ambitions/Services` — feature service protocols and repository-backed implementations.
- `Native/Ambitions/Persistence` — SwiftData-backed native persistence.
- `Native/Ambitions/Features` — Today, Capture, Goals, Plan, You, and related feature surfaces.
- `Native/Ambitions/UI` — shared shell UI.
- `Native/Ambitions/PreviewSupport` — preview-safe bootstrap and fixture data.
- `Sources/` — `AmbitionsDesignSystem` Swift package.
- `AppUI/Sources/` — `AmbitionsWidgetUI` Swift package.

Some internal identifiers remain compatibility-oriented and are tracked by [Repo Hygiene And Active Canon Policy](docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md). Compatibility seams should read as intentional engineering choices, not as active product language.

---

## Repo boundaries

- Production UI belongs in `Native/Ambitions/`, `Sources/`, or `AppUI/Sources/`.
- New top-level destinations require explicit 3.0 parent-canon revision.
- Invention-bank ideas should be implemented through 3.0 primitives.
- Production readiness claims require evidence from the release gates.
- Generated scratch artifacts belong outside the repo.

---

## Running the native app

This repo uses XcodeGen rather than a checked-in `.xcodeproj`.

On a Mac with Xcode 16+ and XcodeGen installed:

1. Run `xcodegen generate`.
2. Open `Ambitions.xcodeproj`.
3. Build and run the `Ambitions` scheme on an iOS Simulator.

The reproducible native generation, build, test, UI test, and archive flow lives in [docs/native-build-and-release.md](docs/native-build-and-release.md).

---

## Codex workflow

Codex work should follow:

1. active 3.0 read order from this README
2. [docs/codex/CONTEXT_INDEX.md](docs/codex/CONTEXT_INDEX.md)
3. [docs/codex/BATCH_REGISTRY.md](docs/codex/BATCH_REGISTRY.md) for implementation status
4. target primitive/surface docs
5. [Codex-Only Implementation And Testing Strategy](docs/canon/Ambitions_3_0_Codex_Only_Implementation_And_Testing_Strategy.md)
6. [Release Readiness And Evidence Gates](docs/canon/Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md)

Every implementation batch should report canon docs read, files changed, primitive advanced, loop step advanced, tests run, previews added, copy guard results, accessibility notes, privacy notes, and remaining gaps.

---

## iOS native validation

GitHub Actions validates iOS-native integrity on `macos-15` in [.github/workflows/ios-validate.yml](.github/workflows/ios-validate.yml).

The workflow currently regenerates the Xcode project, resolves Swift package dependencies, builds the app target, runs unit tests, runs UI tests, runs an unsigned Release archive sanity check, and uploads `.xcresult` bundles.

The workflow does not prove signed archives, TestFlight, App Store Connect validation, distribution exports, physical-device behavior, external accessibility conformance, or human usability.

---

## Runtime status

- The app is Swift-native and XcodeGen-driven.
- The app boots through the native SwiftUI entry point.
- State persists through SwiftData where implemented.
- The current shipped surface is local-first and on-device first.
- Notification scheduling, calendar/reminder wiring, widgets, and Live Activity foundations exist, but manual platform verification remains required before production claims.
- Account sync is not implemented.
- The iOS target includes a native app icon set and `PrivacyInfo.xcprivacy`.

---

## Cleanup status

Ambitions 3.0 docs define the active source of truth. Older waves, v2 docs, and historical transformation material are supporting context unless explicitly kept active by the 3.0 source override.

Known cleanup debt is tracked in [Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md](docs/canon/Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md). Current baseline and archive rules live in [Ambitions_3_0_As_Current_Baseline_Policy.md](docs/canon/Ambitions_3_0_As_Current_Baseline_Policy.md), [Ambitions_3_0_Human_Made_Codebase_Standard.md](docs/canon/Ambitions_3_0_Human_Made_Codebase_Standard.md), and [Ambitions_3_0_Active_History_Archive_Policy.md](docs/canon/Ambitions_3_0_Active_History_Archive_Policy.md).

---

## Ambitions 3.0 Codex Performance Operating System

- [Codex Performance Operating System](docs/canon/Ambitions_3_0_Codex_Performance_Operating_System.md)
- [FAANG Team Operating Model](docs/canon/Ambitions_3_0_FAANG_Team_Operating_Model.md)
- [Task Width And Batch Combining Gate](docs/canon/Ambitions_3_0_Task_Width_And_Batch_Combining_Gate.md)
- [UI Test Contract](docs/canon/Ambitions_3_0_UI_Test_Contract.md)
- [Local Toolchain Readiness Matrix](docs/canon/Ambitions_3_0_Local_Toolchain_Readiness_Matrix.md)
- [Definition Of Ready And Done](docs/canon/Ambitions_3_0_Definition_Of_Ready_And_Done.md)
- [Release Claim Truth Protocol](docs/canon/Ambitions_3_0_Release_Claim_Truth_Protocol.md)
- [Ambitions 4.0 Execution Program](docs/canon/Ambitions_4_0_Execution_Program.md)
- [Beyond 3.0 Continuity Rules](docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md)
- [Master Ambitions 3.0 Codex Prompt](docs/codex/MASTER_AMBITIONS_3_0_CODEX_PROMPT.md)
- [Context Loading And Task Routing](docs/codex/AMBITIONS_3_0_CONTEXT_LOADING_AND_TASK_ROUTING.md)
- [Skill System Index](docs/codex/AMBITIONS_3_0_SKILL_SYSTEM_INDEX.md)
- [Run State Protocol](docs/codex/AMBITIONS_3_0_RUN_STATE_PROTOCOL.md)
- [Large Batch And Compact Recovery Protocol](docs/codex/AMBITIONS_3_0_LARGE_BATCH_AND_COMPACT_RECOVERY_PROTOCOL.md)
- [Prompt Quality Rubric](docs/codex/AMBITIONS_3_0_PROMPT_QUALITY_RUBRIC.md)
- [Parallel Codex Worktree Protocol](docs/codex/AMBITIONS_3_0_PARALLEL_CODEX_WORKTREE_PROTOCOL.md)
- [Dependency Management Policy](docs/canon/Ambitions_3_0_Dependency_Management_Policy.md)
- [Mac Codex 5.5 Toolchain Setup](docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md)

## Batch Train Orchestrator

Ambitions 3.0 batch trains are governed by
[docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md](docs/codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md).
The [F17-F30 FAANG Handoff Completion Train](docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md)
is complete and preserved as historical train evidence after F30. F27 is PASS
after the F28 repair/rebaseline, F27.5 is complete with no critical
maintainability blocker, F29 created the final engineer handoff package, and F30
created the Beyond 3.0 continuation plan and final train closeout. Beyond 3.0 is
now represented operationally by the Ambitions 4.0 Execution Program. Release
Evidence Closure is complete through REC06. PX01-PX20 are complete as future
PXOS canon/roadmap evidence; ME, CS, Signature Interface, Product Depth, and AOS remain queued/blocked until
their gates allow execution.

## Product Experience OS Future Canon

[Ambitions Product Experience OS](docs/canon/Ambitions_Product_Experience_OS_Index.md), abbreviated PXOS, is future canon for the user-facing product experience in the Ambitions 4.0 Execution Program. PXOS sits beside AmbitionsOS: AmbitionsOS owns future internal intelligence/runtime architecture; PXOS owns future screens, surfaces, hierarchy, copy, interaction, recovery, trust, visual design, accessibility, and release-safe product messaging. PX01-PX20 are complete as future canon/roadmap evidence; PXOS is not current app implementation.

- [Ambitions 4.0 External Brain Foundation](docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md) - active planned 4.0 expansion scope; not app behavior until EB batch evidence proves it.
