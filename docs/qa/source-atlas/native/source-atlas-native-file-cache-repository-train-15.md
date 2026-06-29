# Source Atlas Native File Cache Repository Train 15

Status: Green for focused native file-backed public-pack cache repository tooling / Yellow overall Source Atlas

Scope completed:
- Added a native `Core/Persistence` file-backed Source Atlas public pack cache repository.
- Persisted verified public manifest and pack bytes from accepted cache journal records.
- Stored local cache files under deterministic hashed relative paths that do not contain pack IDs, goal text, user IDs, account IDs, device IDs, proof IDs, receipt IDs, or private graph markers.
- Verified pack and manifest SHA-256 before write and verified artifact SHA-256 after local readback.
- Added a public lookup path that reloads cached `SourceAtlasStorePayload` by public pack ID, manifest version, and declared SHA-256.
- Proved hash-mismatch, private-looking, and wrong-byte inputs do not persist current pack payloads.

Files changed:
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackCacheFileRepository.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackCacheFileRepositoryTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-file-cache-repository-train-15.json`
- `docs/qa/source-atlas/native/source-atlas-native-file-cache-repository-train-15.md`

Product law preserved:
- Source Atlas remains public/reference/freshness infrastructure only.
- The file cache stores public pack/manifest bytes and public cache journal metadata only.
- Storage paths use hashed IDs and never encode private user context, goal/capture/schedule/proof/receipt data, account/device IDs, behavior data, personalization data, or private graph data.
- The repository does not generate final plans, schedules, Steps, personalized paths, or priority order.
- Offline/no-account local planning remains unblocked when cache commits are rejected or recorded only.

Validation run:
- `xcodegen generate` passed.
- XcodeBuildMCP `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackCacheFileRepositoryTests` passed: 5 passed, 0 failed.
- XcodeBuildMCP adjacent native Source Atlas persistence suite passed: 35 passed, 0 failed.
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
- SwiftData-backed Source Atlas cache migration was not implemented or migration-tested in this slice.
- Account entitlement policy was not implemented or claimed.
- Outside legal review was not run or claimed.
- Rendered device/source inspection visual proof was not run.

Proof artifacts:
- `docs/qa/source-atlas/native/source-atlas-native-file-cache-repository-train-15.json`
- `docs/qa/source-atlas/native/source-atlas-native-file-cache-repository-train-15.md`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T22-34-21-520Z_pid24471_c1e4b118.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T22-34-21-520Z_pid24471_1e38790f.xcresult`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T22-37-43-951Z_pid24471_11a5b766.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T22-37-43-951Z_pid24471_f0bb43cf.xcresult`
- `.codex/xcode-summaries/green-standard/20260627T223959Z/extract/summary.json`

Known risks:
- This is a local file-backed repository, not a SwiftData-backed cache schema.
- This proves deterministic local storage and readback with static public artifacts; it does not prove live R2 object availability, production credentials, CDN/cache behavior, or entitlement policy.
- The repository is not yet wired into app startup/background refresh.
- Legal/terms approval remains governed by upstream registry and pack-production artifacts.

Follow-up required:
- Wire the file-backed public pack cache repository into the remote fetch coordinator or app refresh flow behind existing public/request privacy gates.
- Keep production R2 upload/readback in an owner-approved train with credentials and approval artifacts.
- Keep entitlement/account behavior separately scoped if public-pack access policy changes.

Rollback plan:
- Revert `SourceAtlasPublicPackCacheFileRepository.swift`.
- Revert `SourceAtlasPublicPackCacheFileRepositoryTests.swift`.
- Revert Train 15 QA evidence files.
- Keep Train 14 cache journal, Train 13 metadata handling, and Train 12 public transport behavior intact.

Source Atlas status ceiling:
- Yellow overall Source Atlas.
- Green only for focused native file-backed public-pack cache repository tooling proven by Train 15 validation.

R2 request privacy proof:
- The repository consumes existing public cache journal records and does not create R2 request paths.
- Local storage paths are hashed and do not expose pack ID, account ID, device ID, goal, capture, schedule, proof, receipt, or private graph fields.
- Private lookup IDs and private object-key journal records do not resolve or persist cached payloads.

No private graph egress proof:
- Focused XCTest proves private-looking journal object keys are rejected without writing artifacts or a journal.
- Focused XCTest proves private lookup IDs return no cached payload.
- The Source Atlas no-private-graph egress audit passed.

License/terms proof:
- Not claimed.
- Native file cache stores only publisher-approved public/reference artifacts handed to it by prior pack/fetch gates; it does not create legal approval.

Restricted-source exclusion proof:
- Inherited from pack-production artifacts.
- Native file caching does not re-admit restricted source lanes.

Provenance completeness proof:
- Not broadened by this train.
- This train stores pack/manifest bytes by verified SHA and pack-level metadata, not claim-level provenance completeness.

Freshness/revocation proof:
- Revoked and stale-critical decisions remain enforced by the existing fetch/cache pipeline.
- The repository only persists current pack payloads when the cache journal is accepted and hash-clean.

LKG/rollback proof:
- Adjacent LKG tests remain green.
- Train 15 does not claim production R2 rollback execution.

Native offline/no-account proof:
- Local file-cache rejection and record-only paths do not block core local planning.
- Adjacent native Source Atlas persistence tests remain green.

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
- Files moved or created: new `Core/Persistence/SourceAtlasPublicPackCacheFileRepository.swift`; new focused persistence tests; QA evidence under `docs/qa/source-atlas/native`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: app refresh wiring, SwiftData migration if later required, production R2 credentials/object availability, entitlement policy, stable promotion, and release proof remain unproven.
- Next repair train if debt remains: wire repository into remote fetch/app refresh flow or owner-approved production R2 upload/readback.
- Confirmation: no equivalent folder/path interpretation was used.
