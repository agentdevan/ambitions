# AMB-587 No-Card Final Primitive Scan

Verdict: Yellow

AMB-587 ran the hard no-card scan before polish. Green is not honest because active `Card` / `Tile` / `Dashboard` and root-geometry hits remain in runtime source. Red is not the correct closeout for this gate because the remaining review-required hits are classified and tied to the owner-filed follow-up issue AMB-607.

Runtime/source changed files: none.

Required proof artifact added:

- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-587-no-card-final-primitive-scan.md`

## Active Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `docs/codex/ambitions_no_card_replacement_taxonomy.md`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-no-card-audit.md`
- `artifacts/ambitions-ui-reconstruction/final-proof/AMB-586-primitive-family-replacement-proof-gate.md`

## Scan Commands And Outputs

### Card / Tile / Dashboard Source Scan

Command:

```bash
rg -n "Card|HeroCard|SurfaceCard|ModuleCard|Tile|Dashboard" Native Sources --glob "*.swift" | wc -l
```

Output:

```text
968
```

Command:

```bash
rg -n "Card|HeroCard|SurfaceCard|ModuleCard|Tile|Dashboard" Native Sources --glob "*.swift" | sed -n '1,180p'
```

Representative output:

- `Sources/Components/InformationPrimitives.swift:104` - `public struct StatTile: View`
- `Native/Ambitions/Features/Onboarding/ProgressiveIntelligenceOnboarding.swift:169` - `HeroCard(state: .selected)`
- `Native/Ambitions/Features/Goals/GoalComponents.swift:836` - `struct GoalsHeroCard: View`
- `Native/Ambitions/Features/Goals/GoalComponents.swift:1496` - `struct GoalsAtlasCardView: View`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift:682` - `private struct GoalDetailReviewTrailCard: View`
- `Native/Ambitions/Features/Time/TimeScreen.swift:371` - `private struct TimeCalendarAwarenessCard: View`
- `Native/Ambitions/Features/Today/TodayPanels.swift:1070` - `struct TodayHeroCard: View`
- `Native/Ambitions/Features/You/YouScreen.swift:531` - `private struct YouConstitutionCard: View`

Classification:

- Runtime and preview/test hits remain.
- Active runtime hits are review-required and owner-filed under AMB-607.
- Shared primitive definitions such as `AppCard`, `HeroCard`, `WidgetCard`, and `StatTile` are source-present compatibility primitives, not proof that top-level surfaces are clean.

### Root Geometry / Container Shape Scan

Command:

```bash
rg -n "RoundedRectangle|\.background\(|\.cornerRadius\(|\.shadow\(" Native/Ambitions/App Native/Ambitions/Features Sources --glob "*.swift" | wc -l
```

Output:

```text
625
```

Command:

```bash
rg -n "RoundedRectangle|\.background\(|\.cornerRadius\(|\.shadow\(" Native/Ambitions/App Native/Ambitions/Features Sources --glob "*.swift" | sed -n '1,180p'
```

Representative output:

- `Native/Ambitions/Features/Onboarding/ProgressiveIntelligenceOnboarding.swift:274` - `RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)`
- `Native/Ambitions/Features/You/YouPlanningDefaultsSectionCard.swift:67` - `RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)`
- `Native/Ambitions/Features/You/YouScreen.swift:556` - `RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)`
- `Native/Ambitions/Features/You/YouScreen.swift:1028` - `RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)`
- `Sources/Components/AmbitionsPremiumMaterials.swift:172` - `.background(theme.colors.surfaceOverlay)`
- `Sources/Components/LifeDirectionalIntegrationPrimitives.swift:288` - `.clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))`

Classification:

- Some geometry belongs to shared primitives and native surface materials.
- Repeated root/feature-local rounded container geometry remains review-required.
- AMB-607 owns classification and replacement for any active root-surface geometry that still behaves like a panel/card stack.

### Structural Anti-Card Validator

Command:

```bash
python3 scripts/ios26-anti-card-check.py --surface global --batch AMB-587 --markdown
```

Output summary:

- Status: Red from the structural validator.
- Files scanned: 477.
- Red findings: 127.
- Yellow findings: 0.
- Missing object root evidence: `LivingChrome`, `CaptureRouteLens`, `TrustAutomation`.
- The generated local `build/reports/frontend-object-purity/AMB-587-anti-card.*` files were kept out of the commit scope; this report records the scan summary and representative findings.

Representative Red findings:

- `Native/Ambitions/Features/Goals/GoalComponents.swift:836` - `struct GoalsHeroCard: View`
- `Native/Ambitions/Features/Goals/GoalComponents.swift:928` - `struct GoalsWeekPressureCard: View`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift:682` - `private struct GoalDetailReviewTrailCard: View`
- `Native/Ambitions/Features/Habits/HabitComponents.swift:4` - `struct HabitsHeroCard: View`
- `Native/Ambitions/Features/Insights/InsightsScreen.swift:344` - `private struct InsightsHeroCard: View`
- `Native/Ambitions/Features/Shared/DegradedStateOrchestrator.swift:477` - `struct DegradedStateCard: View`
- `Native/Ambitions/Features/Time/TimeScreen.swift:371` - `private struct TimeCalendarAwarenessCard: View`
- `Native/Ambitions/Features/Today/TodayPanels.swift:1070` - `struct TodayHeroCard: View`
- `Native/Ambitions/Features/You/YouScreen.swift:531` - `private struct YouConstitutionCard: View`

