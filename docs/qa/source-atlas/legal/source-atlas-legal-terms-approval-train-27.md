# Source Atlas Legal Terms Approval Train 27

Status: Green for bounded internal legal/terms approval packet workflow / Yellow overall Source Atlas

Scope completed:
- Added a schema-versioned internal legal/terms approval packet for Source Atlas public/reference sources.
- Added source-specific approval validation for source match, terms URL match, artifact-class scope, expiry, private-data scan, pack policy, R2 policy, and outside-legal artifact proof.
- Wired the existing Source Atlas distribution gate so callers can require a valid approval packet before pack output.
- Added a `terms-approval-packet` Foundry command that emits JSON and Markdown approval evidence.
- Generated the Train 27 approval packet for O*NET, BLS, Wikidata crosswalk data, and OpenAlex metadata.

Files changed:
- `tools/source-atlas/foundry/terms_approval_packet.py`
- `tools/source-atlas/foundry/adapter_sdk.py`
- `tools/source-atlas/foundry/terms_registry.py`
- `tools/source-atlas/foundry/cli.py`
- `tools/source-atlas/foundry/tests/test_terms_approval_packet_train_27.py`
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.json`
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.md`
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-train-27.json`
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-train-27.md`

Product law preserved:
- Source Atlas remains public/reference/freshness infrastructure only.
- R2 remains prohibited from receiving goals, captures, schedules, proof, receipts, account IDs, device IDs, private graph data, or personalization context.
- Source Atlas does not generate final user paths, schedules, Steps, or personalized plans.
- USAJOBS/restricted lanes remain blocked from redistributable and R2-ready pack output.
- Wikidata remains crosswalk/support only and is not regulated authority.

Validation run:
- `python3 -m pytest tools/source-atlas/foundry/tests/test_terms_approval_packet_train_27.py tools/source-atlas/foundry/tests/test_adapter_broad_coverage_train_01.py::test_terms_registry_validation_and_distribution_policy_gate tools/source-atlas/foundry/tests/test_stable_channel_api_governance_train.py::test_legal_review_packet_marks_outside_legal_approval_as_non_claim`
- `python3 tools/source-atlas/source-atlas-foundry.py terms-approval-packet --source onet.database --source bls.public.data.api --source wikidata.crosswalk --source openalex.dataset --json docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.json --created-at 2026-06-28T00:00:00Z`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
- `python3 scripts/source-atlas-boundary-audit.py`
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
- `python3 scripts/ambitions-green-standard-audit.py`
- `python3 scripts/ambitions-local-first-boundary-scan.py`

Validation not run:
- Production R2 upload/readback was not run in this train.
- Native XCTest/build-for-testing was not rerun for Train 27 because this train changed Python tooling and QA evidence only. Train 26 covered focused native approval gating and green-standard build-for-testing.
- Outside legal counsel review was not run or claimed.
- Device/offline/release proof was not run.

Proof artifacts:
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.json`
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-packet-train-27.md`
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-train-27.json`
- `docs/qa/source-atlas/legal/source-atlas-legal-terms-approval-train-27.md`

Known risks:
- Current Train 27 Green is internal legal/terms approval packet workflow Green, not outside legal approval.
- Source terms can change; packet approvals expire on 2026-12-28 and must be refreshed before reuse after expiry.
- College Scorecard, USAJOBS, catalogs, and review-required lanes remain blocked or review-required until a future source-specific review train approves them.
- Production R2 write/readback, active production target activation, native release proof, and governed coverage-frontier promotion remain separate gates.

Follow-up required:
- Apply approval packets to pack-production promotion gates so production/stable R2 write refuses stale, mismatched, or missing legal/terms approval.
- Create production owner approval artifact for any stable-channel write.
- Run approved production R2 upload/readback with current credentials only when explicitly requested.
- Run native device/offline/no-account proof before runtime/release Green.
- Continue governed coverage-frontier expansion without claiming literal universal coverage.

Rollback plan:
- Revert the Train 27 approval packet module, gate wiring, CLI command, tests, and QA evidence.
- Existing default fixture packability remains available without `require_approval_packet` until production gates are explicitly tightened in the next train.

Source Atlas status ceiling:
- Yellow overall Source Atlas.
- Green only for bounded internal legal/terms approval packet workflow and the listed source-specific internal review packet.

R2 request privacy proof:
- No R2 request path changed in Train 27.
- Approval packet validation scans the packet payload for private-looking fields before pack gates can rely on it.

No private graph egress proof:
- `source-atlas-no-private-graph-egress-audit.py` passed.
- Approval packets include non-claims and no user-goal, capture, schedule, proof, receipt, account, device, or private graph fields.

License/terms proof:
- O*NET, BLS, Wikidata crosswalk data, and OpenAlex metadata have a bounded internal Source Atlas approval packet.
- Outside legal approval is not claimed.
- Source-specific terms still control.

Restricted-source exclusion proof:
- USAJOBS remains blocked from redistributable and R2-ready pack output.
- Review-required and restricted lanes cannot pass the approval-packet validator as pack output.

Provenance completeness proof:
- Not expanded in Train 27. Existing claim/provenance trains remain the authority for claim-level provenance completeness.

Freshness/revocation proof:
- Approval packet expiry is validated.
- Runtime revocation and stale-critical quarantine were not changed in Train 27.

LKG/rollback proof:
- Not run in Train 27. No stable pointer, R2 object, revocation manifest, or LKG pointer was modified.

Native offline/no-account proof:
- Not run in Train 27. No native files changed in this train.

Production non-claims:
- Not outside legal approval.
- Not production R2 readiness.
- Not release readiness.
- Not App Store readiness.
- Not full Source Atlas Green.
- Not universal coverage.
- Not a final user plan, schedule, or Step generator.
