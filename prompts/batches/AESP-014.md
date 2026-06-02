<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AESP-014 - Capture / Atmosphere Composer Experience Elevation

Linear issue: AMB-436
Project: Ambitions Experience Sovereignty Program
Milestone: M03 - Surface-by-Surface Experience Elevation

## Source-Truth Entry

Before editing, inspect the active Ambitions truth files in the AGENTS.md order:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. relevant Capture source, tests, evidence, scripts, and status docs

Active canon constraints:

- Top-level IA remains exactly `Today / Goals / Capture / Time / You`.
- `Plan` is not user-facing top-level IA.
- Capture must remain composer-first and minimal at top level.
- Capture must not become an inbox, notes feed, chat transcript, category grid, status board, or generic task intake.
- Use `step`, not `move`, for action items.
- Do not introduce cloud AI, hosted inference, backend, analytics, tracking SDKs, paid services, or server dependencies.
- Preserve local-first deterministic Private Life Runtime posture.
- No release, accessibility, performance, privacy, device, App Store, TestFlight, or CI claims without matching evidence.

## Champion Merge Source Boundary

- AESP-014 is a scoped owner-review elevation of the existing canonical `capture_root` owner.
- Extend `capture_root`; do not create a new parallel Capture owner.
- `capture_routing` remains accepted Yellow for broad runtime consolidation. This batch may improve the Capture feature presentation inside the recorded owner boundary, but it must not claim full Capture runtime consolidation.
- Do not touch durability, export, handoff, backend, analytics, cloud AI, or release-signing owners.
- No-claim boundary: this batch can claim only local source/test evidence for the scoped Capture feature elevation.
- Follow-up gate: broad Capture runtime consolidation remains gated until the existing gauntlet is Green or owner-accepted.
- Affected canonical owner: `capture_root`.

## Batch Goal

Implement AESP-014 fully enough for Green local source/test/evidence status:

Elevate the Capture / Atmosphere Composer experience so it presents a premium native iPhone-first capture surface with composer-first hierarchy, inspectable placement preview, ambiguity handling, and reviewable explanation. The user should be able to understand what the capture draft is likely becoming without the surface feeling like a feed, inbox, chat, category picker, or generic notes screen.

## Implementation Scope

Use existing owners unless Phase 01 proves a narrower or adjacent owner is required:

- `Native/Ambitions/Features/Capture/CaptureScreen.swift`
- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Capture/CaptureViewModel.swift`
- `Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift`
- related focused Capture feature tests under `Native/AmbitionsTests/Capture/`

Do not create parallel implementation surfaces. Do not add a new app route, tab, package dependency, service dependency, backend, AI dependency, or telemetry dependency.

## Required Product Outcomes

The completed slice must demonstrate:

- Composer-first Capture hierarchy, with the primary object being intent composition.
- Placement preview/reveal that is understandable without exposing implementation jargon.
- Ambiguity handling that invites correction/review instead of pretending certainty.
- Reviewable local explanation for placement confidence and ambiguity using existing `capture_root` feature state.
- Copy and state labels aligned with Ambitions canon: quiet luxury, trust, calm language, no shame, no urgency theater.
- Accessibility-aware structure: VoiceOver order, Dynamic Type resilience, and Reduce Motion compatibility considered in source and evidence boundaries.
- Visual/product quality consistent with native premium iPhone expectations, not a status board or web-style pile of panels.

## Required Tests / Coverage

Add or update focused tests that prove the behavioral shape of the Capture elevation. Prefer existing test owners:

- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
- `Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift`

At minimum, cover:

- Composer-first copy/state does not present Capture as inbox/feed/chat/category grid/status board.
- Placement preview/reveal reflects likely destination and confidence/ambiguity.
- Ambiguous capture does not claim certainty and exposes review/correction state.
- Local explanation text or feature model behavior records placement reasoning.
- Existing Capture feature behavior remains compatible.

## Required Evidence Packet

Create or update:

`build/reports/aesp/AESP-014/capture-atmosphere-composer-evidence.md`

The evidence packet must include:

- Linear issue and commit placeholder until commit exists.
- Source files changed and why each was touched.
- Source mapping from Capture product outcomes to implementation owners.
- Tests added/updated and exact local validation commands.
- Verified/Not verified/Blocked/Human follow-up sections.
- Explicit statement that screenshots, physical device validation, release validation, TestFlight/App Store validation, legal/privacy signoff, and CI validation are not claimed unless actually produced.
- Dirty-worktree preservation notes for unrelated pre-existing files.

## Required Validation

Run current local validation and repair until Green or a truth-file hard stop is hit:

```bash
python3 scripts/ambitions-champion-coverage-check.py --batch AESP-014
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-014 --prompt prompts/batches/AESP-014.md --batch-type source-changing --allow-yellow
xcodegen generate
make xcode-build-for-testing BATCH=AESP-014
make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests/CaptureViewModelTests
make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests/CapturePlacementReviewStateTests
make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests
python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-014 --prompt prompts/batches/AESP-014.md --changed-from 7f3d5256cd3507f49a84a9f76696039087773ff2 --batch-type source-changing --allow-yellow
git diff --check
```

If a focused test identifier is stale, discover the current test symbol with `rg` and use the nearest current focused Capture lane. Record any substitution in the evidence packet and Linear closeout.

## Linear Update Requirements

Keep AMB-436 updated with:

- Start state and dirty-worktree boundary.
- Runner status.
- Repair findings if a repair cycle is needed.
- Final source/test/evidence summary.
- Commit SHA when committed.

Only mark AMB-436 Done after local Green evidence and commit are both complete.
