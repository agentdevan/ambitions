# AOS01-AOS30 AmbitionsOS Local Intelligence Train

Status: Future train manifest; not started automatically

Rules: Green may continue only after evidence, report, commit, and push. Yellow/Red stop. Do not touch .github/workflows, add runtime dependencies, retire compatibility seams, create release claims, or implement outside the named scope.

## Batches

- AOS01: AmbitionsOS Canon And Runtime Contract. blocks all AOS work. Owner: Governance / Runtime. Surface: all. Boundary: no implementation; canon/runtime contract only.
- AOS02: Life Graph Event Log Foundation. depends on AOS01. Owner: Life Graph. Surface: Goals/Plan/You. Boundary: event log models only after AOS01.
- AOS03: Graph Delta Review Projection Store. depends on AOS02. Owner: Life Graph. Surface: all projections. Boundary: projection review after AOS02.
- AOS04: Control Plane Work Classifier. depends on AOS01-AOS03. Owner: Control Plane. Surface: all. Boundary: classifier after AOS01-AOS03.
- AOS05: Starting Position Kernel. depends on AOS02-AOS04. Owner: Starting Position. Surface: Goals/You. Boundary: baseline snapshots.
- AOS06: Goal Path Kernel Goal Compiler. depends on AOS05. Owner: Goal Path. Surface: Goals. Boundary: goal compiler.
- AOS07: Local Goal Packs Requirement Slots. depends on AOS06. Owner: Goal Path. Surface: Goals. Boundary: local archetype packs.
- AOS08: Alternate Path Kernel Path Portfolio. depends on AOS05-AOS07. Owner: Alternate Path. Surface: Goal Detail. Boundary: path portfolio.
- AOS09: Option Value North Star. depends on AOS08. Owner: Alternate Path. Surface: Goal Detail/Plan. Boundary: option value.
- AOS10: Commitment Time Kernel. depends on AOS02-AOS04. Owner: Commitment Time. Surface: Plan/Today. Boundary: commitment model.
- AOS11: Reality Drift Bounded Reflow. depends on AOS10 and AOS12. Owner: Reality Drift. Surface: Today/Plan. Boundary: bounded reflow.
- AOS12: Proof Trust Closure Receipts. depends on AOS02-AOS04. Owner: Proof Trust. Surface: Today/Goal Detail/You. Boundary: proof trust.
- AOS13: Source Truth Claim State Machine. depends on AOS02-AOS04. Owner: Source Truth. Surface: You/Goal Detail. Boundary: claim states.
- AOS14: Recommendation Start Here Kernel. depends on AOS04, AOS12, and AOS13. Owner: Recommendation. Surface: Today. Boundary: recommendation kernel.
- AOS15: Local Language Kernel Planning. depends on AOS04, AOS13, AOS14, and deterministic fallback. Owner: Local Language. Surface: Capture/You. Boundary: planning only until fallback.
- AOS16: Performance Energy Kernel. must be active before runtime-heavy implementation. Owner: Performance Energy. Surface: all. Boundary: budgets before runtime-heavy work.
- AOS17: Privacy Safety Kernel. must be active before external/sensitive projection work. Owner: Privacy Safety. Surface: all/external. Boundary: privacy projections.
- AOS18: Evaluation Golden Scenarios. depends on AOS01-AOS17 contracts. Owner: Evaluation. Surface: all. Boundary: fixtures and tests.
- AOS19: Experience Kernel Celestial Cognitive Load. depends on AOS18. Owner: Experience. Surface: all. Boundary: experience system.
- AOS20: Adaptation Kernel Local Personalization. depends on AOS14 and AOS18. Owner: Adaptation. Surface: You/Today/Plan. Boundary: local personalization.
- AOS21: Interoperability Kernel App Intents EventKit Planning. depends on AOS16, AOS17, and interoperability privacy gates. Owner: Interoperability. Surface: external. Boundary: planning only; source verification before implementation.
- AOS22: Longevity Kernel Archive Aging. depends on AOS02, AOS12, and AOS13. Owner: Longevity. Surface: You/Goals. Boundary: archive aging.
- AOS23: Governance Kernel Registry. depends on all kernel contracts. Owner: Governance. Surface: Codex OS. Boundary: registries.
- AOS24: AmbitionsOS UI Integration. depends on AOS18-AOS23. Owner: Experience. Surface: Today/Goals/Capture/Plan/You. Boundary: only after contracts.
- AOS25: AmbitionsOS Test Fixture Library. depends on AOS18 and AOS24. Owner: Evaluation. Surface: tests. Boundary: fixture library.
- AOS26: AmbitionsOS Privacy Performance QA. depends on AOS16, AOS17, AOS18, and AOS25. Owner: Evaluation. Surface: all. Boundary: privacy/performance proof.
- AOS27: AmbitionsOS App Store Claim Truth. depends on AOS26. Owner: Governance. Surface: release docs. Boundary: claim boundary.
- AOS28: AmbitionsOS Handoff. depends on AOS27. Owner: Governance. Surface: handoff. Boundary: handoff only.
- AOS29: AmbitionsOS Repair Train. runs only after failed/Yellow AOS gates are classified. Owner: Governance. Surface: repair. Boundary: only after Yellow/failed gates.
- AOS30: AmbitionsOS Beyond Roadmap. runs only after AOS28 or explicit user decision. Owner: Governance. Surface: roadmap. Boundary: only after AOS28 or explicit decision.
