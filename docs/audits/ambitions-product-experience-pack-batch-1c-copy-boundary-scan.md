# Ambitions Product Experience Pack Batch 1C Copy-Boundary Scan

Status: Batch 1C complete; docs/planning only
Date: 2026-05-04

## 1. Result

Yellow / Stopped.

Batch 1C ran a docs-only risky-copy scan, created a copy-boundary registry, and
updated the Product Experience Pack handoff maps. It did not edit app code,
SwiftUI feature surfaces, navigation, design tokens, persistence, sync, auth,
network, AI/LDI runtime, CI/config, tests, previews, fixtures, generated files,
or product source truth.

## 2. Batch / Task Name

Batch 1C — Product Experience Pack Copy-Boundary Scan.

## 3. Source Truth Used

- User-provided Product Experience Pack lock for Batch 1C.
- Batch 0 repo reconnaissance report.
- Batch 1A traceability map.
- Batch 1A file-boundary map.
- Batch 1A boundary report.
- Batch 1B reconciliation report.
- Existing repo files and architecture inspected read-only.
- Existing Codex OS / train rules through the handoff maps.

## 4. Batch 0 Evidence Used

- Branch was `main`.
- Product Depth remains parked until the exact approval phrase.
- Global batch train remains parked.
- Legacy compatibility vocabulary exists internally.
- Top-level tabs remain Today, Goals, Capture, Plan, You.
- Copy risks from Batch 0 remain: legacy Habits/Insights/Profile naming,
  technical failure vocabulary, score/confidence-oriented domain terms, and
  source/privacy/trust wording that needs user-facing review.

## 5. Batch 1A Evidence Used

- Batch 1A created the initial traceability map, file-boundary map, and
  boundary report.
- Batch 1A identified copy-boundary risk but did not remediate copy.

## 6. Batch 1B Evidence Used

- Batch 1B separated internal compatibility vocabulary from user-facing copy
  risk.
- Batch 1B marked app code, navigation, theme, persistence, tests, previews,
  fixtures, runtime, CI/config, and generated files as outside docs-only scope.
- Batch 1B recommended Batch 1C as a docs-only copy-boundary scan.

## 7. Files Inspected

- `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md`
- `docs/audits/ambitions-product-experience-pack-batch-1a-boundary-report.md`
- `docs/audits/ambitions-product-experience-pack-batch-1b-reconciliation-report.md`
- `docs/canon/**`
- `docs/codex/**`
- `docs/handoff/**`
- `docs/audits/**`
- `Native/Ambitions/**`
- `Sources/**`
- `Native/AmbitionsTests/**`
- `Native/AmbitionsUITests/**`
- `scripts/**`
- `project.yml`
- `Package.swift`

The initial broad scan included a missing `Tests` path in the requested
category list; the effective repo test paths inspected were
`Native/AmbitionsTests/**` and `Native/AmbitionsUITests/**`.

## 8. Files Changed

- `docs/handoff/Ambitions_Product_Experience_Pack_Repo_Traceability_Map.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_File_Boundary_Map.md`
- `docs/audits/ambitions-product-experience-pack-batch-1c-copy-boundary-scan.md`

## 9. Product Decisions Preserved

- Ambitions remains a premium iPhone-native life operating system.
- Top-level tabs remain Today, Goals, Capture, Plan, You.
- Capture remains text-first.
- Plan remains LifeShape-first.
- You remains trust/control-first.
- Proof remains evidence, not achievement.
- Receipt remains consequence and reversibility, not notification.
- Source remains freshness, conflict, and review boundary.
- Privacy remains user control.
- Generated visual-board copy remains non-binding unless repeated in locked
  source truth.

## 10. Caveats Preserved

- Internal compatibility vocabulary may remain if not user-facing and required
  for migration/history.
- User-facing surfaces must obey Product Experience Pack copy rules.
- Candidate items were not upgraded.
- You / Privacy / Memory / Receipts remain copy-density guarded.
- Automation and trust remain permission posture only.
- Source must not become certification.
- Proof must not become trophy/gamification.
- Receipt must not become feed/notification posture.
- Privacy must not become surveillance/detection tone.

