# Source Atlas Pack Compiler and R2 Dry-Run Controls Train 4

Status: Source Green for pack compiler/R2 dry-run controls
Source Atlas status ceiling: Yellow overall Source Atlas; pack compiler and R2 dry-run controls only

Scope completed:
- Deterministic pack compiler from Train 3 claim/frontier output.
- Pack slices for claims, entities, sources, licenses, freshness, adjudications, non-claims, attribution, and coverage.
- Manifest with object keys, SHA-256 hashes, registry/frontier/claim graph hashes, revocation key, LKG key, rollback candidates, and cache policy.
- Revocation manifest, LKG pointer, rollback plan, non-private scan, and R2 dry-run plan.
- Execute path approval gates without production upload.

Files changed:
- tools/source-atlas/foundry/pack_production.py
- tools/source-atlas/foundry/cli.py
- tools/source-atlas/foundry/tests/test_pack_production_train_04.py
- tools/source-atlas/generated/pack-production/train-04-fixture/*
- docs/qa/source-atlas/r2/source-atlas-pack-production-train-04.json
- docs/qa/source-atlas/r2/source-atlas-pack-production-train-04.md

Product law preserved:
- R2 remains public/reference/freshness infrastructure only.
- Dry-run plan contains public object keys only and no credentials.
- Pack output contains public/reference claims only.
- Source Atlas does not generate final plans, schedules, or Steps.

Validation run:
- python3 tools/source-atlas/source-atlas-foundry.py pack-production --input-root tools/source-atlas/generated/claim-frontier/train-03-fixture --output-root tools/source-atlas/generated/pack-production/train-04-fixture --domain occupation_foundation --environment staging --channel candidate --created-at 2026-06-27T00:00:00Z
- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests
- python3 scripts/source-atlas-boundary-audit.py
- python3 scripts/source-atlas-no-private-graph-egress-audit.py
- python3 scripts/ambitions-green-standard-audit.py
- python3 scripts/ambitions-local-first-boundary-scan.py
- git diff --check

Validation not run:
- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON evidence, and generated Source Atlas artifacts only.
- Production R2 upload/readback not run.
- Outside legal review not run or claimed.

Proof artifacts:
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/pack.json
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/manifest.json
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/r2-dry-run-plan.json
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/revocations.json
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/lkg.json
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/rollback-plan.json
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/non-private-scan-report.json
- tools/source-atlas/generated/pack-production/train-46-travel-production-stable/closeout.md

R2 request privacy proof:
- No production R2 request path changed or executed.
- Dry-run object keys passed private-key segment validation.
- Dry-run plan contains no credentials or private user context.

No private graph egress proof:
- Non-private scan passed for pack slices, manifest, revocation, LKG, rollback, and dry-run plan.
- Pack non-claims forbid private graph, final path, final schedule, Step list, and personalized plan output.

License/terms proof:
- License slice is generated from governed legal/terms registry entries for included packable sources.
- Restricted/crosswalk-only/review-required claims are excluded from pack slices.
- Outside legal approval is not claimed.

Restricted-source exclusion proof:
- Blocked claims excluded: 0.
- USAJOBS and Wikidata crosswalk claims are not included in the packable claim slice.

Provenance completeness proof:
- Pack input is restricted to Train 3 packable claims with complete provenance tuples.
- Manifest includes the Train 3 claim graph hash.

Freshness/revocation proof:
- Freshness slice is generated for included claims.
- Revocation manifest is emitted.
- Runtime revocation handling is not claimed in this train.

LKG/rollback proof:
- LKG pointer and rollback plan are emitted as dry-run artifacts.
- No stable R2 pointer update ran.

Native offline/no-account proof:
- Not claimed in Train 4. No native files changed and no XCTest/build-for-testing gate was required.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas.
- Files moved or created: pack production compiler, tests, generated Source Atlas pack/R2 dry-run evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: real R2 upload/readback, native fetch/cache/verify, source inspection, and broad domain expansion remain unproven.
- Next repair train if debt remains: production publisher/readback proof or native fetch/cache/verify integration.
- No equivalent folder/path interpretation was used.

Known risks:
- This train does not prove production R2 write/readback.
- This train does not prove native app fetch/cache/verify behavior.
- Only the occupation foundation frontier has packable claim coverage in current evidence.

Follow-up required:
- Add production publisher upload/readback proof when explicitly approved.
- Add native public-pack fetch/cache/verify integration.
- Expand governed source lanes and adapters for non-occupation domains.

Rollback plan:
- Revert the pack production compiler, CLI command, tests, generated Train 4 artifacts, and QA evidence packet.

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
