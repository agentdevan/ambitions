# Source Atlas Native Remote Metadata Train 13

Status: Green for focused native revocation/LKG remote metadata tooling / Yellow overall Source Atlas

Scope completed:
- Extended native public-pack remote transport to fetch publisher revocation metadata when the current pointer provides a public revocation key.
- Applied revocation metadata before pack-object fetch, so a revoked current pack is quarantined instead of replacing local cache.
- Extended native public-pack remote transport to fetch publisher LKG pointer metadata and the LKG manifest when public keys are present.
- Used LKG manifest pack SHA-256 only as rollback guidance for an existing local last-known-good payload.
- Rejected private-looking LKG manifest object keys before current pack fetch.
- Preserved offline/no-account local planning behavior and Source Atlas reference-only semantics.

Files changed:
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRemoteTransport.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRemoteTransportAdapters.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublishedPackMetadataCompatibility.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackFetchPipeline.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRemoteMetadataTests.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRemoteTransportTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-remote-metadata-train-13.json`
- `docs/qa/source-atlas/native/source-atlas-native-remote-metadata-train-13.md`

Product law preserved:
- Source Atlas remains public/reference/freshness infrastructure only.
- R2 metadata keys are public artifact locators, not user-data identifiers.
- No goal text, capture text, schedule, proof, receipt, account/user identifier, device identifier, behavior data, personalization data, or private graph field is accepted into remote metadata request shape or object keys.
- Remote metadata does not generate final plans, schedules, Steps, personalized paths, or priority order.
- Last-known-good metadata can only guide selection of an existing local LKG payload whose hash verifies.

Validation run:
- `xcodegen generate` passed.
- XcodeBuildMCP `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackRemoteMetadataTests` passed: 3 passed, 0 failed.
- XcodeBuildMCP `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackRemoteTransportTests -only-testing:AmbitionsTests/SourceAtlasPublicPackFetchPipelineTests` passed: 13 passed, 0 failed.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` passed: 125 passed.
- `python3 scripts/source-atlas-boundary-audit.py` passed: PASS (40 targets).
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` passed.
- `python3 scripts/ambitions-green-standard-audit.py` passed: GREEN.
- `python3 scripts/ambitions-local-first-boundary-scan.py` passed: GREEN.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` passed: `FAILURE_CLASS=passed`.
- `git diff --check` passed.

Validation not run:
- Production R2 upload/readback was not run.
- Stable production promotion was not run.
- Full native app runtime/release suite was not claimed.
- Outside legal review was not run or claimed.
- Rendered device/source inspection visual proof was not run.

Proof artifacts:
- `docs/qa/source-atlas/native/source-atlas-native-remote-metadata-train-13.json`
- `docs/qa/source-atlas/native/source-atlas-native-remote-metadata-train-13.md`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T22-01-30-931Z_pid24471_4111744e.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T22-01-30-931Z_pid24471_acb20ae8.xcresult`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T22-03-37-512Z_pid24471_f579194b.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T22-03-37-512Z_pid24471_0684aaad.xcresult`
- `.codex/xcode-summaries/green-standard/20260627T220715Z/extract/summary.json`

Known risks:
- This proves deterministic native metadata handling with static public objects; it does not prove live R2 object availability, production credentials, CDN/cache behavior, or account entitlement policy.
- LKG metadata is used only to authorize an existing local payload by hash; this train does not implement downloading or storing a replacement LKG pack.
- Revocation/LKG artifacts remain governed by upstream R2 publisher and pack-production controls.
- Legal/terms approval remains governed by upstream registry and pack-production artifacts.

Follow-up required:
- Run final Train 13 Python/audit/build validation and patch this evidence packet.
- Add production R2 upload/readback only in an owner-approved train with credentials and approval artifacts.
- Keep entitlement/account behavior separately scoped if public-pack access policy changes.

Rollback plan:
- Revert `SourceAtlasPublishedPackMetadataCompatibility.swift`.
- Revert Train 13 metadata additions in `SourceAtlasPublicPackRemoteTransport.swift` and `SourceAtlasPublicPackFetchPipeline.swift`.
- Revert `SourceAtlasPublicPackRemoteTransportAdapters.swift` extraction only if needed to restore prior layout.
- Revert focused metadata XCTest additions and Train 13 QA evidence.
- Keep Train 12 basic public transport and Train 11 publisher compatibility behavior.

Source Atlas status ceiling:
- Yellow overall Source Atlas.
- Green only for focused native revocation/LKG remote metadata tooling proven by Train 13 validation.

R2 request privacy proof:
- Revocation and LKG pointer object keys come only from publisher current pointers and are scanned before fetch.
- LKG manifest object keys are decoded from public LKG metadata and scanned before fetch.
- A private-looking LKG manifest key fixture containing `user_id` is rejected before current pack fetch.

No private graph egress proof:
- Focused XCTest blocks private LKG metadata object keys before current pack fetch.
- No account, device, goal, capture, schedule, proof, receipt, behavior, personalization, or private graph fields are represented in remote metadata input.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` passed.

License/terms proof:
- Not claimed.
- Native metadata handling consumes publisher-approved public metadata but does not create legal approval.

Restricted-source exclusion proof:
- Inherited from pack-production artifacts.
- Native metadata handling does not re-admit restricted source lanes.

Provenance completeness proof:
- Not broadened by this train.
- This train affects freshness/revocation/LKG selection metadata only, not claim provenance.

Freshness/revocation proof:
- Focused XCTest proves revoked current packs are blocked before pack-object fetch and quarantined through the existing cache pipeline.
- Revocation metadata is public/reference-only and source-atlas object-key-scanned.

LKG/rollback proof:
- Focused XCTest proves LKG pointer plus LKG manifest can add rollback hash guidance for an existing local LKG payload.
- Focused XCTest proves private LKG manifest object keys stop before current pack fetch.
- Train 13 does not claim production R2 rollback execution.

Native offline/no-account proof:
- Existing offline/no-account transport and fetch pipeline tests remain green.
- Core local planning remains unblocked when remote Source Atlas metadata is unavailable or local fallback is used.

Production non-claims:
- Not full Source Atlas Green.
- Not production R2 readiness.
- Not production R2 upload proof.
- Not stable production promotion.
- Not legal approval.
- Not release readiness.
- Not universal goal coverage.
- Not a final user plan, schedule, or Step generator.
- Not a private user-data backend.
- Not private life graph storage.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Persistence`.
- Files moved or created: new `Core/Persistence/SourceAtlasPublishedPackMetadataCompatibility.swift`; new `Core/Persistence/SourceAtlasPublicPackRemoteTransportAdapters.swift`; new focused persistence tests; QA evidence under `docs/qa/source-atlas/native`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: live production R2 credentials/object availability, entitlement policy, stable promotion, and release proof remain unproven.
- Next repair train if debt remains: owner-approved production R2 upload/readback or entitlement/public-access policy integration.
- Confirmation: no equivalent folder/path interpretation was used.
