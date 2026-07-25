# B02 accessibility review

Status: `PROPOSED`

- Visual branch: `AVF-TODAY-S10-B02-R00`
- Fixture: `today-flagship/preparing-for-baby/still-counts/v1`
- Source revision at capture: uncommitted Task 10 changes on
  `f38e943b993166ab94ae5ebf71e4e75fbc0cbbd6`
- Host: `com.ambitions.ios.nativefoundry`
- Simulator: iOS 26.5 (23F77), Xcode 26.6
- Media in this record are evaluation references; `production_baseline = false`

## 1. Preserve exactly

- The fixture identities, semantic journey, truth-state distinctions, native
  `NavigationStack`, native full-screen review, native recovery sheet, explicit
  return, four-root ordering, dock-owned Search and Capture, and local fixture
  boundary remain unchanged.
- The same product meaning is available in standard size, Accessibility 5,
  Increased Contrast, Differentiate Without Color, Reduce Transparency, Arabic
  RTL, and long-LTR composition.
- Primary content remains matte and opaque. Liquid Glass remains functional
  shell chrome only, with an authored opaque dock branch.

## 2. Changed

- Accessibility 5 uses a natural vertical review/action composition. `Not now`
  precedes `Record progress`; both remain separately reachable, named, and at
  least 44 by 44 points without shrinking typography.
- The adaptive crown no longer receives a screenshot-tuned fixed height at
  accessibility pressure. It grows naturally while the ordinary crown retains
  its established compact scroll transformation.
- Review and History `DisclosureGroup` labels now have explicit 44-point
  interaction envelopes.
- Native scroll indicators are restored on every journey depth that has
  continuation. Root indicator margins keep the system indicator clear of the
  overlaid Dock Peek without custom scroll behavior.
- Current and proposed relief gain authored Increased Contrast outlines; the
  existing paired-node/dashed-seam Differentiate Without Color treatment keeps
  the distinction structural rather than hue-only.
- Functional action and dock commands expose localized
  `accessibilityInputLabels`, providing distinct Voice Control command names.
- Interruption, recovery, settlement, and truthful return post restrained
  platform accessibility announcements at their actual state boundaries.
- Accessibility focus metadata continues to follow the journey's semantic
  anchors for focused identity, review current truth, recovered progress,
  settled truth, returned settled object, Full Day Now, and Full Day action.

## 3. Removed

- Blanket-hidden scroll indicators from the root, focus, Full Day, review,
  settlement, interruption, and recovery depths.
- The 26-point disclosure-label interaction surface found by the RED UI test.
- English record-prefix leakage from the Arabic settlement disclosure.
- Reliance on color alone for high-contrast current/proposed comparison.

## 4. Added

- Exact UI regression `testB02AccessibilityAndAdaptivityMatrix`.
- Foundry host variants for root Accessibility 5, genuine Arabic RTL across
  root, Full Day, focused Step, review, saving, settlement, returned Today, and
  recovery; long LTR; and Reduce Transparency.
- Matching package previews for the same pressure states.
- Native evidence for Accessibility 5, `ar-SA`, long LTR, Increased Contrast,
  Differentiate Without Color, Reduce Transparency, compact iPhone, and Pro Max.

## 5. Unresolved

- Physical VoiceOver spoken order, rotor/custom-action discoverability, focus
  perception, Voice Control recognition, Switch Control cadence, Full Keyboard
  Access, Button Shapes comfort, Bold Text comfort, Smart Invert, grayscale,
  left- and right-hand dock reach, edge-gesture competition, haptics, OLED
  low-brightness behavior, and Dynamic Island/call-state pressure remain direct-
  device obligations.
- Simulator XCTest proves semantic order, labels, focus anchors, targets, and
  state transitions; it does not prove the physical spoken experience.
- Button Shapes and Bold Text retain native `Button` and semantic system-font
  behavior. This iOS 26.5 `simctl ui` exposes appearance, content size, and
  Increased Contrast, but not Button Shapes or Bold Text. No fixture-only
  imitation was added merely to manufacture proof.
- No editable input exists, so keyboard avoidance is not applicable.

## 6. Architecture-sensitive assumptions

- Fixture-local strings and snapshots remain non-authoritative adapters. The
  Arabic text is evaluation localization, not production localization authority.
- Accessibility announcements describe fixture-supported state transitions;
  they do not imply production persistence or runtime timing.
- `accessibilityInputLabels` improve command discovery without replacing visible
  localized labels or ordinary native controls.
- The opaque dock identifier is evidence instrumentation for the authored
  Reduce Transparency branch, not a new runtime API.
- The original Task 10 envelope was extended only to the existing legacy
  review/focused wrappers where the RED target audit and continuation audit
  demonstrated a real 26-point disclosure target and hidden native indicators.
  No IA, product decision, or runtime boundary changed.

## 7. Validation

### TDD

- RED: `testB02AccessibilityAndAdaptivityMatrix` failed because the native
  `Details` disclosure exposed a 26-point target.
