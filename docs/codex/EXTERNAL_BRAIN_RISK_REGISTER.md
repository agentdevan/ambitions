# External Brain Risk Register

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active Codex OS protocol and EB36 QA/risk evidence.
Date: 2026-05-04

This document defines External Brain regression risks, owner lanes, required
proof, and release-claim impact. It is not a product readiness claim and does
not by itself authorize new app behavior.

Green requires source truth, allowed/forbidden files, evidence, validation, and
conservative claim boundaries. Yellow requires owner and safe deferral. Red
stops or enters the Red repair decision tree.

## Risk Table

| Risk ID | Area | Trigger | Severity | Owner lane | Current evidence | Mitigation | Next review | Release impact |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| EB-RISK-001 | Privacy / memory creep | Context recall or command surfaces imply durable memory without source, edit, delete, or receipt proof. | High | EB37 Privacy Threat Model / Trust Center | EB08-EB12, EB33, EB35 evidence name source and review boundaries. | Require source/confidence/review/delete/export proof before durable memory claims. | EB37, EB38, EB40 | Blocks memory/privacy release claims. |
| EB-RISK-002 | Capture routing | Universal Capture changes route/raw/persistence behavior without owner map and rollback. | High | Capture / EB03B owner lane | EB03A owner map and EB03B focused tests exist. | Keep EB03 parent blocked; route changes require EB03B-style proof. | Any future Capture EB batch | Blocks Capture routing claims if unproven. |
| EB-RISK-003 | Command surface overreach | Command surface appears to write calendar, mutate plans, or run automation silently. | High | Command Surface / Trust | EB34 command contracts mark calendar writes and durable memory as false. | Commands must name destination, safety summary, fallback, and confirmation needs. | EB36, EB37, EB39 | Blocks automation and calendar-write claims. |
| EB-RISK-004 | Accessibility proof gap | EB UI or command surfaces claim accessible behavior without manual VoiceOver, Dynamic Type, Reduce Motion, or motor proof. | Medium | Accessibility QA / EB38 | EB27-EB30 and EB35 provide internal evidence only. | Keep proof as Yellow until manual or rendered evidence exists. | EB38 | Blocks public accessibility claims. |
| EB-RISK-005 | Scenario coverage gap | QA depends on scenarios not represented in PreviewSupport or audit evidence. | Medium | EB35 / EB36 QA | EB35 adds typed scenarios for Capture, Memory Lens, correction, command, You, and recovery. | Require scenario owner, privacy boundary, accessibility expectation, and expected evidence. | EB36 and EB40 | Blocks broad EB closeout Green if unowned. |
| EB-RISK-006 | Generic product drift | EB surfaces drift into chatbot, admin surface, generic productivity, or noisy AI framing. | Medium | PXEQ / SIG / EB QA | DAV/SIG/PXEQ gates exist; scans still have historical advisory backlog. | Keep top-level IA fixed and require anti-generic scan classification for UI batches. | UI-affecting EB/SIG/PD batches | Blocks product-experience Green for affected UI. |
| EB-RISK-007 | Persistence/schema migration | Durable memory, receipts, export/delete, or schema changes land without migration plan. | High | Persistence / Trust / EB37 | Current EB08-EB35 changes avoid schema changes. | Require explicit schema owner, migration, rollback, import/export proof, and tests. | Any persistence-owning EB batch | Blocks release and data-safety claims. |
| EB-RISK-008 | Fake proof / release claim | Reports imply screenshot, device, VoiceOver, Instruments, production, TestFlight, App Store, or release proof without evidence. | High | Release-claim safety / EB39 | No-fake-proof and release-claim scans run as advisory/hard gates. | Reports must list not-run proof and claim boundaries. | Every EB closeout | Blocks release readiness claims. |
| EB-RISK-009 | Performance / battery | Visual or search layers add high-frequency animation, heavy blur, or broad expensive queries without profiling. | Medium | Performance QA | DAV13 risk ledger exists; EB33 search is bounded local query metadata. | Require risk scan, measured proof only when actually profiled, and safer fallback. | EB36, EB38, EB40 | Blocks battery/performance safety claims. |
| EB-RISK-010 | Train-state drift | Registry, global order, run state, and audit reports disagree after interrupted runs. | Medium | Codex OS / batch train | Recovery protocol and current run-state are actively updated after each batch. | Commit/push each logical batch; next-batch scripts must match registry/order. | Every batch | Blocks train continuation if dirty or contradictory. |

## EB36 QA Regression Matrix

| Proof lane | Current status | Required Green proof | EB36 classification |
| --- | --- | --- | --- |
| Capture route/raw/persistence | EB03A/EB03B evidence exists; no EB36 Swift touched. | Focused Capture route tests plus rollback for future route changes. | Green for EB36 non-change; future-owned for new behavior. |
| Memory source/confidence/review | EB08-EB12 and EB33 evidence exists. | Durable source/edit/delete/export proof before memory claims. | Yellow for future durable memory; no Red in EB36. |
| Command surface safety | EB34 contract evidence exists. | UI consumption proof and confirmation behavior if commands become visible. | Yellow for UI presentation; no Red in EB36. |
| Preview/scenario coverage | EB35 scenario library exists. | Rendered screenshots or human visual QA when claimed. | Yellow for rendered proof; no Red in EB36. |
| Accessibility | EB27-EB30 internal evidence exists. | Human/manual or rendered accessibility traversal by surface. | Yellow; blocks public accessibility claims. |
| Privacy threat model | EB13 trust gate exists; EB37 owns threat model. | EB37 threat model with mitigations and release impact. | Yellow until EB37. |
| Release claims | Claim scans run; reports use non-claim boundaries. | Human/device/platform proof only when actually performed. | Green for claim restraint; Yellow for missing proof. |

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
