# Source Atlas Claim Graph and Coverage Frontier Train 3

Status: Source Green for claim/frontier tooling
Source Atlas status ceiling: Yellow overall Source Atlas; claim graph and coverage frontier tooling only

Scope completed:
- Canonical public claim graph over governed harvest output.
- Claim-level provenance tuple gate.
- Citation graph for inspectable public references.
- Coverage frontier reports for pilot domains.
- Restricted, crosswalk-only, stale, conflicted, review-required, missing-provenance, and missing-legal blockers.

Files changed:
- tools/source-atlas/foundry/claim_frontier.py
- tools/source-atlas/foundry/cli.py
- tools/source-atlas/foundry/public_reference_adapters.py
- tools/source-atlas/foundry/tests/test_claim_frontier_train_03.py
- tools/source-atlas/frontier/coverage-frontiers.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/manifest.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/claim-graph.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/citation-graph.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/coverage-frontier-report.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/closeout.md

Product law preserved:
- R2 remains public/reference/freshness infrastructure only.
- Claim graph output contains public/reference claims and citations only.
- Source Atlas does not receive private user goals, captures, schedules, proof, receipts, behavior history, or private graph data.
- Source Atlas does not generate final plans, schedules, or Steps.

Validation run:
- python3 tools/source-atlas/source-atlas-foundry.py governed-harvest --mode fixture --output-root tools/source-atlas/generated/governed-harvest --run-id train-02-fixture --limit 25 --created-at 2026-06-27T00:00:00Z
- python3 tools/source-atlas/source-atlas-foundry.py claim-frontier --input-root tools/source-atlas/generated/governed-harvest/train-02-fixture --output-root tools/source-atlas/generated/claim-frontier/train-03-fixture --created-at 2026-06-27T00:00:00Z
- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests
- python3 scripts/source-atlas-boundary-audit.py
- python3 scripts/source-atlas-no-private-graph-egress-audit.py
- python3 scripts/ambitions-green-standard-audit.py
- python3 scripts/ambitions-local-first-boundary-scan.py
- git diff --check

Validation not run:
- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON config, and generated Source Atlas evidence only.
- Production R2 upload/readback not run.
- Outside legal review not run or claimed.

Proof artifacts:
- manifest.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/claim-graph.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/citation-graph.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/coverage-frontier-report.json
- tools/source-atlas/generated/claim-frontier/train-03-fixture/closeout.md

R2 request privacy proof:
- No production R2 request path changed or executed.
- Claim/frontier output is local generated evidence only.
- Object key publication and stable-channel promotion remain unclaimed.

No private graph egress proof:
- Manifest privacy scan passed.
- Claim graph non-claims forbid private graph, final path, final schedule, Step list, and personalized plan output.
- Coverage frontiers report public source lanes and public claim classes only.

License/terms proof:
- Packable claims require source lane pack policy and legal registry pack_output_allowed=true.
- Missing or ambiguous legal/terms posture blocks pack output.
- Outside legal approval is not claimed.

Restricted-source exclusion proof:
- USAJOBS remains blocked from packable claims.
- Wikidata remains crosswalk-only and cannot satisfy regulated authority.

Provenance completeness proof:
- Packable claim provenance completeness: 1.00.
- Every packable claim carries source lane, locator, retrieval time, evidence hash, and adjudication rule.
- Missing provenance blocks pack output at claim level.

Freshness/revocation proof:
- Stale-critical, revoked, conflicted, and terms-blocked claims are blocked from pack output.
- Runtime revocation handling is not claimed in this train.

LKG/rollback proof:
- Not claimed in Train 3. No stable R2 publish, pointer update, or rollback operation ran.

Native offline/no-account proof:
- Not claimed in Train 3. No native files changed and no XCTest/build-for-testing gate was required.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; tooling/config/evidence only under tools/source-atlas.
- Files moved or created: claim frontier compiler, tests, config, and generated Source Atlas evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: generalized pack compiler, R2 production publisher, native fetch/cache/verify, and source inspection remain unproven.
- Next repair train if debt remains: Train 4 coverage ontology/frontier expansion or Train 5 pack/R2 generalization, depending sequencing.
- No equivalent folder/path interpretation was used.

Known risks:
- This train does not prove production pack compilation or stable R2 promotion.
- Non-occupation pilot domains remain below claim-graph-ready until adapters, legal review, and claim evidence are added.
- Native app runtime fetch/cache/verify behavior remains unproven.

Follow-up required:
- Generalize pack compiler and manifest slices.
- Add broader source discovery/frontier candidates behind review-required gates.
- Implement native public pack fetch/cache/verify in a later train.

Rollback plan:
- Revert the claim frontier compiler, CLI command, tests, frontier config, generated Train 3 artifacts, and the adapter provenance-ID repair if needed.

Production non-claims:
- not a private user-data backend
- not private life graph storage
- not an official legal, medical, financial, or admissions decision
- not runtime recommendation proof by itself
- not R2 release readiness
- not accessibility, privacy, or legal approval
- not full Source Atlas Green
- not production R2 readiness
- not native app runtime readiness
- not outside legal approval
- not universal goal coverage
- not a final user plan, schedule, or Step generator
