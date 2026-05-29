# Release Candidate Review Checklist

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Use this checklist after Batch 60 and before any App Store submission attempt.
It is the short execution companion to [../canon/Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md).

## Build And Stability

- Regenerate the project with `xcodegen generate`.
- Complete the native build/test/archive workflow from [../native-build-and-release.md](../native-build-and-release.md).
- Confirm the intended release candidate is stable on real devices, not simulator-only.
- Confirm critical routes, URLs, and first-run flows are fully functional.

## R03 Device QA Gate

- Treat `ReleaseDeviceQAReadinessReport` as the simulator/source readiness ledger, not as physical-device proof.
- Complete physical-device smoke before using TestFlight-ready language.
- Verify fresh install, returning user, denied permissions, no-data, lots-of-data, missed-week, export/import, and external-surface journeys on device where possible.
- Keep representative family/shared-life, career, creative, finance/life-admin, and home/life-admin journeys as QA fixtures only; do not hardcode them into product defaults.

## R04 External Truth Gate

- Treat `ReleaseExternalTruthReadinessPacket` as the drafted evidence ledger for App Store copy, privacy labels, reviewer notes, release notes, investor/demo story, marketing one-pager, accessibility claims, and platform claims.
- Do not treat the R04 packet as App Store submission readiness, TestFlight readiness, a signed archive result, or final RC lock.
- Provide live support and privacy URLs before submission; the repo does not currently prove hosted release pages.
- Generate and human-review current screenshots from the final signed build and privacy-safe demo data before App Store Connect entry.
- Keep public accessibility claims locked until manual VoiceOver, Dynamic Type, Reduce Motion, contrast, motor/tap-target, and external-surface proof exists.
- Keep widgets, Live Activities, notifications, Shortcuts/Siri, and installed-device shared-container claims blocked until device/platform proof exists.

## R05 RC Decision Gate

- Treat `ReleaseCandidateLockDecisionReport` as the final repo decision ledger, not as human approval.
- Current repo status is `Candidate prepared; human approval required`.
- Do not use final RC lock, TestFlight-ready, App Store-ready, real-device-verified, or accessibility-verified language until the named blockers are closed.
- Resolve physical-device smoke, manual accessibility proof, signed archive/App Store Connect validation, rendered external-platform proof, current store screenshots, live support/privacy URLs, and final human approval before changing the release posture.
- Keep Apple-first sync and App Store submission-candidate status as human/operator decisions, not automatic repo outcomes.

## Reviewer Access And Completeness

- Confirm the submitted build is not incomplete, placeholder-heavy, or obviously broken.
- Prepare reviewer notes for any non-obvious review flow.
- If login is required, prepare reviewer credentials or a truthful demo mode.
- Confirm all support, marketing, and privacy URLs are live and correct.

## Privacy And Permissions

- Confirm the Privacy Policy URL is ready for submission.
- Reconcile App Privacy disclosures with the actual release candidate and any third-party partners.
- Reconcile permission-purpose strings with shipped behavior.
- If calendar, reminders, health-like signals, or personalization inputs ship, do a final disclosure and permission-trust review.

## Conditional Account / Auth / Monetization Gates

- If account creation ships, confirm in-app account deletion is present and reviewable.
- If third-party or social login ships, confirm Apple login-service and equivalent-login requirements are satisfied as applicable.
- If subscriptions, digital unlocks, or IAP ship, complete the separate business-model and purchase-flow review before submission.

## External And Ambient Surfaces

- Review widgets, Live Activities, notifications, App Intents, shortcuts, and related external routes on real devices.
- Confirm ambient surfaces are glanceable, bounded, and tied to defined tasks or events.
- Confirm ambient surfaces do not expose sensitive info casually and do not behave like ads/promotions.
- Confirm rendered widget gallery behavior, Live Activity Lock Screen/Dynamic Island lifecycle, notification delivery, Shortcuts/Siri invocation, and installed-device app-group I/O before claiming platform readiness.

## Final Gate

- Confirm Batch 60 is closed in repo truth.
- Confirm R05 remains `Candidate prepared; human approval required` unless explicit human approval and the remaining device/platform/operator gates are recorded.
- Confirm the release candidate matches current product truth and submission metadata.
- Confirm all active conditional gates are resolved.
- Record operator signoff only after the full RC gate in [../canon/Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md) is satisfied.

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
