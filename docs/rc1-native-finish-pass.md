# Ambitions RC 1.0 Native Finish Pass

Superseded in part by the later production-readiness pass documented in [native-build-and-release.md](native-build-and-release.md). The app now has a native privacy manifest, a complete app icon set, system-driven appearance by default, and neutral first-run identity defaults.

Date: 2026-04-14
Scope: native SwiftUI finish pass for motion/polish, accessibility, planner trust, unfinished-flow removal, and RC hardening.

## Files Modified

- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsViewModels.swift`
- `Native/Ambitions/Features/Habits/HabitComponents.swift`
- `Native/Ambitions/Features/Habits/HabitsFeatureService.swift`
- `Native/Ambitions/Features/Habits/HabitsScreen.swift`
- `Native/Ambitions/Features/Habits/HabitsViewModel.swift`
- `Native/Ambitions/Features/Insights/InsightsScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Shared/FeatureScaffoldView.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayViewModel.swift`
- `Native/Ambitions/PreviewSupport/PreviewAppContainer.swift`
- `Native/Ambitions/PreviewSupport/PreviewFixtures.swift`
- `Native/Ambitions/Services/AppServices.swift`
- `Native/Ambitions/UI/LaunchGateView.swift`
- `Sources/Components/InformationPrimitives.swift`
- `Sources/Components/NavigationPrimitives.swift`
- `Sources/Components/SurfacePrimitives.swift`

## Finish-Pass Improvements

### Motion, Interaction, and Visual Polish

- Tightened shared press feedback for buttons with calmer shadow, offset, and scale behavior.
- Added reduced-motion-aware animations to segmented controls, bottom navigation, progress rails, and major screen state transitions.
- Added reusable `ambitionPanel` transitions for inline messages, expandable panels, celebrations, and loading/error state swaps.
- Moved key screens from eager `VStack` scroll bodies to `LazyVStack` to reduce long-scroll layout cost.
- Added pull-to-refresh across Today, Goals, Goal Detail, Habits, Insights, and Profile.
- Upgraded launch copy and primary scaffold headers to feel less provisional.

### Accessibility and Readability

- Increased hit-target safety on action chips, segmented controls, and major control rows.
- Added combined accessibility output for pills, stat tiles, progress rails, and panel surfaces.
- Added explicit accessibility value output for progress rails and metric tiles.
- Preserved reduced-motion compliance across state changes and number transitions.
- Improved multiline resilience for segmented controls and key action labels.

### Cross-Screen Consistency and Unfinished Flow Removal

- Removed dead-end action affordances from Insights and Profile instead of teasing nonexistent drill-ins.
- Replaced preview/demo/stub-style production copy in Today, Goals, Habits, Insights, Profile, launch, and bootstrap messaging.
- Aligned card/panel behavior across Today, Goals, Goal Detail, and Habits with shared accessibility and reveal treatment.
- Replaced preview hero placeholders in loading states with native-loading copy on Goals and Habits.
- Added lightweight tab rerouting support for widget actions still used elsewhere.

### Planner-Quality Trust Improvements

- Rewrote Today help/detail feedback so it no longer admits missing native flows.
- Rewrote Goals action messages to emphasize evidence, timing softening, and support framing rather than preview semantics.
- Rewrote Habits open-detail and seeded-state copy to reinforce calm, non-punitive support and consistency framing.
- Kept untimed/supportive language intact instead of implying false urgency.
- Preserved clarification-first and blocker-visible behavior rather than inventing plan certainty.

## Release-Readiness Checklist

- Confirm `project.yml` still generates the iOS project cleanly with XcodeGen.
- Build the app in Debug on iOS 17+ simulator.
- Build the app in Release on iOS 17+ simulator.
- Run `AmbitionsTests` and confirm GoalEngine and Persistence suites pass.
- Verify Today, Goals, Goal Detail, Habits, Insights, and Profile all load without placeholder admissions.
- Verify reduced-motion behavior with iOS Reduce Motion enabled.
- Verify Dynamic Type at Large, Extra Extra Large, and accessibility sizes.
- Verify VoiceOver labels for cards, buttons, progress rails, and stat tiles.
- Verify tab switching, pull-to-refresh, and goal-detail navigation.
- Verify no dead-end buttons remain on Insights/Profile.
- Verify starter data seeds only once in live mode and does not duplicate.
- Verify launch, error, and retry states across all main tabs.
- Validate widget/UI package compile compatibility from `Package.swift`.
- Validate archive, signing, and export flow in Xcode using the commands and Organizer steps in `docs/native-build-and-release.md`.
- Validate App Store submission metadata, privacy strings, and screenshots.

## Remaining Blockers

- Apple-side compile, archive, signing, and App Store validation were still unverified during this pass; use the documented native build pipeline for current validation steps.
- Real simulator/device validation for SwiftUI layout, animation, VoiceOver, scene transitions, and lifecycle behavior remains outstanding.
- Notification, widget, and connected-account systems remain post-1.0 scope and therefore are not RC 1.0 repo blockers.

## High-Risk Flows

- First launch and seed/bootstrap path.
- Today action handling: complete, delay, skip, smaller step, why-this-matters, quick log, help.
- Goal Detail action rail: complete, delay, skip, smaller, stuck, untimed, support mode, manual priority up/down.
- Goal Detail clarification answer write-back and draft recompilation.
- Habit logging and cadence advancement, especially minimum-version and skip/recovery behavior.
- Navigation handoff from Today/Habits into Goal Detail.
- Insights/Profile fallback states and empty/error transitions.
- Persistence migrations and legacy import behavior.

## QA Plan

1. Launch the app from a clean install and confirm starter data seeds once.
2. Open each main tab and capture screenshots for loading, loaded, and error states.
3. From Today, run each inline action on at least one standard goal, one starter plan, one blocked/clarification path, and one supportive goal.
4. From Habits, run complete, minimum version, quick log, delay, skip, easier version, and plan-is-wrong.
5. From Goals, verify filter counts, sort changes, empty states, and drill-in transitions.
6. In Goal Detail, verify path/task lens switching, progress labels, clarification visibility, blocked visibility, support framing, and history/evidence rendering.
7. Enable VoiceOver and verify cards/buttons read coherent summaries rather than fragmented text.
8. Enable Reduce Motion and confirm no large-scale motion remains.
9. Test Dynamic Type from default through accessibility sizes and confirm key controls remain tappable.
10. Test offline or forced-service-error paths and confirm retry surfaces remain usable.

## Suggested App Store Screenshot Surfaces

- Today: premium hero + daily targets + focus now + celebration.
- Goals: roadmap hero + portfolio list with clear path quality.
- Goal Detail: outcome, progress, path view, and trust-oriented explanation surfaces.
- Habits: calm consistency dashboard with minimum-version framing and recovery section.
- Insights: behavioral readout with stats, chart, and recent signals.
- Profile: polished identity and settings summary.

## Apple-Side Validation Checklist

1. Run `xcodegen generate` from repo root.
2. Open the generated Xcode project/workspace and resolve package dependencies.
3. Build `Ambitions` for iPhone simulator in Debug.
4. Run `AmbitionsTests`.
5. Build `Ambitions` for Release.
6. Boot on current iPhone simulator and smoke-test all six tabs.
7. Toggle Reduce Motion, Larger Text, Bold Text, and VoiceOver in simulator Accessibility settings.
8. Verify no Auto Layout or SwiftUI runtime warnings appear in console.
9. Archive the app in Xcode.
10. Run archive validation and note signing, entitlement, privacy, or icon issues.
11. Verify app icons, launch screen behavior, bundle metadata, and Info.plist strings.
12. Capture screenshot set from the surfaces listed above.
13. If archiving succeeds, perform TestFlight-ready export and App Store Connect preflight checks.

## Repo-Complete vs Real-Device Work

### Repo-Complete

- Shared motion/reduced-motion primitives for cards, rails, segmented controls, and tab shell.
- Native loading/error/refresh scaffolds across all major screens.
- Removal of obvious placeholder/demo admissions in live UI copy.
- Repository-backed Insights readout over persisted goals, drafts, evidence, feedback, and habit history.
- Repository-backed Profile with persisted local preferences and explicit local-first RC scope.
- Clarification answer write-back, manual priority persistence, typed habit evidence, and help-first Goal Detail routing.
- Planner-trust wording for Today, Goals, Goal Detail, and Habits.

### Requires Real Device or Apple Runtime

- Final animation feel, haptics absence/presence, and scroll smoothness.
- Dynamic Type clipping and VoiceOver rotor/read-order verification.
- Safe-area, tab-bar, and navigation-bar behavior on multiple device classes.
- Notification, widget, and connected-account entitlement validation if those systems are brought into post-1.0 scope.
- Archive signing, symbol generation, and App Store submission preflight.

## Known Limitations Before RC 1.0

- Apple-toolchain verification was not possible during this earlier pass. The current repo-level validation path is documented in `docs/native-build-and-release.md`.
- Performance validation is code-review-based only; there is no Instruments trace yet.
- Real-device checks for VoiceOver cadence, haptic feel, and final frame pacing remain open.

## RC 1.0 Scope Statement

- RC 1.0 includes the native shell, Today, Goals, Goal Detail, Habits, Insights, Profile, local persistence, planner/adaptation, clarification write-back, manual priority ordering, and typed habit evidence.
- RC 1.0 is intentionally local-first. Connected account, sync, and fake-auth blockers are out of scope for this release candidate.
- Home-screen widgets and notifications remain post-1.0 systems unless Apple validation is explicitly scheduled as a separate pass.
