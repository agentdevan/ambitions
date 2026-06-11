# UIQL Linear Mapping Patch - 2026-06-11

Status: Reconciliation/tooling only
Branch: `main`
Base commit: `7d681b0fd8e4fe9727630726fcad014a758af59e`

## Issue-ID Drift Summary

The repo Goal Mode UIQL adapter used synthetic labels such as `UIQL-001`, `UIQL-002`, and later `UIQL-*` as if they were Linear identifiers. The real Linear project is `Ambitions Flagship UI Quality Lockdown`, and its actual issue IDs are AMB-956 through AMB-970.

This patch binds the UIQL adapter to the real AMB issue IDs and makes the rule explicit:

> Codex must never fetch, update, close, or comment on Linear using synthetic `UIQL-*` labels. Codex must always use the mapped `AMB-*` issue ID for Linear operations. `UIQL-*` is a title/sequence label only, not a Linear identifier.

## Actual AMB Mapping

| UIQL label | Actual Linear issue | Title |
| --- | --- | --- |
| UIQL-001 | AMB-956 | AOR Failure Postmortem + Supersession |
| UIQL-002 | AMB-957 | Install UI Quality Firewall |
| UIQL-003 | AMB-958 | Runtime Shell Proof Refresh |
| UIQL-004 | AMB-959 | Shell Safe-Area + Dock Legibility Repair |
| UIQL-005 | AMB-960 | Visual Anatomy Purge |
| UIQL-006 | AMB-961 | Active UI Copy Purge |
| UIQL-007 | AMB-962 | Today Reconstruction |
| UIQL-008 | AMB-963 | Goals Reconstruction |
| UIQL-009 | AMB-964 | Time Reconstruction |
| UIQL-010 | AMB-965 | Motion Reconstruction |
| UIQL-011 | AMB-966 | You Reconstruction |
| UIQL-012 | AMB-967 | Capture + Create Goal Reconstruction |
| UIQL-013 | AMB-968 | Accessibility Variant Proof Pass |
| UIQL-013.5 | AMB-970 | Independent Red-Team Visual Audit |
| UIQL-014 | AMB-969 | Final Owner Approval Package |

## Files Patched

- `artifacts/ui-quality-lockdown/UIQL_GOAL.md`
- `artifacts/ui-quality-lockdown/UIQL-run-state.md`
- `artifacts/ui-quality-lockdown/UIQL_DECISIONS.md`
- `.agents/skills/uiql-quality-lockdown/SKILL.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-closeout-template.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-reviewer-prompts.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-red-escalation-template.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-repair-reframe-template.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-accessibility-proof-standard.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-final-owner-package-standard.md`
- `.agents/skills/uiql-quality-lockdown/references/uiql-screenshot-proof-standard.md`
- `artifacts/ui-quality-lockdown/UIQL_LINEAR_MAPPING_PATCH_20260611.md`

## App Source Confirmation

No app source changed in this mapping patch. This patch does not modify Swift source, tests, Xcode project files, product implementation, dependencies, entitlements, or app resources.

## Pushed Synthetic UIQL Commits Retained As Partial Evidence Only

- `c2321a555c9a7b033210cc9c064ec0de82345ad7` - `UIQL-001 preflight authority refresh`
- `1043c1df11737fb7620c9951e92b3a8e61a9f686` - `UIQL-001 repair activation contract canon`
- `2aefb43b96f3e7c1bf6742e823b256f4cc833f1e` - `UIQL-002 repair shell geometry safe areas`
- `bd487793aa57e7488fee905f93761133d84d3014` - `UIQL-003 close Today Reality Meridian quality gate`
- `d4b273e299ac4a207759d9104685a223dbfb9bbd` - `UIQL-004 lock Start Here recommendation object`
- `2d9dd87549ef71887ec10d363f5a1f9381436eec` - `UIQL-005 lock Goals direction quality gate`
- `8dbc7065a4652da93bc77d0e3915e450a178d3e1` - `UIQL-006 lock Time LifeShape Field quality gate`
- `fba3d1b00a349c58f408012e058aeaecd7a8446e` - `UIQL-007 lock Motion Current quality gate`

These commits remain partial repo evidence only. They do not close any actual AMB Linear issue unless a later owner-reviewed AMB issue closeout explicitly accepts them.

## Linear Closure Status

Actual Linear issues remain unclosed unless separately updated by AMB ID. Synthetic `UIQL-*` labels must not be used for Linear operations.

## Next Executable Issue

Next executable issue: AMB-956 - UIQL-001 AOR Failure Postmortem + Supersession.

Do not continue UIQL implementation until the owner reviews the reconciliation and mapping patch.

## Manual Linear Comment Text

If Linear update is unavailable, post this to AMB-956 manually:

```text
UIQL Goal Mode issue-ID drift was reconciled. Prior synthetic UIQL commits are retained as partial repo evidence only and do not close any AMB issue. UIQL Goal Mode adapter now maps UIQL labels to actual Linear issue IDs AMB-956 through AMB-970. Next executable issue is AMB-956.
```
