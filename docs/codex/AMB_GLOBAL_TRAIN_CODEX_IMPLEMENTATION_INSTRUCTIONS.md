# Ambitions Global Train Codex Implementation Instructions

Status: Active implementation guide for the 146-record remaining queue
Scope: Prompt-system and execution guidance only; not app implementation proof

## Global Execution Command

```bash
make batch BATCH=PK17 PROMPT=prompts/batches/PK17.md
```

## Batch-level validation entrypoint

- Use wrapper-first validation for all executable batches:

  `scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane <none|build|build-for-testing|focused-test|test-plan|ui-proof|terminal-device-proof> [--test <TEST_ID>] [--test-plan <PLAN_NAME>]`

Raw `xcodebuild` examples in historical batches are retained as historical context only.

Current next batch: PK17 Today Read Model Extraction

## Queue Order

Use `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` as the canonical order. Preserve IDs and order exactly unless active truth files are updated by an approved governance batch.

## Per-Train Execution Gates

- PK: Serial platform kernel execution. Each PK batch must preserve prior PK proof and use focused native source validation.
- SA: Source Atlas execution with provenance, freshness, claim-state, and no unsupported certainty.
- LDI: Living Dream/Plan intelligence execution only after PK and Source Atlas prerequisites, with deterministic local behavior and rollback.
- AOS: AmbitionsOS tail execution through runtime/privacy/evaluation/experience gates, no cloud intelligence.
- FCP: Flagship closeout execution with visual/accessibility/product proof and conservative claims.
- PFC: Platform compliance execution with local proof packets and no release-readiness overclaim.
- RHC: Repo hygiene execution after owner mapping, no broad cleanup pulled early.
- EFC: Proof overlay only; fold into owning executable batches, do not run as broad standalone stream.
- CS: Conditional compatibility seam work only with named regression/proof target and rollback.
- PX: Historical/product-experience canon coverage unless a future approved runnable prompt scopes implementation.

## Per-Batch Instructions

### PK04 - Atomic Goal Creation
Batch ID: PK04
Title: Atomic Goal Creation
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK04 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK04 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk04-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK05

### PK05 - Atomic Clarification / Materialization
Batch ID: PK05
Title: Atomic Clarification / Materialization
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK05 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK05 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk05-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK06

### PK06 - Atomic Capture Promotion
Batch ID: PK06
Title: Atomic Capture Promotion
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK06 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK06 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk06-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK07

### PK07 - Storage Schema Version Ledger
Batch ID: PK07
Title: Storage Schema Version Ledger
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK07 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK07 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk07-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK08

### PK08 - Migration Plan Scaffold
Batch ID: PK08
Title: Migration Plan Scaffold
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK08 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK08 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk08-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK09

### PK09 - Unknown Persisted Value Degradation
Batch ID: PK09
Title: Unknown Persisted Value Degradation
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK09 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK09 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk09-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK10

### PK10 - Storage Invariant Checker
Batch ID: PK10
Title: Storage Invariant Checker
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK10 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK10 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk10-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK11

### PK11 - Pre-Migration Backup
Batch ID: PK11
Title: Pre-Migration Backup
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK11 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK11 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk11-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK12

