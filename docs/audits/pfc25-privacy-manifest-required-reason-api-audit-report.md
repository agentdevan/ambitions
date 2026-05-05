# PFC25 Privacy Manifest / Required-Reason API Audit Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance Completion
Batch ID: PFC25

## Result

PFC25 completed as a docs/platform/privacy audit. It reviewed the current
privacy manifest, official Apple required-reason API categories, active source
usage, and dependency boundary. No `PrivacyInfo.xcprivacy` edit was made because
the active source scan did not find direct required-reason API usage requiring a
declaration.

## Source Truth Used

- Apple Developer Documentation:
  `https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api`
- Apple Technote TN3183:
  `https://developer.apple.com/documentation/technotes/tn3183-adding-required-reason-api-entries-to-your-privacy-manifest`
- Apple privacy manifest files documentation:
  `https://developer.apple.com/documentation/bundleresources/privacy_manifest_files`
- Apple `UserDefaults` documentation:
  `https://developer.apple.com/documentation/foundation/userdefaults`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/Ambitions_Privacy_Manifest_Required_Reason_API_Audit.md`
- `docs/canon/Ambitions_Privacy_Data_Map_And_App_Privacy_Labels.md`
- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/canon/Ambitions_App_Store_Release_Compliance.md`
- `docs/audits/pfc04-dependency-supply-chain-policy-report.md`

## Files Read

- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `Package.swift`
- `project.yml`
- `Native/**`
- `Sources/**`
- `AppUI/**`
- PFC and global train-state docs

## Files Changed

- `docs/canon/Ambitions_Privacy_Manifest_Required_Reason_API_Audit.md`
- `docs/audits/pfc25-privacy-manifest-required-reason-api-audit-report.md`
- global order, optimized order, dependency graph, registry, context, PFC train,
  and run-state docs

## What Changed

- Created the PFC25 privacy manifest / required-reason API audit.
- Documented Apple's current required-reason API categories reviewed by PFC25.
- Confirmed the checked-in privacy manifest currently declares no tracking, no
  collected data types, and no accessed API categories.
- Confirmed active source scans found no direct usage of UserDefaults, file
  timestamp APIs, disk-space APIs, system-boot-time APIs, or active-keyboard
  APIs.
- Confirmed no remote runtime package dependency or third-party SDK privacy
  manifest surfaced in this audit.
- Preserved PFC24 App Privacy label draft and final release/human gates.
- Advanced global state from PFC25 queued to PFC25 Green and selected PFC26 as
  the next eligible global batch.

## Why

Apple requires privacy-manifest declarations for covered API categories when
used by app or third-party SDK code. The current Ambitions source inventory did
not show direct covered API usage, so adding required-reason declarations would
overstate current behavior. The correct action is to document the audit, leave
the manifest untouched, and require final archive privacy-report proof later.

## Product Decisions Preserved

- Ambitions remains local-first in current repo evidence.
- No App Store, TestFlight, legal-compliance, privacy-compliance, release,
  physical-device, public accessibility, or archive privacy-report claim was
  added.
- No dependency, entitlement, privacy manifest, project, production Swift, or
  runtime behavior changed.

## Caveats Preserved

- Apple required-reason categories can change over time.
- Final Xcode archive privacy report remains required before release claims.
- Human legal/privacy review remains required.
- PFC24 App Privacy labels remain a draft until final binary and App Store
  Connect reconciliation.

## Candidate Items Touched Or Avoided

No Candidate item was finalized. PFC25 is an audit-only privacy manifest batch.

## CQS Reviewers Applied

- Privacy / Legal / App Store reviewer: no unsupported privacy compliance claim.
- Security reviewer: no hidden data-access claim introduced.
- FAANG handoff reviewer: manifest decision is traceable to source scans.
- Anti-agentic-slop reviewer: no placeholder declaration added.

## AQOS Impact Classification

Docs/platform/privacy audit. Required evidence is official Apple source review,
manifest inspection, source scan, dependency boundary review, and docs
validation.

## FVQ Rendered Proof Classification

No visible UI changed. No rendered visual, device, accessibility, or release
claim was made.

## Accessibility / Reduced Motion Impact

No runtime accessibility or motion behavior changed.

## Privacy / Legal / App Store Impact

PFC25 strengthens privacy manifest truth by documenting why the current manifest
does not declare required-reason APIs. It does not certify legal compliance or
App Store acceptance.

## Performance / Battery Impact

No runtime behavior changed. The audit found no direct disk-space or boot-time
API usage requiring a declaration.

## Validation Commands

- `git status --short`
- `git diff --check`
- touched-file trailing whitespace scan
- `plutil -p Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- required-reason API source scan:
  `UserDefaults`, file timestamp, disk space, system boot time, and active
  keyboard API terms
- privacy manifest / required-reason docs scan
- `scripts/cqs-product-drift-scan.sh ... || true`
- `scripts/cqs-accessibility-motion-scan.sh ... || true`
- `scripts/cqs-privacy-security-claim-scan.sh ... || true`
- `scripts/cqs-performance-budget-scan.sh ... || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git status --short`: PFC25 docs and train-state changes only before
  commit.
- `git diff --check`: passed.
- Touched-file trailing whitespace scan: passed after removing trailing spaces
  in the new canon header.
- `PrivacyInfo.xcprivacy`: declares `NSPrivacyTracking` false,
  `NSPrivacyCollectedDataTypes` empty, and `NSPrivacyAccessedAPITypes` empty.
- Required-reason source scan: no direct active-root hits for `UserDefaults`,
  file timestamp APIs, disk-space APIs, system-boot-time APIs, or
  active-keyboard APIs.
- Privacy manifest / required-reason docs scan: found the current manifest,
  PFC04/PFC24/PFC25 docs, and run-state references only.
- CQS product-drift scan: `CQS_PRODUCT_DRIFT_HITS=0`.
- CQS accessibility/motion scan: `CQS_ACCESSIBILITY_MOTION_HITS=0`.
- CQS privacy/security/legal-claim scan:
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0`.
- CQS performance-budget scan: `CQS_PERFORMANCE_BUDGET_HITS=0`.
- `scripts/run-doc-qa.sh || true`: completed with known advisory backlog in
  stale-guidance, deprecated-language, and markdownlint; lychee reported
  650 OK / 0 errors.
- `scripts/batch-train-gate-check.sh || true`: returned the expected
  pre-commit dirty-worktree hint for this batch; no Hard Red surfaced.

## Repairs Attempted

- Removed trailing spaces in the new canon header.

## Remaining Yellow Items

- Final archive privacy report is not generated in this docs-only batch.
- Apple required-reason categories may change and must be rechecked before
  release.
- Human legal/privacy review remains required.
- Existing doc QA advisory backlog may remain.

## Red Classification

No Recoverable Red or Hard Red found during implementation.

## Rollback Path

Revert the PFC25 commit to remove the required-reason API audit and restore
PFC25 to queued in global order, registry, context, PFC train, and run-state
docs.

## Next Eligible Batch

PFC26 Terms / Privacy Policy / Legal Review Packet is next under full-stack
order.

## Continuation Decision

PFC25 may continue to PFC26 after validation passes and the batch is committed
and pushed.
