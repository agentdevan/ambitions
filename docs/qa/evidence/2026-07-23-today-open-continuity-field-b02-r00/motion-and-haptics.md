# B02 motion and haptics

Status: `PROPOSED`

- Visual branch: `AVF-TODAY-S10-B02-R00`
- Fixture: `today-flagship/preparing-for-baby/still-counts/v1`
- Source revision at capture: uncommitted Task 09 changes on `929761ed241d719d93d684305ebccbfc4ed66d47`
- Host bundle: `com.ambitions.ios.nativefoundry`
- Device: VC14 iPhone 17 Pro, Simulator `EDE1E954-C663-47FB-855B-95F96AE2DBDD`
- OS: iOS 26.5 Simulator
- Appearance: Dark
- Dynamic Type: Large
- Screenshots and recordings: evaluation references; `production_baseline = false`

## 1. Preserve exactly

- The same fixture identities, accepted/proposed/saving/settled truth, navigation,
  focus anchors, safe-area actions, matte content, Continuity Spine shapes, and
  native presentation behavior remain authoritative within this fixture slice.
- Motion never carries product meaning. Every current, proposed, saving,
  settled, interrupted, protected, fixed, external, and open-lane state retains
  its unique static node geometry and text.
- Primary content remains opaque. Task 09 adds no content glass and makes no
  change to the existing functional dock glass or its Reduce Transparency
  equivalent.

## 2. Changed

- `TodayOpenContinuityMotionPolicy(reduceMotion:)` now owns the short 0.22-second
  state animation used by continuity nodes, returned-object placement, timeline
  identity updates, recovered progress, truth-state changes, and dock expansion.
- Reduce Motion makes `stateAnimation` `nil`; native navigation, focus, static
  seams, and visible state remain.
- Full Day's native `Scroll to Now` action uses the same policy, preserving the
  destination without spatial animation when Reduce Motion is enabled.
- Settlement emits one state-driven `.success` sensory feedback only when the
  phase changes from saving to settled.
- Crowned Edge Dock commands emit one selection feedback at their existing
  command boundary, and Peek keeps its pressed affordance without scale motion
  under Reduce Motion.
- Saturated crown scroll progress is clamped in the geometry transform, so the
  scroll observer stops emitting redundant values after reaching 0 or 1.
- Timeline objects are snapshotted once per body evaluation before row emission,
  preventing repeated selection/count work within the row loop.

## 3. Removed

- Ad hoc per-view ease durations for dock expansion, return scrolling, and the
  saving transition.
- Spatial animation under Reduce Motion.
- Redundant saturated crown-progress callbacks and repeated timeline-object
  evaluation during one body pass.

## 4. Added

- A focused RED/GREEN contract for the required motion policy, non-color static
  semantics, and distributed haptic ownership.
- A focused RED/GREEN performance guard for clamped crown observation and one
  timeline snapshot per body.
- Foundry-host variants `b02-motion-normal` and
  `b02-motion-reduce-motion` for continuous journey comparison.
- Two native Foundry-host recordings and matched saving-state frames.

## 5. Unresolved

- Simulator playback proves state and motion composition, not physical haptic
  quality. Selection, commitment, and settlement tactility remain direct-device
  obligations.
- Physical Reduce Motion focus perception, one-handed dock reach, edge-gesture
  competition, and low-brightness inspection remain incomplete.

## 6. Architecture-sensitive assumptions

- Motion policy is journey-local Foundry calibration, not final global token or
  production design-system authority.
- The fixture-host delay remains synthetic evaluation timing; it does not imply
  persistence or runtime latency.
- Haptic trigger ownership is intentionally distributed to avoid duplicates:
  `TodayFlagshipReviewView` retains the previously established selection trigger
  when the proposal review appears and light commitment impact when Record
  Progress begins; `TodayFlagshipNavigationChrome` owns dock-command selection;
  `TodayFlagshipCalibrationView` owns settlement success for
  saving-to-settled. Dismissal, history disclosure, and return emit no new
  haptic.
- The original Task 09 file envelope was extended only to
  `TodayOpenContinuityFullDayView.swift` and
  `TodayFlagshipNavigationChrome.swift` after focused review demonstrated that
  Full Day scrolling and functional dock chrome were named motion/haptic
  surfaces. No behavior, IA, or production boundary was broadened.
- No live runtime, app entry, legacy frontend, or production adapter changed.

## 7. Validation

### TDD

- RED motion contract: failed because `TodayOpenContinuityMotionPolicy` did not
  exist (`/tmp/b02-task09-red.log`).
- GREEN motion contract: passed
  `TodayFlagshipCalibrationFixtureTests/testB02ReduceMotionKeepsStaticStateMeaning`.
- RED performance contract: five expected source assertions failed before the
  bounded fixes (`/tmp/b02-task09-red-performance.log`).
- RED pressed-state contract: failed before Reduce Motion removed the Peek and
  primary-action scale response (`/tmp/b02-task09-red-pressed-scale.log`).
- RED reviewer-repair contract: failed before Full Day adopted the shared
  motion policy and the dock owned its command-selection feedback
  (`/tmp/b02-task09-red-reviewer-repairs.log`).
