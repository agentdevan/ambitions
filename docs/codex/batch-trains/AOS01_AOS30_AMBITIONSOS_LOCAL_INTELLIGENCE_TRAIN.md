# AOS01-AOS30 AmbitionsOS Local Intelligence Train

Status: Queued Ambitions 4.0 train manifest; not started; blocked pending `Start AOS Train`.

## Start Rule

This train starts only when the user explicitly approves it after Ambitions 3.0/F17-F30 truth is Green and `docs/codex/BATCH_REGISTRY.md` records the selected train as active. Required user approval phrase: `Start AOS Train`.

## What Does Not Start This Train

Reading this manifest, updating future canon, completing AmbitionsOS docs, finishing F30, or selecting a roadmap lane does not start the train. AOS/ME/CS/Product Depth/Release Evidence Closure do not start each other by implication.

## Historical Truth To Preserve

Ambitions 3.0 is complete by F30 closeout evidence. F17-F30 remains a complete historical train. AmbitionsOS remains future canon until implementation evidence exists. Release, App Store, TestFlight, physical-device, public accessibility, signed archive, App Store Connect, and rendered external-platform claims remain unmade unless a later train produces proof.

## Train Safety Gates

- Batch order is sequential unless this manifest names an explicit dependency exception.
- Green may continue only after evidence, report, registry/context/run-state update, commit, and push.
- Yellow stops unless the manifest says the next batch may proceed with documented risk.
- Red stops immediately and opens a repair or user-decision prompt.
- Build/test requirements are batch-specific: docs-only batches use doc and registry checks; app-code batches require focused tests and advisory build at minimum; release-claim batches require evidence-ledger proof and explicit claim review.
- No second batch starts from this manifest unless the active batch is Green and train rules allow continuation.
- Repair-train triggers: unclassified validation failure, forbidden file drift, claim overreach, privacy/source/compatibility uncertainty, or behavior regression.
- Every batch must be committed before continuation.

## File Boundaries

Allowed files are the files named by each batch prompt. Forbidden across the train: `.github/workflows/**`, dependencies, lockfiles, signing/project release config, persistence/schema files unless a migration batch explicitly owns them, broad app refactors, new top-level navigation, backend/sync/account/telemetry/runtime AI additions, and release/platform claims without evidence.

## Batch Order And Gates

