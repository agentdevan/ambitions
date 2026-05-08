# Ambitions Docs

This folder contains product, canon, implementation, build, release, audit, and Codex documentation for the native SwiftUI Ambitions app.

## Start here

Use this read order for current work:

1. [AmbitionsCanon/README.md](AmbitionsCanon/README.md) — active product and design source truth.
2. [status/current-implementation-map.md](status/current-implementation-map.md) — current implemented, scaffolded, planned, and historical status.
3. [status/repo-cleanup-index.md](status/repo-cleanup-index.md) — cleanup, quarantine, and hosted-CI cost policy.
4. [status/release-evidence-packet.md](status/release-evidence-packet.md) — local validation and release evidence posture.
5. [native-build-and-release.md](native-build-and-release.md) — local VM/Mac build, test, archive, and release-validation workflow.
6. [../AGENTS.md](../AGENTS.md) — AI/Codex contributor rules.

## Current posture

- The current app is the native SwiftUI target under `Native/Ambitions/`.
- The app is local-first / on-device first where implemented.
- Validation is local VM/Mac validation only.
- There is no active hosted CI workflow in this repo.
- The repo no longer has an active TypeScript / Expo / React Native runtime path.
- Sync, auth, account backend flows, TestFlight readiness, App Store readiness, physical-device proof, public accessibility conformance, legal/privacy signoff, and human release approval are not current claims.

## Active source-truth package

Use [AmbitionsCanon/README.md](AmbitionsCanon/README.md) for future Ambitions product, visual, shell, chrome, IA, Signature Object, trust, accessibility, QA, token/material, and implementation-planning work.

Older Ambitions 3.0, 4.0, PXOS, SI, handoff, audit, and Codex train docs remain historical/supporting context or stricter proof gates where compatible. They do not override the Ambitions Design System or AmbitionsCanon pack where conflicts exist.

## Status and evidence docs

- [status/current-implementation-map.md](status/current-implementation-map.md)
- [status/repo-cleanup-index.md](status/repo-cleanup-index.md)
- [status/release-evidence-packet.md](status/release-evidence-packet.md)

## Native build and release docs

- [native-build-and-release.md](native-build-and-release.md)
- [handoff/Ambitions_3_0_Testing_And_Release_Proof.md](handoff/Ambitions_3_0_Testing_And_Release_Proof.md)
- [marketing/Ambitions_3_0_App_Store_Truth_Packet.md](marketing/Ambitions_3_0_App_Store_Truth_Packet.md)
- [codex/Launch_Operator_Runbook.md](codex/Launch_Operator_Runbook.md)
- [codex/Release_Candidate_Review_Checklist.md](codex/Release_Candidate_Review_Checklist.md)

These files are useful only to the extent their claims match the current release evidence packet.

## Product/design canon package

- [AmbitionsCanon/Ambitions_Design_System.md](AmbitionsCanon/Ambitions_Design_System.md)
- [AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md](AmbitionsCanon/00_Canon_Index_10_10_Maturity_Gate.md)
- [AmbitionsCanon/01_Product_Canon.md](AmbitionsCanon/01_Product_Canon.md)
- [AmbitionsCanon/02_Continuity_Layer_Chrome.md](AmbitionsCanon/02_Continuity_Layer_Chrome.md)
- [AmbitionsCanon/03_Signature_Object_Specs.md](AmbitionsCanon/03_Signature_Object_Specs.md)
- [AmbitionsCanon/04_Trust_Privacy_Automation.md](AmbitionsCanon/04_Trust_Privacy_Automation.md)
- [AmbitionsCanon/05_Accessibility_Motion_Performance.md](AmbitionsCanon/05_Accessibility_Motion_Performance.md)
- [AmbitionsCanon/06_QA_Preview_Visual_Drift.md](AmbitionsCanon/06_QA_Preview_Visual_Drift.md)
- [AmbitionsCanon/07_Native_Shell_Tokens_Materials.md](AmbitionsCanon/07_Native_Shell_Tokens_Materials.md)
- [AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md](AmbitionsCanon/08_Implementation_Codex_Repo_Integration.md)

## Historical/supporting docs

The repo retains older docs for traceability, audit evidence, and Codex continuity. Treat them as historical/supporting unless explicitly elevated by the active canon or current implementation map.

Common historical/supporting areas:

- `docs/canon/`
- `docs/codex/`
- `docs/audits/`
- `docs/handoff/`
- `docs/archive/`
- `.codex/`
- `.agents/`

## Codex and batch-train docs

Codex and batch-train files remain available for AI-assisted implementation, but they are not the public repo front door and are not release proof by themselves.

Key entry points:

- [codex/CONTEXT_INDEX.md](codex/CONTEXT_INDEX.md)
- [codex/BATCH_REGISTRY.md](codex/BATCH_REGISTRY.md)
- [codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md](codex/AMBITIONS_3_0_BATCH_TRAIN_ORCHESTRATOR.md)
- [codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md](codex/FAANG_HANDOFF_REPO_CLEANUP_PROMPT.md)

## Update rule

When changing documentation, preserve this separation:

- product/design truth -> `docs/AmbitionsCanon/`
- implementation status -> `docs/status/current-implementation-map.md`
- cleanup/quarantine policy -> `docs/status/repo-cleanup-index.md`
- release/validation proof -> `docs/status/release-evidence-packet.md`
- local build procedure -> `docs/native-build-and-release.md`
- AI/Codex operation -> `AGENTS.md`, `docs/codex/`, `.codex/`, `.agents/`

Do not add hosted CI or hosted validation docs without an explicit cost/billing decision.
