# UIQL GOAL - Flagship UI Quality Lockdown

Program: UIQL
Active project: Ambitions Flagship UI Quality Lockdown
Execution model: Goal Mode, main only, no branches
Scope: UIQL-only quality governance, scans, proof standards, visual/accessibility review workflow, and issue gates
Forbidden scope: backend/runtime dependencies, release claims, broad app-source implementation outside active UIQL issue, top-level IA changes without active truth

## Linear Identifier Rule

Codex must never fetch, update, close, or comment on Linear using synthetic `UIQL-*` labels. Codex must always use the mapped `AMB-*` issue ID for Linear operations. `UIQL-*` is a title/sequence label only, not a Linear identifier.

Before every UIQL issue, Codex must fetch and update the actual AMB issue ID from this mandatory mapping:

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

If an `AMB-*` issue cannot be fetched, stop and produce manual closeout text for the AMB issue. Do not fall back to fetching `UIQL-*`. Do not continue UIQL implementation after issue-ID drift until the owner reviews `artifacts/ui-quality-lockdown/UIQL_LINEAR_RECONCILIATION_20260611.md`.

Active IA is `Today / Goals / Time / Motion / You`. Capture is a global action only, not a tab. AOR is historical only. Screenshot path is not proof. Product Yellow is not allowed for ugly UI, weak design, unsafe shell geometry, unreadable dock, clipped text, generic card/list/dashboard/form/calendar/chatbot anatomy, or missing accessibility semantics.

## Issue Order

1. AMB-956 / UIQL-001 - AOR Failure Postmortem + Supersession.
2. AMB-957 / UIQL-002 - Install UI Quality Firewall.
3. AMB-958 / UIQL-003 - Runtime Shell Proof Refresh.
4. AMB-959 / UIQL-004 - Shell Safe-Area + Dock Legibility Repair.
5. AMB-960 / UIQL-005 - Visual Anatomy Purge.
6. AMB-961 / UIQL-006 - Active UI Copy Purge.
7. AMB-962 / UIQL-007 - Today Reconstruction.
8. AMB-963 / UIQL-008 - Goals Reconstruction.
9. AMB-964 / UIQL-009 - Time Reconstruction.
10. AMB-965 / UIQL-010 - Motion Reconstruction.
11. AMB-966 / UIQL-011 - You Reconstruction.
12. AMB-967 / UIQL-012 - Capture + Create Goal Reconstruction.
13. AMB-968 / UIQL-013 - Accessibility Variant Proof Pass.
14. AMB-970 / UIQL-013.5 - Independent Red-Team Visual Audit.
15. AMB-969 / UIQL-014 - Final owner package; owner approval boundary only, no approval claim.

Use `UIQL-run-state.md` to minimize context churn. Run `uiql-preflight.sh` before work and `uiql-mini-regression.sh` before closeout. Use reviewer board before push when useful. Push main after honest close, then update Linear or prepare manual text.

Repair generic/ugly UI before closeout. Reframe screenshot paths as not proof. Roll back current UIQL edits only. UIQL proof does not prove release readiness, device validation, legal/privacy approval, or complete accessibility conformance.
