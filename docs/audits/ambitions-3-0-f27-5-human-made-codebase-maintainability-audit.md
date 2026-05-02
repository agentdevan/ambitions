# Ambitions 3.0 F27.5 Human-Made Codebase Maintainability Audit

Date: 2026-05-01

Status: GREEN

## Verdict

F27.5 is Green.

No critical maintainability blocker was found that should prevent F29 handoff
packaging. The repo still carries meaningful architecture debt, especially
large feature/service files and compatibility names, but those risks are
indexed, bounded, and understandable. They do not require opportunistic
renames or broad extraction before handoff packaging.

F29 and F30 may proceed only after this F27.5 report is committed and pushed.

## Active-Doc Freshness Fix

F27.5 found one active guidance issue:

- `docs/codex/README.md` and
  `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md` still
  described the old F17/F18 train entry point.
- `docs/codex/batches/F17_Shell_Meridian_Planning_And_Readiness_Audit_Prompt.md`
  still labeled the completed F17 prompt as the active next batch prompt.
- `docs/canon/Ambitions_3_0_FAANG_Handoff_Readiness_Gate.md` still described
  F27 as future-blocking instead of passed by current train evidence.

F27.5 fixed those lines so the active first-hour train entry now says F17-F28
are Green, F27.5 is the active checkpoint, and F29/F30 remain blocked until
F27.5 is Green; the F17 prompt is historical completed-batch evidence; and
F29 packaging is blocked until both F27 and F27.5 PASS.

## Compatibility Seams

These seams remain allowed and documented. They are not user-facing product
drift, but they must be preserved carefully:

| Seam | Owner | Reason retained | Exposure | Current coverage |
| --- | --- | --- | --- | --- |
| `Profile` feature/type names | You/Profile feature | Existing You surface is implemented through the Profile feature folder. | User-facing copy says You. | `ProfileFeatureServiceTests`, You/Profile UI smoke. |
| `Insights` route/models | App shell, You/history support | Legacy route/history compatibility and contextual intelligence surfaces. | Not a top-level tab. | Shell routing and legacy Insights route UI tests. |
| `Habits` route/models | Plan/Ritual compatibility | Saved routes and ritual support compatibility. | Not a top-level tab. | Shell/tab exclusion tests and Ritual/Plan tests. |
| `activeFocus` external snapshot field | Runtime/external snapshot compatibility | Preserves external snapshot schema stability. | Not visible app copy. | Runtime/external snapshot tests. |
| `TodayFocus*` and `.focus` semantics | Today compatibility/design-state seam | Broad internal compatibility after Step Session migration. | Visible copy uses Step Session/Start now where product-facing. | Today view model and UI tests. |
| Internal `.failed` states | Shared async/result state | Internal taxonomy remains useful for error handling and safe-failure receipts. | Visible copy is softened where active. | Receipt, command, and feature tests. |

Retirement should be schema-aware and route-aware. Blind renames remain riskier
than documented compatibility.

## Architecture Debt

`scripts/swiftui-architecture-scan.sh || true` remains advisory and reports
pre-existing extraction risks. Highest-risk examples:

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift` at 5024 lines.
- `Native/Ambitions/Features/Today/TodayFeatureService.swift` at 2718 lines.
- `Native/Ambitions/Features/Today/TodayPanels.swift` at 2423 lines.
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift` at 2394 lines.
- `Native/Ambitions/Features/Profile/ProfileScreen.swift` at 2167 lines.
- `Native/Ambitions/Features/Plan/PlanScreen.swift` at 1978 lines.
- Several domain and persistence files exceed the extraction-required
  threshold.

Classification: indexed maintainability debt, not a handoff-stopping blocker.
The next engineer should avoid adding behavior to extraction-required files
without first extracting a bounded state/projector/panel/service seam.

## Handoff Prerequisites

A new engineer can still find the current product and implementation path:

- active product truth starts from the Ambitions 3.0 source stack;
- canonical destinations remain `Today / Goals / Capture / Plan / You`;
- feature ownership is legible under `Native/Ambitions/App`,
  `Native/Ambitions/Features`, `Native/Ambitions/Domain`,
  `Native/Ambitions/Services`, and `Native/Ambitions/Persistence`;
- XcodeGen remains the project source of truth;
- build/test commands are documented and recently verified by F27/F28;
- release, accessibility, physical-device, TestFlight, App Store, and rendered
  external-platform claims remain evidence-gated.

## Validation

- Current branch: `main`.
- F28 repair checkpoint committed and pushed before F27.5 started:
  `2dfb4b24`.
- `scripts/swiftui-architecture-scan.sh || true`: advisory warnings only;
  no new code behavior was added by F27.5.
- `scripts/batch-train-gate-check.sh || true`: advisory Yellow while the
  intended F27.5 report/docs edits are in the working tree.
- `scripts/build-local.sh`: PASS. Log:
  `output/logs/build-local-20260501-224535.log`.
- Active-doc stale-entry scan: found and fixed the old F17/F18 train entry
  wording in active Codex/train docs.
- Build/test evidence carried from the immediately preceding F27/F28 gate:
  `scripts/test-local.sh` passed 779 unit tests and 29 UI tests in
  `output/logs/test-local-20260501-220744.log`.
- `git diff --check`: must pass before F27.5 closeout commit.

## Gate Decision

F27.5 is Green.

F29 Final Handoff Package + Engineer Onboarding is unblocked after this F27.5
checkpoint is committed and pushed. F30 remains blocked until F29 is Green.
