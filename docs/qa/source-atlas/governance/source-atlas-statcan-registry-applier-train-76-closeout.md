# Source Atlas Statistics Canada Registry Apply Train 76 Closeout

Status: Source Green for active governance registry application of Statistics Canada Table 13-10-0974-01 / Yellow overall Source Atlas

Scope completed:
- Applied exactly one reviewed planned registry mutation to the active Source Atlas governance registries using the approval-gated registry applier.
- Added source lane `official.statcan.table.13100974`.
- Added legal/terms entry `statcan.open-licence.2026-06-28`.
- Added API policy `api.official.statcan.table.13100974.v1`.
- Registry counts after apply: 33 source lanes, 26 legal entries, 10 API policies.

Files changed:
- `tools/source-atlas/governance/source-lane-registry.json`
- `tools/source-atlas/governance/legal-terms-registry.json`
- `tools/source-atlas/governance/api-governance-registry.json`
- `tools/source-atlas/generated/catalog-registry-applier/train-76-statcan-table-13100974-active-apply/`
- `docs/qa/source-atlas/governance/source-atlas-statcan-registry-applier-train-76.json`
- `docs/qa/source-atlas/governance/source-atlas-statcan-registry-applier-train-76.md`
- `docs/qa/source-atlas/governance/source-atlas-statcan-registry-applier-train-76-closeout.json`
- `docs/qa/source-atlas/governance/source-atlas-statcan-registry-applier-train-76-closeout.md`

Product law preserved:
- Registry metadata remains public/reference/freshness-only governance metadata.
- No claims, packs, R2 objects, final plans, schedules, or Steps were emitted.
- No private user context, goals, captures, schedules, proof, receipts, account identifiers, behavior history, inferred priorities, or private life graph data were added.

Validation run:
- `PYTHONPATH=tools/source-atlas python3 -m foundry.cli catalog-registry-applier --plan ... --execute --allow-active-registry-write ...` - pass.
- `python3 -m pytest tools/source-atlas/foundry/tests/test_governance_registry_train_01.py tools/source-atlas/foundry/tests/test_catalog_registry_applier_train_60.py` - 15 passed.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 319 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - PASS (40 targets).
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - PASS.
- `python3 scripts/ambitions-green-standard-audit.py` - GREEN.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - GREEN.
- `git diff --check` - pass.

Validation not run:
- Production R2 upload/readback was not run.
- Pack production was not run.
- Native XCTest/build-for-testing was not run because Train 76 edited tooling/governance JSON only.
- Outside legal approval was not run or claimed.

Proof artifacts:
- `tools/source-atlas/generated/catalog-registry-applier/train-76-statcan-table-13100974-active-apply/catalog-registry-applier-report.json`
- `tools/source-atlas/generated/catalog-registry-applier/train-76-statcan-table-13100974-active-apply/active-registry-mutations.json`
- `docs/qa/source-atlas/governance/source-atlas-statcan-registry-applier-train-76.md`

Registry hash proof:
- Source registry before: `043518da3973d13f5135aba853977ce3722d9efacd33155e7da11ecac8da8105`
- Source registry after: `e125d2f2df679cc0454e0de922cc7eb68a9c3d0c85182cd6b0b15e955755e787`
- Legal registry before: `f3c0a58a023459e118fbbf06e2392174ae352b40b187feb66625e916b2cafe4c`
- Legal registry after: `77eb8c5ab28efdc9dd53e514459d5bd9e1055645b1add33d9106bdeaa4b9a59b`
- API registry before: `8d12c7bf47c67f0b7c4500d3d747020093780f2131a1408b631043e23ac5ac4c`
- API registry after: `12dfaacdbf2bde99581da104ec93bebbdd4ce43c654f971631f43d8a3f10dbe9`
- Applier report hash: `a04341f7d8bc89992ed4548b20faea9c1f442c1e4667412a96cc466bf6d1a3b8`

Known risks:
- Active registry application does not mean a harvested adapter, claim graph, pack, R2 publish, native fetch/cache, or release proof exists for this source.
- This is one official Canadian public statistical table, not full health/wellness coverage.
- Outside legal approval is not claimed.

Follow-up required:
- Add a fixture-first StatCan static HTTPS adapter and raw-evidence manifest for table `13-10-0974-01`.
- Normalize allowed aggregate public/reference statistical claims with provenance.
- Run coverage frontier and pack production gates before any pack-ready claim.
- Run R2 upload/readback only with explicit production approval and credentials.
- Run native fetch/cache/quarantine/LKG/offline proof before runtime/release claims.

Rollback plan:
- Remove `official.statcan.table.13100974` from `source-lane-registry.json`.
- Remove `statcan.open-licence.2026-06-28` from `legal-terms-registry.json`.
- Remove `api.official.statcan.table.13100974.v1` from `api-governance-registry.json`.
- Remove Train 76 generated proof artifacts if the active apply must be undone.

Source Atlas status ceiling:
- Yellow overall Source Atlas; active governance registry application only.

R2 request privacy proof:
- No R2 request path changed or executed.
- R2 key prefix posture was already validated in Train 75 and the active registry passed governance validation.

No private graph egress proof:
- Boundary and no-private-graph egress audits passed after active registry apply.

License/terms proof:
- Active legal registry contains source-specific internal terms posture for Statistics Canada Open Licence.
- Outside legal approval is not claimed.

Restricted-source exclusion proof:
- Registry validator passed restricted/source-of-sources checks after active apply.

Provenance completeness proof:
- Registry provenance is captured by Train 75/76 review and mutation proof.
- Claim-level provenance is not claimed because no claims were emitted.

Freshness/revocation proof:
- Source review and terms review dates are recorded with next review due `2026-09-28`.
- No pack freshness, revocation, LKG, or rollback operation ran.

LKG/rollback proof:
- No stable R2 pointer changed.
- Rollback is removal of the three active registry entries listed above.

Native offline/no-account proof:
- Not claimed in Train 76.
- No native files were edited by this train.

Production non-claims:
- Not production R2 readiness.
- Not app runtime readiness.
- Not release readiness.
- Not outside legal approval.
- Not universal coverage.
- Not final user planning, scheduling, or Step generation.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; tooling/governance/evidence only under `tools/source-atlas` and `docs/qa/source-atlas`.
- Non-canonical owners touched: none.
- Files moved or created: governance registry entries and QA proof artifacts.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Architecture debt: none from Train 76; broader native/runtime/R2 proof remains Yellow.
- Next repair train if debt remains: fixture-first StatCan adapter and evidence manifest.
- No equivalent folder/path interpretation was used.
