+++
initiative = "component-sourcing-and-system"
document_type = "research"
status = "absorbed"
upstream = ""
+++

## Idea and user problem

Ambitions needs an explicit sourcing strategy for its recurring interface
building blocks: buttons and controls, cards and lists, forms and inputs,
presentations, transient feedback, navigation, loading states, charts, motion,
and effects. The strategy must make clear when Codex should use an Apple
component unchanged, style or compose an Apple component, build an
Ambitions-owned semantic component, or consider an external dependency.

Without that strategy, two failures are likely. Treating every screen as a
bespoke composition produces drift and duplicated behavior. Treating a generic
component library as the product language produces a polished-looking but
interchangeable app. Ambitions instead needs a coherent native substrate and a
small authored layer that carries its object meaning, continuity, atmosphere,
and interaction character.

## Current truth

The current project targets iOS 26 and Swift 6. Its declared application
dependencies are repository-local packages; `project.yml` contains no remote
Swift Package dependency. `AmbitionsDesignSystem` also declares no external
package dependency.

The repository already contains a broad but overlapping presentation
inventory: 59 Swift files under
`Packages/AmbitionsDesignSystem/Sources/Components/` and 100 Swift files under
`Native/Ambitions/DesignSystem/` at the inspected commit. Current application
source mixes Apple-native controls and presentations with Ambitions button
styles, panels, custom shell chrome, loading/degraded-state primitives, and
product-specific spatial views. Existence does not establish that every
component remains current visual authority or deserves reuse.

The governing canon already establishes important boundaries:

- SwiftUI and system-owned navigation, controls, materials, accessibility, and
  presentation are the default. Custom interaction or rendering must prove a
  product-law need and supply accessible, reduced-effects, failure-safe
  alternatives.
- Shared abstraction follows shared semantics, state, accessibility, and
  lifecycle rather than visual similarity alone.
- A card is earned containment, not the default grouping primitive. Integrated
  canvases, structured lists, contextual layers, strong axes, and object-led
  composition are preferred over generic card stacks.
- Ambitions identity comes from composition, hierarchy, atmosphere, semantic
  state, and continuity, not from reskinning every platform control.
- "Expensive" means exact anatomy, typography, material restraint, coherent
  motion, responsive states, and faultless continuity. Decorative novelty is
  not a substitute.
- Native SwiftUI previews and the running app, followed by physical iPhone
  observation, are the proving environments. A component catalog or screenshot
  is not runtime, accessibility, device, or release proof.

## Evidence

Apple's current frameworks cover most behavioral foundations needed by
Ambitions:

| Category | Apple-native foundation | Ambitions-specific opportunity | Observed gap or caution |
| --- | --- | --- | --- |
| Buttons and controls | `Button`, roles, `ButtonStyle`, `Toggle`, `Picker`, `Menu`, `ControlGroup`, `Slider`, `Stepper`, `Gauge`, and system control sizing | Semantic action tiers, state language, placement, and restrained surface-specific styling while retaining `Button` behavior | Replacing controls or gestures risks losing platform behavior, accessibility, and future adaptation |
| Cards and lists | `List`, `Section`, `DisclosureGroup`, `OutlineGroup`, `Grid`, lazy stacks, swipe actions, context menus, and refresh behavior | Object rows, relationship traces, receipts, timelines, and earned independent surfaces | Apple has no universal semantic "Card" that should become Ambitions' default; a stack of rounded rectangles is especially likely to look generic |
| Forms and inputs | `Form`, `TextField`, `SecureField`, `TextEditor`, `Picker`, `DatePicker`, `MultiDatePicker`, `PhotosPicker`, format styles, submit behavior, and focus APIs | Field grouping, validation, consequence preview, local-draft continuity, and Capture's freeform-to-structured progression | Custom-drawn fields and pickers would create unnecessary keyboard, focus, autofill, localization, and accessibility risk |
| Sheets and modals | `sheet`, `fullScreenCover`, `popover`, presentation detents, `alert`, and `confirmationDialog` | Custom content anatomy, review/commit states, receipts, and return-context handling inside the native presentation | Presentation height is not the semantic decision; consequential work must not be compressed into a convenient sheet when canon requires a focused destination or full-screen composer |
| Toasts and alerts | Native alerts and confirmation dialogs cover interruption and consequential confirmation | A small Ambitions-owned transient notice or attached status/receipt may cover nonblocking acknowledgement | SwiftUI does not expose a general-purpose in-app toast component. Auto-dismiss feedback is unsafe for durable success, error, privacy, or recovery claims and must never be the only evidence |
| Navigation and tab bars | `NavigationStack`, value-based destinations, `TabView`, toolbars, search roles, tab-bar minimization, and bottom accessories | Ambitions' four-root identity, contextual Search/Capture entry, continuity, and content-led chrome retreat | Custom replacement bars can become stale platform mimicry and weaken restoration, system gestures, search integration, and accessibility. Exact shell treatment remains a product decision, not a component shortcut |
| Loading and skeletons | `ProgressView`, refresh behavior, redaction with `.placeholder`, and ordinary placeholder composition | Honest local-runtime states, known-structure placeholders, stale/partial/source-specific recovery, and calm transition choreography | There is no reason for a universal shimmer. It can imply remote latency, add ornamental motion, and hide the more useful distinction between loading, empty, stale, degraded, and blocked |
| Charts | Swift Charts supplies marks, axes, scales, legends, interaction hooks, localization, and accessibility | Ambitions-authored chart grammar, point inspection, semantic annotations, relationship context, and compact-to-deep disclosure | A custom `Canvas` is appropriate only when the object is not actually a statistical chart or native marks cannot express the product meaning. Graph-like decoration is a kill signal |
| Animations and effects | SwiftUI animation, transitions, `PhaseAnimator`, `KeyframeAnimator`, symbol effects, sensory feedback, materials, and iOS 26 Liquid Glass APIs | Typed motion roles for continuity, causality, commit, recovery, focus, and object ownership; selective atmospheric rendering | Motion completion cannot create truth. Glass belongs in functional chrome or transient focus, with Reduce Motion and opaque Reduce Transparency equivalents |