## 11. Candidate Items Touched Or Avoided

Touched as planning references only:

- User-facing copy remediation.
- Compatibility vocabulary boundaries.
- Fixture/preview/accessibility copy risk.

Avoided:

- No Candidate item was finalized.
- No internal compatibility cases were renamed.
- No source strings were changed.
- No Batch 2 was created.
- Product Depth and global train remained parked.

## 12. Copy Scan Summary

Scan commands searched exact and case-insensitive risky terms across docs,
source, tests, scripts, and package/config files. Findings are broad and
expected in this repo because many hits are negative examples, compatibility
seams, technical state names, source-truth guardrails, or historical audit
records.

High-signal clusters:

- User-facing risk: Habit/Ritual preview copy, Insights/History metric labels,
  Goal confidence/explainability labels, external snapshot urgency/mode labels,
  ScreenContract forbidden-copy lists, and privacy/source labels that need
  wording review before user-facing reuse.
- Internal compatibility/domain allowed: `AppTab` compatibility cases,
  external route fallbacks, async `.failed` states, receipt `failedSafely`
  values, stale/source states, domain confidence/score models, goal modes, and
  legacy import contracts.
- Historical docs/source-truth allowed: canon forbidden lists, audit reports,
  train prompts, release-claim ledgers, and validation scripts using risky terms
  as negative examples or technical pass/fail vocabulary.
- Test/fixture/preview risk: `Native/Ambitions/PreviewSupport/**`,
  `Sources/Previews/**`, and `Native/AmbitionsTests/**` include copy that may
  be screenshot-visible, spoken in accessibility evidence, or asserted as
  product contract.

This batch intentionally does not resolve every occurrence.

## 13. Copy-Boundary Registry Summary

