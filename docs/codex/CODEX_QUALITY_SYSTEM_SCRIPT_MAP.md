# Codex Quality System Script Map
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
| `scripts/cqs-product-drift-scan.sh` | Dashboard, habit, streak, inbox, notes, chatbot, AI confidence, calendar clone, productivity score. |
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
