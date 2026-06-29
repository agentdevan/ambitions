# Source Atlas Governed Harvest Runner Train 2

Status: Source Green for governed harvest runner
Source Atlas status ceiling: Yellow overall Source Atlas; governed harvest runner only

Scope completed:
- Governed fixture-first runner manifest.
- Live/write flag gates.
- Governance registry preflight.
- API budget and missing-key checks.
- Deterministic evidence hashes.
- Restricted-source exclusion proof.

Files changed:
- tools/source-atlas/foundry/harvest_runner.py
- tools/source-atlas/foundry/cli.py
- tools/source-atlas/foundry/tests/test_governed_harvest_runner_train_02.py
- tools/source-atlas/generated/governed-harvest/train-02-fixture/manifest.json
- tools/source-atlas/generated/governed-harvest/train-02-fixture/closeout.md
- tools/source-atlas/generated/governed-harvest/train-02-fixture/evidence/*.json
- tools/source-atlas/generated/governed-harvest/train-02-fixture/normalized/*.json

Product law preserved:
- R2 remains public/reference/freshness infrastructure only.
- Runner output contains public/reference adapter fixtures and provenance evidence only.
- Source Atlas does not receive private user goals, captures, schedules, proof, receipts, behavior history, or private graph data.
- Source Atlas does not generate final plans, schedules, or Steps.

Validation run:
- python3 tools/source-atlas/source-atlas-foundry.py governed-harvest --mode fixture --output-root tools/source-atlas/generated/governed-harvest --run-id train-02-fixture --created-at 2026-06-27T00:00:00Z
- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests
- python3 scripts/source-atlas-boundary-audit.py
- python3 scripts/source-atlas-no-private-graph-egress-audit.py
- python3 scripts/ambitions-green-standard-audit.py
- python3 scripts/ambitions-local-first-boundary-scan.py
- git diff --check

Validation not run:
- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON evidence, and Source Atlas generated artifacts only.
- Production R2 upload/readback not run.
- Outside legal review not run or claimed.

Proof artifacts:
- tools/source-atlas/generated/governed-harvest/train-41-education-credential-fixture/manifest.json
- tools/source-atlas/generated/governed-harvest/train-41-education-credential-fixture/closeout.md

R2 request privacy proof:
- No production R2 request path changed or executed.
- Governed harvest output emits local public/reference evidence only.
- Restricted and crosswalk-only lanes are excluded from pack-candidate output.

No private graph egress proof:
- Manifest privacy scan passed.
- Normalized blocked lanes have packCandidates cleared before output.
- Runner non-claims forbid private graph, final path, final schedule, Step list, and personalized plan output.

License/terms proof:
- Runner requires Train 1 governance registry validation before output.
- Pack-candidate eligibility is filtered by source lane R2 pack policy.
- Outside legal approval is not claimed.

Restricted-source exclusion proof:
- USAJOBS emits an exclusion proof and zero pack candidates.
- Wikidata crosswalk-only output emits an exclusion proof and zero pack candidates.

Provenance completeness proof:
- Runner emits deterministic evidence hashes per adapter output.
- Claim-level provenance completeness remains a later claim graph train and is not claimed here.

Freshness/revocation proof:
- Source-state fixture outputs are preserved from adapter coverage.
- Runtime revocation and stale-critical quarantine are not claimed in this train.

LKG/rollback proof:
- Not claimed in Train 2. No stable R2 publish, pointer update, or rollback operation ran.

Native offline/no-account proof:
- Not claimed in Train 2. No native files changed and no XCTest/build-for-testing gate was required.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.
- Files moved or created: governed runner module, tests, CLI command, and generated Source Atlas runner evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: none from this tooling slice; claim graph/frontier/R2/native trains remain unproven.
- Next repair train if debt remains: Train 3 claim graph and coverage frontier.
- No equivalent folder/path interpretation was used.

Known risks:
- This runner does not prove app runtime fetch/cache/verify behavior.
- Live network harvesting still requires explicit live execution evidence.
- Claim graph/frontier/pack/R2/native trains remain incomplete.

Rollback plan:
- Revert the governed harvest runner module, CLI command, tests, generated runner artifacts, and this evidence packet.

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
- not live production harvest proof unless --live evidence is separately reviewed
- not a final user plan, schedule, or Step generator