| Term | File path | Context summary | Classification | Risk | Future treatment | Source edit later | Approval required | Replacement if user-facing |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `habit` / `habits` | `Native/Ambitions/App/AppTab.swift`, `Native/Ambitions/App/AppExternalRouting.swift`, `Native/Ambitions/Features/Habits/**`, `Native/Ambitions/Features/Shared/HabitGoalSemantics.swift` | Compatibility cases, routes, and ritual-derived internals. | B. Internal compatibility / domain allowed | Green if not surfaced; Yellow if visible | Preserve internals; inventory visible labels before edits. | Only for visible labels or approved retirement | Yes for enum/route edits | Time, capacity, and defaults / Your time, your rules |
| `habit` / `habits` | `Native/Ambitions/PreviewSupport/PreviewHabitsScenarios.swift`, `Native/Ambitions/PreviewSupport/PreviewPlanScenarios.swift` | Preview copy includes Habits owner names, streak/rhythm metrics, and "Routines and habits." | D. Test / fixture / preview risk | Yellow | Stage 3 fixture/preview correction before screenshots or visual QA. | Yes, in preview batch | Yes if preview contracts change | Time, capacity, and defaults / Rituals where current canon permits |
| `score` | `Native/Ambitions/Domain/**`, `Native/Ambitions/Services/**` | Domain scoring and ranking fields for deterministic model logic. | B. Internal compatibility / domain allowed | Green if not exposed | Preserve technical semantics; prevent visible labels from saying score. | No unless UI leak is proven | Yes for model contract edits | Review state / Source state / Proof state |
| `score` | `Native/Ambitions/Services/GoalExplainabilityProjector.swift` | Builds visible-looking labels such as understanding/path score. | A. User-facing risk | Red if rendered directly | Stage 2 inventory, then Stage 4 visible UI correction. | Likely yes if rendered | Yes | Review state / Source state / Proof state |
| `stale` | `Sources/Components/LoadingDegradedStatePrimitives.swift`, `Native/Ambitions/ExternalSnapshots/**`, `Native/Ambitions/Domain/GoalEngine/GoalFreshnessUpdateModels.swift` | Source freshness/degraded states. | B. Internal/domain allowed with user-facing guard | Yellow | Preserve freshness meaning; confirm visible copy says source may be stale. | Only where copy says generic stale | Yes for external snapshot copy | Source may be stale |
| `overdue` | `Native/Ambitions/Domain/CommitmentWaitingModels.swift`, `Native/Ambitions/ExternalSnapshots/**`, `Native/AmbitionsWidgetExtension/**` | Technical timing state and external urgency mapping. | B/E. Domain or non-user-facing risk | Yellow | Inventory external/widget visible labels before any release claim. | Maybe | Yes for contracts/widgets | Review needed / Recovery available |
| `failed` / `fail` | `Native/Ambitions/UI/AsyncViewState.swift`, `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`, `Native/Ambitions/Domain/ActionClosureReceiptModels.swift`, tests | Technical async, command, receipt, and validation state. | B/C. Internal compatibility and historical allowed | Green if technical | Preserve raw values and tests; do not bulk rename. | No unless visible copy leaks | Yes for enum/raw value edits | Blocked / Still counts / Needs recovery |
| `failed` / `fail` | `Native/Ambitions/Features/*/*ViewModel.swift`, `Native/Ambitions/Features/*/*Screen.swift` | Feature view models and screen switches use technical failed states. | F. Ambiguous, needs later review | Yellow | Stage 2 inventory to inspect rendered messages and accessibility labels. | Maybe | Yes per touched feature | Blocked / Needs recovery |
| `streak` | `Native/Ambitions/PreviewSupport/PreviewHabitsScenarios.swift`, tests, docs/canon forbidden lists | Preview metrics and negative examples. | D/C. Preview risk and source-truth history | Yellow | Correct preview-facing metrics before screenshots; preserve forbidden lists. | Yes for previews | Yes if screenshot evidence changes | Proof / Evidence / Current rhythm if approved |
| `confidence` | `Native/Ambitions/Domain/**`, `Native/Ambitions/Services/**`, `docs/codex/batches/**` | Technical recommendation/source model fields and train names. | B/C. Internal/domain and historical allowed | Green if not surfaced | Preserve internals; map visible copy to review/source/proof states. | No unless UI leak is proven | Yes for model contract edits | Review state / Source state / Proof state |
| `confidence` | `Native/Ambitions/Services/GoalExplainabilityProjector.swift`, `Native/Ambitions/PreviewSupport/PreviewFixtures.swift` | Visible-looking labels and accessibility expectation mention source confidence. | A/D. User-facing or fixture risk | Red/Yellow | Stage 2 inventory; Stage 3/4 correction if rendered. | Likely yes | Yes | Review state / Source state / Proof state |
| `verified` | `Sources/Accessibility/**`, `Sources/Components/RichPanelPrimitives.swift`, release support docs | Accessibility claim state, often explicit non-claim or evidence lock. | B/C. Technical claim-gating allowed | Yellow | Preserve release/accessibility claim lock semantics; avoid product trust certification. | No unless visible product claim leaks | Yes for claim language | Source-backed only if true / Review source |
| `sensitive` / `sensitive data` | `Sources/Components/**`, `Native/Ambitions/ExternalSnapshots/**`, `Native/Ambitions/Persistence/PortableSnapshotContracts.swift` | Privacy and redaction states. | B/F. Privacy domain allowed, tone needs review | Yellow | Keep control/redaction framing; avoid detection tone. | Maybe | Yes for privacy/trust surfaces | Details hidden from previews / Private detail hidden |
| `tracked` / `monitored` | docs, preview copy, analytics/history contexts | Can imply surveillance if user-facing. | F. Ambiguous, needs later review | Yellow | Search visible strings in Stage 2; replace if user-facing. | Maybe | Yes for trust/privacy copy | Remembered items / You control what Ambitions remembers |
| `surveillance` | docs/canon and Batch docs | Mostly negative examples and guardrails. | C. Historical/source-truth allowed | Green | Preserve as forbidden concept in docs; avoid product claims. | No | No | You control what Ambitions remembers |
| `trophy` / `achievement` | `Native/Ambitions/ExternalSnapshots/**`, `Native/Ambitions/Domain/GoalEngine/**`, docs/canon forbidden lists | Goal mode/domain vocabulary and negative examples. | B/F. Domain allowed, possible visible risk | Yellow | Inventory rendered goal mode labels and external surfaces. | Maybe | Yes for contracts | Proof / Evidence |
| `notification feed` / `activity feed` | docs/canon | Negative examples and future caveats. | C. Historical/source-truth allowed | Green | Preserve guardrails; avoid feed framing in UI. | No | No | Receipts / History / Evidence Ledger |
| `optimized` / `AI optimized` / `AI decided` | docs/canon, docs/codex, domain copy | Mostly negative examples; some "optimize" language in planning/recovery copy. | C/F. Historical or ambiguous | Yellow | Stage 2 inventory before any user-facing use. | Maybe | Yes | Review before changing / Ambitions asks before consequential changes |
| `fully automated` | docs/canon and codex prompts | Negative example / forbidden language. | C. Historical/source-truth allowed | Green | Preserve as guardrail only. | No | No | Ambitions asks before consequential changes |
| `classified as` | docs/audits, docs/canon, reports | Audit classification language. | C. Historical/source-truth allowed | Green | Preserve in audit/report contexts; avoid using to describe user identity or private data. | No | No | Review state / Source state |
| `profile` | `Native/Ambitions/Features/Profile/**`, `AppTab.profile`, tests/docs | Internal owner for user-facing You. | B. Internal compatibility allowed | Green if label remains You | Preserve owner names; only visible copy inventory if "Profile" appears to user. | Only if user-facing leak | Yes for route/owner edits | You / Personal System Center |
| `insights` | `Native/Ambitions/Features/Insights/**`, `AppTab.insights`, routes/tests/docs | Contextual intelligence/history compatibility. | B. Internal compatibility allowed | Green if not top-level tab | Preserve route/model names; inventory visible labels for History/Review wording. | Only if user-facing leak | Yes for route edits | History / Review / Contextual intelligence |

