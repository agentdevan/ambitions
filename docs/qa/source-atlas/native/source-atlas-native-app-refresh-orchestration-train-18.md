# Source Atlas Native App Refresh Orchestration Train 18

Status: Green for focused native app-safe public Source Atlas refresh orchestration / Yellow overall Source Atlas

Scope completed:
- Added a `Core/Persistence` app refresh coordinator for startup, background, and manual public Source Atlas refresh attempts.
- The coordinator loads cached public freshness manifests from the file-backed repository before choosing remote, cached, bundled, LKG, or unavailable behavior.
- The coordinator loads matching cached pack payloads from the repository when the cached manifest entry is public and hash-bound.
- The coordinator delegates remote work to the existing repository-backed public remote refresh path, preserving current pointer, manifest, pack, hash, journal, and repository commit gates.
- Offline/no-account startup refresh can use repository cached manifest and payload without touching transport or blocking core local planning.
- Online background refresh can use cached repository context and still accept a newly verified remote public pack.
- Private-looking cached manifest hints and unsafe manifest requests are blocked before transport or current-pack persistence.

Files changed:
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackAppRefreshCoordinator.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackAppRefreshCoordinatorTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-app-refresh-orchestration-train-18.json`
- `docs/qa/source-atlas/native/source-atlas-native-app-refresh-orchestration-train-18.md`

Product law preserved:
- Source Atlas remains public/reference/freshness infrastructure only.
- Refresh inputs contain public domain/channel/schema/app version, public pack ID, optional public locale, optional cached manifest lookup, public payloads, network/account availability state, and local checked-at time.
- No goals, captures, schedules, proof, receipts, account IDs, device IDs, behavior data, personalization data, inferred priorities, or private graph context are sent to Source Atlas or R2.
- Unsafe cached manifest hints force remote skipping for that refresh attempt.
- The coordinator does not create a Source Atlas product center, entitlement service, account service, hosted AI path, or server-side personalization path.
- The coordinator does not generate final plans, schedules, Steps, priority order, recovery paths, or personalized paths.
- Offline/no-account local planning remains unblocked when remote refresh is skipped, unavailable, unsafe, or cache lookup fails.

Validation run:
- `xcodegen generate` passed.
- XcodeBuildMCP `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackAppRefreshCoordinatorTests` passed: 4 passed, 0 failed.
- XcodeBuildMCP adjacent native Source Atlas public-pack persistence suite passed: 34 passed, 0 failed.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` passed: 125 passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` passed: `FAILURE_CLASS=passed`.
- `python3 scripts/source-atlas-boundary-audit.py` passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` passed.
- `python3 scripts/ambitions-green-standard-audit.py` passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` passed.
- `git diff --check` passed.
- `python3 -m json.tool docs/qa/source-atlas/native/source-atlas-native-app-refresh-orchestration-train-18.json` passed.

Validation not run:
- Production R2 upload/readback was not run.
- Stable production promotion was not run.
- Live R2/CDN object availability was not proven.
- Actual iOS `BackgroundTasks` registration/scheduling was not implemented or proven in this slice.
- App launch integration was not wired into `App/` startup code in this slice.
- Full native app runtime/release suite was not claimed.
- SwiftData-backed Source Atlas cache migration was not implemented or migration-tested in this slice.
- Account entitlement policy was not implemented or claimed.
- Outside legal review was not run or claimed.
- Rendered device/source inspection visual proof was not run.

Proof artifacts:
- `docs/qa/source-atlas/native/source-atlas-native-app-refresh-orchestration-train-18.json`
- `docs/qa/source-atlas/native/source-atlas-native-app-refresh-orchestration-train-18.md`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T23-29-05-723Z_pid24471_1d5bbe9e.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T23-29-05-723Z_pid24471_9f97d9f3.xcresult`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T23-32-36-401Z_pid24471_3ab18465.log`
- `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T23-32-36-402Z_pid24471_14ab7147.xcresult`
- `.codex/xcode-summaries/green-standard/20260627T233440Z/extract/summary.json`

Known risks:
- This adds an app-safe orchestration primitive; it does not wire actual app launch or `BackgroundTasks` scheduling.
- It proves local file-backed repository behavior, not production R2 credentials, CDN behavior, production bucket policy, or stable promotion.
- The file-backed cache remains a local repository proof, not a SwiftData migration proof.
- Legal/terms approval remains governed by upstream registry and pack-production artifacts.

Follow-up required:
- Wire the app refresh coordinator into an approved app launch/background refresh surface when that train is scoped.
- Keep production R2 upload/readback in an owner-approved train with credentials and approval artifacts.
- Keep entitlement/account behavior separately scoped if public-pack access policy changes.
- Keep legal/terms approval separate and artifact-backed.

Rollback plan:
- Revert `SourceAtlasPublicPackAppRefreshCoordinator.swift`.
- Revert `SourceAtlasPublicPackAppRefreshCoordinatorTests.swift`.
- Revert Train 18 QA evidence files.
- Keep Train 14 cache journal, Train 15 file repository, Train 16 repository-backed remote refresh, and Train 17 cached manifest readback intact.

Source Atlas status ceiling:
- Yellow overall Source Atlas.
- Green only for focused native app-safe public Source Atlas refresh orchestration proven by Train 18 validation.

R2 request privacy proof:
- Focused XCTest proves offline/no-account startup refresh uses repository cached manifest and payload with no transport object requests.
- Focused XCTest proves private cached manifest hints force remote skipping and do not persist a current pack payload.
- Focused XCTest proves unsafe manifest requests stop before transport and persistence.
- No new URL/header/query/request-body model carrying private context was introduced.

No private graph egress proof:
- The coordinator validates cached manifest hints with the no-private-graph egress scanner plus cache-metadata private token checks.
- Lower-level request, object-key, journal, and repository egress scanners remain in force.
- The Source Atlas no-private-graph egress audit passed.

License/terms proof:
- Not claimed.
- Native app refresh orchestration stores and reloads only public/reference artifacts handed to it by prior pack/fetch/legal gates; it does not create legal approval.

Restricted-source exclusion proof:
- Inherited from upstream pack-production artifacts.
- Native refresh orchestration does not re-admit restricted source lanes or create pack eligibility.

Provenance completeness proof:
- Not broadened by this train.
- This train coordinates public pack refresh/readback and does not assert arbitrary claim-level provenance completeness.

Freshness/revocation proof:
- Cached freshness manifest readback is used when available.
- Remote freshness, revocation, LKG, manifest hash, and pack hash gates remain delegated to the existing fetch/cache pipeline and adjacent tests.

LKG/rollback proof:
- Adjacent remote metadata/LKG tests remain green in the public-pack persistence suite.
- Train 18 does not claim production R2 rollback execution.

Native offline/no-account proof:
- Focused XCTest proves offline/no-account startup refresh can use repository cached manifest and payload without transport and without blocking core local planning.
- The coordinator computes access through `SourceAtlasAccessBoundary` and preserves `coreLocalPlanningBlocked == false`.

Production non-claims:
- Not full Source Atlas Green.
- Not production R2 readiness.
- Not production R2 upload proof.
- Not stable production promotion.
- Not legal approval.
- Not release readiness.
- Not universal goal coverage.
- Not app launch/background scheduling proof.
- Not entitlement/account readiness.
- Not a final user plan, schedule, or Step generator.
- Not a private user-data backend.
- Not private life graph storage.

Architecture closeout:
- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Persistence`.
- Files moved or created: new `Core/Persistence/SourceAtlasPublicPackAppRefreshCoordinator.swift`; new focused persistence tests; QA evidence under `docs/qa/source-atlas/native`.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt remaining: app launch integration, actual `BackgroundTasks` scheduling, SwiftData migration if later required, production R2 credentials/object availability, entitlement policy, stable promotion, legal approval, and release proof remain unproven.
- Next repair train if debt remains: wire the app refresh coordinator into an approved app startup/background refresh path or owner-approved production R2 upload/readback.
- Confirmation: no equivalent folder/path interpretation was used.
