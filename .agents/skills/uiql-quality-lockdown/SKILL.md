---
name: uiql-quality-lockdown
description: Use for Ambitions UIQL Goal Mode execution, visual/accessibility gates, shell/copy/card-anatomy scans, proof packaging, and Linear closeout boundaries.
---

# UIQL Quality Lockdown

Authority: Program skill for UIQL, subordinate to `docs/truth/*` and `artifacts/ui-quality-lockdown/UIQL_GOAL.md`.
What it is: Reusable UIQL procedure and deterministic script bundle.
What it is not: App implementation proof, screenshot approval, accessibility certification, release proof, or owner approval.

Use for AMB-956 through AMB-970, whose titles carry UIQL-001 through UIQL-014 sequence labels. Do not use for backend/runtime work, dependency additions, release claims, or source changes outside the active AMB issue.

Issue identifier rule: `UIQL-*` is a sequence label only, never a Linear identifier. Before work or closeout, fetch/update the actual AMB issue ID:

- AMB-956 = UIQL-001 - AOR Failure Postmortem + Supersession
- AMB-957 = UIQL-002 - Install UI Quality Firewall
- AMB-958 = UIQL-003 - Runtime Shell Proof Refresh
- AMB-959 = UIQL-004 - Shell Safe-Area + Dock Legibility Repair
- AMB-960 = UIQL-005 - Visual Anatomy Purge
- AMB-961 = UIQL-006 - Active UI Copy Purge
- AMB-962 = UIQL-007 - Today Reconstruction
- AMB-963 = UIQL-008 - Goals Reconstruction
- AMB-964 = UIQL-009 - Time Reconstruction
- AMB-965 = UIQL-010 - Motion Reconstruction
- AMB-966 = UIQL-011 - You Reconstruction
- AMB-967 = UIQL-012 - Capture + Create Goal Reconstruction
- AMB-968 = UIQL-013 - Accessibility Variant Proof Pass
- AMB-970 = UIQL-013.5 - Independent Red-Team Visual Audit
- AMB-969 = UIQL-014 - Final Owner Approval Package

If the AMB issue cannot be fetched, stop with manual AMB closeout text. Do not fetch or update `UIQL-*` as a Linear issue. Do not continue implementation while `artifacts/ui-quality-lockdown/UIQL_LINEAR_RECONCILIATION_20260611.md` is pending owner review.

Inputs: active issue, changed files, truth files, screenshots/logs when available. Outputs: script logs, reviewer output, proof ledger entries, and Linear closeout after push.

Green requires no product Yellow, no generic UI anatomy, no forbidden copy, actual visual evaluation when claimed, bounded accessibility proof, and no app-source surprise. Yellow is only tooling/manual/device proof gaps. Red stops on ugly UI, unsafe shell geometry, clipped text, generic anatomy, stale IA promoted as active, or proof overclaims.

Repair owning surface or reframe claim. Roll back current issue edits only. Linear closeout after push includes proof paths and no release/owner approval claims.