## 14. Internal Compatibility Rule Summary

Internal compatibility cases may remain when they preserve history, migration,
routing compatibility, raw-value compatibility, technical state, or legacy data
interpretation. Internal naming does not automatically equal user-facing copy.

Future implementation must prevent internal compatibility words from leaking
into visible labels, VoiceOver labels, receipts, headers, buttons, tab labels,
empty states, onboarding copy, external snapshot copy, or screenshots unless
the active product source truth permits the wording.

Any source edit touching compatibility enums, routes, raw values, model
contracts, migration paths, external snapshots, or async/result taxonomy
requires explicit scope, focused tests, and compatibility evidence.

## 15. Future Copy Remediation Boundary Summary

| Stage | Purpose | Allowed files | Forbidden files | Required validation | Required evidence | Stop conditions |
| --- | --- | --- | --- | --- | --- | --- |
| Stage 1 | Docs-only scan and classification | `docs/audits/*copy-boundary*`, handoff maps | App/source code | `git diff --check`, doc QA, gate check | Registry and risk classes | Any app edit requested |
| Stage 2 | User-facing string inventory | Docs/audit output only; source inspect-only | Source edits | `rg` scans, doc QA | File/path/string inventory with rendered-risk notes | Ambiguous ownership |
| Stage 3 | Fixtures/previews copy correction | Preview/fixture files only if explicitly scoped | App runtime, navigation, persistence, CI | Focused preview/fixture scans; optional snapshot/preview validation | Before/after copy list; screenshot or preview evidence if used | Copy changes affect product contracts |
| Stage 4 | Visible UI copy correction | Named feature/source files only by explicit batch | Navigation, persistence, theme, runtime, broad refactors | Focused tests for touched feature; copy scan | Rendered string inventory and replacement proof | Internal enum/raw value change required |
| Stage 5 | VoiceOver/accessibility label correction | Named accessibility labels/hints only | Identifier churn without alias/test plan | Focused accessibility/UI tests or manual evidence plan | Labels/hints before and after | Stable identifier risk |
| Stage 6 | Receipt/source/privacy copy correction | Named trust/receipt/source/privacy files only | Persistence/schema/runtime without scope | Receipt/source/privacy tests and scan | Proof that source is review/freshness, receipt is consequence, privacy is control | Certification/detection/feed tone appears |
| Stage 7 | Regression scan | Scripts/docs/report only; source inspect-only | New product edits | risky-copy scan, doc QA, relevant tests from stages 3-6 | Final hit classification and residual risk | Unclassified Red user-facing hit |

