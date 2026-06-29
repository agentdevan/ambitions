# Source Atlas R2 Legal Approval Gate Train 28

Status: Green for stable pack/R2 legal approval packet enforcement / Yellow overall Source Atlas

Scope completed:
- Pack-production production/stable mode now requires `--legal-approval-packet`.
- R2 publisher production/stable mode now requires `--legal-approval-packet`.
- Legal packet validation is source-specific and checks source match, artifact classes, expiry, private-data scan, pack policy, R2 policy, and outside-legal artifact overclaims.
- Owner approval remains a separate execute gate; legal/terms approval cannot satisfy owner approval.
- Generated production/stable dry-run pack and publisher evidence with the Train 27 legal/terms approval packet.

Files changed:
- `tools/source-atlas/foundry/pack_production.py`
- `tools/source-atlas/foundry/r2_pack_publisher.py`
- `tools/source-atlas/foundry/cli.py`
- `tools/source-atlas/foundry/tests/test_pack_production_train_04.py`
- `tools/source-atlas/foundry/tests/test_r2_pack_publisher_train_10.py`
- `tools/source-atlas/generated/pack-production/train-28-stable-approval-gate/*`
- `tools/source-atlas/generated/r2-publisher/train-28-stable-approval-gate/*`
- `docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28.json`
- `docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28.md`
- `docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28-closeout.json`
- `docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28-closeout.md`

Product law preserved:
- R2 remains public/reference/freshness infrastructure only.
- Dry-run publisher made no production R2 upload and used no credentials.
- No user goals, captures, schedules, proof, receipts, account IDs, device IDs, private graph data, or personalization context were added to packs, object keys, requests, or manifests.
- Source Atlas does not generate final user paths, schedules, Steps, or personalized plans.

Validation run:
- `python3 -m pytest tools/source-atlas/foundry/tests/test_pack_production_train_04.py tools/source-atlas/foundry/tests/test_r2_pack_publisher_train_10.py`
- `python3 tools/source-atlas/source-atlas-foundry.py pack-production --input-root tools/source-atlas/generated/claim-frontier/train-03-fixture --output-root tools/source-atlas/generated/pack-production/train-28-stable-approval-gate --domain occupation_foundation --environment production --channel stable --created-at 2026-06-28T00:00:00Z --legal-approval-packet docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.json`
- `python3 tools/source-atlas/source-atlas-foundry.py pack-r2-publisher --pack-root tools/source-atlas/generated/pack-production/train-28-stable-approval-gate --output-root tools/source-atlas/generated/r2-publisher/train-28-stable-approval-gate --environment production --channel stable --mode dry_run --created-at 2026-06-28T00:00:00Z --legal-approval-packet docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.json --emit-evidence docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28.json --markdown docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28.md`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
- `python3 scripts/source-atlas-boundary-audit.py`
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
- `python3 scripts/ambitions-green-standard-audit.py`
- `python3 scripts/ambitions-local-first-boundary-scan.py`
- `git diff --check`

Validation not run:
- Production R2 upload/readback was not run.
- Real R2 credentials were not used.
- Native XCTest/build-for-testing was not rerun for Train 28 because this train changed Python tooling, generated Source Atlas evidence, and QA evidence only.
- Outside legal counsel review was not run or claimed.
- Device/offline/release proof was not run.

Proof artifacts:
- `tools/source-atlas/generated/pack-production/train-28-stable-approval-gate/pack-production-report.json`
- `tools/source-atlas/generated/pack-production/train-28-stable-approval-gate/manifest.json`
- `tools/source-atlas/generated/pack-production/train-28-stable-approval-gate/r2-dry-run-plan.json`
- `tools/source-atlas/generated/r2-publisher/train-28-stable-approval-gate/r2-publisher-report.json`
- `tools/source-atlas/generated/r2-publisher/train-28-stable-approval-gate/r2-request-privacy-report.json`
- `tools/source-atlas/generated/r2-publisher/train-28-stable-approval-gate/r2-upload-readback-report.json`
- `docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28.json`
- `docs/qa/source-atlas/r2/source-atlas-r2-legal-approval-gate-train-28.md`

Known risks:
- This is production/stable dry-run gate proof, not production R2 upload/readback proof.
- Internal legal/terms approval remains separate from outside legal counsel approval.
- The stable occupation foundation dry-run has legal approval for included O*NET, BLS, and OpenAlex sources only.
- Native fetch/cache/verify/quarantine behavior and release readiness remain separate proof gates.

Follow-up required:
- Run real production R2 upload/readback only with explicit owner approval, current credentials, and current legal packet.
- Add R2 credentials/readback evidence if production write is requested.
- Run native device/offline/no-account proof before runtime/release Green.
- Continue governed coverage-frontier expansion without literal universal coverage claims.

Rollback plan:
- Revert Train 28 legal packet enforcement wiring, tests, generated pack/publisher evidence, and QA closeout artifacts.
- Do not promote the dry-run stable pack; no stable pointer was changed.

Source Atlas status ceiling:
- Yellow overall Source Atlas.
- Green only for stable pack/R2 legal approval packet enforcement.

R2 request privacy proof:
- Publisher dry-run generated no real network request and used no credentials.
- Object keys passed public-reference segment validation.
- Current pointer remains dry-run only and did not update stable R2.

No private graph egress proof:
- `source-atlas-no-private-graph-egress-audit.py` passed.
- Pack and publisher payload scans passed before publish planning.

License/terms proof:
- Production/stable pack and publisher gates validated the Train 27 legal/terms approval packet for included sources.
- Outside legal approval is not claimed.

Restricted-source exclusion proof:
- USAJOBS and review-required lanes remain excluded from the stable pack.
- Wikidata crosswalk claims remain excluded from packable regulated output.

Provenance completeness proof:
- Inherited from existing claim-frontier and pack-production artifacts.
- Train 28 did not expand claim-level provenance scope.

Freshness/revocation proof:
- Revocation, LKG, rollback, and current-pointer metadata are present in dry-run publisher evidence.
- Runtime revocation behavior was not changed.

LKG/rollback proof:
- Dry-run LKG and rollback artifacts were emitted.
- No stable pointer was updated.

Native offline/no-account proof:
- Not run in Train 28. No native files changed in this train.

Production non-claims:
- Not production R2 upload proof.
- Not real R2 credentials proof.
- Not outside legal approval.
- Not release readiness.
- Not App Store readiness.
- Not full Source Atlas Green.
- Not universal coverage.
- Not a final user plan, schedule, or Step generator.
