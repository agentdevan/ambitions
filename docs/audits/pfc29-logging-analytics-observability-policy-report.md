# PFC29 Logging / Analytics / Observability Policy Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance Completion
Batch ID: PFC29

## Result

PFC29 completed as a docs/privacy/observability policy. It creates an explicit
no-analytics, no-remote-telemetry, no-crash-SDK current runtime decision and
separates local product receipts/event ledgers from developer telemetry.

## Source Truth Used

- `project.yml`
- `Package.swift`
- `Native/Ambitions/Resources/PrivacyInfo.xcprivacy`
- `docs/canon/Ambitions_Privacy_Data_Map_And_App_Privacy_Labels.md`
- `docs/canon/Ambitions_Privacy_Manifest_Required_Reason_API_Audit.md`
- `docs/canon/Ambitions_Security_Threat_Model_And_Secrets_Audit.md`
- `docs/canon/Ambitions_Terms_Privacy_Policy_Legal_Review_Packet.md`
- `docs/canon/Ambitions_Safety_Professional_Boundary_Crisis_Policy.md`
- `Native/Ambitions/Domain/EventLedgerModels.swift`
- `Native/Ambitions/Services/CaptureService.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `AppUI/Sources/WidgetFoundation.swift`
- `AppUI/Sources/WidgetPreviews.swift`

## Files Read

- Startup/global order and PFC train docs.
- Current run-state, batch-train-state, registry, context, dependency graph,
  and optimized order.
- Privacy data map, privacy manifest audit, security threat model, legal packet,
  and safety boundary policy.
- Project/dependency wiring and active source hits for logging, analytics,
  telemetry, crash, local event ledger, and widget metadata.

## Files Changed

- `docs/canon/Ambitions_Logging_Analytics_Observability_Policy.md`
- `docs/audits/pfc29-logging-analytics-observability-policy-report.md`
- global order, optimized order, dependency graph, registry, context, PFC train,
  and run-state docs

## What Changed

- Added the active PFC29 logging/analytics/observability policy.
- Locked the current runtime decision: no remote analytics, no remote telemetry,
  no third-party crash SDK, no developer diagnostics collection.
- Clarified that local Event Ledger / receipt records are user-trust product
  data, not developer telemetry.
- Clarified that `AppUI` widget `analyticsID` is local view-model/previews
  metadata, not a shipped analytics pipeline.
- Added future observability gates, redaction rules, and forbidden event fields.
- Advanced global state from PFC29 queued to PFC29 Green and selected PFC30 as
  the next eligible global batch.

## Product Decisions Preserved

- Ambitions remains Today / Goals / Capture / Plan / You.
- Ambitions remains local-first in current repo evidence.
- No analytics, crash reporting, remote telemetry, tracking, ad SDK, account,
  sync, cloud, hosted AI, release, App Store, TestFlight, physical-device, or
  public accessibility claim was added.

## Validation Commands

- `git status --short`
- `git diff --check`
- touched-file trailing whitespace scan
- logging/analytics/telemetry/crash source scan
- `scripts/cqs-product-drift-scan.sh || true`
- `scripts/cqs-privacy-security-claim-scan.sh || true`
- `scripts/cqs-accessibility-motion-scan.sh || true`
- `scripts/cqs-performance-budget-scan.sh || true`
- `scripts/cqs-prompt-built-smell-scan.sh || true`
- `scripts/cqs-architecture-boundary-scan.sh || true`
- `scripts/cqs-preview-coverage-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git diff --check`: PASS.
- Touched-file trailing whitespace scan: PASS.
- Logging/analytics/telemetry/crash source scan: PASS WITH YELLOW. Hits are
  local product event ledger/receipt code, `AppUI` preview/view-model metadata,
  EventKit save-event method names, and policy/audit docs. No active analytics
  SDK, crash SDK, remote telemetry pipeline, tracking SDK, or developer
  diagnostics upload was found.
- CQS privacy/security claim scan: PASS WITH YELLOW. Advisory hits are existing
  forbidden-claim/token guardrails and current no-claim wording.
- CQS product drift scan: PASS WITH YELLOW. Existing broad backlog remains
  outside PFC29 scope; no top-level IA or product identity change was made.
- CQS accessibility/motion scan: PASS WITH YELLOW. No UI changed.
- CQS performance budget scan: PASS WITH YELLOW. No runtime performance path
  changed.
- CQS prompt-built smell scan: PASS WITH YELLOW. Existing placeholder/generic
  wording backlog remains outside PFC29 scope.
- CQS architecture boundary scan: PASS WITH YELLOW. Existing Domain SwiftUI
  import and large-file advisories remain; no production architecture changed.
- CQS preview coverage scan: PASS WITH YELLOW. Existing preview/state advisory
  backlog remains; no UI surface changed.
- `scripts/run-doc-qa.sh || true`: PASS WITH YELLOW. Stale/deprecated guidance
  and markdownlint backlog remain existing repo advisory debt; lychee checked
  650 links with 650 OK.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. Yellow was the
  expected pre-commit dirty tree for PFC29 files only.

## Repairs Attempted

- Replaced the PFC29 report validation placeholder with actual gate results.

## Remaining Yellow Items

- Existing CQS/doc-QA advisory backlog may remain outside PFC29 scope.
- Future observability, crash reporting, telemetry, analytics, or diagnostics
  upload requires a new approved implementation/privacy/security/legal batch.
- Final App Privacy labels, privacy manifest, signed-binary inspection,
  App Store review, TestFlight upload, physical-device proof, release approval,
  and public accessibility conformance remain human/operator gates.

## Red Classification

No Recoverable Red or Hard Red found during implementation.

## Rollback Path

Revert the PFC29 commit to remove the observability policy and restore PFC29 to
queued in global order, registry, context, PFC train, and run-state docs.

## Next Eligible Batch

PFC30 Performance Budget And Instruments Plan is next under full-stack order.

## Continuation Decision

PFC29 may continue to PFC30 after validation passes and the batch is committed.
