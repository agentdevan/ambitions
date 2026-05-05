# FCP09 Motion / Haptics / Reduced Motion Proof Prompt

## Role

You are operating as the Ambitions FCP09 shared design-system implementation
agent.

## Batch

FCP09 — Motion / Haptics / Reduced Motion Proof

## Source Truth

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/audits/si12-interaction-motion-haptics-system-report.md`
- `docs/audits/dav10-adaptive-motion-reduce-motion-state-transitions-report.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_GATE_MATRIX.md`
- `docs/codex/CODEX_QUALITY_SYSTEM_REPAIR_PROTOCOL.md`

## Scope

Add object-specific motion and haptic policy proof for:

- Start Here
- Reality Rail
- Receipt Drawer
- Source Fold
- MissionControlTimeSpine
- Action Closure Diamond
- LifeShape Map
- Capture Atmosphere Composer

## Allowed Files

- `Sources/Components/MotionPrimitives.swift`
- `Sources/Previews/InteractionMotionHapticsPreviews.swift`
- `Native/AmbitionsTests/App/InteractionMotionHapticsDesignSystemTests.swift`
- FCP09 audit/report docs
- train registry, context index, current-run-state, current-batch-train-state,
  global order, and FCP train docs needed for batch closeout

## Forbidden Files

- Top-level navigation/tab definitions
- Persistence/schema/sync/auth/network files
- AI/AOS/LDI runtime files
- CI/workflow/signing/entitlement files
- App Store, TestFlight, release, legal, privacy, or public accessibility claim
  files unless only recording claim boundaries in the audit report

## Acceptance

- Each flagship object has a policy with owner, motion token, state meaning,
  non-motion cues, Reduce Motion equivalent, and haptic boundary.
- No motion-only meaning.
- Haptics stay optional and user-initiated.
- Source, proof, privacy, receipt, Capture, LifeShape, and
  MissionControlTimeSpine source truth remain intact.
- No route/raw-value, persistence/schema, sync/account, AI/LDI runtime, release,
  legal/privacy, or public accessibility claims are introduced.

## Required Validation

- `xcodegen generate`
- Focused `InteractionMotionHapticsDesignSystemTests`
- `scripts/build-local.sh`
- `git diff --check`
- touched-doc trailing whitespace scan
- CQS advisory scans relevant to motion, drift, accessibility, privacy, and
  prompt-built smell
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Stop Conditions

Stop only for a true Hard Red: app build break without safe repair path,
route/raw-value compatibility break, persistence/schema risk, unsupported
release/legal/privacy/accessibility claim, severe product drift, or a user
decision required to preserve source truth.
