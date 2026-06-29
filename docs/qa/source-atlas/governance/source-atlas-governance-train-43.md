# Source Atlas Governance Registry Train 1

Status: Source Green for governance tooling
Source Atlas status ceiling: Yellow overall Source Atlas; governance tooling only

Scope completed:
- Source lane registry schema and registry validation
- Legal/terms registry schema and registry validation
- API governance registry schema and registry validation
- Source-specific hard rules for O*NET, BLS, Wikidata, OpenAlex, USAJOBS, and catalog/discovery lanes

Files changed:
- tools/source-atlas/foundry/governance_registry.py
- tools/source-atlas/foundry/cli.py
- tools/source-atlas/foundry/tests/test_governance_registry_train_01.py
- tools/source-atlas/governance/source-lane-registry.json
- tools/source-atlas/governance/legal-terms-registry.json
- tools/source-atlas/governance/api-governance-registry.json
- tools/source-atlas/governance/schemas/source-lane-registry.schema.json
- tools/source-atlas/governance/schemas/legal-terms-registry.schema.json
- tools/source-atlas/governance/schemas/api-governance-registry.schema.json
- docs/qa/source-atlas/governance/source-atlas-governance-train-01.json
- docs/qa/source-atlas/governance/source-atlas-governance-train-01.md

Counts:
- Source lanes: 14
- Legal/terms entries: 10
- API policies: 9

Checks:
- source_lane_registry_schema_exists: pass
- legal_terms_registry_schema_exists: pass
- api_governance_registry_schema_exists: pass
- source_lanes_have_required_posture: pass
- legal_terms_have_required_posture: pass
- api_policies_have_required_posture: pass
- wikidata_crosswalk_only: pass
- openalex_high_volume_gated: pass
- bls_v1_v2_modes_represented: pass
- usajobs_r2_pack_blocked: pass
- legal_registry_present: pass
- private_r2_key_validation: pass
- no_final_plan_schedule_step_output: pass

Product law preserved:
- R2 remains public/reference/freshness infrastructure only.
- Source Atlas does not receive private user context.
- Candidate discovery is not claim authority.
- Source Atlas does not generate final plans, schedules, or Steps.

Validation run:
- python3 tools/source-atlas/source-atlas-foundry.py governance-registry-check --emit-evidence docs/qa/source-atlas/governance/source-atlas-governance-train-01.json --markdown docs/qa/source-atlas/governance/source-atlas-governance-train-01.md
- python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests
- python3 scripts/source-atlas-boundary-audit.py
- python3 scripts/source-atlas-no-private-graph-egress-audit.py
- python3 scripts/ambitions-green-standard-audit.py
- python3 scripts/ambitions-local-first-boundary-scan.py
- git diff --check

Validation not run:
- Native XCTest/build-for-testing not run because this train changed Python tooling, JSON registries, and QA evidence only.
- Production R2 upload/readback not run; no production upload was requested.
- Outside legal review not run or claimed.

Proof artifacts:
- docs/qa/source-atlas/governance/source-atlas-governance-train-01.json
- docs/qa/source-atlas/governance/source-atlas-governance-train-01.md

R2 request privacy proof:
- Registry-level only. No native or production R2 request path changed in this train.
- Packable lanes must declare public object prefixes and private-looking R2 key segments fail validation.

No private graph egress proof:
- Source lanes forbid private_goal_graph, final_user_path, final_schedule, step_list, and personalized_plan artifact classes.
- Packable lane object prefixes are public/reference prefixes only.

License/terms proof:
- Legal/terms posture is machine-readable per license entry.
- Missing or ambiguous legal/terms posture blocks pack output.
- Outside legal approval is not claimed without an approval artifact.

Restricted-source exclusion proof:
- USAJOBS is lookup-only, review-required, and pack_blocked_restricted.
- Catalog/discovery lanes are candidate-only and cannot become claim authority.
- Wikidata is crosswalk-only and cannot satisfy regulated authority.

Provenance completeness proof:
- Not claimed in Train 1. Claim-level provenance completeness belongs to the claim graph train.

Freshness/revocation proof:
- Source lanes carry freshness SLA fields.
- Runtime revocation, stale-critical quarantine, and replacement selection are not claimed in Train 1.

LKG/rollback proof:
- Not claimed in Train 1. No stable R2 publish, pointer update, or rollback operation ran.

Native offline/no-account proof:
- Not claimed in Train 1. No native files changed and no XCTest/build-for-testing gate was required.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; tooling/evidence only under tools/source-atlas and docs/qa/source-atlas.
- Files moved or created: new governance registry, schemas, tests, and QA evidence listed above.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: none from this train; later native/R2 trains remain unproven.
- Next repair train if debt remains: Train 2 adapter SDK and deterministic harvest runner.
- No equivalent folder/path interpretation was used.

Known risks:
- This is governance tooling proof, not app runtime fetch/cache/verify proof.
- Legal entries are technical posture records unless an approval artifact is present.
- Catalog and review-required lanes remain non-packable until later review gates pass.

Follow-up required:
- Train 2: adapter SDK and deterministic harvest runner green.
- Later trains: claim graph, coverage frontier, generalized pack compiler, R2 publish gate, native fetch/cache/verify, and source inspection.

Rollback plan:
- Revert the governance registry files, validator module, CLI command, tests, and QA evidence from this train.

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
