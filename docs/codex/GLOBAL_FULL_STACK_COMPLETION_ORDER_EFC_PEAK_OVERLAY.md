# Global Full-Stack Completion Order — EFC Peak Overlay

<!-- markdownlint-disable MD013 -->

Status: Active peak optimized sequencing overlay.  
Date: 2026-05-08  
Scope: docs/governance/proof sequencing only; no app implementation by this file.

## Purpose

This overlay upgrades the active `GLOBAL_FULL_STACK_COMPLETION_ORDER.md` to peak proof sequencing for Ambitions' 100/100 planned architecture target.

It does not replace the global order. It overlays it.

The active global order continues to preserve completed batch history and next eligible active state. EFC adds proof obligations and targeted owner batches so the remaining trains produce flagship evidence rather than only feature completion.

## Active State At Overlay Creation

At overlay creation, the active batch state was:

```text
Current batch: AFI11 Trust Seam And Receipts / Accepted Yellow
Next eligible batch: AFI12 Accessibility And State Proof
```

AFI12-AFI16 have since closed under the active train. As of the PK14 closeout,
PK15 Receipt Backend is the next eligible global batch unless repo evidence
shows a dirty or half-complete active batch must close first.

EFC must not interrupt or overwrite Codex while it is actively running. Before any continuation, read:

1. `.codex/state/active-batch.yml`
2. `.codex/reports/current-batch-train-state.md`
3. `.codex/reports/current-run-state.md`
4. `docs/codex/BATCH_REGISTRY.md`
5. `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
6. this file

## Peak Sequencing Principle

The peak global sequence is:

```text
Active AFI lane continues
→ EFC proof overlay applies immediately
→ Existing unfinished owner batches absorb EFC proof where they already own the system
→ Standalone EFC owner batches run only where no existing batch can produce the proof
→ Release Truth Machine and Anti-Ceremony Compiler close the proof loop
```

Do not create an EFC01-EFC30 parallel feature train. The EFC batch set is capped to proof-owner batches EFC00-EFC18 unless a later senior review proves a specific missing owner.

## Optimized Phase Order

### Phase 0 — EFC Overlay Insertion

1. EFC00 — Flagship Proof Operating Layer Integration.

Result:

- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md` exists.
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md` exists.
- this peak overlay exists.
- active state is historical for AFI11 / AFI12; current continuation must follow
  `.codex/state/active-batch.yml`, current run-state docs, and
  `docs/codex/BATCH_REGISTRY.md`.
- no production Swift, persistence, schema, route, signing, entitlement, dependency, hosted CI, sync, AI runtime, legal/privacy, release, device, or accessibility proof claim is made.

### Phase 1 — Continue Active AFI Accessibility And State Proof

2. AFI12 — Accessibility And State Proof.

EFC inheritance:

- EFC09 Accessibility Shadow Surface System requirements apply.
- AFI12 cannot close Green from labels alone if it touches visual/user-facing accessibility; it must record nonvisual summary, VoiceOver order, Dynamic Type, Reduce Motion, Differentiate Without Color, degraded state, and no-claim proof.
- If real-device proof is unavailable, carry it as EFC10-owned Yellow, not as accessibility-complete.

### Phase 2 — Product Proof Foundation

Run as soon as safe after AFI12 or when a current owner needs the proof:

3. EFC01 — Private Product Evidence Engine.
4. EFC02 — First Useful Object Onboarding.
5. EFC03 — First 30 Days Lifecycle And Retention Proof.
6. EFC07 — Ambitions Twin Fixture Library.

Reason:

Future product, design, intelligence, and release claims need a local proof substrate and whole-life fixtures before they can honestly claim flagship usefulness.

### Phase 3 — Intelligence / Time / Goal Quality

Wire into existing AOS, LDI, PK, and Time owners; run standalone only where needed:

7. EFC14 — Local Language Quality Benchmark.
8. EFC05 — Recommendation Court Integration Gate.
9. EFC04 — Time Physics Edge Case Lab.
10. EFC06 — Goal Thermodynamics And Drift Handling.

Reason:

No external LLM is part of core architecture. Ambitions' local intelligence must be proven through corpora, deterministic courts, time physics, goal aging, and correction loops.

### Phase 4 — Source, Recovery, Notifications, Data Ownership, Support

11. EFC08 — Source Freshness Commons And Operations.
12. EFC12 — Data Control And Proof Portability Vault.
13. EFC13 — Notification Cadence Governor.
14. EFC11 — Privacy-Safe Observability And Support Pack.

Reason:

Trust is not only UI. Trust requires source freshness, data ownership, respectful notifications, support diagnostics, and privacy-safe incident handling.

### Phase 5 — Accessibility / Device / Localization / Release Proof

15. EFC09 — Accessibility Shadow Surface System.
16. EFC10 — Real Device Proof Lab.
17. EFC15 — Localization And Globalization Readiness.
18. EFC16 — Release Truth Machine.
19. EFC17 — App Store Creative And Reviewer Package.

Reason:

Simulator proof and docs-only proof are not flagship release proof. Device, accessibility, localization, public copy, metadata, screenshots, support/privacy URLs, and claim truth must be evidence-bound.

### Phase 6 — Governance Collapse / Anti-Ceremony

20. EFC18 — Anti-Ceremony Compiler.

Reason:

After EFC proof routing is installed, reduce repo friction. Classify active docs and batches as executable, decision, evidence, historical, superseded, aspirational, duplicate, or dangerous. Produce a single next-safe-action view.

## Cross-Train Wiring Matrix

| Existing train | Must inherit EFC proof for | EFC owner |
| --- | --- | --- |
| AFI/FCP/FVQ | Signature object accessibility, shadow surfaces, visual proof, reduced motion, large text, device visual evidence | EFC09, EFC10, EFC07 |
| PK | event ledger, receipt backend, trust history, side effects, notifications, EventKit, diagnostics, data controls, intelligence quarantine, performance fixtures | EFC01, EFC05, EFC11, EFC12, EFC13 |
| AOS | recommendation quality, time physics, local language fallback, evaluation scenarios, adaptation, UI integration, privacy/performance QA | EFC04, EFC05, EFC07, EFC14, EFC16 |
| LDI | capture/dream/goal language, path recompile, mutation permissions, source freshness, red-team evaluation, goal thermodynamics | EFC03, EFC05, EFC06, EFC08, EFC14 |
| Source Atlas | freshness, source changed claims, local impact matcher, source review, packs, diff tooling, offline fallback | EFC08, EFC07 |
| PFC/REC | device proof, privacy support pack, App Store truth, release truth, public copy, metadata, reviewer notes, support/privacy URLs | EFC10, EFC11, EFC16, EFC17 |
| CQS/GOV | source-truth simplification, stale-doc quarantine, next safe action, ceremony control | EFC18 |

## Batch Closeout Addendum

Every batch after EFC00 must add this section to its closeout report:

```markdown
## EFC Flagship Proof Overlay

