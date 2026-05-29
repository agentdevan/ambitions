# Codex OS Engine Supplement

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-13671442, AMB28-same_source_file_targeted_by_multiple_active_batches-17730920, AMB28-same_source_file_targeted_by_multiple_active_batches-19661963, AMB28-same_source_file_targeted_by_multiple_active_batches-19756138, AMB28-same_source_file_targeted_by_multiple_active_batches-21802874, AMB28-same_source_file_targeted_by_multiple_active_batches-27024816, AMB28-same_source_file_targeted_by_multiple_active_batches-32243448, AMB28-same_source_file_targeted_by_multiple_active_batches-69194013, AMB28-same_surface_multiple_active_batches-13212827

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Active supplement to `docs/codex/CODEX_OS_INDEX.md`.  
Date: 2026-05-08  
Scope: Adds repair, speed, proof-cache, build, visual, accessibility, and privacy/security parity engines.

## Why This Exists

The existing Codex OS index already maps ACX, routes, gates, evidence, batch state, and skills. This supplement adds the higher-order operating engines that push repair, speed, validation routing, and proof discipline toward FAANG-grade maturity.

## New Engines

| Engine | Purpose | Owners |
| --- | --- | --- |
| Speed Engine | Bundles, impact routing, proof cache, and closeout acceleration. | `docs/codex/CODEX_SPEED_ENGINE.md`, `.codex/manifests/acx-bundles.yml`, `.codex/manifests/changed-file-impact-map.yml`, `scripts/ai/acx_impact.py`, `scripts/ai/acx_closeout.py` |
| Repair Engine | Failure classification, safe repair boundary, active repair state, repair ledger, and hard-stop behavior. | `docs/codex/CODEX_REPAIR_ENGINE.md`, `.codex/manifests/repair-profiles.yml`, `scripts/ai/acx_repair.py` |
| Proof Cache | Local-only proof reuse with raw-log hashes and sanitized packets. | `docs/codex/CODEX_PROOF_CACHE_PROTOCOL.md`, `scripts/ai/acx_sanitized_evidence.py`, `.codex/state/proof-cache.json` local-only |
| Build Sheriff | Build/test saved-log classification and build/test claim boundaries. | `docs/codex/CODEX_BUILD_SHERIFF_PROTOCOL.md`, `.codex/manifests/build-commands.yml`, `.codex/manifests/test-impact-map.yml`, `scripts/ai/acx_build_triage.py` |
| Visual QA | UI visual proof packet generation and FVQ field discipline. | `docs/codex/CODEX_VISUAL_QA_PROTOCOL.md`, `.codex/manifests/visual-proof-map.yml`, `scripts/ai/acx_visual_packet.py` |
| Accessibility Proof | Accessibility proof packet generation and claim boundaries. | `docs/codex/CODEX_ACCESSIBILITY_PROOF_PROTOCOL.md`, `.codex/manifests/accessibility-proof-map.yml`, `scripts/ai/acx_accessibility_packet.py` |
| Privacy/Security Scan | Secrets, privacy, sensitive logs, and unsupported compliance claim scanning. | `docs/codex/CODEX_PRIVACY_SECURITY_SCAN_PROTOCOL.md`, CQS privacy/security scan, ACX Local bundles |

## Default Modern Flow

```bash
python3 scripts/ai/acx_local.py bundle quick
python3 scripts/ai/acx_impact.py <changed files>
python3 scripts/ai/acx_local.py bundle <suggested-bundle>
python3 scripts/ai/acx_repair.py diagnose
python3 scripts/ai/acx_closeout.py
```

Use `acx_repair.py diagnose` only when there is a needs review profile, repeated Yellow, Red, hard Red, or repair-oriented closeout.

## Claim Boundary

These engines improve routing, speed, repair intelligence, and proof packaging. They do not independently prove app build/test/device/accessibility/release/legal/privacy readiness. Those claims still require matching raw evidence and owner proof.

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
