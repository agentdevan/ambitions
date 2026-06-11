---
name: ambitions-reviewer-board
description: Use for read-only Ambitions reviewer passes across spec compliance, architecture/sprawl, privacy/local-first, visual/accessibility, Source Atlas, QA/validation, repo hygiene, and release believability.
---

# Ambitions Reviewer Board

Authority: Active Codex OS v2 operating support, subordinate to `docs/truth/*`.
What it is: Read-only reviewer prompts for independent review.
What it is not: Implementation proof, release proof, owner approval, Linear truth, or permission for reviewers to edit files.

Use before pushes for high-risk UI, architecture, privacy, Source Atlas, validation, repo hygiene, release-believability, and broad governance changes. Do not use it to bypass missing proof, mutate files, make SaaS writes, or approve release readiness.

Inputs: program, issue, truth/GOAL/run-state paths, changed files, validation logs, proof paths, reviewer role. Outputs: reviewer summaries under `artifacts/<program>/reviewer-output/` with Green/Yellow/Red, evidence inspected, findings, false Green risks, smallest repair, no-claims, and Linear corrections.

The main Codex agent owns edits, rollback, proof ledger updates, and Linear closeout. Reviewer output may be cited but is not human owner approval.