- GREEN: the exact test passed 1 of 1 on VC14 iPhone 17 Pro, iOS 26.5. The
  final fresh rerun passed in 365.934 seconds (439.099 seconds including build
  and test orchestration). It verifies Accessibility 5 vertical/reachable
  actions and scrollable navigation commands, visible custom-button targets and
  unique names on the audited pressure surfaces, opaque dock fallback, Arabic
  semantic order and native Back across the complete fixture journey, recovery
  dismissal without mutation, long-LTR outcome reachability, no-color
  current/proposed structure, contrast-state presence, and native scroll-
  indicator separation from Dock Peek.

### Simulator setting proof

- Content size was set through `simctl ui` to
  `accessibility-extra-extra-extra-large`; readback matched before AX5 capture.
- Increased Contrast was set through `simctl ui`; readback returned `enabled`
  before capture.
- Both settings were restored after capture. Final readback is `large`,
  `disabled`, Dark appearance.
- Reduce Transparency uses the repository's established launch-environment
  convention plus the matching host fixture environment. The real rendered
  host exposed `tfcs-dock-shell-peek-opaque`; physical material appearance is
  still open.

### Fresh changed-scope results

- `swift test --package-path Packages/AmbitionsPresentation`: PASS, 49 tests.
- Foundry host Simulator build on VC14 iPhone 17 Pro: PASS,
  `** BUILD SUCCEEDED **`; fresh log:
  `/tmp/b02-task10-final-host-build-20260725.log`.
- Strict SwiftLint across all 16 changed Swift files: PASS, 0 violations;
  fresh log: `/tmp/b02-task10-final-swiftlint-scope-20260725.log`.
- `git diff --check`: PASS.
- Final Simulator settings readback: content size `large`, Increased Contrast
  `disabled`, appearance `dark`.

## 8. Evidence

All screenshots are real rendered Native Foundry host frames.

| Evidence | Device / mode | Dimensions | SHA-256 |
| --- | --- | --- | --- |
| `screenshots/task10-accessibility-adaptivity/B02-T10-accessibility5-review-standard-pro.png` | iPhone 17 Pro, Dark, Accessibility 5 | 1206x2622 | `90e1f1abb615d7ababf53761643afc11c932f959c69be30c1bc788d3af187ec8` |
| `screenshots/task10-accessibility-adaptivity/B02-T10-ar-SA-rtl-root.png` | iPhone 17 Pro, Dark, `ar-SA`, RTL | 1206x2622 | `b18d3fd27cd8af872b2985de88be1836cb4cb8d52f4d1d8a2d36112ab25a833e` |
| `screenshots/task10-accessibility-adaptivity/B02-T10-long-ltr-root.png` | iPhone 17 Pro, Dark, long LTR | 1206x2622 | `798fe1eec13a20f75cd1028a674b7cfeece53278bd2dcaf928fed7428d9399c7` |
| `screenshots/task10-accessibility-adaptivity/B02-T10-differentiate-without-color-review.png` | iPhone 17 Pro, Dark, no-color distinction | 1206x2622 | `e47431e2fa08832235a524a52b5e7aace313f72b02146c84acbcecb743cf44ad` |
| `screenshots/task10-accessibility-adaptivity/B02-T10-increased-contrast-review.png` | iPhone 17 Pro, Dark, system Increased Contrast | 1206x2622 | `f8c74786b8209e8efce3738f0c38fcd01b725a4459788f08900ffbdd8af5aa1d` |
| `screenshots/task10-accessibility-adaptivity/B02-T10-reduce-transparency-root.png` | iPhone 17 Pro, Dark, opaque dock | 1206x2622 | `da0fefbc8ad389642fbbf2f895055024fe077b46469c2961a5fe0c2b5d1291d8` |
| `screenshots/task10-accessibility-adaptivity/B02-T10-active-scroll-indicator-dock-clear.png` | iPhone 17 Pro, Dark, naturally scrolled root with Dock Peek visible | 1206x2622 | `3a2d199dbbbb9947bca65ff4021f46b2b1300f81205859a34516f27564ce0c02` |

The AX5 screenshot proves both safe-area actions are visible and unobscured.
The repaired Arabic frame proves real RTL script, a complete untruncated crown
context, localized date/time, mirrored geometry, and the deliberate mixed-
direction `Ambitions S10` identity. The scrolled frame proves the Dock Peek
remains visually stable during natural scrolling; the passing UI geometry
assertion proves the native indicator and Dock Peek occupy distinct trailing
regions because the indicator itself is transient and not visible in the still.
The no-color and contrast frames preserve the current/proposed difference
without hue alone.

## 9. Proof ceiling

This phase proves fixture-driven native Simulator rendering, machine-inspected
labels/order/targets/focus metadata, real system content-size and Increased
Contrast settings, and the authored opaque dock branch. It does not prove direct
device behavior, production localization, runtime integration, physical assistive
technology behavior, or visual acceptance. `APPROVED FOR SWIFTUI` remains false.
