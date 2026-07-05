# Frontend Deletion And Quarantine Candidates

Status: Current-main quarantine registry / Implemented Yellow
Date: 2026-07-05
Scope: AMB-1751
Baseline SHA: `9885e8fbd32089c872376b47ff2aa8ab9b338afd`

## Quarantine Policy

This file names candidates only. AMB-1751 does not delete source, tests,
fixtures, screenshots, or docs. Deletion requires a scoped follow-up issue with
owner path, expected blast radius, and validation commands.

Classification terms:

- delete-candidate: likely removable after exact owner approval and validation.
- quarantine-candidate: keep but mark as historical, preview-only, test-only, or
  docs-only so it cannot support current runtime claims.
- retain-current: keep as active source/test/proof support.

## Candidates

| Candidate | Current classification | Recommendation | Reason | Required follow-up validation |
| --- | --- | --- | --- | --- |
| `Native/Ambitions/PreviewSupport` development assets | preview-only | quarantine-candidate | XcodeGen includes this as `DEVELOPMENT_ASSET_PATHS`, so it can support previews but must not be cited as runtime proof. | Follow-up should scan for production imports before any deletion. Run `git diff --check`, `python3 scripts/ambitions-quality-gate.py`, and XcodeGen drift check. |
| `docs/qa/evidence/2026-06-22-device-review/` screenshots | docs-only historical evidence | quarantine-candidate | Useful historical review artifact, but not current `main` rendered proof. | Keep as historical evidence; add current screenshot packet rather than deleting. |
| VSP/Figma packages under `docs/qa/evidence/2026-06-30-*` and `docs/qa/evidence/2026-07-01-*` | prototype / docs-only | quarantine-candidate | These record design or owner-review packages, not current SwiftUI runtime proof. | Follow-up docs should label any reused artifact as design reference only. |
| `docs/audits/amb-1749-frontend-evidence-harness.md` and `.json` | retain-current | retain-current | Active harness/index for future screenshot and frontend evidence lanes. | Keep; run `python3 scripts/ambitions-frontend-evidence-harness.py --check --json` when testing lanes are allowed. |
| `docs/audits/amb-1747-stage-shell-frontend-reality-audit.md` | retain-current | retain-current | Prior source-route audit remains useful but is superseded by AMB-1751 registries for current-main screen/journey recovery state. | Cross-link rather than delete. |
| Stale root labels `Plan`, `Pulse`, `Profile`, `Captures` in tests | test-only | quarantine-candidate | Many hits are negative assertions that protect current IA. They should stay if they assert absence, but should not be cited as active surface evidence. | Follow-up should separate negative-assertion tests from stale fixture copy before edits. Run focused source scans and quality gate. |
| `ShellCommandDestination.staleIADestinationBlockers` stale labels | retain-current | retain-current | This is active guard code blocking stale IA destinations such as Plan, Pulse, Profile, calendar, and inbox. | Do not delete without replacement guard. |
| `You` copy containing `Profile` as source label | production-copy review candidate | quarantine-candidate | Some source labels use Profile to describe user profile facts, not a root tab. Review for user-facing canon consistency before source edits. | Follow-up owner path: `Native/Ambitions/Surfaces/You/Projection/`. Validate copy scan and screen snapshots when tests return. |
| `Time` copy containing calendar language | production-copy review candidate | retain-current / review | Product canon now requires calendar-grade Time while forbidding calendar-clone framing and silent calendar writes. Do not delete blindly. | Follow-up should distinguish native Life Calendar language from stale Calendar root-route assumptions. |
| Wrapper inspection views with no direct proof path in this pass | active source, proof-limited | retain-current | `ProofInspectionView`, `PrivacyInspectionView`, and `ReceiptInspectionView` are active wrappers, but need invocation proof. | Follow-up should add journey evidence before any deletion consideration. |
| External snapshot contracts | active source, external proof-limited | retain-current | Widget/share/app-intent routes use these contracts from active XcodeGen targets. | Do not delete in frontend cleanup. External route proof belongs to a scoped external-surface train. |

## Follow-Up Leaves

| Leaf | Scope | Owner paths | Validation when testing is allowed |
| --- | --- | --- | --- |
| AMB-1751-FU-Q1 | Preview/development asset quarantine label audit | `Native/Ambitions/PreviewSupport`, preview-only Swift files, docs references | `git diff --check`; `python3 scripts/ambitions-quality-gate.py`; `scripts/ambitions-xcodegen-needed.sh` |
| AMB-1751-FU-Q2 | Historical screenshot evidence labeling | `docs/qa/evidence/2026-06-22-device-review/`, VSP/Figma evidence folders | markdown checks; `git diff --check`; release claim scan over changed docs |
| AMB-1751-FU-Q3 | Stale surface label source split | `Native/Ambitions/Surfaces/You/Projection/`, `Native/AmbitionsTests/`, `Native/AmbitionsUITests/` | source scan for root labels; focused tests only after testing permission returns |
| AMB-1751-FU-Q4 | Trust inspection invocation proof | `Native/Ambitions/Trust/`, `Native/Ambitions/Surfaces/You/` | screenshot/UI route lane after testing permission returns |

## Non-Deletion Result

No production source path should be deleted from AMB-1751. The current source
graph needs proof, not broad cleanup. Candidates above are routing and evidence
hygiene inputs for later scoped leaves.
