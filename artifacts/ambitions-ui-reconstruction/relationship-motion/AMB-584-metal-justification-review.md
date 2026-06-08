# AMB-584 Metal Justification Review

Verdict: Green for AMB-584 read-only audit.

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `docs/codex/chatgpt-pro-ui-development-context-pack.md`
- `docs/codex/ambitions-ui-primitives-inventory.md`

## Scope

AMB-584 is read-only audit only. No Metal, shader, SwiftUI source, Canvas source, test source, registry, concept-lock, or app behavior change was made.

Changed files:

- none

Audit artifact:

- `artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-584-metal-justification-review.md`

## Findings

- No `.metal` or `.metallib` file is present in the bounded filename scan.
- No Swift source uses `MetalKit`, `MTL*`, `Shader(`, `layerEffect(`, `distortionEffect(`, or `colorEffect(`.
- Existing advanced visuals are SwiftUI, Canvas, TimelineView, Path, Shape, and theme/material based.
- `PRODUCT_DESIGN_TRUTH.md` keeps primitive approval locked unless a later implementation packet proves missing capability, fallback behavior, accessibility behavior, performance concern, ownership, and rollback.
- Current supporting guidance says Metal is only for highly specialized shaders after Canvas performance insufficiency is proven. No such insufficiency was found in this audit.

## SwiftUI / Canvas Justification

Metal is not justified for current AMB-584 scope.

- Layout, navigation, text, state rows, object stages, and accessibility semantics remain SwiftUI-owned.
- Product-meaningful contours are already handled by Canvas or Shape-backed engines with Reduce Motion fallbacks.
- The AMB-583 shared Canvas engine explicitly records fallback and performance boundaries, so Metal would add complexity without a missing capability.
- Existing Canvas/TimelineView paths already need review through performance and accessibility proof before any heavier rendering technology would be justified.

## Metal Veto

Do not use Metal for:

- text
- layout
- accessibility semantics
- navigation
- generic decoration
- card, glass, particle, or contour effects that SwiftUI, Canvas, Path, Shape, or theme materials can express

## Focused Tests

- not available — AMB-584 is read-only audit only, no source code changed, and there is no directly relevant focused test target for a no-Metal justification review.

## Validation

- `rg --files -g '! .git/**' -g '! .codex/**' | rg -i '\\.(metal|metallib)$|shader'` — no matches.
- `rg -n "\\.metal|MetalKit|\\bMTL[A-Za-z]*\\b|Shader\\(|layerEffect\\(|distortionEffect\\(|colorEffect\\(|shader" . --glob '!.git/**' --glob '!.codex/**'` — docs/prompt references only, no app or design-system source API usage.
- `rg -n "\\bMetal\\b|MTL|Shader\\b|shader|layerEffect|distortionEffect|colorEffect|visualEffect|drawingGroup|TimelineView|Canvas \\{" Native/Ambitions Sources AppUI/Sources --glob '*.swift'` — Canvas/TimelineView source exists; no Metal or shader API usage.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-584 --batch-type audit-only --prompt artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-584-metal-justification-review.md --changed-from 6d6cea3e7eff92d945f00f42722662ad706dfe32 --changed-path artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-584-metal-justification-review.md` — Green.
- `python3 scripts/ambitions-unsupported-claim-scan.py --changed-from 6d6cea3e7eff92d945f00f42722662ad706dfe32` — Green.
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-584-metal-justification-review.md` — no blocking hits.
- `git diff --check` — clean.
- `bash scripts/release-claim-safety-scan.sh` — Green after staging the audit artifact so the scan targets this issue diff instead of defaulting to truth files.

## Remaining Yellow Debt

- None

## Rollback

Remove this report artifact to roll back the AMB-584 audit record. No source rollback is needed.

## Proof Boundaries

- This is a read-only source audit and documentation artifact.
- No build, app behavior, screenshot, real-device, accessibility, measured performance, privacy, legal, CI, TestFlight, App Store, or release readiness proof is claimed.
