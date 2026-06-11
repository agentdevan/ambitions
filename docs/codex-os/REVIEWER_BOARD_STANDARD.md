# Reviewer Board Standard

Status: Active Codex OS v2 standard
Authority: Process standard, subordinate to `docs/truth/*`

## What It Is

A read-only reviewer board for spec compliance, architecture/sprawl, privacy/local-first, visual/accessibility, Source Atlas, QA/validation, repo hygiene, and release believability.

## What It Is Not

It is not implementation proof, release proof, owner approval, or permission for reviewers to edit files.

## Required Reviewer Output

Green/Yellow/Red status, exact evidence inspected, findings by severity, false Green risks, smallest repair/reframe, no-claim boundaries, and Linear closeout corrections.

## Use / Do Not Use

Use before pushes for high-risk UI, architecture, privacy, Source Atlas, release/readiness, and broad governance changes. Do not use reviewers to bypass missing proof, mutate files, make SaaS writes, or approve release readiness.

## Outputs

Reviewer output belongs under `artifacts/<program>/reviewer-output/` and may be indexed in run-state and proof ledger as process evidence.

## Gates

Green: no blocking findings in scope.
Yellow: non-blocking risk or missing external proof is explicit.
Red: false Green risk, boundary violation, product conflict, privacy/release overclaim, or duplicate architecture.

## Repair / Rollback / Linear

Main agent repairs, updates run-state/proof, and reruns reviewers when useful. Linear cites reviewer output paths but not human approval.