- EFC applicability: invoked / not applicable / accepted Yellow.
- Product proof:
- Trust proof:
- Privacy proof:
- Accessibility proof:
- Degraded-state proof:
- Test proof:
- Release-claim boundary:
- Recovery proof:
- Performance proof:
- Continuation proof:
- EFC Yellow owners:
```

If the batch is docs-only and touches no user-facing behavior, it may mark most fields not applicable, but it must still state no-claim boundaries.

## 100/100 Moat Requirements

EFC strengthens Ambitions' moat through proof systems, not marketing claims:

- Private Product Evidence Engine makes usefulness locally inspectable without telemetry.
- Recommendation Court makes deterministic intelligence defensible without external LLMs.
- Time Physics makes scheduling recommendations believable.
- Goal Thermodynamics makes long-term goals living without shame or scores.
- Twin Fixtures make whole-life QA repeatable.
- Source Freshness Commons makes real-world requirements safer without an official-database overclaim.
- Accessibility Shadow Surfaces make visual inventions usable nonvisually.
- Release Truth Machine prevents public overclaiming.
- Anti-Ceremony Compiler keeps the repo executable instead of ceremonial.

## Non-Claims

This overlay does not implement any product feature, production Swift, persistence schema, release process, signing, entitlements, hosted CI, physical-device proof, public accessibility conformance, legal/privacy compliance, App Store readiness, TestFlight readiness, sync, hosted AI, telemetry, analytics, source freshness operations, or 100/100 shipped-product status.

It defines the peak optimized proof order future batches must follow.
