# Ambitions 3.0 F16.5 SwiftUI Architecture Hardening Report

Date: 2026-05-01

## Result

F16.5 gate: Green, planning/checkpoint hardening only.

The conditional F16.5 trigger fired because the post-F16 architecture scan still
reports broad feature-boundary and extraction-required risks across existing
feature, domain, service, preview, and shell-adjacent files. F16 itself touched
only UI tests and did not worsen those files.

Per the F15-F16-F16.5 train manifest, architecture trains are planning-only
unless explicitly approved for implementation. This checkpoint records the risk
map, state-contract boundaries, F17 readiness posture, and the exact next prompt
without performing a surprise cross-feature refactor.

## Trigger Evidence

- Architecture scan reports extraction-required files in Goals, Plan, Profile,
  Today, Domain, Persistence, and Preview support.
- F16 UI modernization revealed stale UI-test expectations that depended on
  layout details instead of product contracts.
- Shell/Meridian planning would be unsafe if treated as a broad implementation
  pass without first respecting the current shell, route, and state-contract
  ownership boundaries.

## Files Inspected

- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/App/AppShellView.swift`
- `Native/Ambitions/Features/Today`
- `Native/Ambitions/Features/Goals`
- `Native/Ambitions/Features/Plan`
- `Native/Ambitions/Features/Profile`
- `Native/Ambitions/Features/Captures`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- Architecture canon and F15-F16-F16.5 train docs

## Boundary Map

- App shell owns top-level IA, tab presentation, command entry, and route
  dispatch. It must not absorb feature projection logic.
- Today owns Step Session, Action Closure entry points, Reality Rail, Day Rail,
  and Today execution projection.
- Plan owns Day Shape, Week Shape, Life Shape, reflow/recovery/decision state,
  and Plan-to-Today handoff contracts.
- Goals owns Goal Mission Control, goal-local proof/status display, goal path
  and lane ownership, and goal-local source labels.
- You/Profile owns `What Ambitions Knows`, personalization consent, memory
  source/freshness visibility, correction/deletion controls, and sensitive-memory
  approval posture.
- Evidence/Proof owns receipt/proof semantics and hierarchy, not UI shell state.
- UI tests own product-contract verification and should avoid asserting private
  layout implementation details.

## Extraction And Hardening Decision

No behavior-preserving extraction was performed in F16.5.

Reasons:

- F16 touched only UI tests and did not worsen product architecture files.
- The remaining extraction-required files are broad pre-existing backlog, not a
  new current-batch regression.
- A Green F16.5 code hardening pass would require a dedicated, approved
  architecture implementation plan with per-feature ownership and focused tests.
- Broadly extracting Goals, Plan, Profile, Today, App shell, and Domain files in
  one automatic continuation would exceed the safe train width.

## F17 Readiness Classification

F17 Shell/Meridian planning may proceed.

F17 Shell/Meridian implementation is not approved by this checkpoint. The next
F17 planning prompt must start by mapping shell ownership, route contracts,
feature boundaries, existing App shell line-count risk, and UI-test product
contracts before any Shell/Meridian code is implemented.

## Remaining Architecture Risks

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift` remains a major
  extraction-required file.
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift` and
  `Native/Ambitions/Features/Plan/PlanScreen.swift` remain extraction-required.
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift` and
  `Native/Ambitions/Features/Profile/ProfileScreen.swift` remain
  extraction-required.
- `Native/Ambitions/Features/Today/TodayFeatureService.swift` and
  `Native/Ambitions/Features/Today/TodayPanels.swift` remain extraction-required.
- App shell files remain near or above responsibility-review thresholds and must
  be handled carefully before any Shell/Meridian implementation.

## Validation

- Build: PASS, `scripts/build-local.sh` on `iPhone 17` during F16 closeout.
- Focused tests: PASS, modernized UI lane, 7 tests.
- Full local test wrapper: PARTIAL/advisory. `scripts/test-local.sh || true`
  reached the known full UI smoke failure class with `29` UI tests run and
  `7` UI failures, then required process cleanup after the failure summary.
- Architecture scan: advisory/PARTIAL with pre-existing extraction warnings.
- Copy guard: PASS for F16 touched UI-test path.
- Doc QA: advisory/PARTIAL from known stale-guidance, deprecated-language,
  markdownlint, and lychee backlog.
- Diff check: PASS after F16.

## Gate Classification

Green.

F16.5 completed the required architecture checkpoint without introducing new
product behavior, broad refactors, dependencies, workflow changes, or release
claims. F17 may proceed as a Shell/Meridian planning prompt only.