### PK12 - Staged Portable Import Dry Run
Batch ID: PK12
Title: Staged Portable Import Dry Run
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK12 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK12 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/AmbitionsTests/*Portable*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk12-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK13

### PK13 - Restore Rollback
Batch ID: PK13
Title: Restore Rollback
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK13 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK13 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk13-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK14

### PK14 - Durable Command/Event Ledger
Batch ID: PK14
Title: Durable Command/Event Ledger
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK14 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK14 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk14-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK15

### PK15 - Receipt Backend
Batch ID: PK15
Title: Receipt Backend
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK15 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK15 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk15-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK16

### PK16 - Trust History Query
Batch ID: PK16
Title: Trust History Query
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PK16 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Not runnable from this prompt; preserve as historical, overlay, or conditional metadata unless active truth reauthorizes execution.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PK16 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/pk16-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK17

### PK17 - Today Read Model Extraction
Batch ID: PK17
Title: Today Read Model Extraction
Purpose: Extract a Today read-model boundary from the current Today feature so TodayScreen and Today panels consume a stable projected state instead of owning projection logic inline.
Start condition: Complete prior PK batch PK16 and any data-safety proof named by the PK train.
Primary implementation action: Extract a Today read-model boundary from the current Today feature so TodayScreen and Today panels consume a stable projected state instead of owning projection logic inline.
Files likely involved:
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayExecutionViewState.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Domain/TodayModels.swift`
- `Native/AmbitionsTests/*Today*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `focused Today unit tests or snapshots for the extracted read model`
- `xcodegen generate only if project/source wiring changes`
- `wrapper focused-test lane for Today-owned tests when local simulator tooling is available`
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk17-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK18

### PK18 - Today Command Handler Extraction
Batch ID: PK18
Title: Today Command Handler Extraction
Purpose: Extract Today command handling behind the existing Today action flow while preserving receipt and side-effect boundaries.
Start condition: Complete prior PK batch PK17 and any data-safety proof named by the PK train.
Primary implementation action: Extract Today command handling behind the existing Today action flow while preserving receipt and side-effect boundaries.
Files likely involved:
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/Ambitions/Domain/AmbitionsCommandModels.swift`
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `Native/Ambitions/Domain/EventLedgerModels.swift`
- `Native/AmbitionsTests/*Today*`
- `Native/AmbitionsTests/*Command*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `focused command executor/unit tests for Today commands`
- `receipt/ledger tests for side-effect boundaries`
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk18-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK19

### PK19 - Goals Query/Projector Extraction
Batch ID: PK19
Title: Goals Query/Projector Extraction
Purpose: Extract Goals query/projector boundaries without changing goal semantics, mission-control hierarchy, or adding KPI/productivity-score framing.
Start condition: Complete prior PK batch PK18 and any data-safety proof named by the PK train.
Primary implementation action: Extract Goals query/projector boundaries without changing goal semantics, mission-control hierarchy, or adding KPI/productivity-score framing.
Files likely involved:
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsViewModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Domain/GoalsModels.swift`
- `Native/AmbitionsTests/*Goals*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `focused Goals projector/query tests`
- `focused build/test for Goals owner seam`
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk19-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK20

### PK20 - Capture Service Extraction
Batch ID: PK20
Title: Capture Service Extraction
Purpose: Extract Capture service boundaries while keeping the Capture composer as the primary intake surface.
Start condition: Complete prior PK batch PK19 and any data-safety proof named by the PK train.
Primary implementation action: Extract Capture service boundaries while keeping the Capture composer as the primary intake surface.
Files likely involved:
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
- `Native/Ambitions/Features/Captures/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Captures/CapturePlacementReviewState.swift`
- `Native/Ambitions/Services/CaptureService.swift`
- `Native/Ambitions/Domain/CaptureModels.swift`
- `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- `Native/AmbitionsTests/*Capture*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `focused Capture service/routing tests`
- `focused Capture compile/build validation`
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk20-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK21

### PK21 - Time Service Extraction
Batch ID: PK21
Title: Time Service Extraction
Purpose: Extract the Time service behind the user-facing Time surface while preserving Plan names only as internal compatibility seams.
Start condition: Complete prior PK batch PK20 and any data-safety proof named by the PK train.
Primary implementation action: Extract the Time service behind the user-facing Time surface while preserving Plan names only as internal compatibility seams.
Files likely involved:
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Plan/PlanViewModel.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureModels.swift`
- `Native/Ambitions/Features/Plan/PlanLifeShapeTimeCapacityMap.swift`
- `Native/Ambitions/Domain/Planning/PlanningDomainModels.swift`
- `Native/AmbitionsTests/*Plan*`
- `Native/AmbitionsTests/*Time*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `focused Plan/Time service tests`
- `route/shell smoke only if call sites change`
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk21-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK22

### PK22 - SideEffectLedger Foundation
Batch ID: PK22
Title: SideEffectLedger Foundation
Purpose: Implement SideEffectLedger Foundation in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK21 and any data-safety proof named by the PK train.
Primary implementation action: Implement SideEffectLedger Foundation in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk22-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK23

### PK23 - Notifications Through SideEffectLedger
Batch ID: PK23
Title: Notifications Through SideEffectLedger
Purpose: Implement Notifications Through SideEffectLedger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK22 and any data-safety proof named by the PK train.
Primary implementation action: Implement Notifications Through SideEffectLedger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Notifications/**`
- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/AmbitionsTests/*Notification*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk23-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK24

### PK24 - EventKit Through SideEffectLedger
Batch ID: PK24
Title: EventKit Through SideEffectLedger
Purpose: Implement EventKit Through SideEffectLedger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK23 and any data-safety proof named by the PK train.
Primary implementation action: Implement EventKit Through SideEffectLedger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift`
- `Native/AmbitionsTests/*EventKit*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk24-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK25

### PK25 - External Snapshots Through SideEffectLedger
Batch ID: PK25
Title: External Snapshots Through SideEffectLedger
Purpose: Implement External Snapshots Through SideEffectLedger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK24 and any data-safety proof named by the PK train.
Primary implementation action: Implement External Snapshots Through SideEffectLedger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/ExternalSnapshots/**`
- `Native/Ambitions/Widgets/**`
- `Native/AmbitionsTests/*External*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk25-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK26

### PK26 - Privacy Classification System
Batch ID: PK26
Title: Privacy Classification System
Purpose: Implement Privacy Classification System in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK25 and any data-safety proof named by the PK train.
Primary implementation action: Implement Privacy Classification System in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `docs/status/release-evidence-packet.md`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk26-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK27

### PK27 - Diagnostic Ledger
Batch ID: PK27
Title: Diagnostic Ledger
Purpose: Implement Diagnostic Ledger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK26 and any data-safety proof named by the PK train.
Primary implementation action: Implement Diagnostic Ledger in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/EventLedgerModels.swift`
- `Native/Ambitions/Support/**`
- `Native/AmbitionsTests/*Diagnostic*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk27-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK28

### PK28 - Data Control Commands
Batch ID: PK28
Title: Data Control Commands
Purpose: Implement Data Control Commands in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK27 and any data-safety proof named by the PK train.
Primary implementation action: Implement Data Control Commands in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk28-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK29

### PK29 - Entity Revision And Tombstones
Batch ID: PK29
Title: Entity Revision And Tombstones
Purpose: Implement Entity Revision And Tombstones in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK28 and any data-safety proof named by the PK train.
Primary implementation action: Implement Entity Revision And Tombstones in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk29-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK30

### PK30 - Conflict Policy Engine
Batch ID: PK30
Title: Conflict Policy Engine
Purpose: Implement Conflict Policy Engine in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK29 and any data-safety proof named by the PK train.
Primary implementation action: Implement Conflict Policy Engine in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Persistence/SyncCapabilityContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/AmbitionsTests/*Sync*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk30-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK31

### PK31 - Manual Portable Sync Merge
Batch ID: PK31
Title: Manual Portable Sync Merge
Purpose: Implement Manual Portable Sync Merge in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK30 and any data-safety proof named by the PK train.
Primary implementation action: Implement Manual Portable Sync Merge in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/AmbitionsTests/*Portable*`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk31-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK32

### PK32 - Knowledge Claim Boundary Hardening
Batch ID: PK32
Title: Knowledge Claim Boundary Hardening
Purpose: Implement Knowledge Claim Boundary Hardening in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK31 and any data-safety proof named by the PK train.
Primary implementation action: Implement Knowledge Claim Boundary Hardening in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk32-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK33

### PK33 - Recommendation Evidence Model
Batch ID: PK33
Title: Recommendation Evidence Model
Purpose: Implement Recommendation Evidence Model in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK32 and any data-safety proof named by the PK train.
Primary implementation action: Implement Recommendation Evidence Model in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
- `Native/Ambitions/Services/RecommendationExplanationAdapter.swift`
- `Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk33-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK34

### PK34 - Intelligence Quarantine
Batch ID: PK34
Title: Intelligence Quarantine
Purpose: Implement Intelligence Quarantine in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK33 and any data-safety proof named by the PK train.
Primary implementation action: Implement Intelligence Quarantine in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk34-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK35

### PK35 - Large-Store Fixture Generator
Batch ID: PK35
Title: Large-Store Fixture Generator
Purpose: Implement Large-Store Fixture Generator in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK34 and any data-safety proof named by the PK train.
Primary implementation action: Implement Large-Store Fixture Generator in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk35-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK36

### PK36 - Performance Budgets
Batch ID: PK36
Title: Performance Budgets
Purpose: Implement Performance Budgets in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK35 and any data-safety proof named by the PK train.
Primary implementation action: Implement Performance Budgets in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/AmbitionsOSPerformanceEnergyModels.swift`
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `docs/status/release-evidence-packet.md`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk36-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK37

### PK37 - Derived Read-Model Cache
Batch ID: PK37
Title: Derived Read-Model Cache
Purpose: Implement Derived Read-Model Cache in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK36 and any data-safety proof named by the PK train.
Primary implementation action: Implement Derived Read-Model Cache in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk37-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK38

### PK38 - Move Domain To Package
Batch ID: PK38
Title: Move Domain To Package
Purpose: Implement Move Domain To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK37 and any data-safety proof named by the PK train.
Primary implementation action: Implement Move Domain To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Domain/**`
- `Package.swift only if explicitly approved in that future batch`
- `project.yml only if explicitly approved in that future batch`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk38-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK39

### PK39 - Move Storage To Package
Batch ID: PK39
Title: Move Storage To Package
Purpose: Implement Move Storage To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK38 and any data-safety proof named by the PK train.
Primary implementation action: Implement Move Storage To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Persistence/**`
- `Package.swift only if explicitly approved in that future batch`
- `project.yml only if explicitly approved in that future batch`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk39-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK40

### PK40 - Move Runtime To Package
Batch ID: PK40
Title: Move Runtime To Package
Purpose: Implement Move Runtime To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK39 and any data-safety proof named by the PK train.
Primary implementation action: Implement Move Runtime To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Package.swift only if explicitly approved in that future batch`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk40-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PK41

### PK41 - Move Feature Engines To Package
Batch ID: PK41
Title: Move Feature Engines To Package
Purpose: Implement Move Feature Engines To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Start condition: Complete prior PK batch PK40 and any data-safety proof named by the PK train.
Primary implementation action: Implement Move Feature Engines To Package in the Platform Kernel owner seam, preserving PK serial order, local-first data boundaries, receipts, and compatibility with existing native SwiftUI surfaces.
Files likely involved:
- `Native/Ambitions/Features/**`
- `AppUI/Sources/**`
- `Package.swift only if explicitly approved in that future batch`
- `Native/Ambitions/Domain/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Persistence/**`
- `Native/Ambitions/Features/<owning surface>/**`
- `Native/AmbitionsTests/<focused owner tests>`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/pk41-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA07

### SA07 - Claim State Machine
Batch ID: SA07
Title: Claim State Machine
Purpose: Implement the Source Atlas claim state machine with explicit state transitions, provenance requirements, and conservative non-claim defaults.
Start condition: PK source/storage prerequisites and SA06 completion evidence; do not skip SA in fallback order.
Primary implementation action: Implement the Source Atlas claim state machine with explicit state transitions, provenance requirements, and conservative non-claim defaults.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
- `Native/AmbitionsTests/*Claim*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `Source Atlas claim-state unit tests`
- `source title strict check`
- `forbidden claim scan for changed files`
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa07-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA08

### SA08 - Requirement Graph Implementation
Batch ID: SA08
Title: Requirement Graph Implementation
Purpose: Implement Requirement Graph Implementation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: PK source/storage prerequisites and SA06 completion evidence; do not skip SA in fallback order.
Primary implementation action: Implement Requirement Graph Implementation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa08-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA09

### SA09 - Proof Map Implementation
Batch ID: SA09
Title: Proof Map Implementation
Purpose: Implement Proof Map Implementation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: PK source/storage prerequisites and SA06 completion evidence; do not skip SA in fallback order.
Primary implementation action: Implement Proof Map Implementation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa09-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA10

### SA10 - Freshness And Risk Model Implementation
Batch ID: SA10
Title: Freshness And Risk Model Implementation
Purpose: Implement Source Atlas freshness and risk modeling with conservative currentness, staleness, and source-risk boundaries.
Start condition: PK source/storage prerequisites and SA06 completion evidence; do not skip SA in fallback order.
Primary implementation action: Implement Source Atlas freshness and risk modeling with conservative currentness, staleness, and source-risk boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `docs/codex/SOURCE_ATLAS_HPS_AOS_LDI_INTEGRATION_MAP.md`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
- `Native/AmbitionsTests/*Freshness*`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `freshness/risk model unit tests`
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `forbidden release/claim scan for changed docs`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa10-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA10A

### SA10A - Capability Graph / Level Ladder Implementation
Batch ID: SA10A
Title: Capability Graph / Level Ladder Implementation
Purpose: Implement Capability Graph / Level Ladder Implementation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: SA07-SA10 plus SAP composition/projection gates.
Primary implementation action: Implement Capability Graph / Level Ladder Implementation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa10a-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA10B

### SA10B - Goal Projection Engine Contract
Batch ID: SA10B
Title: Goal Projection Engine Contract
Purpose: Implement Goal Projection Engine Contract in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: SA07-SA10 plus SAP composition/projection gates.
Primary implementation action: Implement Goal Projection Engine Contract in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa10b-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA10C

### SA10C - Projection Fixtures And No-Sprawl Validation
Batch ID: SA10C
Title: Projection Fixtures And No-Sprawl Validation
Purpose: Implement Projection Fixtures And No-Sprawl Validation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: SA07-SA10 plus SAP composition/projection gates.
Primary implementation action: Implement Projection Fixtures And No-Sprawl Validation in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa10c-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA11

### SA11 - Source Atlas Store
Batch ID: SA11
Title: Source Atlas Store
Purpose: Implement Source Atlas Store in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Source Atlas Store in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa11-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA12

### SA12 - Source Atlas Query Engine
Batch ID: SA12
Title: Source Atlas Query Engine
Purpose: Implement Source Atlas Query Engine in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Source Atlas Query Engine in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa12-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA13

### SA13 - Source Needed Mode
Batch ID: SA13
Title: Source Needed Mode
Purpose: Implement Source Needed Mode in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Source Needed Mode in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa13-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA14

### SA14 - Local Impact Matcher
Batch ID: SA14
Title: Local Impact Matcher
Purpose: Implement Local Impact Matcher in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Local Impact Matcher in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa14-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA15

### SA15 - Offline Fallback Runtime
Batch ID: SA15
Title: Offline Fallback Runtime
Purpose: Implement Offline Fallback Runtime in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Offline Fallback Runtime in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa15-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA16

### SA16 - Source Container Model
Batch ID: SA16
Title: Source Container Model
Purpose: Implement Source Container Model in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Source Container Model in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa16-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA17

### SA17 - URL Source Importer
Batch ID: SA17
Title: URL Source Importer
Purpose: Implement URL Source Importer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement URL Source Importer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa17-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA18

### SA18 - Plain Text Importer
Batch ID: SA18
Title: Plain Text Importer
Purpose: Implement Plain Text Importer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Plain Text Importer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa18-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA19

### SA19 - PDF Import Boundary
Batch ID: SA19
Title: PDF Import Boundary
Purpose: Implement PDF Import Boundary in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement PDF Import Boundary in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa19-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA20

### SA20 - PDFKit Text Extraction
Batch ID: SA20
Title: PDFKit Text Extraction
Purpose: Implement PDFKit Text Extraction in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement PDFKit Text Extraction in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa20-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA21

### SA21 - Vision OCR Fallback
Batch ID: SA21
Title: Vision OCR Fallback
Purpose: Implement Vision OCR Fallback in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Vision OCR Fallback in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa21-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA22

### SA22 - Image / Screenshot Importer
Batch ID: SA22
Title: Image / Screenshot Importer
Purpose: Implement Image / Screenshot Importer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Image / Screenshot Importer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa22-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA23

### SA23 - Document Type Classifier
Batch ID: SA23
Title: Document Type Classifier
Purpose: Implement Document Type Classifier in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Document Type Classifier in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa23-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA24

### SA24 - Claim Candidate Extractor
Batch ID: SA24
Title: Claim Candidate Extractor
Purpose: Implement Claim Candidate Extractor in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Claim Candidate Extractor in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa24-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA25

### SA25 - Source Review Sheet / Claim Review Drawer
Batch ID: SA25
Title: Source Review Sheet / Claim Review Drawer
Purpose: Implement Source Review Sheet / Claim Review Drawer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Source Review Sheet / Claim Review Drawer in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa25-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA26

### SA26 - User Mini-Pack Builder
Batch ID: SA26
Title: User Mini-Pack Builder
Purpose: Implement User Mini-Pack Builder in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement User Mini-Pack Builder in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa26-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA27

### SA27 - Pack Factory Lite
Batch ID: SA27
Title: Pack Factory Lite
Purpose: Implement Pack Factory Lite in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Pack Factory Lite in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa27-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA28

### SA28 - Pack Diff / Changed Claim Tooling
Batch ID: SA28
Title: Pack Diff / Changed Claim Tooling
Purpose: Implement Pack Diff / Changed Claim Tooling in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Pack Diff / Changed Claim Tooling in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa28-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA29

### SA29 - Hash / Signature / Revocation Tooling
Batch ID: SA29
Title: Hash / Signature / Revocation Tooling
Purpose: Implement Hash / Signature / Revocation Tooling in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Hash / Signature / Revocation Tooling in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa29-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA30

### SA30 - Freshness Broker Manifest Contract
Batch ID: SA30
Title: Freshness Broker Manifest Contract
Purpose: Implement Freshness Broker Manifest Contract in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Freshness Broker Manifest Contract in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa30-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA31

### SA31 - Official Source Adapter Contracts
Batch ID: SA31
Title: Official Source Adapter Contracts
Purpose: Implement Official Source Adapter Contracts in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Official Source Adapter Contracts in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa31-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: SA32

### SA32 - Source Atlas UI Primitives / QA / Handoff
Batch ID: SA32
Title: Source Atlas UI Primitives / QA / Handoff
Purpose: Implement Source Atlas UI Primitives / QA / Handoff in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Start condition: Prior SA batch, PK storage/privacy prerequisites where touched, and EFC08 where freshness is claimed.
Primary implementation action: Implement Source Atlas UI Primitives / QA / Handoff in the Source Atlas owner seam with explicit source, provenance, freshness, stale/unknown states, and conservative claim boundaries.
Files likely involved:
- `Native/Ambitions/Domain/SourceAtlasPackModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSSourceTruthModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSLivingDreamSourceClaimGraphModels.swift`
- `docs/codex/batch-trains/SA01_SA32_SOURCE_ATLAS_FULL_MATURITY_TRAIN.md`
- `Native/AmbitionsTests/*Source*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`
- `focused Source Atlas unit tests selected from touched files`
Final report path: docs/audits/sa32-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI15

### LDI15 - Living Plan Recompiler
Batch ID: LDI15
Title: Living Plan Recompiler
Purpose: Implement Living Plan Recompiler only after dependency gates prove the required PK transaction/storage and Source Atlas boundaries.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Living Plan Recompiler only after dependency gates prove the required PK transaction/storage and Source Atlas boundaries.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Domain/Planning/PlanningDomainModels.swift`
- `Native/Ambitions/Domain/Planning/DeterministicGoalPlanner.swift`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`
- `Native/AmbitionsTests/*Planning*`
- `Native/AmbitionsTests/*LDI*`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `recompiler preview/rollback unit tests`
- `receipt tests for mutation permissions`
- `wrapper focused-test lane for Plan/Planning tests`
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi15-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI16

### LDI16 - Mutation Permissions And Impact Levels
Batch ID: LDI16
Title: Mutation Permissions And Impact Levels
Purpose: Implement Mutation Permissions And Impact Levels in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Mutation Permissions And Impact Levels in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi16-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI17

### LDI17 - Continuity Sync
Batch ID: LDI17
Title: Continuity Sync
Purpose: Implement Continuity Sync in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Continuity Sync in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi17-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI18

### LDI18 - Archive And Schema Migration
Batch ID: LDI18
Title: Archive And Schema Migration
Purpose: Implement Archive And Schema Migration in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Archive And Schema Migration in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi18-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI19

### LDI19 - Multi-Device Merge Ledger
Batch ID: LDI19
Title: Multi-Device Merge Ledger
Purpose: Implement Multi-Device Merge Ledger in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Multi-Device Merge Ledger in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi19-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI20

### LDI20 - Freshness Broker
Batch ID: LDI20
Title: Freshness Broker
Purpose: Implement Freshness Broker in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Freshness Broker in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi20-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI21

### LDI21 - Red-Team Evaluation Suite
Batch ID: LDI21
Title: Red-Team Evaluation Suite
Purpose: Implement Red-Team Evaluation Suite in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Red-Team Evaluation Suite in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi21-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: LDI22

### LDI22 - Governance And Maintenance Console
Batch ID: LDI22
Title: Governance And Maintenance Console
Purpose: Implement Governance And Maintenance Console in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Start condition: Relevant PK transaction/storage/side-effect/privacy proof plus Source Atlas SA07-SA32 where source/freshness or changed claims are used.
Primary implementation action: Implement Governance And Maintenance Console in the Living Dream/Plan intelligence owner seam with deterministic local logic, visible mutation permission, rollback, and receipt proof.
Files likely involved:
- `docs/codex/batch-trains/LDI01_LDI22_LIVING_DREAM_INTELLIGENCE_TRAIN.md`
- `Native/Ambitions/Domain/Planning/**`
- `Native/Ambitions/Features/Plan/**`
- `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`
- `Native/AmbitionsTests/*Planning*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/ldi22-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: AOS24

### AOS24 - AmbitionsOS Runtime Tail Gate
Batch ID: AOS24
Title: AmbitionsOS Runtime Tail Gate
Purpose: Implement AmbitionsOS Runtime Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Start condition: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
Primary implementation action: Implement AmbitionsOS Runtime Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Files likely involved:
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/aos24-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: AOS25

### AOS25 - AmbitionsOS Integration Tail Gate
Batch ID: AOS25
Title: AmbitionsOS Integration Tail Gate
Purpose: Implement AmbitionsOS Integration Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Start condition: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
Primary implementation action: Implement AmbitionsOS Integration Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Files likely involved:
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/aos25-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: AOS26

### AOS26 - AmbitionsOS Evaluation Tail Gate
Batch ID: AOS26
Title: AmbitionsOS Evaluation Tail Gate
Purpose: Implement AmbitionsOS Evaluation Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Start condition: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
Primary implementation action: Implement AmbitionsOS Evaluation Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Files likely involved:
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/aos26-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: AOS27

### AOS27 - AmbitionsOS Privacy Safety Tail Gate
Batch ID: AOS27
Title: AmbitionsOS Privacy Safety Tail Gate
Purpose: Implement AmbitionsOS Privacy Safety Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Start condition: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
Primary implementation action: Implement AmbitionsOS Privacy Safety Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Files likely involved:
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `docs/status/release-evidence-packet.md`
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/aos27-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: AOS28

### AOS28 - AmbitionsOS Experience Tail Gate
Batch ID: AOS28
Title: AmbitionsOS Experience Tail Gate
Purpose: Implement AmbitionsOS Experience Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Start condition: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
Primary implementation action: Implement AmbitionsOS Experience Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Files likely involved:
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/aos28-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: AOS29

### AOS29 - AmbitionsOS Handoff Tail Gate
Batch ID: AOS29
Title: AmbitionsOS Handoff Tail Gate
Purpose: Implement AmbitionsOS Handoff Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Start condition: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
Primary implementation action: Implement AmbitionsOS Handoff Tail Gate as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Files likely involved:
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/aos29-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: AOS30

### AOS30 - AmbitionsOS Closeout
Batch ID: AOS30
Title: AmbitionsOS Closeout
Purpose: Implement AmbitionsOS Closeout as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Start condition: Complete source/freshness dependencies, PK intelligence/data-control gates, and owner-specific LDI proof where applicable.
Primary implementation action: Implement AmbitionsOS Closeout as an AmbitionsOS tail gate, proving runtime/privacy/evaluation/experience obligations without widening into app redesign or cloud intelligence.
Files likely involved:
- `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_PROMPT.md`
- `Native/Ambitions/Domain/AmbitionsOS*.swift`
- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/AmbitionsTests/*AmbitionsOS*`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `xcodegen generate if source/project wiring requires it`
- `wrapper focused-test lane for touched owner seam`
Final report path: docs/audits/aos30-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: FCP27

### FCP27 - App-Wide Flagship Audit And Remediation
Batch ID: FCP27
Title: App-Wide Flagship Audit And Remediation
Purpose: Implement App-Wide Flagship Audit And Remediation as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Start condition: Earlier FCP object maturity, FVQ rendered proof, accessibility and release-claim boundaries.
Primary implementation action: Implement App-Wide Flagship Audit And Remediation as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Files likely involved:
- `Native/Ambitions/App/**`
- `Native/Ambitions/Features/**`
- `Native/Ambitions/UI/**`
- `AppUI/Sources/**`
- `docs/audits/fcp*-report.md`
- `Native/AmbitionsUITests/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/fcp27-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: FCP28

### FCP28 - Final Visual Proof Packet
Batch ID: FCP28
Title: Final Visual Proof Packet
Purpose: Implement Final Visual Proof Packet as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Start condition: Earlier FCP object maturity, FVQ rendered proof, accessibility and release-claim boundaries.
Primary implementation action: Implement Final Visual Proof Packet as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Files likely involved:
- `Native/Ambitions/App/**`
- `Native/Ambitions/Features/**`
- `Native/Ambitions/UI/**`
- `AppUI/Sources/**`
- `docs/audits/fcp*-report.md`
- `Native/AmbitionsUITests/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/fcp28-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: FCP29

### FCP29 - Accessibility And Dynamic Type Closeout
Batch ID: FCP29
Title: Accessibility And Dynamic Type Closeout
Purpose: Implement Accessibility And Dynamic Type Closeout as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Start condition: Earlier FCP object maturity, FVQ rendered proof, accessibility and release-claim boundaries.
Primary implementation action: Implement Accessibility And Dynamic Type Closeout as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Files likely involved:
- `Native/Ambitions/Features/**`
- `AppUI/Sources/**`
- `Native/AmbitionsUITests/**`
- `docs/audits/*accessibility*`
- `Native/Ambitions/App/**`
- `Native/Ambitions/UI/**`
- `docs/audits/fcp*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/fcp29-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: FCP30

### FCP30 - Flagship Completion Handoff
Batch ID: FCP30
Title: Flagship Completion Handoff
Purpose: Implement Flagship Completion Handoff as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Start condition: Earlier FCP object maturity, FVQ rendered proof, accessibility and release-claim boundaries.
Primary implementation action: Implement Flagship Completion Handoff as a flagship closeout batch with source-backed UI/accessibility/visual proof and conservative release claim boundaries.
Files likely involved:
- `Native/Ambitions/App/**`
- `Native/Ambitions/Features/**`
- `Native/Ambitions/UI/**`
- `AppUI/Sources/**`
- `docs/audits/fcp*-report.md`
- `Native/AmbitionsUITests/**`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/fcp30-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC31

### PFC31 - Architecture Extraction Closeout
Batch ID: PFC31
Title: Architecture Extraction Closeout
Purpose: Implement Architecture Extraction Closeout as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Architecture Extraction Closeout as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc31-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC32

### PFC32 - Build And Test Determinism Closeout
Batch ID: PFC32
Title: Build And Test Determinism Closeout
Purpose: Implement Build And Test Determinism Closeout as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Build And Test Determinism Closeout as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc32-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC33

### PFC33 - External Surface Release Evidence
Batch ID: PFC33
Title: External Surface Release Evidence
Purpose: Implement External Surface Release Evidence as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement External Surface Release Evidence as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc33-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC34

### PFC34 - Privacy Legal Review Reconciliation
Batch ID: PFC34
Title: Privacy Legal Review Reconciliation
Purpose: Implement Privacy Legal Review Reconciliation as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Privacy Legal Review Reconciliation as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `docs/status/release-evidence-packet.md`
- `docs/audits/pfc24-privacy-data-map-app-privacy-labels-report.md`
- `docs/audits/pfc25-privacy-manifest-required-reason-api-audit-report.md`
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc34-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC35

### PFC35 - Security And Threat Model Reconciliation
Batch ID: PFC35
Title: Security And Threat Model Reconciliation
Purpose: Implement Security And Threat Model Reconciliation as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Security And Threat Model Reconciliation as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc35-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC36

### PFC36 - Performance And Observability Reconciliation
Batch ID: PFC36
Title: Performance And Observability Reconciliation
Purpose: Implement Performance And Observability Reconciliation as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Performance And Observability Reconciliation as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `Native/Ambitions/Domain/AmbitionsOSPerformanceEnergyModels.swift`
- `Native/Ambitions/Support/ReleasePerformanceResponsivenessReport.swift`
- `docs/status/release-evidence-packet.md`
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc36-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC37

### PFC37 - Release Engineering Evidence
Batch ID: PFC37
Title: Release Engineering Evidence
Purpose: Implement Release Engineering Evidence as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Release Engineering Evidence as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `scripts/build-local.sh`
- `output/logs/** proof artifacts`
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc37-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC38

### PFC38 - Signed Candidate Preparation Gate
Batch ID: PFC38
Title: Signed Candidate Preparation Gate
Purpose: Implement Signed Candidate Preparation Gate as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Signed Candidate Preparation Gate as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `output/logs/** archive proof artifacts; do not create signing automation without approval`
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc38-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC39

### PFC39 - Final Platform Handoff
Batch ID: PFC39
Title: Final Platform Handoff
Purpose: Implement Final Platform Handoff as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Final Platform Handoff as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc39-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PFC40

### PFC40 - Platform Framework Compliance Closeout
Batch ID: PFC40
Title: Platform Framework Compliance Closeout
Purpose: Implement Platform Framework Compliance Closeout as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Start condition: Relevant PK/FCP/FVQ/EFC proof and human/legal/device gates where named.
Primary implementation action: Implement Platform Framework Compliance Closeout as platform-framework compliance work with local validation evidence, proof packet updates, and no release/readiness overclaim.
Files likely involved:
- `project.yml only if explicitly scoped by the PFC prompt`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy for privacy batches only`
- `Native/Ambitions/Support/Ambitions.entitlements for entitlement batches only`
- `docs/native-build-and-release.md`
- `docs/status/release-evidence-packet.md`
- `scripts/** validation helpers`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `local proof command named by docs/native-build-and-release.md or release packet`
- `wrapper ui-proof lane only when source/UI is touched`
Final report path: docs/audits/pfc40-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: RHC01

### RHC01 - Repo Hygiene Triage And Owner Map
Batch ID: RHC01
Title: Repo Hygiene Triage And Owner Map
Purpose: Perform repo hygiene triage and owner mapping only; create a scoped cleanup map without deleting or broad-refactoring production source.
Start condition: Run after LDI/AOS/FCP/PFC tails unless a hygiene Hard Red blocks active work.
Primary implementation action: Perform repo hygiene triage and owner mapping only; create a scoped cleanup map without deleting or broad-refactoring production source.
Files likely involved:
- `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md`
- `docs/status/repo-cleanup-index.md`
- `docs/audits/rhc01-batch-closeout-report.md`
- `scripts/ambitions-prompt-audit.sh`
- `scripts/*scan*.sh`
- `prompts/**`
- `docs/audits/rhc*-batch-closeout-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
- `repo hygiene scan commands named by the RHC manifest`
- `targeted hygiene/scan command named by the changed script/doc`
Final report path: docs/audits/rhc01-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: RHC02

### RHC02 - Large File Extraction And Module Boundary
Batch ID: RHC02
Title: Large File Extraction And Module Boundary
Purpose: Implement Large File Extraction And Module Boundary as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Start condition: Run after LDI/AOS/FCP/PFC tails unless a hygiene Hard Red blocks active work.
Primary implementation action: Implement Large File Extraction And Module Boundary as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Files likely involved:
- `docs/status/repo-cleanup-index.md`
- `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md`
- `scripts/*scan*.sh`
- `prompts/**`
- `docs/audits/rhc*-batch-closeout-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
- `targeted hygiene/scan command named by the changed script/doc`
Final report path: docs/audits/rhc02-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: RHC03

### RHC03 - Placeholder Stub And Compatibility Seam Cleanup
Batch ID: RHC03
Title: Placeholder Stub And Compatibility Seam Cleanup
Purpose: Implement Placeholder Stub And Compatibility Seam Cleanup as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Start condition: Run after LDI/AOS/FCP/PFC tails unless a hygiene Hard Red blocks active work.
Primary implementation action: Implement Placeholder Stub And Compatibility Seam Cleanup as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Files likely involved:
- `docs/status/repo-cleanup-index.md`
- `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md`
- `scripts/*scan*.sh`
- `prompts/**`
- `docs/audits/rhc*-batch-closeout-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
- `targeted hygiene/scan command named by the changed script/doc`
Final report path: docs/audits/rhc03-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: RHC04

### RHC04 - Stale Copy Docs And Generated Artifact Hygiene
Batch ID: RHC04
Title: Stale Copy Docs And Generated Artifact Hygiene
Purpose: Implement Stale Copy Docs And Generated Artifact Hygiene as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Start condition: Run after LDI/AOS/FCP/PFC tails unless a hygiene Hard Red blocks active work.
Primary implementation action: Implement Stale Copy Docs And Generated Artifact Hygiene as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Files likely involved:
- `docs/status/repo-cleanup-index.md`
- `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md`
- `scripts/*scan*.sh`
- `prompts/**`
- `docs/audits/rhc*-batch-closeout-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
- `targeted hygiene/scan command named by the changed script/doc`
Final report path: docs/audits/rhc04-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: RHC05

### RHC05 - Validation Script Noise And Allowlist Hardening
Batch ID: RHC05
Title: Validation Script Noise And Allowlist Hardening
Purpose: Implement Validation Script Noise And Allowlist Hardening as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Start condition: Run after LDI/AOS/FCP/PFC tails unless a hygiene Hard Red blocks active work.
Primary implementation action: Implement Validation Script Noise And Allowlist Hardening as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Files likely involved:
- `docs/status/repo-cleanup-index.md`
- `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md`
- `scripts/*scan*.sh`
- `prompts/**`
- `docs/audits/rhc*-batch-closeout-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
- `targeted hygiene/scan command named by the changed script/doc`
Final report path: docs/audits/rhc05-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: RHC06

### RHC06 - Repo Hygiene Closeout And Handoff
Batch ID: RHC06
Title: Repo Hygiene Closeout And Handoff
Purpose: Implement Repo Hygiene Closeout And Handoff as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Start condition: Run after LDI/AOS/FCP/PFC tails unless a hygiene Hard Red blocks active work.
Primary implementation action: Implement Repo Hygiene Closeout And Handoff as owner-mapped repo hygiene only; classify and repair the named seam without broad cleanup or production behavior drift.
Files likely involved:
- `docs/status/repo-cleanup-index.md`
- `docs/codex/batch-trains/RHC01_RHC06_REPO_HYGIENE_CLOSEOUT_TRAIN.md`
- `scripts/*scan*.sh`
- `prompts/**`
- `docs/audits/rhc*-batch-closeout-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
- `targeted hygiene/scan command named by the changed script/doc`
Final report path: docs/audits/rhc06-batch-closeout-report.md
Green definition: owned source/docs changes pass focused validation, proof is current, and no forbidden claims or scope drift remain.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC01

### EFC01 - Private Product Evidence Engine
Batch ID: EFC01
Title: Private Product Evidence Engine
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC01 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC01 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc01-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC02

### EFC02 - First Useful Object Onboarding
Batch ID: EFC02
Title: First Useful Object Onboarding
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC02 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC02 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc02-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC03

### EFC03 - First 30 Days Lifecycle And Retention Proof
Batch ID: EFC03
Title: First 30 Days Lifecycle And Retention Proof
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC03 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC03 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc03-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC04

### EFC04 - Time Physics Edge Case Lab
Batch ID: EFC04
Title: Time Physics Edge Case Lab
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC04 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC04 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc04-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC05

### EFC05 - Recommendation Court Integration Gate
Batch ID: EFC05
Title: Recommendation Court Integration Gate
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC05 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC05 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
- `Native/Ambitions/Services/RecommendationExplanationAdapter.swift`
- `Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc05-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC06

### EFC06 - Goal Thermodynamics And Drift Handling
Batch ID: EFC06
Title: Goal Thermodynamics And Drift Handling
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC06 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC06 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc06-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC07

### EFC07 - Ambitions Twin Fixture Library
Batch ID: EFC07
Title: Ambitions Twin Fixture Library
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC07 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC07 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc07-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC08

### EFC08 - Source Freshness Commons And Operations
Batch ID: EFC08
Title: Source Freshness Commons And Operations
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC08 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC08 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc08-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC09

### EFC09 - Accessibility Shadow Surface System
Batch ID: EFC09
Title: Accessibility Shadow Surface System
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC09 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC09 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Features/**`
- `AppUI/Sources/**`
- `Native/AmbitionsUITests/**`
- `docs/audits/*accessibility*`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc09-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC10

### EFC10 - Real Device Proof Lab
Batch ID: EFC10
Title: Real Device Proof Lab
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC10 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC10 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc10-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC11

### EFC11 - Privacy-Safe Observability And Support Pack
Batch ID: EFC11
Title: Privacy-Safe Observability And Support Pack
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC11 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC11 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/AmbitionsOSPrivacySafetyModels.swift`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `docs/status/release-evidence-packet.md`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc11-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC12

### EFC12 - Data Control And Proof Portability Vault
Batch ID: EFC12
Title: Data Control And Proof Portability Vault
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC12 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC12 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/**`
- `Native/Ambitions/Persistence/**`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc12-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC13

### EFC13 - Notification Cadence Governor
Batch ID: EFC13
Title: Notification Cadence Governor
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC13 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC13 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Notifications/**`
- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/AmbitionsTests/*Notification*`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc13-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC14

### EFC14 - Local Language Quality Benchmark
Batch ID: EFC14
Title: Local Language Quality Benchmark
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC14 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC14 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc14-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC15

### EFC15 - Localization And Globalization Readiness
Batch ID: EFC15
Title: Localization And Globalization Readiness
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC15 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC15 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc15-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC16

### EFC16 - Release Truth Machine
Batch ID: EFC16
Title: Release Truth Machine
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC16 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC16 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc16-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC17

### EFC17 - App Store Creative And Reviewer Package
Batch ID: EFC17
Title: App Store Creative And Reviewer Package
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC17 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC17 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc17-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: EFC18

### EFC18 - Anti-Ceremony Compiler
Batch ID: EFC18
Title: Anti-Ceremony Compiler
Purpose: Do not execute implementation from this absorbed_as_overlay record; preserve EFC18 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Existing owner batch must declare invoked/not applicable/accepted Yellow.
Primary implementation action: Do not execute implementation from this absorbed_as_overlay record; preserve EFC18 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/batch-trains/EFC00_EFC18_FLAGSHIP_PROOF_CLOSURE_OVERLAY.md`
- `docs/audits/efc*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/efc18-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: CS02C

### CS02C - CSCS02C
Batch ID: CS02C
Title: CSCS02C
Purpose: Do not execute implementation from this conditional_trigger_only record; preserve CS02C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Named regression/proof target, owner, rollback plan, and focused tests.
Primary implementation action: Do not execute implementation from this conditional_trigger_only record; preserve CS02C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `Native/Ambitions/App/AppTab.swift only in an approved CS seam batch`
- `Native/Ambitions/App/AmbitionsRootView.swift only in an approved CS seam batch`
- `docs/audits/cs*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/cs02c-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: CS03C

### CS03C - CSCS03C
Batch ID: CS03C
Title: CSCS03C
Purpose: Do not execute implementation from this conditional_trigger_only record; preserve CS03C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Named regression/proof target, owner, rollback plan, and focused tests.
Primary implementation action: Do not execute implementation from this conditional_trigger_only record; preserve CS03C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `Native/Ambitions/App/AppTab.swift only in an approved CS seam batch`
- `Native/Ambitions/App/AmbitionsRootView.swift only in an approved CS seam batch`
- `docs/audits/cs*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/cs03c-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: CS04C

### CS04C - CSCS04C
Batch ID: CS04C
Title: CSCS04C
Purpose: Do not execute implementation from this conditional_trigger_only record; preserve CS04C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Named regression/proof target, owner, rollback plan, and focused tests.
Primary implementation action: Do not execute implementation from this conditional_trigger_only record; preserve CS04C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `Native/Ambitions/App/AppTab.swift only in an approved CS seam batch`
- `Native/Ambitions/App/AmbitionsRootView.swift only in an approved CS seam batch`
- `docs/audits/cs*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/cs04c-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: CS05C

### CS05C - CSCS05C
Batch ID: CS05C
Title: CSCS05C
Purpose: Do not execute implementation from this conditional_trigger_only record; preserve CS05C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Named regression/proof target, owner, rollback plan, and focused tests.
Primary implementation action: Do not execute implementation from this conditional_trigger_only record; preserve CS05C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `Native/Ambitions/App/AppTab.swift only in an approved CS seam batch`
- `Native/Ambitions/App/AmbitionsRootView.swift only in an approved CS seam batch`
- `docs/audits/cs*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/cs05c-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: CS06C

### CS06C - CSCS06C
Batch ID: CS06C
Title: CSCS06C
Purpose: Do not execute implementation from this conditional_trigger_only record; preserve CS06C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Named regression/proof target, owner, rollback plan, and focused tests.
Primary implementation action: Do not execute implementation from this conditional_trigger_only record; preserve CS06C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `Native/Ambitions/App/AppTab.swift only in an approved CS seam batch`
- `Native/Ambitions/App/AmbitionsRootView.swift only in an approved CS seam batch`
- `docs/audits/cs*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/cs06c-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: CS09C

### CS09C - CSCS09C
Batch ID: CS09C
Title: CSCS09C
Purpose: Do not execute implementation from this conditional_trigger_only record; preserve CS09C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Named regression/proof target, owner, rollback plan, and focused tests.
Primary implementation action: Do not execute implementation from this conditional_trigger_only record; preserve CS09C as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`
- `Native/Ambitions/App/AppTab.swift only in an approved CS seam batch`
- `Native/Ambitions/App/AmbitionsRootView.swift only in an approved CS seam batch`
- `docs/audits/cs*-report.md`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/cs09c-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX01

### PX01 - PXOS Parent Canon
Batch ID: PX01
Title: PXOS Parent Canon
Purpose: Keep PXOS Parent Canon as historical/do-not-run coverage; do not execute implementation from this prompt unless a future approved PX train reactivation changes active truth.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Keep PXOS Parent Canon as historical/do-not-run coverage; do not execute implementation from this prompt unless a future approved PX train reactivation changes active truth.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/audits/px01-product-experience-os-canon-surface-hierarchy-report.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `metadata validation only`
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px01-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX02

### PX02 - Today Experience Canon
Batch ID: PX02
Title: Today Experience Canon
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX02 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX02 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px02-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX03

### PX03 - Goals Mission Control Canon
Batch ID: PX03
Title: Goals Mission Control Canon
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX03 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX03 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px03-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX04

### PX04 - Capture Experience Canon
Batch ID: PX04
Title: Capture Experience Canon
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX04 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX04 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px04-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX05

### PX05 - Plan Life Shape Canon
Batch ID: PX05
Title: Plan Life Shape Canon
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX05 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX05 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px05-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX06

### PX06 - You Personal System Center Canon
Batch ID: PX06
Title: You Personal System Center Canon
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX06 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX06 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px06-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX07

### PX07 - Action Closure Recovery Canon
Batch ID: PX07
Title: Action Closure Recovery Canon
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX07 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX07 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px07-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX08

### PX08 - Trust Proof Receipts Canon
Batch ID: PX08
Title: Trust Proof Receipts Canon
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX08 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX08 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px08-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX09

### PX09 - Copy Language And Explanation System
Batch ID: PX09
Title: Copy Language And Explanation System
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX09 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX09 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px09-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX10

### PX10 - Visual Interaction System
Batch ID: PX10
Title: Visual Interaction System
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX10 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX10 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px10-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX11

### PX11 - Onboarding Setup And Personalization
Batch ID: PX11
Title: Onboarding Setup And Personalization
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX11 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX11 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px11-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX12

### PX12 - Accessibility Cognitive Load And Emotional Safety
Batch ID: PX12
Title: Accessibility Cognitive Load And Emotional Safety
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX12 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX12 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `Native/Ambitions/Features/**`
- `AppUI/Sources/**`
- `Native/AmbitionsUITests/**`
- `docs/audits/*accessibility*`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px12-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX13

### PX13 - Empty Edge And Degraded States
Batch ID: PX13
Title: Empty Edge And Degraded States
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX13 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX13 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px13-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX14

### PX14 - Product Depth And Drilldown Rules
Batch ID: PX14
Title: Product Depth And Drilldown Rules
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX14 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX14 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px14-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX15

### PX15 - Cross Surface Continuity System
Batch ID: PX15
Title: Cross Surface Continuity System
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX15 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX15 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px15-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX16

### PX16 - User-Facing Intelligence Expression
Batch ID: PX16
Title: User-Facing Intelligence Expression
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX16 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX16 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px16-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX17

### PX17 - Release Safe Product Messaging
Batch ID: PX17
Title: Release Safe Product Messaging
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX17 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX17 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px17-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX18

### PX18 - Implementation Readiness Reorder
Batch ID: PX18
Title: Implementation Readiness Reorder
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX18 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX18 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px18-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX19

### PX19 - PXOS Handoff
Batch ID: PX19
Title: PXOS Handoff
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX19 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX19 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px19-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: PX20

### PX20 - PXOS Beyond Roadmap
Batch ID: PX20
Title: PXOS Beyond Roadmap
Purpose: Do not execute implementation from this historical_complete_do_not_run record; preserve PX20 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Start condition: Only a new explicitly approved PXOS implementation train can create runnable PX work.
Primary implementation action: Do not execute implementation from this historical_complete_do_not_run record; preserve PX20 as canonical coverage and use it only as historical, overlay, or conditional metadata until active truth reauthorizes it.
Files likely involved:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/batch-trains/PX01_PX20_PRODUCT_EXPERIENCE_OS_TRAIN.md`
- `docs/codex/PXOS_DEFINITION_OF_READY_DONE.md`
- `docs/audits/px*-report.md`
- `Native/Ambitions/Features/<surface>/** only if a future runnable PX implementation prompt scopes it`
Files forbidden:
- Native/AppUI/Sources outside owner seam
- Package.swift unless explicitly scoped
- project.yml unless explicitly scoped
- .github/**
- signing/entitlements/generated Xcode/release automation unless explicitly scoped
- hosted backend or external/cloud LLM core paths
Tests/proof required:
- `make prompt-audit`
- `make batch-self-check`
Final report path: docs/audits/px20-batch-closeout-report.md
Green definition: metadata coverage remains correct and no implementation is executed.
Accepted Yellow allowance: environment/proof blocker only, with owner, no-claim boundary, and next proof path; not allowed for queue corruption or release overclaim.
Red stop: dependency failure, forbidden scope mutation, invalid JSON/queue corruption, Plan top-level restoration, cloud LLM core authorization, or proof/claim mismatch.
Next handoff: terminal / none

## Validation Map

- `git status --short`
- `git diff --check`
- `make prompt-audit`
- `make batch-self-check`
- `scripts/codex-forbidden-claim-scan.sh <changed files> 2>/dev/null || true`
- `python3 scripts/ambitions-queue-snapshot.py`
- `python3 scripts/ambitions-control-plane-check.py`
- `python3 scripts/ambitions-source-atlas-title-check.py --strict`

## Recovery Protocol

Stop on Hard Red, preserve logs, avoid broad reset, and repair only the owner seam named by the failing batch. Use path-limited restore/clean for rollback and never discard unrelated user work.

## Accepted Yellow Retirement Protocol

Accepted Yellow must name owner, blocker, no-claim boundary, next validation path, and whether continuation is allowed. Retire the Yellow only after current local proof closes the blocker.

## Stop Conditions

Stop for queue corruption, completed-batch reactivation, invalid JSON, production source mutation outside scope, unsupported release/readiness claims, DPTG terminal-rule violation, external/cloud LLM core authorization, or Plan top-level restoration.

## Rollback Expectations

Every batch report must list changed files and a path-limited rollback. Rollback must preserve completed-batch evidence, historical reports, and unrelated user work.

## No-Claim Policy

No batch may claim app behavior, global train completion, release readiness, TestFlight/App Store readiness, device proof, public accessibility conformance, performance validation, privacy/legal approval, production readiness, hosted CI proof, or cloud/sync readiness without current proof artifacts.
