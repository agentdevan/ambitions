# Global Autonomous Quality Overlay

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: retired_ia_or_terminology_reference
> Prior recommended actions: Rewrite
> Candidate references: AMB28-retired_ia_or_terminology_reference-91229146

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, rewrite-authority-before-proof, terminology-quarantine
> Dispositions: quarantine-or-rewrite-terminology, rewrite-authority-before-proof, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active global overlay for AQOS adoption.
Date: 2026-05-05

## Purpose

This overlay makes AQOS binding even while the global train is moving. Codex must read this file at the next safe batch boundary and install Evidence-Gated Quality before broad continuation.

## Live-Run Safety Rule

When Codex pulls this overlay:

1. Do not interrupt an active in-progress batch mid-edit.
2. Finish, validate, repair, and commit the active batch if safe.
3. Pull latest remote.
4. Read AQOS source truth.
5. Run AQOS adoption before continuing broad global work.
6. If FVQ is already queued or running, run FVQ first or alongside AQOS according to the visual Hard Red risk.
7. Resume the global order only when no unresolved AQOS Hard Red exists.

## AQOS Adoption Sequence

At the earliest safe boundary, run:

1. AQOS01 Evidence-Gated Quality Canon.
2. AQOS02 Batch Impact Classifier.
3. AQOS03 Required Evidence Matrix.
4. AQOS04 Green Taxonomy / No Generic Green.
5. AQOS05 Repair Batch Generator Protocol.
6. AQOS06 FVQ Integration Hardening.
7. AQOS09 Accessibility Execution Quality.
8. AQOS10 User-Facing Copy Quality.
9. AQOS11 Privacy Exposure QA.
10. AQOS13 Data Integrity QA.
11. AQOS14 Performance / Battery Budget QA.
12. AQOS16 Architecture Fitness Tests.
13. AQOS20 Evidence Maturity Ledger.
14. AQOS22 AOS / LDI Golden Scenario Harness.
15. AQOS26 Autonomous Red-Team Board.
16. AQOS29 Global Orchestrator Integration.
17. AQOS30 No-Proof-No-Green Lock.

Other AQOS batches may run in sequence or be folded into the above where safe.

## Blocking Rule

No future batch may close generic Green. Every batch must state:

- impact classifier result
- required evidence
- evidence produced
- Green taxonomy achieved
- Yellow/Red classification
- Autonomous Quality Council result where major

## No-Proof-No-Green Rule

If a batch changes a domain but does not produce the domain's required proof, it cannot close Green for that domain.

## Repair Rule

If AQOS identifies recoverable Red, Codex must repair or create a narrow repair batch. It must not bury the issue in a generic accepted Yellow.

## Hard Red Rule

Stop only for Hard Red, including:

- unresolved sensitive data leak
- unproven data-loss risk
- unresolved top-level visual prototype/dashboard failure after repair
- inaccessible primary action
- unsupported public/legal/privacy/release claim
- app-breaking build failure with unclear repair
- Codex would need to weaken canon, delete tests, fake evidence, or hide issues

## Relationship To FVQ

FVQ is the visual specialization of AQOS. AQOS does not replace FVQ. It generalizes the same evidence standard to all domains.

## Relationship To CQS

CQS controls Codex behavior and repair discipline. AQOS controls proof quality and domain-specific evidence. Both are required.

## No-Claim Boundary

This overlay does not claim the app is fixed, release-ready, visually final, accessible, legally compliant, secure, or handoff-ready. It requires evidence before those claims can be made.

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
