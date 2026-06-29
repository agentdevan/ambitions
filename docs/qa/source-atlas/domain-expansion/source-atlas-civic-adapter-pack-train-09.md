# Source Atlas Civic Adapter and Pack Dry-Run Train 9

Status: Green for Source Atlas civic adapter/pack dry-run tooling / Yellow overall Source Atlas

Source Atlas status ceiling: Yellow overall Source Atlas; civic adapter/claim/pack dry-run evidence only.

Scope completed:
- Added deterministic `nara.constitution.presidency` fixture adapter coverage for public civic/government requirements.
- Emitted public constitutional and eligibility claims, requirements, provenance, freshness, and one pack candidate under reviewed governance.
- Compiled public civic claim frontier evidence with packable claims and complete provenance.
- Produced `public_civic_requirements` staging pack-production dry-run artifacts with manifest hashes, revocation, LKG, rollback, and non-private scan.

Files changed:
- `tools/source-atlas/foundry/public_reference_adapters.py`
- `tools/source-atlas/foundry/terms_registry.py`
- `tools/source-atlas/foundry/broad_domain_discovery.py`
- `tools/source-atlas/foundry/tests/test_broad_domain_discovery_train_07.py`
- `tools/source-atlas/foundry/tests/test_civic_adapter_train_09.py`
- `tools/source-atlas/frontier/coverage-frontiers.json`
- `tools/source-atlas/generated/governed-harvest/train-09-civic-fixture/*`
- `tools/source-atlas/generated/claim-frontier/train-09-civic-fixture/*`
- `tools/source-atlas/generated/pack-production/train-09-civic-fixture/*`
- `docs/qa/source-atlas/domain-expansion/source-atlas-civic-adapter-pack-train-09.json`
- `docs/qa/source-atlas/domain-expansion/source-atlas-civic-adapter-pack-train-09.md`

Product law preserved:
- R2 remains public/reference/freshness infrastructure only.
- No private goals, captures, schedules, proof, receipts, behavior history, account identifiers, or private runtime context enter Source Atlas output.
- Civic fixture output does not generate final plans, schedules, or Steps.
- Civic references are public/reference evidence only and do not become legal advice or guaranteed eligibility.

Validation run:
- `python3 -m pytest tools/source-atlas/foundry/tests/test_civic_adapter_train_09.py`
- `python3 tools/source-atlas/source-atlas-foundry.py governed-harvest --mode fixture --output-root tools/source-atlas/generated/governed-harvest --run-id train-09-civic-fixture --source nara.constitution.presidency --limit 6 --created-at 2026-06-27T00:00:00Z`
- `python3 tools/source-atlas/source-atlas-foundry.py claim-frontier --input-root tools/source-atlas/generated/governed-harvest/train-09-civic-fixture --output-root tools/source-atlas/generated/claim-frontier/train-09-civic-fixture --created-at 2026-06-27T00:00:00Z`
- `python3 tools/source-atlas/source-atlas-foundry.py pack-production --input-root tools/source-atlas/generated/claim-frontier/train-09-civic-fixture --output-root tools/source-atlas/generated/pack-production/train-09-civic-fixture --domain public_civic_requirements --environment staging --channel candidate --created-at 2026-06-27T00:00:00Z`
- `python3 tools/source-atlas/source-atlas-foundry.py broad-domain-discovery --output-root tools/source-atlas/generated/broad-domain-discovery/train-07-fixture --created-at 2026-06-27T00:00:00Z --emit-evidence docs/qa/source-atlas/domain-expansion/source-atlas-broad-domain-discovery-train-07.json --markdown docs/qa/source-atlas/domain-expansion/source-atlas-broad-domain-discovery-train-07.md`
- `python3 -m pytest tools/source-atlas/foundry/tests/test_civic_adapter_train_09.py tools/source-atlas/foundry/tests/test_broad_domain_discovery_train_07.py tools/source-atlas/foundry/tests/test_claim_frontier_train_03.py tools/source-atlas/foundry/tests/test_pack_production_train_04.py`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
- `python3 scripts/source-atlas-boundary-audit.py`
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
- `python3 scripts/ambitions-green-standard-audit.py`
- `python3 scripts/ambitions-local-first-boundary-scan.py`
- `git diff --check`

Validation not run:
- Native XCTest/build-for-testing not run because Train 9 changed Python tooling, JSON frontier/config, generated Source Atlas artifacts, and QA evidence only.
- Live NARA/static page harvest not run.
- Production R2 upload/readback not run.
- Stable-channel promotion not run.
- Outside legal review not run or claimed.

