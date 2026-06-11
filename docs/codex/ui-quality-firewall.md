# UI Quality Firewall

Status: Active UIQL governance
Authority: Required front-door gate for Ambitions Flagship UI Quality Lockdown issues, subordinate to `docs/truth/*`, `AGENTS.md`, and active Linear AMB issues.
Program: UIQL

## What This Is

The UI Quality Firewall is the permanent closeout gate for Ambitions UI work. It prevents Codex from reporting Green when evidence only proves that files exist, tests ran, screenshots were generated, or components were renamed.

Use this document for AMB-957 and every later UIQL issue before commit, push, and Linear closeout.

## What This Is Not

This is not implementation proof, screenshot approval, accessibility certification, owner approval, device proof, release proof, TestFlight readiness, App Store readiness, or product completion proof.

This is not a replacement for:

- `docs/truth/*`
- `docs/codex/ambitions_final_ui_quality_proof_standard.md`
- `docs/codex/ambitions_no_card_replacement_taxonomy.md`
- `docs/codex/ambitions_ui_review_checklist.md`
- `artifacts/ui-quality-lockdown/UIQL_GOAL.md`
- the active real Linear AMB issue

## Required Identifier Rule

`UIQL-*` labels are sequence/title labels only. They are not Linear issue identifiers.

Codex must fetch, update, comment, and close Linear using the mapped `AMB-*` issue ID:

- UIQL-001 = AMB-956
- UIQL-002 = AMB-957
- UIQL-003 = AMB-958
- UIQL-004 = AMB-959
- UIQL-005 = AMB-960
- UIQL-006 = AMB-961
- UIQL-007 = AMB-962
- UIQL-008 = AMB-963
- UIQL-009 = AMB-964
- UIQL-010 = AMB-965
- UIQL-011 = AMB-966
- UIQL-012 = AMB-967
- UIQL-013 = AMB-968
- UIQL-013.5 = AMB-970
- UIQL-014 = AMB-969

## Non-Negotiable Firewall Rules

Codex must not report Green when any of these are true:

- Green is based on artifact existence.
- Green is based on generated screenshot paths alone.
- Green is based on renamed components without rendered anatomy replacement.
- Green is based on focused tests alone.
- Dock text or navigation is unreadable.
- Safe areas collide with status bar, Dynamic Island, home indicator, keyboard, tab bar, toolbar, or Capture seam.
- The first viewport uses generic card, list, dashboard, settings-stack, form, calendar-clone, chatbot, or AI-wrapper anatomy.
- Active user-facing copy contains implementation/spec/debug/admin language.
- Surface work lacks required accessibility variant evidence.
- A Codex agent claims final owner approval before AMB-969 / UIQL-014.

These are Red, not accepted Yellow:

- ugly UI
- weak or generic design
- clipped text
- unreadable dock
- unsafe shell geometry
- generic first-viewport anatomy
- missing trust/source/receipt path where the surface claims intelligence
- missing accessibility semantics for touched UI
- screenshot-path-only visual proof
- Codex self-approval of final visual quality

## Allowed Yellow

Yellow is allowed only for external, tooling, or device limitations after documented attempts. Examples:

- simulator unavailable after a recorded attempt
- local screenshot capture blocked by tooling
- physical device not available when not required by the issue
- manual human review not provided when the issue does not require it
- Linear connector unavailable after preparing exact manual comment text

Yellow must include:

- exact limitation
- attempted command or action
- artifact path
- owner or next issue
- no-claim boundary

Yellow is not allowed for product quality defects.

## Required Inputs

Every UIQL issue must read or cite:

- active Linear AMB issue
- `artifacts/ui-quality-lockdown/UIQL_GOAL.md`
- `artifacts/ui-quality-lockdown/UIQL-run-state.md`
- `artifacts/ui-quality-lockdown/UIQL_LINEAR_RECONCILIATION_20260611.md`
- active truth files listed in `AGENTS.md`
- relevant source owners or proof artifacts
- existing primitives before inventing or renaming UI structure

## Required Scripts

Run these for every UIQL closeout unless the issue is explicitly read-only and a script is not applicable:

- `bash scripts/codex/program-preflight.sh uiql`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
- `git diff --check`
- `bash scripts/codex/program-proof-index.sh uiql`

The UIQL mini-regression runs:

- `uiql-scan-banned-copy.sh`
- `uiql-scan-card-anatomy.sh`
- `uiql-scan-shell.sh`

The scans log repo-wide findings for classification and fail on changed Swift source that introduces UIQL blockers. A passing scan is not proof of visual quality; it is only one closeout guard.

## Required Evidence By Work Type

| Work type | Required evidence |
|---|---|
| Docs/process only | docs paths, issue template/firewall report, preflight, mini-regression, diff-check, proof-index |
| Shell/root work | source ownership proof, safe-area proof, dock legibility proof, Capture-not-tab proof, focused tests when available |
| Surface reconstruction | active root proof, product object proof, screenshot visual evaluation, accessibility variants, copy scan, card-anatomy scan, focused tests |
| Copy purge | changed-source scan, rendered UI proof where copy is user-facing, no stale IA or implementation copy |
| Visual anatomy purge | before/after inventory, rendered first-viewport evaluation, primitive reuse evidence, no-card taxonomy classification |
| Accessibility pass | Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, VoiceOver semantics/order, tap target evidence |
| Final owner package | recommendation only: Approve, Conditional Approve, or Deny; no owner approval claim |

## Closeout Block

Every UIQL closeout must include this block:

```markdown
UIQL firewall verdict: Green / Yellow / Red
Actual Linear issue: AMB-___
UIQL sequence label:
Active root/source dependency:
Product object:
Surface owner:
Existing primitives inspected:
Screenshot visual evaluation:
Accessibility variant evidence:
Copy/canon scan:
Card/list/dashboard anatomy scan:
Shell/safe-area/dock proof:
Focused validation:
Changed files:
Proof artifacts:
Red blockers:
Yellow tooling/device limits:
No-claim boundary:
Next dependency:
```

## Red Escalation

If a Red remains after three repair cycles, Codex must create a Red Escalation Report instead of closing Green.

The report must state:

- real AMB issue
- changed files
- exact Red blocker
- evidence inspected
- failed repair attempts
- smallest safe next action
- rollback option
- manual Linear text if connector update fails

## Rollback And Failure Behavior

Rollback applies only to the current AMB issue edits unless the owner explicitly requests broader rollback. Do not revert earlier pushed commits during a later UIQL issue unless the issue requires it and the user approves it.

If validation exposes a product Red, stop the issue, document it, and do not proceed to the next AMB issue.

## Linear Closeout

After a successful push to `main`, update the real AMB issue with:

- commit hash
- files changed
- validation commands and status
- artifacts and screenshots
- Green/Yellow/Red status
- no-claim boundary
- next dependency

Never update Linear using a synthetic `UIQL-*` label.
