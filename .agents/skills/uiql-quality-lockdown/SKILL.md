---
name: uiql-quality-lockdown
description: Use for Ambitions UIQL Goal Mode execution, visual/accessibility gates, shell/copy/card-anatomy scans, proof packaging, and Linear closeout boundaries.
---

# UIQL Quality Lockdown

Authority: Program skill for UIQL, subordinate to `docs/truth/*` and `artifacts/ui-quality-lockdown/UIQL_GOAL.md`.
What it is: Reusable UIQL procedure and deterministic script bundle.
What it is not: App implementation proof, screenshot approval, accessibility certification, release proof, or owner approval.

Use for AMB-956 through AMB-970, whose titles carry UIQL-001 through UIQL-014 sequence labels. Do not use for backend/runtime work, dependency additions, release claims, or source changes outside the active AMB issue.

Issue identifier rule: Codex must never fetch, update, close, or comment on Linear using synthetic `UIQL-*` labels. Codex must always use the mapped `AMB-*` issue ID for Linear operations. `UIQL-*` is a title/sequence label only, not a Linear identifier.

Mandatory mapping:

- UIQL-001 = AMB-956 - AOR Failure Postmortem + Supersession
- UIQL-002 = AMB-957 - Install UI Quality Firewall
- UIQL-003 = AMB-958 - Runtime Shell Proof Refresh
- UIQL-004 = AMB-959 - Shell Safe-Area + Dock Legibility Repair
- UIQL-005 = AMB-960 - Visual Anatomy Purge
- UIQL-006 = AMB-961 - Active UI Copy Purge
- UIQL-007 = AMB-962 - Today Reconstruction
- UIQL-008 = AMB-963 - Goals Reconstruction
- UIQL-009 = AMB-964 - Time Reconstruction
- UIQL-010 = AMB-965 - Motion Reconstruction
- UIQL-011 = AMB-966 - You Reconstruction
- UIQL-012 = AMB-967 - Capture + Create Goal Reconstruction
- UIQL-013 = AMB-968 - Accessibility Variant Proof Pass
- UIQL-013.5 = AMB-970 - Independent Red-Team Visual Audit
- UIQL-014 = AMB-969 - Final Owner Approval Package

If the AMB issue cannot be fetched, stop with manual AMB closeout text. Do not fetch or update `UIQL-*` as a Linear issue. Do not continue implementation while `artifacts/ui-quality-lockdown/UIQL_LINEAR_RECONCILIATION_20260611.md` is pending owner review.

Inputs: active issue, changed files, truth files, screenshots/logs when available. Outputs: script logs, reviewer output, proof ledger entries, and Linear closeout after push.

For AMB-957 and later issues, use `docs/codex/ui-quality-firewall.md` and `docs/codex/uiql-issue-template.md` as required UIQL closeout gates. The firewall forbids Green by artifact existence, screenshot paths alone, renamed components, focused tests alone, unsafe shell geometry, unreadable dock, generic first-viewport anatomy, implementation/spec/debug copy, missing accessibility variants, or Codex self-approval. The template supplies the required closeout block.

Green requires no product Yellow, no generic UI anatomy, no forbidden copy, actual visual evaluation when claimed, bounded accessibility proof, and no app-source surprise. Yellow is only tooling/manual/device proof gaps. Red stops on ugly UI, unsafe shell geometry, clipped text, generic anatomy, stale IA promoted as active, or proof overclaims.

Repair owning surface or reframe claim. Roll back current issue edits only. Linear closeout after push includes proof paths and no release/owner approval claims.