- GREEN motion, performance, pressed-state, and reviewer-repair contracts passed
  after the bounded fixes.

### Warm package-preview loop

Command:

```sh
node /Users/devan/.codex/plugins/cache/openai-curated-remote/build-ios-apps/0.1.2/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs \
  /Users/devan/Documents/GitHub/ambitions/.worktrees/today-open-continuity-field/Packages/AmbitionsPresentation/Package.swift \
  --package-target AmbitionsNativeVisualFoundry \
  --device EDE1E954-C663-47FB-855B-95F96AE2DBDD \
  --preview-filter 'B02 Grammar.*Dark'
```

The initial host became ready in 76 seconds. It stayed at PID `87821` for all
four source-changing runs.

| Run | Source-visible change | Save-to-native result | Success | Visual appeared | Host relaunched | Clean build |
| --- | --- | ---: | --- | --- | --- | --- |
| 1 | Heading `Open Continuity Field` to `Motion warm 1` | 16 s | yes | yes, `/tmp/b02-task09-warm1.png` | no | no |
| 2 | Heading to `Motion warm 2` | 13 s | yes | yes, `/tmp/b02-task09-warm2.png` | no | no |
| 3 | Heading to `Motion warm 3` | 13 s | yes | yes, `/tmp/b02-task09-warm3.png` | no | no |
| 4 | Restore intended `Open Continuity Field` | 17 s | yes | yes, `/tmp/b02-task09-warm4-final.png` | no | no |

All four results were real native PreviewHost frames. The final preview hash
matched the pre-mutation baseline:
`8e76cdb5bbf7cad7c18901f11e75a9afcc2d560609f784515515c9cb7ca5bab7`.
The warm loop remains usable and no injection dependency was added.

### Performance audit disposition

- Fixed: clamp crown progress inside `onScrollGeometryChange` before callback.
- Fixed: snapshot the selected timeline objects once per body evaluation.
- Deferred: lazy-row conversion; the largest synthetic stress fixture contains
  only 10 rows and exhibited no scroll symptom.
- ETTrace skipped: no animation hitch, scroll stall, or rendering symptom was
  observed in the package preview or fixture host.
- Memgraph skipped: the bounded value-snapshot journey exhibited no suspicious
  growth or retention symptom.

### Fresh results

- `swift test --package-path Packages/AmbitionsPresentation --filter TodayFlagshipCalibrationFixtureTests/testB02ReduceMotionKeepsStaticStateMeaning`: PASS, 1 test.
- `swift test --package-path Packages/AmbitionsPresentation`: PASS, 48 tests.
- `xcodebuild ... -scheme AmbitionsNativeFoundryHost ... build CODE_SIGNING_ALLOWED=NO`: PASS, `** BUILD SUCCEEDED **`.
- Strict SwiftLint across all Task 09 Swift paths: PASS, 0 violations.
- `git diff --check`: PASS.

## 8. Evidence

### Normal motion

- Screenshot: `screenshots/B02-M01-motion-normal.png`
- Screenshot SHA-256: `e6de8216487c5d689ab688147be531a49c1b6b63fea7d9d7a774825eafa85fd0`
- Recording: `recordings/B02-M01-motion-normal.mp4`
- Duration: 18.075 seconds
- Size: 4,519,396 bytes
- Recording SHA-256: `93a5e42965d74afbb0bc0474d8d0af834afac4083da2e937f0db58504a1cfb2a`
- Accessibility setting: Reduce Motion off; Simulator preference readback `0`

### Reduce Motion

- Screenshot: `screenshots/B02-M02-motion-reduce-motion.png`
- Screenshot SHA-256: `bbba488549594371a7ac9332ab485c784e5d4ef97f7163a93edc8efbc00b57f8`
- Recording: `recordings/B02-M02-motion-reduce-motion.mp4`
- Duration: 16.227 seconds
- Size: 4,057,643 bytes
- Recording SHA-256: `b2641b2cb731ef29c0015e41c720022f8e49a3c350449564e31652899b7d7c05`
- Accessibility setting: Reduce Motion on; Simulator preference readback `1`

For M02, the Simulator's `com.apple.Accessibility` domain was set with
`ReduceMotionEnabled = true`, the device was shut down and booted, and
`defaults read com.apple.Accessibility ReduceMotionEnabled` returned `1` before
capture. The fixture-host variant independently injected the matching
accessibility environment value. After capture, the same write, shutdown,
boot, and readback sequence restored `ReduceMotionEnabled = false`; the final
readback was `0`. M01 was captured with the preference at `0`.

Both saving-state frames preserve object identity, current truth, proposed
truth, active settlement seam, and reachable native safe-area actions. No text
is obscured.

## 9. Proof ceiling

This phase proves fixture-driven native Simulator rendering, package hot reload,
static semantic equivalence under a system-configured Simulator Reduce Motion
preference plus its matching fixture environment, and the presence of
state-bound haptic APIs. It does not prove physical haptic feel, direct-device
motion, runtime persistence, production integration, or visual acceptance.
`APPROVED FOR SWIFTUI` remains false.