- AOS01: AmbitionsOS Canon And Runtime Contract. Gate: blocks all AOS work. Owner: Governance Kernel / Runtime Contract. Surface: all canonical surfaces. Boundary: docs/protocol only; no app implementation.
- AOS02: Life Graph Event Log Foundation. Gate: depends on AOS01. Owner: Life Graph Kernel. Surface: Goals, Plan, You. Boundary: event log and typed graph foundation only after AOS01.
- AOS03: Graph Delta Review Projection Store. Gate: depends on AOS02. Owner: Life Graph Kernel / Runtime Contract. Surface: all projections. Boundary: graph delta review and projection store contracts only after AOS02.
- AOS04: Control Plane Work Classifier. Gate: depends on AOS01-AOS03. Owner: Control Plane. Surface: all surfaces. Boundary: work classifier, gates, and orchestration contracts only after AOS01-AOS03.
- AOS05: Starting Position Kernel. Gate: depends on AOS02-AOS04. Owner: Starting Position Kernel. Surface: Goals, You. Boundary: baseline snapshot and starting-position projection only.
- AOS06: Goal Path Kernel Goal Compiler. Gate: depends on AOS05. Owner: Goal Path Kernel. Surface: Goals, Goal Detail. Boundary: goal compiler and requirement graph contracts only.
- AOS07: Local Goal Packs Requirement Slots. Gate: depends on AOS06. Owner: Goal Path Kernel. Surface: Goals, Goal Detail. Boundary: local archetype packs and requirement slots only; not official requirement databases.
- AOS08: Alternate Path Kernel Path Portfolio. Gate: depends on AOS05-AOS07. Owner: Alternate Path Kernel. Surface: Goal Detail. Boundary: path portfolio contracts and receipts only.
- AOS09: Option Value North Star. Gate: depends on AOS08. Owner: Alternate Path Kernel / Longevity Kernel. Surface: Goal Detail, Plan. Boundary: North Star preservation and option-value comparison only.
- AOS10: Commitment Time Kernel. Gate: depends on AOS02-AOS04. Owner: Commitment Time Kernel. Surface: Plan, Today. Boundary: commitment model and capacity projection only; no platform calendar implementation.
- AOS11: Reality Drift Bounded Reflow. Gate: depends on AOS10 and AOS12. Owner: Reality Drift Kernel. Surface: Today, Plan. Boundary: bounded reflow contracts only; no silent rescheduling.
- AOS12: Proof Trust Closure Receipts. Gate: depends on AOS02-AOS04. Owner: Proof Trust Kernel. Surface: Today, Goal Detail, You. Boundary: closure, receipt, proof-trust contracts only.
- AOS13: Source Truth Claim State Machine. Gate: depends on AOS02-AOS04. Owner: Source Truth Kernel. Surface: You, Goal Detail. Boundary: claim states and source ledger only; no source certification.
- AOS14: Recommendation Start Here Kernel. Gate: depends on AOS04, AOS12, and AOS13. Owner: Recommendation Kernel. Surface: Today, Goal Detail. Boundary: Start Here recommendation contract only; no confidence scoring.
- AOS15: Local Language Kernel Planning. Gate: depends on AOS04, AOS13, AOS14, and deterministic fallback. Owner: Local Language Kernel. Surface: Capture, You. Boundary: planning and adapter boundaries only; no model runtime before deterministic fallback.
- AOS16: Performance Energy Kernel. Gate: must be active before runtime-heavy implementation. Owner: Performance Energy Kernel. Surface: all surfaces. Boundary: budgets, measurement plan, and scheduler contracts before runtime-heavy work.
- AOS17: Privacy Safety Kernel. Gate: must be active before external/sensitive projection work. Owner: Privacy Safety Kernel. Surface: all surfaces and external projections. Boundary: privacy projection contracts and sensitive-goal boundaries only.
- AOS18: Evaluation Golden Scenarios. Gate: depends on AOS01-AOS17 contracts. Owner: Evaluation Kernel. Surface: test and fixture surfaces. Boundary: golden scenarios, fixtures, and kernel contract tests only.
- AOS19: Experience Kernel Celestial Cognitive Load. Gate: depends on AOS18. Owner: Experience Kernel. Surface: Today, Goals, Capture, Plan, You. Boundary: experience language, cognitive load, and wayfinding contracts only.
- AOS20: Adaptation Kernel Local Personalization. Gate: depends on AOS14 and AOS18. Owner: Adaptation Kernel. Surface: You, Today, Plan. Boundary: local user-controlled calibration only; no hidden personalization.
- AOS21: Interoperability Kernel App Intents EventKit Planning. Gate: depends on AOS16, AOS17, and interoperability privacy gates. Owner: Interoperability Kernel. Surface: external surfaces. Boundary: planning only; source verification required before platform implementation.
- AOS22: Longevity Kernel Archive Aging. Gate: depends on AOS02, AOS12, and AOS13. Owner: Longevity Kernel. Surface: You, Goals. Boundary: archive aging and legacy payload survival contracts only.
- AOS23: Governance Kernel Registry. Gate: depends on all kernel contracts. Owner: Governance Kernel. Surface: Codex OS and docs. Boundary: registries, ownership maps, and train integrity only.
- AOS24: AmbitionsOS UI Integration. Gate: depends on AOS18-AOS23. Owner: Experience Kernel / Control Plane. Surface: Today, Goals, Capture, Plan, You. Boundary: UI integration only after contracts and fixtures prove safe; no new top-level tab.
- AOS25: AmbitionsOS Test Fixture Library. Gate: depends on AOS18 and AOS24. Owner: Evaluation Kernel. Surface: tests and fixtures. Boundary: fixture library and coverage matrix only.
- AOS26: AmbitionsOS Privacy Performance QA. Gate: depends on AOS16, AOS17, AOS18, and AOS25. Owner: Evaluation Kernel / Privacy Safety / Performance Energy. Surface: all affected surfaces. Boundary: privacy and performance QA only; no feature expansion.
- AOS27: AmbitionsOS App Store Claim Truth. Gate: depends on AOS26. Owner: Governance Kernel. Surface: release docs. Boundary: claim-boundary proof only; no readiness claim without evidence.
- AOS28: AmbitionsOS Handoff. Gate: depends on AOS27. Owner: Governance Kernel. Surface: handoff docs. Boundary: handoff package only; no release approval by implication.
- AOS29: AmbitionsOS Repair Train. Gate: runs only after failed/Yellow AOS gates are classified. Owner: Governance Kernel. Surface: repair scope only. Boundary: classified repair only after Yellow/failed AOS gates.
- AOS30: AmbitionsOS Beyond Roadmap. Gate: runs only after AOS28 or explicit user decision. Owner: Governance Kernel. Surface: roadmap docs. Boundary: roadmap continuation only after AOS28 or explicit user decision.

## Validation Matrix

Each batch report must include: command evidence, log paths when available, pass/fail/partial status, what the proof covers, what it does not prove, privacy/accessibility/performance/compatibility/release impacts, rollback/repair path, and next allowed batch.

## Auto-Continuation

Auto-continuation is disabled by default. It is allowed only when the active batch is Green, committed, pushed, and the next batch is the direct successor in this manifest. Yellow or Red requires an explicit repair or user-decision prompt.

## Release Claim Boundary

This train does not create release readiness, App Store readiness, TestFlight readiness, final RC lock, physical-device proof, public accessibility conformance, signed archive validation, App Store Connect validation, or rendered external-platform proof unless a batch explicitly produces and records that evidence.

## Closeout

Closeout requires an audit report, registry/context/run-state updates, evidence ledger entry, diff boundary check, and exact next-user-decision statement. AOS closeout must also update AOS dependency graph, invariant ledger, fixture strategy, release-claim boundary, and failure-forensics path.
