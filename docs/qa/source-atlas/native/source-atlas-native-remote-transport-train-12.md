# Source Atlas Native Remote Transport Train 12

Status: Green for focused native anonymous public-pack transport tooling / Yellow overall Source Atlas

Scope completed:
- Added an anonymous native public-pack remote transport boundary for Source Atlas current pointer, publisher manifest, and pack bytes.
- Built current-pointer object keys with the public shape `source-atlas/v1/{environment}/{channel}/{domainID}/current.json`.
- Fetched only object-key-addressed public artifacts and handed bytes to the existing hash/cache/quarantine pipeline.
- Skipped remote transport when the access boundary resolves to offline or local fallback.
- Rejected private-looking manifest request shape and object keys before downstream pack use.
- Exposed `object_keys.pack` from publisher manifests for deterministic native pack-object fetch.
- Preserved local planning behavior when remote Source Atlas references are unavailable, invalid, or local-only.

Files changed:
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRemoteTransport.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublishedPackCompatibility.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRemoteTransportTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-remote-transport-train-12.json`
- `docs/qa/source-atlas/native/source-atlas-native-remote-transport-train-12.md`

Product law preserved:
- Source Atlas remains public/reference/freshness infrastructure only.
- R2 object keys are public artifact locators, not user-data identifiers.
- No goal text, capture text, schedule, proof, receipt, account/user identifier, device identifier, or private graph field is accepted into manifest request shape or remote object keys.
- Remote transport does not generate final plans, schedules, Steps, personalized paths, or priority order.
- The app can skip remote fetch and continue local/offline fallback without blocking core local planning.

Validation run:
- `xcodegen generate` passed.
- XcodeBuildMCP `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackRemoteTransportTests` passed: 5 passed, 0 failed.
- XcodeBuildMCP `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackFetchPipelineTests` passed: 8 passed, 0 failed.
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
- `docs/qa/source-atlas/native/source-atlas-native-remote-transport-train-12.json`
- `docs/qa/source-atlas/native/source-atlas-native-remote-transport-train-12.md`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T21-37-40-397Z_pid24471_665f7067.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T21-37-40-397Z_pid24471_429a5af3.xcresult`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T21-41-18-985Z_pid24471_de9654f5.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T21-41-18-986Z_pid24471_00bc4081.xcresult`
- `.codex/xcode-summaries/green-standard/20260627T214501Z/extract/summary.json`

Known risks:
- This proves static/deterministic and URL construction behavior; it does not prove live R2 credentials, production object availability, or CDN/cache behavior.
- Production R2 promotion remains owner-approved tooling work, not native transport proof.
- Entitlement policy remains outside this train.
- Legal/terms approval remains governed by upstream registry and pack-production artifacts.

Follow-up required:
- Run final Train 12 Python/audit/build validation and patch this evidence packet.
- Add production R2 upload/readback only in an owner-approved train with credentials and approval artifacts.
- Keep entitlement/account behavior separately scoped if public-pack access policy changes.

Rollback plan:
- Revert `SourceAtlasPublicPackRemoteTransport.swift`.
- Revert the `object_keys.pack` bridge addition in `SourceAtlasPublishedPackCompatibility.swift`.
- Revert focused remote transport XCTest additions and Train 12 QA evidence.
- Keep Train 11 publisher compatibility and bundled/offline Source Atlas baseline behavior.

Source Atlas status ceiling:
- Yellow overall Source Atlas.
- Green only for focused native anonymous public-pack transport tooling proven by Train 12 validation.

R2 request privacy proof:
- Current-pointer object keys are built from environment, channel, domainID, and `current.json` only.
- Manifest request shape remains domain/channel/schema/app-version/public-locale only.
- Object-key requests are scanned through `SourceAtlasNoPrivateGraphEgressAudit` before fetch.
- The private domain fixture rejects `goal_text` before any transport fetch.
- The private pointer fixture rejects `user_id` in a manifest object key before manifest or pack fetch.

No private graph egress proof:
- Focused XCTest blocks private manifest request markers before object requests.
- Focused XCTest blocks private pointer object keys before remote manifest or pack fetch.
- No account, device, goal, capture, schedule, proof, receipt, behavior, personalization, or private graph fields are represented in remote transport input.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` passed.

License/terms proof:
- Not claimed.
- Native transport consumes publisher-approved manifest metadata but does not create legal approval.

Restricted-source exclusion proof:
- Inherited from pack-production artifacts.
- Native transport fetches a pack object only after publisher manifest compatibility and downstream hash/cache validation; it does not re-admit restricted source lanes.

Provenance completeness proof:
- Not broadened by this train.
- Downstream publisher compatibility still maps published claim source IDs to native source records for inspection.

Freshness/revocation proof:
- Downstream pipeline still derives native freshness manifest state from publisher manifest data.
- Existing revoked manifest quarantine behavior remains covered by adjacent fetch pipeline tests.

LKG/rollback proof:
- Focused remote transport test proves offline/no-account access skips remote fetch and uses last-known-good payload when available.
- Train 12 does not claim production R2 rollback execution.

Native offline/no-account proof:
- Focused XCTest keeps offline/no-account behavior local-only and unblocked.
- Core local planning remains unblocked when remote Source Atlas fetch is skipped.

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
- Files moved or created: new `Core/Persistence/SourceAtlasPublicPackRemoteTransport.swift`; new focused persistence tests; QA evidence under `docs/qa/source-atlas/native`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: live production R2 credentials/object availability, entitlement policy, stable promotion, and release proof remain unproven.
- Next repair train if debt remains: owner-approved production R2 upload/readback or entitlement/public-access policy integration.
- Confirmation: no equivalent folder/path interpretation was used.
