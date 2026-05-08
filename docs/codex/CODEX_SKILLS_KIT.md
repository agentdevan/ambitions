# Codex Skills Kit

Status: Active skills routing map; does not duplicate existing skills.
Date: 2026-05-07

## Rule

Map to existing `.codex/skills/` first. Add a new skill only when no owner exists and the gap is durable.

## Required Families

| Family | Existing skill examples | Primary route | Gates | Validation tier | Report format |
| --- | --- | --- | --- | --- | --- |
| Canon Steward | `source-truth-librarian`, `product-canon-drift-reviewer`, `repo-truth-enforcer` | Canon Drift | Source Truth, Canon Drift, Deprecated Language | Docs scan | Evidence packet |
| UI Primitive Steward | `ambitions-native-ui-primitive-reviewer`, `swiftui-composition-reviewer`, `design-system-guard` | Today/Goals/Capture/Plan/You UI | SwiftUI, Visual, FVQ, Accessibility | Focused UI proof | FVQ/evidence |
| Build Sheriff | `build-failure-triage-skill`, `build-test-pack-runner`, `xcodegen-target-writer` | Build Failure, Xcode / Toolchain | Validation, Source Truth, Architecture | Build/test raw logs | Failure report |
| Accessibility Reviewer | `accessibility-evidence-reviewer`, `accessibility-reduced-motion-reviewer` | Accessibility / Motion | Accessibility, FVQ | Scan/render proof | Accessibility packet |
| Visual QA Reviewer | `faang-rendered-visual-reviewer`, `visual-qa-preview-fixture-reviewer` | Visual QA | Visual, FVQ, Accessibility | Screenshots/previews | FVQ packet |
| Batch Conductor | `codex-train-integrity-lead`, `aos-train-orchestrator`, `red-repair-loop-operator` | Global Batch Train | Route, Gate, Evidence, Report | Batch pack | G/Y/R report |
| Repo Hygienist | `repo-hygiene-cleaner`, `orphan-doc-resolver`, `file-inventory-classifier` | Repo Hygiene | Scope, Hygiene, Source Truth | ACX/CQS scans | Hygiene packet |
| Release Claim Auditor | `release-claim-blocker`, `release-claim-truth-enforcer`, `app-store-truth-packet-reviewer` | Release Claim Audit | Claim Firewall, Privacy/Legal | Claim scan | Claim firewall |
| External Brain Architect | `external-brain-integration-architect`, `memory-consent-reviewer` | External Brain / Memory / Trust | Privacy, Source Truth, Evidence | Focused tests/docs | Trust packet |
| Privacy / Safety Reviewer | `privacy-threat-model-reviewer`, `professional-boundary-reviewer` | Privacy / Security | Privacy/Legal, Evidence | CQS privacy scan | Safety/privacy packet |
| Performance / Energy Reviewer | `performance-energy-reviewer`, `aos-performance-budget-reviewer` | Performance / Energy | Performance/Battery | Scan/profiling when owned | Performance packet |
| Swift Architecture Reviewer | `faang-staff-ios-architect`, `staff-ios-architect` | Build Failure or selected UI/domain route | Architecture, Scope | Focused build/tests | Architecture report |
| Prompt Quality Reviewer | `codex-prompt-quality-reviewer`, `anti-agentic-slop-reviewer` | Repo Hygiene / Canon Drift | Anti-Slop, Scope | Prompt scan | Prompt quality report |
| Evidence Packet Reviewer | `evidence-gate-reporter`, `validation-evidence-auditor` | Any | Evidence Packet, Report | Raw logs required | Evidence packet |