## 16. File-Boundary Update Summary

The file-boundary map now includes copy-boundary categories for Green allowed
preservation, Yellow inventory candidates, Yellow test/fixture/preview
candidates, Red forbidden bulk changes, and Stop/user-decision copy files.

## 17. Anti-Generic QA

This scan preserves the active IA and does not create a generic task app,
calendar clone, habit tracker, productivity scoring system, chatbot surface,
notification feed, activity feed, or enterprise dashboard.

## 18. Accessibility / Reduced Motion Impact

No UI changed. Accessibility risk is limited to future copy work: VoiceOver
labels, hints, values, and screenshot/preview evidence need explicit inventory
before any remediation. Reduced Motion is unaffected in Batch 1C.

## 19. Privacy / Trust Impact

No privacy behavior changed. The registry marks privacy/source/receipt copy as
approval-gated for future remediation so privacy stays user control, source
stays freshness/conflict/review boundary, and receipts stay consequence and
reversibility.

## 20. Validation Commands Run

- `git status --short`
- `git diff --check`
- touched-doc trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

Optional scan commands run:

- `rg -n -i '\b(habit|habits|score|stale|overdue|failed|fail|streak|confidence|AI verified|verified|sensitive|sensitive data|tracked|monitored|surveillance|trophy|achievement|notification feed|activity feed|optimized|AI optimized|AI decided|fully automated|classified as|profile|insights)\b' ...`
- `rg -n -i '"[^"]*(habit|habits|score|stale|overdue|failed|fail|streak|confidence|AI verified|verified|sensitive|tracked|monitored|surveillance|trophy|achievement|notification feed|activity feed|optimized|AI optimized|AI decided|fully automated|classified as|profile|insights)[^"]*"' Native/Ambitions Sources`
- `rg -n -i 'Score may be stale|Sensitive info policy|AI verified|AI optimized|AI decided|fully automated|classified as|confidence percentage|productivity loss|sensitive data detected|notification feed|activity feed|trophy|surveillance' ...`

## 21. Validation Results

- `git status --short`: showed only the two modified handoff docs and the new
  Batch 1C audit doc before staging.
- `git diff --check`: passed with no whitespace errors.
- Touched-doc trailing whitespace scan: no matches.
- `scripts/run-doc-qa.sh || true`: completed. Advisory stale-guidance,
  deprecated-language, and markdownlint backlog remains broad and pre-existing;
  lychee passed with 650 total links and 0 errors. New logs were written under
  `docs/audits/doc-qa/20260504-190041-*`.
- `scripts/batch-train-gate-check.sh || true`: completed with Yellow hint for
  the expected uncommitted Batch 1C docs and no build run because `RUN_BUILD=1`
  was not set.

## 22. Stop Conditions Encountered

- Product Depth approval phrase was not provided.
- Global train continuation was not authorized.
- Copy remediation requires future explicit source scope.
- Internal compatibility terms cannot be bulk-renamed without migration proof.
- Test/fixture/preview copy may require separate approval and validation.
- VoiceOver/accessibility label correction requires explicit inventory.
- Receipt/source/privacy copy correction requires trust-boundary proof.

## 23. Recommended Next Action

Batch 1D follow-up completed in
`docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md` and
`docs/audits/ambitions-product-experience-pack-batch-1d-readiness-gate-report.md`.

Current recommended one next action: Batch 1E docs-only final file-boundary
approval and implementation-planning gate.

Do not start Product Depth unless the user gives the exact approval phrase from
the Product Depth manifest.

## 24. Commit / Push Status

Pending staging, commit, and push after evidence report completion.
