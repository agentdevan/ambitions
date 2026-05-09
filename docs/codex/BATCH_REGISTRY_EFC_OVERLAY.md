# Batch Registry EFC Overlay

<!-- markdownlint-disable MD013 -->

Status: Active peak-proof overlay for the batch registry.  
Date: 2026-05-08  
Scope: docs/governance/proof sequencing only.

## Purpose

This file records how the EFC Flagship Proof Operating Layer attaches to the active Ambitions global batch train without replacing the active batch or creating a parallel implementation train.

EFC exists to raise the planned architecture target to 100/100 by forcing every remaining user-impacting batch to close with product proof, trust proof, privacy proof, accessibility proof, degraded-state proof, test proof, release-claim boundaries, recovery proof, performance proof, and continuation proof.

## Active Batch Preservation

At EFC insertion time, the active compact mirror said:

```yaml
current:
  train: "Global full-stack execution"
  batch: "AFI11 Trust Seam And Receipts"
  next_eligible_batch: "AFI12 Accessibility And State Proof"
```

EFC did not supersede that active state. AFI12-AFI16 have since closed under
the active train, and current live state must be read from `.codex/state/
active-batch.yml`, `.codex/reports/current-batch-train-state.md`, and
`docs/codex/BATCH_REGISTRY.md`.

As of the PK10 closeout, PK11 Pre-Migration Backup is the next eligible
global batch. EFC attaches to PK11 as a data-safety proof overlay and continues
to attach to later surface/accessibility batches through their existing owners.

## Registry Overlay Rules

1. `docs/codex/BATCH_REGISTRY.md` remains operational status truth.
2. `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md` defines proof obligations for unfinished work.
3. `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md` defines peak optimized sequencing.
4. EFC standalone batches run only when no existing train owner can produce the proof.
5. Existing AFI/FCP/PK/AOS/LDI/SA/PFC/FVQ/REC owners must absorb EFC proof when they already own the implementation surface.
6. Every batch report after EFC00 must state whether EFC was invoked, not applicable, or Yellow-owned with an explicit owner and next review condition.

## EFC Owner Batch Registry

| Batch | Title | Status | Primary owner | Runs when |
| --- | --- | --- | --- | --- |
| EFC00 | Flagship Proof Operating Layer Integration | Complete as source-truth insertion when this overlay and global order overlay exist | Governance / Codex OS | Immediately, docs-only |
| EFC01 | Private Product Evidence Engine | Queued | PK + Product Evidence | Before product usefulness or retention claims |
| EFC02 | First Useful Object Onboarding | Queued | Onboarding / Capture / Today / You | Before first-run value claims |
| EFC03 | First 30 Days Lifecycle And Retention Proof | Queued | Product Lifecycle / FL / AOS | Before retention or habit claims |
| EFC04 | Time Physics Edge Case Lab | Queued | Time / AOS / PK / PFC EventKit | Before advanced time-fit claims |
| EFC05 | Recommendation Court Integration Gate | Queued | AOS / PK / LDI | Before high-quality recommendation claims |
| EFC06 | Goal Thermodynamics And Drift Handling | Queued | Goals / FL / AOS / LDI | Before long-term goal aging/drift claims |
| EFC07 | Ambitions Twin Fixture Library | Queued | Evaluation / AOS / LDI / PK / FVQ | Before whole-life cross-surface proof claims |
| EFC08 | Source Freshness Commons And Operations | Queued | Source Atlas / LDI | Before freshness-maintained source claims |
| EFC09 | Accessibility Shadow Surface System | Queued | Accessibility / FVQ / AFI | Before public accessibility confidence claims |
| EFC10 | Real Device Proof Lab | Queued | PFC / FVQ / REC | Before physical-device/platform proof claims |
| EFC11 | Privacy-Safe Observability And Support Pack | Queued | PK / PFC / Support | Before beta/public support claims |
| EFC12 | Data Control And Proof Portability Vault | Queued | PK / You / Trust | Before data ownership/export/restore claims |
| EFC13 | Notification Cadence Governor | Queued | PFC / PK / Recovery | Before notification quality claims |
| EFC14 | Local Language Quality Benchmark | Queued | AOS / LDI / Evaluation | Before no-LLM language quality claims |
| EFC15 | Localization And Globalization Readiness | Queued | Product Copy / UI / App Store | Before internationalization/global-readiness claims |
| EFC16 | Release Truth Machine | Queued | PFC / REC / Release | Before public launch claim package |
| EFC17 | App Store Creative And Reviewer Package | Queued | PFC / Marketing / Release | Before App Store submission readiness |
| EFC18 | Anti-Ceremony Compiler | Queued | CQS / Governance / Docs | Before final source-truth simplification |

## Existing Train Wiring

### AFI / FCP / FVQ

- AFI12 and later visual/state/accessibility batches inherit EFC09 Accessibility Shadow Surface requirements.
- UI-affecting work inherits EFC07 Twin Fixture and FVQ rendered-proof requirements.
- Final visual claims inherit EFC10 real-device proof and EFC16 release-truth requirements.

### PK

PK14-PK16, PK22-PK28, and PK32-PK37 inherit EFC01, EFC05, EFC11, EFC12, and EFC13 where relevant.

PK may not close Green for event/receipt/diagnostic/data-control/side-effect/intelligence-quarantine/performance work without an EFC applicability note.

### AOS

AOS10, AOS11, AOS14, AOS15, AOS18, AOS20, AOS24-AOS27 inherit EFC04, EFC05, EFC06, EFC07, EFC09, EFC14, and EFC16 where relevant.

AOS recommendation or adaptation claims must invoke Recommendation Court or explicitly Yellow-own the gap.

### LDI

LDI02-LDI04, LDI08-LDI16, LDI18, and LDI20-LDI22 inherit EFC03, EFC05, EFC06, EFC08, EFC14, and EFC07 where relevant.

LDI language/dream/path behavior cannot claim no-LLM flagship quality until EFC14 exists and passes.

### Source Atlas

SA10-SA15, SA16-SA28, and any SA29-SA32 closeout inherit EFC08 Source Freshness Commons where relevant.

Source Atlas may not claim freshness-maintained operations without changed-claim, local-impact, stale-receipt, and no-silent-mutation proof.

### PFC / REC

PFC14, PFC16, PFC18, PFC20, PFC24-PFC30, PFC31 if present, and REC02-REC06 inherit EFC10, EFC11, EFC16, and EFC17 where relevant.

Release-facing work may not claim release readiness, App Store readiness, TestFlight readiness, physical-device proof, public accessibility proof, legal/privacy compliance, or final human approval without Release Truth Machine evidence.

## Hard Red Continuation Stops

Stop if a later batch:

- Ignores EFC applicability when user-facing behavior, data, intelligence, source/freshness, side effects, release posture, accessibility, or public claims are touched.
- Introduces analytics, telemetry, hosted AI, user-data servers, or cloud processing as core behavior without explicit user decision and privacy/legal proof.
- Treats EFC as product scope expansion rather than proof ownership.
- Adds broad duplicate batches instead of wiring proof into existing owners.
- Changes the current active batch without re-reading `.codex/state/active-batch.yml`.

## Non-Claims

This overlay does not implement product features, production Swift, persistence schema, device proof, public accessibility proof, release readiness, App Store readiness, TestFlight readiness, legal/privacy compliance, sync, hosted CI, signing, entitlements, telemetry, analytics, or 100/100 shipped-product status.
