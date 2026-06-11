---
name: source-atlas-factory
description: Use for Source Atlas Factory Goal Mode execution, pack/seed/R2/revocation/release gates, and wrapping existing Source Atlas tooling without duplicating runtime architecture.
---

# Source Atlas Factory

Authority: Program skill for SAF, subordinate to `docs/truth/*` and `artifacts/source-atlas-factory/SAF_GOAL.md`.
What it is: Governance and script bundle for Source Atlas pack/seed lifecycle.
What it is not: New runtime implementation, pack release proof, privacy/legal approval, or release readiness.

Use for SAF pack/seed gates. Do not duplicate existing Source Atlas source/tools or publish runtime-eligible packs without gates.

Inputs: pack ID, source binding, freshness/revocation, risk/jurisdiction/review, changed files. Outputs: script logs, pack ledger, proof ledger, reviewer outputs, Linear closeout.

Green requires source binding, freshness, revocation, risk/jurisdiction/review, signature/hash, eligibility, release receipt, rollback, and non-claims. Yellow is unavailable external review or no runtime eligibility. Red stops on private data in R2, source-free packs, high-risk missing review, or duplicate architecture.
