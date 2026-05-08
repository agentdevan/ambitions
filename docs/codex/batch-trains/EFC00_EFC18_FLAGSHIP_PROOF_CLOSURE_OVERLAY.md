# EFC00-EFC18 Flagship Proof Closure Overlay

<!-- markdownlint-disable MD013 -->

Status: Active overlay train; proof-owner batches queued after EFC00 source-truth insertion.  
Date: 2026-05-08  
Train code: EFC  
Scope: proof ownership, global sequencing, and missing-owner closure. Not a parallel feature train.

## Purpose

EFC00-EFC18 wires Ambitions' remaining unfinished planned work to a 100/100 planned-architecture proof standard.

The train is an overlay. It does not replace AFI, FCP, PK, AOS, LDI, Source Atlas, PFC, FVQ, CQS, or REC. Existing batches remain implementation owners wherever they already own the system. EFC adds new owner batches only for proof systems that do not have a sufficient existing owner.

## Start / Continuation Rule

Before starting or continuing any EFC work, re-read:

- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `.codex/reports/current-run-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`

EFC00 is docs-only and may be inserted without changing the active AFI batch. After EFC00, continue the active global train from the repo's current active state. At insertion time, that state was AFI11 accepted Yellow with AFI12 next eligible.

## Non-Goals

EFC does not authorize:

- sixth tab
- hosted AI core behavior
- user-data server
- remote telemetry or analytics by default
- productivity scores
- shame/streak mechanics
- silent mutation
- broad duplicate trains
- App Store/TestFlight/release/device/accessibility/legal/privacy claims without evidence
- production Swift changes during docs-only proof wiring

## Batch Table

| Batch | Title | Type | Required result | Key inheritance |
| --- | --- | --- | --- | --- |
| EFC00 | Flagship Proof Operating Layer Integration | Docs/governance | Adds EFC operating layer, registry overlay, peak global order overlay, and index pointers without changing active batch. | All trains |
| EFC01 | Private Product Evidence Engine | Domain/runtime planning then implementation when owned by PK | Local-only evidence primitives for Captured -> Placed -> Shaped -> Started -> Closed -> Remembered, with review/clear/export and no telemetry. | PK14-PK16, PK27-PK28 |
| EFC02 | First Useful Object Onboarding | Product/UI/runtime | First run creates one useful object or respected manual mode, with first receipt and no setup bloat. | Onboarding, Capture, Today, You |
| EFC03 | First 30 Days Lifecycle And Retention Proof | Product/runtime/evaluation | Day 0/1/3/7/14/21/30 lifecycle states, recovery, drift, weekly rhythm, and local retention proof without streaks. | FL06, AOS20, LDI15, EFC01 |
| EFC04 | Time Physics Edge Case Lab | Runtime/test fixtures | DST, travel, timezone, recurring exceptions, all-day events, limited permissions, protected time, buffers, away, and recovery fixtures. | AOS10-AOS11, PK21, PK24, PFC20 |
| EFC05 | Recommendation Court Integration Gate | Runtime/evaluation | Candidate evidence, objections, alternatives, allow/downgrade/block outcomes, and Why This? trace without confidence scores. | AOS14, AOS18, PK32-PK34, LDI13 |
| EFC06 | Goal Thermodynamics And Drift Handling | Domain/product/runtime | Warming/Active/Cooling/Dormant/Revivable/Released goal states, proof preservation, no failure labels, user override. | FL05-FL06, AOS22, LDI15, LDI18 |
| EFC07 | Ambitions Twin Fixture Library | Test/evaluation | Whole-life synthetic users spanning surfaces, privacy, source, accessibility, device, recovery, and release proof. | AOS18, AOS25, LDI21, PK35, FVQ |
| EFC08 | Source Freshness Commons And Operations | Source runtime/tools | Signed pack changes, changed claim IDs, local impact match, stale/source-changed receipts, review before mutation. | SA14-SA15, SA27-SA28, LDI20 |
| EFC09 | Accessibility Shadow Surface System | Accessibility/UI/test | Testable nonvisual summaries, VoiceOver order, Dynamic Type, Reduce Motion, Differentiate Without Color for all signature/external surfaces. | AFI12, FVQ, FCP |
| EFC10 | Real Device Proof Lab | Release/device/manual proof | Physical-device matrix for app, widgets, Live Activities, notifications, App Intents, share extension, accessibility, performance. | PFC14, PFC16, PFC18, PFC20, REC |
| EFC11 | Privacy-Safe Observability And Support Pack | Diagnostics/support/privacy | Redacted local diagnostics, user-approved support export, incident runbook, no private logs. | PK26-PK28, PFC privacy/security |
| EFC12 | Data Control And Proof Portability Vault | Data-control UX/runtime | Export/delete/restore/redaction/backup/proof-portability UX, dry-run import, rollback, delete/forget/hide flows. | PK11-PK13, PK28, You |
| EFC13 | Notification Cadence Governor | Product/platform/runtime | Notification fatigue rules, quiet hours, lock-screen privacy, recovery-first copy, no silent mutation. | PK23, PFC20, Recovery |
| EFC14 | Local Language Quality Benchmark | Evaluation/runtime | Corpus for captures, vague goals, source-heavy input, unsafe dreams, ambiguity, corrections, and no-LLM quality proof. | AOS15, LDI02-LDI14, LDI21 |
| EFC15 | Localization And Globalization Readiness | UI/copy/platform | Pseudo-localization, copy extraction, date/time, pluralization, text expansion, RTL stress review. | AFI copy, UI, App Store |
| EFC16 | Release Truth Machine | Release/governance/tooling | Can-claim/proof/unproven/owner/forbidden-copy packet across build, tests, visual, a11y, device, privacy, App Store, human signoff. | PFC27-PFC30, REC |
| EFC17 | App Store Creative And Reviewer Package | Release/marketing | Screenshots, metadata, support/privacy URLs, demo data, reviewer notes, permission explanation, claim-safe copy. | PFC, REC, EFC16 |
| EFC18 | Anti-Ceremony Compiler | Governance/tooling | Classify docs/batches as executable/decision/evidence/historical/superseded/aspirational/duplicate/dangerous and produce next-safe-action. | CQS, docs cleanup |

## Phase Order

1. EFC00 source-truth insertion.
2. Continue active AFI lane with EFC inherited by AFI12 and later UI-affecting batches.
3. Product proof foundation: EFC01, EFC02, EFC03, EFC07.
4. Intelligence/time/goal quality: EFC14, EFC05, EFC04, EFC06.
5. Source/data/support/notifications: EFC08, EFC12, EFC13, EFC11.
6. Accessibility/device/release: EFC09, EFC10, EFC15, EFC16, EFC17.
7. Governance collapse: EFC18.

## EFC Closeout Requirements

Every EFC batch must close with:

- source-truth files read
- active batch state checked before edits
- files changed
- behavior changed / not changed
- validation commands or explicit not-run reason
- EFC proof family covered
- non-claims
- Yellow owners
- next eligible global batch
- rollback path

## Non-Claims

This overlay train does not implement product behavior by itself and does not claim release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, legal/privacy compliance, sync readiness, hosted CI, remote telemetry, hosted AI, user-data server, or 100/100 shipped-product status.