Classification:

- These findings block a Green no-card claim.
- They do not create an unowned Red blocker for AMB-587 because AMB-566 and AMB-586 already point this class of debt to AMB-607.

### Focused-Test Availability Check

Command:

```bash
rg --files Native/AmbitionsTests | rg -i 'no.?card|anti.?card|card|tile|dashboard|primitive|objectstage|container'
```

Output:

```text
Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift
Native/AmbitionsTests/UI/SourceAtlasUIPrimitivesTests.swift
Native/AmbitionsTests/App/ClosureRecoveryPrimitiveFamilyTests.swift
Native/AmbitionsTests/App/QuietReflowPrimitiveFamilyTests.swift
Native/AmbitionsTests/App/CaptureRoutingPrimitiveFamilyTests.swift
Native/AmbitionsTests/App/ProofRelationshipTracePrimitiveFamilyTests.swift
Native/AmbitionsTests/App/AppContainerFactoryTests.swift
Native/AmbitionsTests/Domain/SourceAtlasSourceContainerModelsTests.swift
Native/AmbitionsTests/Time/HorizonCapacityPrimitiveFamilyTests.swift
```

Classification:

- Existing tests are primitive-specific or source/container-model specific.
- No directly relevant global no-card final scan XCTest target exists.
- Creating a broad test harness would violate the AMB-587 testing rule.

## Owner-Filed Yellow Debt

All active runtime Card/Tile/Dashboard and unclassified root geometry review debt is tied to:

- AMB-607 - classify and replace active card/container structures.

This matches AMB-566 and AMB-586. AMB-587 does not add new source debt and does not expand the owner set.

## Focused Tests

Focused tests are `not available` for AMB-587. The issue is a read-only scan/classification gate. Existing focused primitive tests do not prove the global no-card scan condition, and no matching no-card final scan XCTest target exists.

## Validation

- `rg -n "Card|HeroCard|SurfaceCard|ModuleCard|Tile|Dashboard" Native Sources --glob "*.swift" | wc -l` - 968 hits.
- `rg -n "Card|HeroCard|SurfaceCard|ModuleCard|Tile|Dashboard" Native Sources --glob "*.swift" | sed -n '1,180p'` - completed; representative output recorded above.
- `rg -n "RoundedRectangle|\\.background\\(|\\.cornerRadius\\(|\\.shadow\\(" Native/Ambitions/App Native/Ambitions/Features Sources --glob "*.swift" | wc -l` - 625 hits.
- `rg -n "RoundedRectangle|\\.background\\(|\\.cornerRadius\\(|\\.shadow\\(" Native/Ambitions/App Native/Ambitions/Features Sources --glob "*.swift" | sed -n '1,180p'` - completed; representative output recorded above.
- `python3 scripts/ios26-anti-card-check.py --surface global --batch AMB-587 --markdown` - structural scan returned Red with 127 red findings; classified as accepted Yellow for AMB-587 because remaining review-required hits are owner-filed under AMB-607.
- `rg --files Native/AmbitionsTests | rg -i 'no.?card|anti.?card|card|tile|dashboard|primitive|objectstage|container'` - completed; no directly relevant no-card final scan XCTest target exists.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-587 --prompt docs/codex/ambitions_primitive_invention_registry.md --changed-from 3d366957202e41d466363b0d3182d20fa6728668 --batch-type audit-only --changed-path artifacts/ambitions-ui-reconstruction/final-proof/AMB-587-no-card-final-primitive-scan.md` - Green; report `build/reports/parallel-implementation-guard/AMB-587-post.md`.
- `python3 scripts/ambitions-unsupported-claim-scan.py artifacts/ambitions-ui-reconstruction/final-proof/AMB-587-no-card-final-primitive-scan.md` - Green.
- `bash scripts/codex-forbidden-claim-scan.sh artifacts/ambitions-ui-reconstruction/final-proof/AMB-587-no-card-final-primitive-scan.md` - no blocking hits.
- `bash scripts/release-claim-safety-scan.sh` - Green after staging the AMB-587 report.
- `git diff --check` - passed.

## Proof Boundaries

- This report proves only scan execution and classification.
- It does not claim Green no-card completion, source remediation, fresh app build, fresh focused tests, fresh screenshots, human visual approval, public accessibility conformance, performance readiness, device behavior, privacy/legal approval, TestFlight readiness, App Store readiness, or release readiness.

## Rollback

- Remove this AMB-587 proof report if the gate needs rollback.
- No app source rollback is needed because AMB-587 changed no app source.

## Required Completion Footer

Verdict: Yellow
Artifact paths:
- artifacts/ambitions-ui-reconstruction/final-proof/AMB-587-no-card-final-primitive-scan.md
Focused tests:
- `not available` - AMB-587 is a read-only no-card final scan with no directly relevant existing no-card final scan XCTest target; creating a broad harness would violate the testing rule.
Changed files:
- none (runtime/source); required report artifact added only.
Remaining Yellow debt:
- AMB-607
