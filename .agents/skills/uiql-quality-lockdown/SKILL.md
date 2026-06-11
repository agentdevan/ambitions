---
name: uiql-quality-lockdown
description: Use for Ambitions UIQL Goal Mode execution, visual/accessibility gates, shell/copy/card-anatomy scans, proof packaging, and Linear closeout boundaries.
---

# UIQL Quality Lockdown

Authority: Program skill for UIQL, subordinate to `docs/truth/*` and `artifacts/ui-quality-lockdown/UIQL_GOAL.md`.
What it is: Reusable UIQL procedure and deterministic script bundle.
What it is not: App implementation proof, screenshot approval, accessibility certification, release proof, or owner approval.

Use for UIQL-001 through UIQL-014. Do not use for backend/runtime work, dependency additions, release claims, or source changes outside active UIQL issue.

Inputs: active issue, changed files, truth files, screenshots/logs when available. Outputs: script logs, reviewer output, proof ledger entries, and Linear closeout after push.

Green requires no product Yellow, no generic UI anatomy, no forbidden copy, actual visual evaluation when claimed, bounded accessibility proof, and no app-source surprise. Yellow is only tooling/manual/device proof gaps. Red stops on ugly UI, unsafe shell geometry, clipped text, generic anatomy, stale IA promoted as active, or proof overclaims.

Repair owning surface or reframe claim. Roll back current issue edits only. Linear closeout after push includes proof paths and no release/owner approval claims.
