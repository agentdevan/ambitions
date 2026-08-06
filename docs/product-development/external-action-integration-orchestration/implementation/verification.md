# Verification

## Exact commands

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check docs/product-development/external-action-integration-orchestration --json
python3 scripts/ambitions-canon.py check
python3 -m pytest tools/external-actions/tests
python3 tools/external-actions/cli.py validate-registry --require-zero-remote-enabled
python3 tools/external-actions/cli.py run-fault-matrix --provider fake
python3 tools/external-actions/cli.py run-oauth-threat-matrix --provider fake
python3 scripts/ambitions-local-first-boundary-scan.py
python3 scripts/ambitions-runtime-direct-write-audit.py
python3 scripts/ci/ambitions-no-weak-implementation-scan.py
bash scripts/ci/ambitions-gitleaks-scan.sh --range-only
scripts/ambitions-xcode-test-focused.sh --batch PDL-EXTERNAL-ACTIONS --test AmbitionsTests/ExternalAdapterRegistryTests --test AmbitionsTests/ExternalActionDraftPreviewTests --test AmbitionsTests/ExternalActionAuthorizationTests --test AmbitionsTests/OAuthNativeSecurityTests --test AmbitionsTests/ExternalActionOutboxTests --test AmbitionsTests/ExternalActionReconciliationTests --test AmbitionsTests/CalendarEditorHandoffTests --test AmbitionsTests/ExternalDisconnectPurgeTests --test AmbitionsTests/ExternalActionPrivacySecurityTests --test AmbitionsTests/ExternalActionAccessibilityTests
make test-local BATCH=PDL-EXTERNAL-ACTIONS-FULL LANE=test-plan
swift test --package-path Packages/AmbitionsExternalContracts
xcodegen generate
git diff --check -- Ambitions.xcodeproj project.yml
make xcode-build-for-testing BATCH=PDL-EXTERNAL-ACTIONS
git diff --check
```

## Required evidence

- Registry rejects incomplete/changed adapters and proves zero remote enabled.
- Intent contains no payload/credential/authorization; exact draft/preview/hash/
  expiry/precondition and stale confirmation tests pass.
- Fake OAuth threat matrix covers external agent, PKCE, state, issuer, redirect,
  mix-up, replay, least scope, rotation/revoke and Keychain/no-secret leakage.
- Every outbox phase fault/duplicate/timeout/unknown/relaunch/background/expiry/
  revoke yields at-most-one contracted attempt and truthful status.
- Reconciliation/compensation/local-owner spies prove separation/no mutation.
- Migration evidence proves existing links and calendar observations remain
  observations and are never recast as successful authorized actions.
- Physical-device EventKit editor permission/presentation/cancel/callback evidence
  uses only actual proof language and minimal access.
- Disconnect/purge clears credentials/queue safely; unknown recovery remains
  minimally truthful; no remote delete claim.
- Logs/metrics/crashes/model/branch/export contain no token/payload/private canary.
- Accessibility/user preview, irreversible/unknown/result/disconnect comprehension
  and device performance pass.

## Final claim ceiling

Passing proves orchestration and Calendar handoff on tested devices plus fake
OAuth/outbox conformance. It proves no remote provider action, remote success,
external undo, webhook, deployment or release.