Proof artifacts:
- `tools/source-atlas/generated/governed-harvest/train-09-civic-fixture/manifest.json`
- `tools/source-atlas/generated/governed-harvest/train-09-civic-fixture/evidence/nara.constitution.presidency.json`
- `tools/source-atlas/generated/governed-harvest/train-09-civic-fixture/normalized/nara.constitution.presidency.json`
- `tools/source-atlas/generated/claim-frontier/train-09-civic-fixture/manifest.json`
- `tools/source-atlas/generated/claim-frontier/train-09-civic-fixture/claim-graph.json`
- `tools/source-atlas/generated/claim-frontier/train-09-civic-fixture/citation-graph.json`
- `tools/source-atlas/generated/claim-frontier/train-09-civic-fixture/coverage-frontier-report.json`
- `tools/source-atlas/generated/pack-production/train-09-civic-fixture/pack-production-report.json`
- `tools/source-atlas/generated/pack-production/train-09-civic-fixture/manifest.json`
- `tools/source-atlas/generated/pack-production/train-09-civic-fixture/r2-dry-run-plan.json`
- `tools/source-atlas/generated/pack-production/train-09-civic-fixture/revocations.json`
- `tools/source-atlas/generated/pack-production/train-09-civic-fixture/lkg.json`
- `tools/source-atlas/generated/pack-production/train-09-civic-fixture/rollback-plan.json`
- `docs/qa/source-atlas/domain-expansion/source-atlas-civic-adapter-pack-train-09.json`

R2 request privacy proof:
- No production R2 request path changed or executed.
- Dry-run object keys passed private object-key validation.
- Dry-run plan contains no credentials and no private user context.
- Stable pointer update did not run.

No private graph egress proof:
- Governed harvest privacy scan passed.
- Claim/frontier privacy scan passed.
- Pack non-private scan passed.
- Output contains no final user path, final schedule, Step list, personalized plan, or private graph artifact.

License/terms proof:
- `nara.constitution.presidency` uses `us_federal_public_source`.
- Source lane is reviewed.
- Source lane is `redistribution_policy=redistributable_with_attribution`.
- Source lane is `r2_pack_policy=pack_allowed_with_attribution`.
- Legal/terms registry is `pack_output_allowed=true`.
- Attribution is required.
- Outside legal approval is not claimed.

Restricted-source exclusion proof:
- No restricted source is included in the civic pack dry-run.
- Blocked claims excluded: 0.
- Wikidata, USAJOBS, and candidate-only sources are not part of the civic pack slice.

Provenance completeness proof:
- 2 civic claims emitted.
- 2 packable civic claims compiled.
- 2 complete provenance tuples emitted.

Freshness/revocation proof:
- Fixture claim freshness is current.
- Revocation manifest is emitted.
- Runtime revocation handling is not claimed in Train 9.

LKG/rollback proof:
- LKG pointer artifact is emitted.
- Rollback plan artifact is emitted.
- No stable R2 pointer update ran.

Native offline/no-account proof:
- Not claimed in Train 9. No native files changed and no XCTest/build-for-testing gate was required for this train.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; tooling/evidence only under `tools/source-atlas` and `docs/qa/source-atlas`.
- Files moved or created: civic adapter test and Train 9 generated/QA artifacts listed above.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: production R2 upload/readback, stable promotion, native fetch/cache/verify, source inspection proof, and broad domain readiness remain unproven.
- Next repair train if debt remains: production R2 validation-prefix upload/readback for an approved public pack, or native fetch/cache/verify proof.
- No equivalent folder/path interpretation was used.

Known risks:
- This is a static fixture-backed civic adapter; no live page retrieval is claimed.
- The dry-run plan proves object-key/checksum/manifest construction only; it does not prove R2 upload/readback.
- The public civic references are not legal advice or eligibility guarantees.

Follow-up required:
- Run live static-page verification only behind explicit `--live` and budget gates.
- Execute production R2 validation-prefix upload/readback only with explicit approval and credentials.
- Prove native fetch/cache/verify/quarantine/LKG behavior before any app runtime readiness claim.

Rollback plan:
- Revert the NARA civic adapter registration, embedded terms entry, public civic frontier ceiling change, Train 9 tests, generated Train 9 artifacts, and this QA packet.

Production non-claims:
- Not full Source Atlas Green.
- Not production R2 readiness.
- Not native app runtime readiness.
- Not outside legal approval.
- Not universal goal coverage.
- Not legal advice.
- Not guaranteed eligibility.
- Not stable-channel promotion.
- Not a final user plan, schedule, or Step generator.