Apple explicitly supports custom `ButtonStyle` implementations while retaining
standard interaction behavior, custom chart marks and axes within Swift Charts,
and Liquid Glass on custom views. This means "native" and "authored" are not
opposites: Ambitions can own composition and appearance while keeping the
platform's semantic controls, presentation, navigation, and accessibility
machinery.

External libraries exist for broad SwiftUI extensions, popups/toasts,
skeletons, and exported or state-machine animation runtimes. They can reduce
initial coding effort, but they also import another product's API assumptions,
animation grammar, accessibility behavior, OS-version lag, dependency surface,
and visual defaults. Because Codex will implement and maintain this system
directly, saving a small amount of wrapper code is not by itself a sufficient
reason to accept those costs.

External evidence consulted for this Research includes Apple's current
documentation for [buttons and custom styles](https://developer.apple.com/documentation/swiftui/buttonstyle),
[lists](https://developer.apple.com/documentation/swiftui/displaying-data-in-lists),
[forms](https://developer.apple.com/documentation/swiftui/form),
[modal presentation](https://developer.apple.com/documentation/swiftui/modal-presentations),
[navigation](https://developer.apple.com/documentation/swiftui/navigationstack),
[tab accessories](https://developer.apple.com/documentation/swiftui/view/tabviewbottomaccessory%28content%3A%29),
[progress](https://developer.apple.com/documentation/swiftui/progressview),
[placeholder redaction](https://developer.apple.com/documentation/swiftui/redactionreasons/placeholder),
[Swift Charts](https://developer.apple.com/documentation/charts),
[animation](https://developer.apple.com/documentation/swiftui/animations), and
[custom Liquid Glass](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views).
Representative external options were inspected only to understand the
alternative: [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX),
[PopupView](https://github.com/exyte/PopupView),
[SkeletonUI](https://github.com/CSolanaM/SkeletonUI),
[Lottie](https://github.com/airbnb/lottie-ios), and
[Rive](https://github.com/rive-app/rive-ios).

## Alternatives

### 1. Apple-only, with no Ambitions component layer

Use raw SwiftUI controls and containers directly everywhere. This maximizes
platform adaptation and minimizes dependency risk, but it cannot by itself
produce coherent product-specific object anatomy, semantic states, atmosphere,
or cross-surface continuity. The result could be credible but generic.

### 2. General-purpose third-party component library

Adopt a library for controls, cards, navigation, popups, loading, charts, or
motion as a shared foundation. This can accelerate common prototypes, but it
would make Ambitions inherit another library's abstractions and style pressure.
It also conflicts with the repository's current local dependency posture and
raises accessibility, OS-adoption, maintenance, privacy-manifest, supply-chain,
and removal costs. A general UI library is a poor strategic fit.

### 3. Fully bespoke Ambitions controls and navigation

Custom-draw and custom-route most interface elements. This permits maximum
visual novelty, but novelty would be purchased by reimplementing mature Apple
behavior: focus, keyboard, Dynamic Type, VoiceOver, gestures, restoration,
presentation adaptation, and new OS conventions. It is the highest-risk route
and would likely feel less expensive in the hand despite looking distinctive in
static frames.

### 4. Native substrate plus an Ambitions semantic composition layer

Keep Apple controls, containers, navigation, presentation, charts, and motion
primitives as the behavioral substrate. Add Ambitions-owned tokens, styles,
semantic wrappers, object views, and spatial compositions where product meaning
requires them. Admit a narrow external dependency only after a documented gap
analysis and exit plan. This best matches current canon and balances native
credibility with authored identity.

## Unknowns and risks

- The current component inventory has not yet been classified as active,
  candidate, legacy/reference-only, duplicate, or removable. File count is not
  maturity evidence.
- Current source has multiple overlapping button, panel, navigation, and object
  primitives. The owning implementation boundary and migration direction need
  resolution before any API is stabilized.
- The exact shell, tab-bar, Search/Capture access, and bottom-accessory strategy
  is a cross-surface product decision. iOS 26 provides stronger native options,
  but their fit must be rendered and compared without bypassing current owner
  visual sequencing.
- Toast semantics need a strict event taxonomy. A transient notice may be valid
  for reversible, already-visible acknowledgement, but not for durable commit,
  failure, recovery, destructive consequence, or accessibility-critical state.
- Chart needs must be derived from actual product questions. Choosing chart
  types from visual appeal risks turning Goals, Time, or You into a dashboard.
- Custom effects can regress battery, scrolling, OLED behavior, contrast,
  Reduce Motion, or Reduce Transparency. Static screenshots cannot resolve
  those risks.
- The minimum supported OS is currently iOS 26, but deployment policy can
  change. Any reliance on new platform behavior needs an explicit availability
  and fallback decision in later phases.
- External packages can change ownership, licensing, maintenance level, binary
  distribution, privacy declarations, or security posture. A library decision
  must be based on current source and exact version rather than reputation.

## Frontend impact investigation

- Potential frontend impact: certain
- Existing surfaces investigated: Today, Goals, Time, You, Capture, Search,
  contextual Trust, onboarding/setup, current sheets and overlays, app shell,
  `Packages/AmbitionsDesignSystem`, `Native/Ambitions/DesignSystem`, the SwiftUI
  and design-system standard, Owner Taste, Visual System R1, and current project
  dependency declarations.
- Evidence and unknowns: All listed component categories affect user-visible
  anatomy, interaction, motion, and accessibility across multiple surfaces.
  Existing source proves there is substantial material to audit, but this
  Research does not select final APIs, approve a visual family, authorize a
  production migration, or prove any current component on device.

## Recommended direction

Proceed with Alternative 4: an Apple-native behavioral substrate plus a narrow,
Ambitions-owned semantic composition layer.

Use the following sourcing order as the candidate policy for Scope to decide:

1. Use the Apple component when it owns the interaction role.
2. Customize it through supported styles, labels, content, tokens, and
   composition while preserving native behavior.
3. Build an Ambitions semantic component only when a recurring product object,
   state machine, accessibility contract, or continuity behavior justifies it.
4. Use custom rendering only when the product meaning cannot be expressed by
   native layout or Swift Charts, and require a native/accessibility fallback.
5. Consider an external runtime dependency only when the gap is material,
   repeated, independently testable, and expensive to own; require license,
   privacy, security, accessibility, performance, OS-support, maintenance, and
   removal review before adoption.

The likely category posture is:

- **Native-first:** controls, forms, text input, navigation, tab bars, sheets,
  alerts, confirmation dialogs, progress indicators, menus, pickers, focus,
  gestures, haptics, and the chart engine.
- **Native behavior with Ambitions-authored presentation:** action hierarchy,
  rows, list sections, sheet content, transient nonblocking notices, loading and
  degraded-state composition, chart grammar and inspection, motion tokens, and
  selective functional glass.
- **Ambitions-owned product components:** Reality Meridian and temporal axes,
  Goal paths and relationship views, Life Area/shape views, Capture's
  freeform-to-structured progression, contextual Trust and receipts, recovery
  bands, proof traces, and other components whose meaning is inseparable from
  Ambitions' canonical objects.
- **Not a baseline dependency:** general UI kits, custom navigation/tab-bar
  frameworks, toast/popup kits, skeleton/shimmer kits, third-party charting, and
  Lottie/Rive-style animation runtimes. A later exception remains possible only
  after the dependency gate above.

This Research is approved as an input and absorbed into
`docs/product-development/frontend-completion-program/`. Its sourcing order,
category posture, external-dependency gate, and proof boundary are now governed
only by that unified Scope, Design, implementation plan, tasks, verification,
and the sole operational ledger. This directory creates no second Scope/Design
sequence, component-system program, approval path, or migration authority.

No existing visual component is stabilized merely because it is already
shared, and no production rewrite begins from this Research alone.
