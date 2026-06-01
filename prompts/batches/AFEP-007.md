<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-007 - Semantic Token and Motion/Haptic Compiler

## Batch ID

AFEP-007

## Linear Issue

AMB-401 - AFEP-007 - Semantic Token and Motion/Haptic Compiler

## Objective

Bind runtime semantics to typography, color, materials, motion, symbols, and haptics through deterministic, accessibility-safe compiler artifacts. Visual emphasis, motion, and haptic affordances must be traceable to semantic inputs rather than decorative styling or opaque UI taste.

## Active Source Truth

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- Live source, tests, and current wrapper logs beat stale docs or old batch claims.

## Required Actions

- Define a semantic token taxonomy that maps product/runtime meaning to typography, color, materials, symbols, motion, and haptic intent.
- Add deterministic compiler models or fixtures that make visual emphasis traceable to semantic inputs.
- Add reduced-motion variants for every motion-bearing semantic output.
- Add differentiate-without-color variants so meaning never depends on color alone.
- Add haptic language policy that treats haptics as reinforcement only, never as sole confirmation or proof.
- Add causality tests proving semantic inputs produce expected token, motion, and haptic outputs.
- Preserve explicit SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection seams in any semantic causality artifact that references runtime provenance or proof.
- Store a causality packet and motion/accessibility matrix under `build/reports/afep/AFEP-007/`.

## Acceptance Gates

- Visual emphasis is traceable to semantic inputs.
- Accessibility-safe variants exist for reduced motion and differentiate-without-color.
- Motion is optional, bounded, and never the only carrier of meaning.
- Haptics reinforce visible/accessible state changes and are never the sole confirmation path.
- You / What Ambitions knows inspection can trace any runtime-derived visual emphasis back to its SourceRecord, Receipt, and ReplayTrace context.
- The compiler does not create a parallel design system, runtime engine, recommendation owner, or proof owner.

## Allowed Scope

- Existing canonical design-token, visual-state, accessibility, proof/report, and focused test owners under `Sources/`, `AppUI/Sources`, `Native/Ambitions/UI`, `Native/Ambitions/Domain`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-007/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-007 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel design system, styling engine, runtime engine, planner, recommendation path, proof/receipt/replay path, or user-profile owner.
- Do not add cloud AI, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not revive `Plan` as a user-facing top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not use color-only meaning, motion-only meaning, haptics-only confirmation, or productivity-guilt visual pressure.
- Do not refactor broad SwiftUI surfaces unless a focused compiler integration or test seam requires it.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, CI, TestFlight, App Store, or broad full-suite proof.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-007`.
- Run focused test lanes for semantic compiler behavior and any changed owner tests.
- Run `git diff --check`.
- If broad UI or visual proof lanes are attempted, record any existing out-of-scope failures honestly as Yellow unless they are introduced by this batch.

## Proof Artifacts

- `build/reports/afep/AFEP-007/causality-packet.md`
- `build/reports/afep/AFEP-007/motion-accessibility-matrix.md`

## Rollback / Failure Behavior

Use reduced semantic styling if evidence fails. On Red, stop with the smallest safe repair rather than widening into broad design-system or runtime cleanup.

## Hard Red

- Color-only meaning.
- Motion-only meaning.
- Haptics as sole confirmation.
- Opaque AI confidence or decorative intelligence framing.
- Required cloud AI, backend, analytics, tracking, or hosted inference.
- New parallel design system, runtime, recommendation, planning, or proof owner.
- Release, accessibility conformance, or full-suite proof claims without current evidence.
