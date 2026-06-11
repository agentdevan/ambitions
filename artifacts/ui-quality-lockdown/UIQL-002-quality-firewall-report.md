# AMB-957 / UIQL-002 Quality Firewall Report

Status: Green for docs/process plus lightweight script install, pending push.

## Issue Identity

Actual Linear issue: AMB-957
UIQL sequence label: UIQL-002
Title: Install UI Quality Firewall
Project: Ambitions Flagship UI Quality Lockdown

`UIQL-002` is not a Linear identifier. All Linear operations for this gate use AMB-957.

## Mission

Install the permanent UI Quality Firewall so future UIQL work cannot close Green from weak evidence:

- artifact existence
- screenshot paths alone
- renamed components alone
- focused tests alone
- unreadable dock
- safe-area collision
- first-viewport generic anatomy
- implementation/spec/debug language
- missing accessibility variant evidence
- owner approval claims before AMB-969 / UIQL-014

## Files Installed Or Updated

- `docs/codex/ui-quality-firewall.md`
- `docs/codex/uiql-issue-template.md`
- `.agents/skills/uiql-quality-lockdown/SKILL.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-closeout-template.md`
- `.agents/skills/uiql-quality-lockdown/scripts/uiql-scan-banned-copy.sh`
- `.agents/skills/uiql-quality-lockdown/scripts/uiql-scan-card-anatomy.sh`
- `.agents/skills/uiql-quality-lockdown/scripts/uiql-scan-shell.sh`
- `artifacts/ui-quality-lockdown/UIQL-002-quality-firewall-report.md`

## Firewall Rule Coverage

| Required rule | Installed coverage |
|---|---|
| No Green by artifact existence | `docs/codex/ui-quality-firewall.md` non-negotiable rules and closeout block |
| No Green by generated screenshot paths alone | firewall doc, issue template screenshot section, closeout template |
| No Green by renamed components | firewall doc and no-card/card-anatomy scan |
| No Green by focused tests alone | firewall doc and issue template |
| No Green with unreadable dock | firewall doc closeout block and shell/safe-area proof section |
| No Green with safe-area collision | firewall doc and issue template Red conditions |
| No Green with first-viewport card/list/dashboard/settings/form anatomy | firewall doc, issue template, card-anatomy scan |
| No Green with implementation/spec/debug language | firewall doc, issue template, banned-copy scan |
| No Green without accessibility variant evidence for surface work | firewall doc and issue template accessibility section |
| No final owner approval until UIQL-014 | firewall doc, issue template, closeout template |

## Script Behavior

The UIQL mini-regression now uses lightweight deterministic scripts that:

- write repo-wide reference findings to `artifacts/ui-quality-lockdown/script-output/`
- fail on changed Swift source that introduces UIQL-banned copy
- fail on changed Swift source that introduces unclassified card/list/dashboard anatomy terms
- verify the active shell source contract remains Today / Goals / Time / Motion / You
- fail if changed shell source introduces stale IA or top-level Capture/Pulse/Profile/Plan risks

The scripts do not claim existing repo-wide findings are fixed. Existing findings remain classification evidence for the relevant future AMB issue.

## Candidate Green Closeout Block Installed

The required closeout block is installed in:

- `docs/codex/ui-quality-firewall.md`
- `docs/codex/uiql-issue-template.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-closeout-template.md`

## Yellow Policy

Yellow is limited to external, tooling, or device limitations after documented attempts. Product-quality defects remain Red.

## Owner Approval Boundary

Owner approval is reserved for AMB-969 / UIQL-014. UIQL-014 may recommend Approve, Conditional Approve, or Deny, but Codex must not claim owner approval.

## App Source Boundary

No app source, tests, Xcode project files, product runtime behavior, dependencies, entitlements, or app resources are changed by AMB-957.

## Validation

- `git diff --check` - passed.
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh` - passed after Bash 3 portability repair to the scan scripts.
- `bash scripts/codex/program-preflight.sh uiql` - passed, result `GREEN`, artifact `artifacts/ui-quality-lockdown/script-output/program-preflight-20260611T074628.log`.
- `bash scripts/codex/program-proof-index.sh uiql` - passed, wrote `artifacts/proof-ledger/proof-index.json` with `12` entries, artifact `artifacts/ui-quality-lockdown/script-output/program-proof-index-20260611T074628.log`.

## UIQL Firewall Verdict Block

UIQL firewall verdict: Green
Actual Linear issue: AMB-957
UIQL sequence label: UIQL-002
Active root/source dependency: Active shell contract checked by `uiql-scan-shell.sh`; `AppTab.allCases` and `AmbitionsRootView` root `Tab` values must remain Today / Goals / Time / Motion / You.
Product object: Permanent UI quality closeout gate; no product runtime object changed.
Surface owner: UIQL governance under `docs/codex/`, `.agents/skills/uiql-quality-lockdown/`, and `artifacts/ui-quality-lockdown/`.
Existing primitives inspected: `docs/codex/ambitions_final_ui_quality_proof_standard.md`, `docs/codex/ambitions_no_card_replacement_taxonomy.md`, `docs/codex/ambitions_ui_review_checklist.md`, and `docs/codex/ambitions_primitive_green_gate.md`.
Screenshot visual evaluation: Not applicable for docs/process gate; firewall now forbids screenshot-path-only Green for later surface work.
Accessibility variant evidence: Not applicable for docs/process gate; firewall now requires variant evidence for surface work.
Copy/canon scan: `uiql-scan-banned-copy.sh` passes for changed Swift source and logs repo-wide reference findings for classification.
Card/list/dashboard anatomy scan: `uiql-scan-card-anatomy.sh` passes for changed Swift source and logs repo-wide reference findings for classification.
Shell/safe-area/dock proof: `uiql-scan-shell.sh` verifies canonical root shell source contract; no UI shell source changed.
Focused validation: UIQL mini-regression passed; no app tests required for docs/process-only install.
Changed files: docs/process, UIQL skill/templates/scripts, UIQL artifacts, proof ledger.
Proof artifacts: this report and `artifacts/proof-ledger/PROOF_LEDGER.md`.
Red blockers: none for AMB-957 scope.
Yellow tooling/device limits: none.
No-claim boundary: no UI implementation, screenshot approval, accessibility certification, owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, performance proof, privacy/legal approval, or product completion.
Next dependency: AMB-958 / UIQL-003 Runtime Shell Proof Refresh.

## No-Claim Boundary

This install does not claim UI implementation repair, screenshot approval, accessibility certification, owner approval, release readiness, TestFlight readiness, App Store readiness, physical-device proof, performance proof, privacy/legal approval, or product completion.

## Next Dependency

After AMB-957 is pushed and Linear is updated, the next issue is AMB-958 / UIQL-003 Runtime Shell Proof Refresh.
