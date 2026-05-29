# Codex Quality System Script Map

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-10983828, AMB28-same_source_file_targeted_by_multiple_active_batches-13671442, AMB28-same_source_file_targeted_by_multiple_active_batches-17730920, AMB28-same_source_file_targeted_by_multiple_active_batches-19661963, AMB28-same_source_file_targeted_by_multiple_active_batches-19756138, AMB28-same_source_file_targeted_by_multiple_active_batches-21802874, AMB28-same_source_file_targeted_by_multiple_active_batches-27024816, AMB28-same_source_file_targeted_by_multiple_active_batches-28141868, AMB28-same_source_file_targeted_by_multiple_active_batches-32243448, AMB28-same_source_file_targeted_by_multiple_active_batches-38999459, AMB28-same_source_file_targeted_by_multiple_active_batches-53091603, AMB28-same_source_file_targeted_by_multiple_active_batches-65413798 and 8 more

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference-needs-owner-triage**
> AMB-291 note: This Codex reference is retained but requires owner/status clarification before it drives implementation.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Active CQS script map  
Date: 2026-05-13

All CQS scripts are advisory by default. Set `CQS_STRICT=1` or each script's documented strict-mode environment variable to make a matching scan exit nonzero. Scripts must not delete, rewrite, stage, commit, or mutate production files.

| Script | Purpose |
| --- | --- |
| `scripts/cqs-prompt-built-smell-scan.sh` | Generic names, TODO/FIXME/stub residue, unsupported AI copy, overused helpers/managers/coordinators. |
| `scripts/cqs-architecture-boundary-scan.sh` | Domain/view/service dependency direction, preview leakage, mega-files, shared primitive sprawl. |
| `scripts/ambitions-swift6-modernization-scan.py` | Swift 6 settings proof plus native architecture regression guardrails for Combine-owned state, ObservableObject/@Published, AnyCancellable, VIPER naming, Hummingbird native-app leakage, unchecked Sendable, and Domain/Feature/DesignSystem/WidgetUI boundary leaks. Use `--strict` or `AMBITIONS_SWIFT6_SCAN_STRICT=1` to fail on blocking findings. |
| `scripts/ambitions-swift6-final-gate.sh` | Local Swift 6 final gate: scanner self-test, scanner unit tests, strict repo scan, XcodeGen, Swift 6 app build, and focused deterministic tests for migration readiness, App Intent routing, external actions, and system-control contracts. Requires macOS/Xcode. |
| `scripts/cqs-product-drift-scan.sh` | surface, habit, proof thread, inbox, notes, chatbot, AI confidence, calendar clone, proof signal. |
| `scripts/cqs-privacy-security-claim-scan.sh` | Secrets, sensitive logging, unsupported privacy/legal/release claims, required-reason and manifest references. |
| `scripts/cqs-accessibility-motion-scan.sh` | Accessibility labels, color-only states, motion-only states, Reduce Motion gaps. |
| `scripts/cqs-preview-coverage-scan.sh` | Preview/screenshot coverage for normal, loading, empty, private, stale, blocked, recovery, overloaded, Reduced Motion, Dynamic Type states. |
| `scripts/cqs-performance-budget-scan.sh` | Expensive effects, broad animation loops, nested scroll risks, observers, widget/Live Activity update abuse. |
| `scripts/ai/acx.py` | Non-executing bounded reads, saved-log summaries, changed-file grouping, advisory scans, and compact gate reports. |
| `scripts/ai/acx_local.py` | Allowlisted local executor and bundle runner that writes raw logs, summaries, and local proof-cache entries. |
| `scripts/ai/acx_impact.py` | Non-mutating changed-file impact planner that maps paths to routes, bundles, gates, and extra validation. |
| `scripts/ai/acx_repair.py` | Non-mutating repair diagnosis/proposal/closeout helper with R1-R10 repair classes. |
| `scripts/ai/acx_closeout.py` | Compact Codex OS closeout packet generator from local mirrors and proof cache. |
| `scripts/ai/acx_sanitized_evidence.py` | Sanitized proof-cache evidence packet generator; raw logs remain local. |
| `scripts/ai/acx_build_triage.py` | Saved build/test log classifier; does not prove build/test success. |
| `scripts/ai/acx_visual_packet.py` | Visual QA packet template generator for UI-affecting work. |
| `scripts/ai/acx_accessibility_packet.py` | Accessibility proof packet template generator for UI-affecting work. |

Run relevant scripts after focused build/test validation and before commit for implementation batches. Docs-only batches may run the docs-relevant subset.

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
