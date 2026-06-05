<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-514-CANON-COPY-REPAIR

Mission: repair AMB-514 Capture copy/state-label drift against promoted `docs/truth/PRODUCT_DESIGN_TRUTH.md`.

Keep scope narrow:
- Do not redesign Capture.
- Do not add new primitives.
- Do not touch unrelated surfaces.
- Preserve AMB-514 local route evaluation, Held Object, correction, and receipt behavior.
- Preserve the existing SourceRecord, ReplayTrace, and `You / What Ambitions knows` inspection seams.

Authoritative truth:
- Use `docs/truth/PRODUCT_DESIGN_TRUTH.md` as active authority.

Current Capture truth:
- Capture is a global action, not a tab.
- Activated title: `Capture Anything`.
- Primary object: Placement Field.
- Activated layer: Atmosphere Composer.
- Open Field is activated atmosphere mode.
- Input becomes local Held Object.
- Approved route states: `Needs a Place`, `Ready to Place`, `Grow into Goal`, `Held for Review`.
- Low confidence saves first as `Needs a Place`.
- Meaningful placement leaves Receipt.
- `Placement Field` should not be ordinary user-facing label unless onboarding/help/internal.
- `Atmosphere Composer` should not be ordinary user-facing label.

Repair target:
1. In active visible Capture UI, restore `Capture Anything` where AMB-514 changed active title/header to `Placement Field`.
2. Remove `Placement Field` from ordinary user-facing first-screen copy unless the specific location is onboarding/help/internal/debug/design-state proof.
3. Keep `Placement Field` as internal/product-object language in tests/docs only where appropriate.
4. Ensure low-confidence/no-safe-destination route uses `Needs a Place`.
5. Use `Held for Review` only for explicit deferred-review/held-review state, not as a blanket replacement for `Needs a Place`.
6. Preserve route states:
   - `Needs a Place`
   - `Ready to Place`
   - `Grow into Goal`
   - `Held for Review`
7. Keep no cloud classification, no AI confidence language, no Capture tab, no floating Capture button, no notes inbox/chat/category grid/task board.
8. Update focused tests to prove the corrected copy/state split.
9. Keep SourceRecord, ReplayTrace, and `You / What Ambitions knows` inspection copy intact unless the touched copy is the specific canon drift above.

Inspect first:
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift`
- `Native/Ambitions/Features/Capture/CaptureViewModel.swift`
- `Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift`
- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
- any preview/view-state files touched by AMB-514

Validation:
- Run Packet 0/0R verified commands.
- Run focused Capture tests that AMB-514 ran:
  - `CaptureViewModelTests`
  - `CapturePlacementReviewStateTests`
- Run guard validation used by the runner.
- Run `git diff --check`.

Proof boundaries:
- Do not claim screenshot, manual VoiceOver, device, performance, privacy/legal, TestFlight, App Store, CI, or release proof unless actually produced.

Push:
- Push to `main` if Green or accepted Yellow.
- Repair Yellow/Red if possible.

Final report must include:
- Status
- commit SHA
- files changed
- exact visible copy repaired
- route-state mapping after repair
- validation run
- proof boundaries
- rollback command
- next eligible Codex command

Next eligible command after this repair should be AMB-515 if no Red blockers remain.
