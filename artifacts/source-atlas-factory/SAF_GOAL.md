# SAF GOAL - Source Atlas Factory

Program: SAF
Execution model: Goal Mode, main only, no branches
Scope: Govern and wrap existing Source Atlas scripts/tools/runtime for pack, seed, R2, release, revocation, and runtime eligibility gates
Forbidden scope: duplicate Source Atlas tooling, private user data in R2, runtime-eligible pack without source binding/freshness/revocation, high-risk pack without risk/jurisdiction/review state, hardcoded personal Steps where reusable seeds are required

Extend existing Source Atlas scripts/tools/runtime. Do not duplicate implementation. Gates: pack manifest, seed schema, R2 boundary, coverage demand, release receipt, rollback/revocation, reviewer board, Linear closeout after push.

Red stops: private user data in R2, source-free runtime eligibility, missing freshness/revocation, high-risk pack without jurisdiction/review, hardcoded personal Steps in reusable seeds, duplicate architecture, or release/readiness claims without proof.

Repair by binding to existing Source Atlas owners, narrowing pack eligibility, or downgrading release state. Roll back current-run artifacts only. Linear closeout includes pack/seed gate status, proof paths, hash, non-claims, and next gate.
