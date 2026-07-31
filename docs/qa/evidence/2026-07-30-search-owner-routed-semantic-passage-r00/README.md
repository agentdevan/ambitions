<!-- markdownlint-disable MD013 -->

# Search Owner-Routed Semantic Passage R00

`AVF-SEARCH-D07-R01-NATIVE-R00 — Owner-Routed Semantic Search Passage`

Status: `READY_FOR_OWNER_SEARCH_NATIVE_REVIEW`

Parent provisional authority: `AVF-SEARCH-D07-R01 — Owner-Routed Semantic Command Field`

Installed closure: `VC10-SEARCH-S01 — Full-Screen Semantic Command Passage`

Fixture: `search-flagship/owner-routed-semantic-passage/v1`

Captured source: `5366214d4b1d1c1a8dd7fbec9889cffbc250843b`

This package is one bounded, fixture-driven native proving slice. It asks whether Search can operate as a full-screen, local, owner-routed semantic command passage without becoming an AI answer feed, generic command palette, Search-owned mutation surface, or privacy leak. Passing validation does not accept Search automatically.

## Preserve exactly

- Search remains a temporary full-screen global non-root, never a tab.
- The origin and initiating Search control remain the exact dismissal and focus-return target.
- Root chrome is absent while Search is active; query and Cancel remain stable above the native keyboard.
- Results preserve canonical identity and canonical owner.
- Find, Inspect, bounded object-backed Understand, and owner-handoff preparation remain non-mutating.
- Privacy suppression never reveals the protected identity.
- No-results and privacy-degraded states remain distinct.
- `APPROVED_FOR_SWIFTUI = false`.

## Changed

- Added only Foundry fixture behavior for the selected Search proving slice.
- Embedded the minimum provisional global-presentation substrate in Search: fixture origin identity, temporary full-screen presentation, origin/trigger return target, initial focus, keyboard containment, Cancel, exact return, and return focus.
- Added an explicit Dynamic Type propagation boundary so the presented passage receives Accessibility 2 instead of inheriting ordinary-size geometry.

## Removed

- Root chrome from the active global Search journey.
- Any assistant avatar, chat anatomy, generated answer, prompt filler, floating command-palette box, confidence score, Search-owned edit control, settlement claim, or protected identity disclosure.
- No production behavior or source was removed.

## Added

- Representative local results for a Time-owned Event and Goals-owned current movement.
- One focused Event inspection containing distinct Inspect and Understand sections.
- One Time-owned handoff-preparation depth that preserves accepted truth and records zero canonical mutations.
- Deterministic no-results and privacy-suppressed states.
- Six standalone native screenshots and focused package/UI assertions.

## Unresolved

- Production indexing, object resolution, routing, privacy authorization, owner handoff, and cross-root return remain unproven.
- No stale/unavailable index, permission-limitation, unsupported-query, ambiguity, or partial-coverage anatomy is proven by this single degraded fixture.
- Production shell and Crowned Edge Dock coexistence remain unproven.
- Manual assistive-technology, RTL, long-localization, and physical-device behavior remain unproven.

## Architecture-sensitive assumptions

- The neutral Today origin is a fixture host only. It neither reproduces nor reopens accepted Today.
- The presentation substrate is provisional Foundry infrastructure embedded in Search, not a final shared component, production API, second shell, or separate acceptance phase.
- The fixture state does not reconcile current production Search models, indexes, routes, or privacy filtering.
- `Continue in Time` records a fixture-only prepared handoff; it does not instantiate Time or mutate the Event.
- Search context restoration is in-session fixture proof, not durable restoration across relaunch.

## Validation

See [validation-results.md](validation-results.md). The Foundry package, focused Search tests, fixture-host build, focused UI journey, screenshot metadata, accessibility order, lint, links, paths, diff, and introduced-range secret scan are the bounded validation set.

## Evidence

- [Focused Search entry](screenshots/01-search-entry-focused-dark.png)
- [Representative results](screenshots/02-search-results-dark.png)
- [Inspect and bounded Understand](screenshots/03-search-inspect-understand-dark.png)
- [Owner-handoff preparation](screenshots/04-search-owner-handoff-preparation-dark.png)
- [Privacy-degraded state](screenshots/05-search-privacy-degraded-dark.png)
- [Accessibility results](screenshots/06-search-results-accessibility-dark.png)
- [Machine-readable screenshot metadata](screenshot-metadata.json)
- [Fixture contract](fixture-contract.md)
- [Owner review](owner-review.md)

All captures are 1206 × 2622 pixels from the `VC14 iPhone 17 Pro` Simulator on iOS 26.5 (23F77). The first five use Dynamic Type Large; the sixth uses Accessibility 2.

## Proof ceiling

This is bounded Simulator evidence for owner review. It is not final, production-ready, a production screenshot baseline, runtime integration, canon installation, shell proof, or implementation authorization.

- Fixture identity: `search-flagship/owner-routed-semantic-passage/v1`
- Simulator evidence only
- `production_baseline = false`
- `direct_device_proof = false`
- `runtime_integration = false`
- `production_implementation = false`
- `canon_installation = false`
- `shell_viability_proof = false`
- `APPROVED_FOR_SWIFTUI = false`
