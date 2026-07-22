<!-- markdownlint-disable MD013 MD060 -->

# RP-08 — Accessibility and Platform Adaptation

## Executive verdict

Ambitions has a strong **normative** accessibility contract and substantial source-level semantic scaffolding: semantic SwiftUI fonts, accessible labels/values/hints on key shell controls, minimum-target and reduced-effects policies, privacy-aware projections, a custom RTL-aware back gesture, and explicit accessibility proof ceilings. That is not the same as proven accessible behavior. The repository itself records manual VoiceOver, Dynamic Type screenshots, reduced-motion walkthroughs, measured contrast, motor review, and physical-device proof as unavailable, and the audit's targeted simulator test batch executed zero tests because the simulator failed to boot. Overall capability is `PARTIALLY_SUPPORTED`, with direct proof `UNKNOWN` or absent where stated.

Platform support is deliberately narrow: iOS 26, iPhone device family only, portrait only, no Mac Catalyst, and no multiple scenes. Widget, Live Activity, notification, App Intent, Siri/Shortcuts, and share-extension source exists, but repository verification records explicitly cap those at not platform-ready until device validation. Spotlight is canonical/planned but no Core Spotlight implementation was found. Localization resources are absent and user-facing strings are predominantly hard-coded, making localization and long-text/RTL readiness a material unresolved area.

For `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`, and `AVF-COHERENCE-S07-R00`, the semantic-continuity principle survives; claims of complete adaptive equivalence do not.

## Scope and authority

This packet audits accessibility, localization, input adaptation, shell accessibility, and current Apple platform targets at repository commit `29872755f705f6bd8e276aeac86dcf376ac5f0d8` on `main`.

Authority order: current source and manifests; current canon; tests and proof-boundary records; provisional visual records. The visual inputs are protected intent but do not prove runtime behavior. Source presence and unit-test definitions are not treated as direct accessibility proof, consistent with `STANDARD-ACCEPTANCE-ACCESSIBILITY-001`.

## Accessibility capability matrix

| Capability | Status | Current evidence | Proof ceiling / disposition |
|---|---|---|---|
| Semantic fonts and Dynamic Type environment | `PARTIALLY_SUPPORTED` | SwiftUI semantic fonts; `DynamicTypePolicy`; shell adapts on `isAccessibilitySize` | Largest-size rendered layouts unverified; `RECONSTRUCTION_PLAN_ACTION_REQUIRED` |
| VoiceOver labels/values/hints | `PARTIALLY_SUPPORTED` | Dock, header, Capture, root summaries and many controls have modifiers/policies | Complete traversal, actions, announcements, rotor grouping, and sensitive-content reading unverified |
| Deterministic focus return | `PLANNED_NOT_IMPLEMENTED` | Logical `StageFocusCoordinator` / `VoiceOverFocusPolicy` records | No `@AccessibilityFocusState` or `.accessibilityFocused` binding found; `RUNTIME_CAPABILITY_REQUIRED` |
| Reduce Motion | `PARTIALLY_SUPPORTED` | `ReduceMotionPolicy` and adaptive-review contracts | Direct walkthrough explicitly unproven |
| Reduce Transparency | `PARTIALLY_SUPPORTED` | `ReduceTransparencyPolicy` and opaque-fallback contracts | Rendered fallback unproven |
| Increased Contrast | `PARTIALLY_SUPPORTED` | `ContrastPolicy` and review contracts | Measured review explicitly unproven |
| Differentiate Without Color | `PARTIALLY_SUPPORTED` | Canon and non-color policy booleans/contracts | Complete state coverage unproven |
| Bold Text | `UNKNOWN` | System fonts may inherit behavior | No direct audit/test found |
| Button Shapes | `UNKNOWN` | Many controls are native `Button` | No direct test/proof found |
| Voice Control | `PARTIALLY_SUPPORTED` | Labeled native buttons provide a semantic substrate | No direct Voice Control run |
| Switch Control | `PARTIALLY_SUPPORTED` | Reachable `Button` controls and minimum-target policies | No direct Switch Control run |
| Full Keyboard Access | `PARTIALLY_SUPPORTED` | One Cmd-K Capture shortcut; indirect-input manifest support | Root 1–4 policy is not wired; focus traversal unproven |
| Hardware keyboard | `PARTIALLY_SUPPORTED` | Cmd-K Capture and policy types | No complete command/focus matrix |
| Pointer/hover | `ABSENT` | No `.hoverEffect`/`onHover` source found; iPhone-only target | No current product requirement established |
| Reach/one-handed use | `PARTIALLY_SUPPORTED` | Current bottom dock; target sizes | Selected edge dock handedness/equivalent posture absent |
| Sensitive accessibility output | `PARTIALLY_SUPPORTED` | Privacy-redacted goal/widget/live-activity labels exist | Lock-screen and VoiceOver privacy behavior require device proof |

Evidence: E-RP08-001 through E-RP08-008.

## Dynamic Type risk register

| Risk | Evidence | Severity | Finding |
|---|---|---|---|
| Binary adaptation instead of complete size-specific design | `DynamicTypePolicy.layoutMode` and shell use `size.isAccessibilitySize` | High | `PARTIALLY_SUPPORTED`; source adapts but does not prove every supported size |
| Header title compression | `AppShellHeaderRail` uses one-line limits/minimum scaling and changes controls at accessibility sizes | High | Meaning may compress or move; rendered proof absent |
| Fixed-height/viewport clipping | `AppShellScaffold` computes viewport height and clips content | High | Largest-size reachability requires direct proof |
| Bottom dock crowding | Dock expands height but remains four icon controls | Medium | Current labels remain assistive-only; direct a11y-size traversal/render proof absent |
| Long localized text | No localization catalogs; English hard-coded title/action strings | High | Long-text readiness cannot be established |
| Widget/Live Activity truncation | Live Activity titles/details use line limits | Medium | Glanceable target is intentional, but alternate complete semantics must be device-verified |

Sources: E-RP08-002, E-RP08-009, E-RP08-010.

## VoiceOver risk register

| Risk | Repository state | Status | Required action |
|---|---|---|---|
| Root order title → context → object → action → objects → dock | Required by canon; modifiers exist on current dock/header | `UNKNOWN` as runtime behavior | Direct scripted VoiceOver traversal |
| Overlay focus entry and dismissal return | Logical policy says restore; no applied focus binding found | `PLANNED_NOT_IMPLEMENTED` | Add runtime focus owner after architecture decision |
| Dynamic announcements after mutation/recovery | Some accessibility summaries exist; no comprehensive announcement owner proven | `PARTIALLY_SUPPORTED` | Runtime and device verification |
| Custom controls and grouped semantics | Current dock/root header expose labels and group identifiers | `PARTIALLY_SUPPORTED` | Verify no duplicate or over-grouped speech |
| Sensitive content | Privacy-safe summaries exist in selected projections | `PARTIALLY_SUPPORTED` | Locked-device and VoiceOver inspection |
| Spatial timelines/path diagrams | Canon requires nonvisual chronological/path equivalents | `PLANNED_NOT_IMPLEMENTED` as a complete cross-surface claim | Object-by-object semantic inspection gate |
| Right-edge dock posture equivalence | No Hidden/Peek/Expanded accessible state model exists | `ABSENT` | UX Blueprint and runtime decision before implementation |

Sources: E-RP08-001, E-RP08-003, E-RP08-004, E-RP08-011.

## Keyboard and focus matrix

| Context/action | Current support | Status | Evidence |
|---|---|---|---|
| Open Capture | Cmd-K on header action | `SUPPORTED` as source | E-RP08-005 |
| Switch Today/Goals/Time/You | `KeyboardPolicy` describes keys 1–4 | `PLANNED_NOT_IMPLEMENTED`; no wiring found | E-RP08-005 |
| Search invocation | App Intent/deep route exists; no shell keyboard shortcut found | `PARTIALLY_SUPPORTED` external, `ABSENT` local shortcut | E-RP08-005, E-RP08-015 |
| Back/dismiss | Visible buttons exist | `PARTIALLY_SUPPORTED`; keyboard focus order unverified | E-RP08-004 |
| Focus after root switch | Logical focus plan | `PLANNED_NOT_IMPLEMENTED` runtime binding | E-RP08-003 |
| Focus after overlay dismissal | Logical policy | `PLANNED_NOT_IMPLEMENTED` runtime binding | E-RP08-003 |
| Full Keyboard Access traversal | Native controls provide substrate | `UNKNOWN` direct behavior | No direct test artifact |
| Pointer/hover | No explicit support found | `ABSENT` | Targeted source search |

The manifest's `UIApplicationSupportsIndirectInputEvents=true` permits indirect input but does not prove Full Keyboard Access or pointer behavior. Evidence: E-RP08-012.

## RTL and localization readiness

| Area | Status | Evidence-based finding |
|---|---|---|
| Localization resources | `ABSENT` | No `.xcstrings`, `.strings`, or `.stringsdict` files found. |
| Localized user-facing strings | `ABSENT` as a systematic infrastructure | Root, header, overlay, widget, and Live Activity labels are hard-coded English; App Intents use `LocalizedStringResource` titles only in their own framework contracts. |
| RTL back behavior | `PARTIALLY_SUPPORTED` | Custom back swipe explicitly mirrors using `layoutDirection`. |
| RTL shell/dock order | `UNKNOWN` | HStack may follow environment direction, but no explicit semantic-order contract or RTL test was found. |
| Directional symbols | `PARTIALLY_SUPPORTED` | SF Symbols are used widely; custom directional meaning was not comprehensively audited. |
| Dates/times/units | `PARTIALLY_SUPPORTED` | User UI uses Swift formatted dates in places and current calendar/time zone in domain code; complete locale/calendar/unit coverage is not proven. |
| Long-text readiness | `PARTIALLY_SUPPORTED` | Some fixed-size/scroll/adaptive layouts exist, but hard-coded English and line limits prevent a complete claim. |
| Localization tests | `ABSENT` | No localization resource or dedicated localization-test inventory found. |

Evidence: E-RP08-006, E-RP08-009.

## Sensitive-content accessibility findings

- Goal-path projections provide privacy-sensitive variants that replace names and proof details with role-level summaries. `PARTIALLY_SUPPORTED` source contract. Evidence: E-RP08-007.
- External widget and Live Activity contracts require privacy-bounded snapshots and label current/stale/unavailable state, but the repository explicitly states that on-device rendering and lifecycle behavior remain unverified. `PARTIALLY_SUPPORTED`. Evidence: E-RP08-014.
- No broad `.privacySensitive()` SwiftUI modifier usage was found in app/widget source. This does not prove exposure, but means OS-managed sensitive rendering cannot be claimed from that mechanism. `UNKNOWN` overall. Evidence: E-RP08-007.
- VoiceOver behavior on a locked device, notification previews, Dynamic Island, widgets, and sensitive recovery states remains `UNKNOWN` until direct device verification.

## Platform target matrix

| Platform/surface | Status | Evidence and proof ceiling |
|---|---|---|
| iPhone | `SUPPORTED` as configured target | iOS app target, device family `1`, deployment 26.0; no current build/device result in this audit |
| Larger iPhones | `PARTIALLY_SUPPORTED` | Same iPhone family; no current multi-device render matrix |
| iPad | `CONTRADICTED` | `TARGETED_DEVICE_FAMILY: "1"` only |
| Mac Catalyst | `CONTRADICTED` | `SUPPORTS_MACCATALYST: NO` |
| Native macOS | `ABSENT` | No macOS application target |
| visionOS | `ABSENT` | No visionOS target/source contract found |
| Portrait orientation | `SUPPORTED` as manifest | Only portrait is declared |
| Landscape | `CONTRADICTED` | Not declared in supported orientations |
| Multiple windows | `CONTRADICTED` | Manifest explicitly disables multiple scenes |
| External display | `ABSENT` | No target/scene support found |
| Widgets | `PARTIALLY_SUPPORTED` | iPhone widget target and source bundle exist; repository says device rendering pending |
| Live Activities / Dynamic Island | `PARTIALLY_SUPPORTED` | ActivityKit widget/service and plist entitlement key exist; source explicitly marks platform readiness false |
| Notifications | `PARTIALLY_SUPPORTED` | Notification runtime/contracts exist; device authorization and delivery pending |
| App Intents | `PARTIALLY_SUPPORTED` | Intent source and metadata contracts exist; device invocation pending |
| Siri / Shortcuts | `PARTIALLY_SUPPORTED` | `AmbitionsShortcutsProvider` publishes shortcuts; discovery/invocation pending |
| Spotlight | `PLANNED_NOT_IMPLEMENTED` | Canon requires a projection, but targeted search found no `CoreSpotlight`/`CSSearchable` source |
| Scene restoration | `ABSENT` | No scene restoration API usage found; multiple scenes disabled |

Evidence: E-RP08-012 through E-RP08-016.

## Widgets, notifications, App Intents, and Spotlight inventory

| Surface | Current source owner | Currentness | Capability |
|---|---|---|---|
| Widget | `AmbitionsWidgetExtension`, `NextStepWidget`, shared external snapshot projector | Current production source | `PARTIALLY_SUPPORTED` |
| Live Activity | `NextStepLiveActivityWidget`, `NextStepLiveActivityService` | Current production source | `PARTIALLY_SUPPORTED`; allowlist says `isPlatformReady: false` |
| Notification | `NotificationRuntime`, `LocalNotificationFoundation` | Current production source | `PARTIALLY_SUPPORTED` |
| App Intents | `App/Intents/*`, `AmbitionsShortcutsProvider` | Current production source | `PARTIALLY_SUPPORTED` |
| Siri/Shortcuts | `AmbitionsShortcutsProvider` | Current production source | `PARTIALLY_SUPPORTED` |
| Spotlight | Canon only | Normative planned contract | `PLANNED_NOT_IMPLEMENTED` |
| Share extension | `AmbitionsShareExtension` target | Current production source | `PARTIALLY_SUPPORTED`; not a selected visual assumption |

The repository's `ExternalSurfaceVerificationChecklist` is authoritative for the proof ceiling: simulator builds/metadata and unit tests do not establish notification delivery, widget gallery behavior, ActivityKit lifecycle, or Shortcuts/Siri invocation. Evidence: E-RP08-014, E-RP08-015.

## Existing test and proof inventory

| Evidence lane | Representative source/test | What it establishes | What it does not establish |
|---|---|---|---|
| Design-system policy | `DesignSystemAccessibilityCanonicalOwnershipTests` | Policy ownership and value contracts | Rendered or assistive behavior |
| Adaptive-interface review | `AccessibilityAdaptiveInterfaceDesignSystemTests` | Required review lanes/axes and manual-proof markers | Runtime changes or release accessibility |
| Nutrition/checklist | `AccessibilityNutritionChecklistTests` | Inventory completeness and proof-boundary metadata | Direct VoiceOver/device proof |
| Shell/navigation unit tests | `AppShellNavigationTests`, `AppShellChromeTests`, `StageBackGestureTests`, `StageSafeAreaPolicyTests` | Reducer/policy/source assertions | Actual traversal, focus, gestures, layouts |
| UI test definitions | `BootstrapShellUITests` | Intended simulator scenarios | No result in this audit; zero tests executed |
| Device checklist | `RealDeviceRenderChecklist` | Required gates for Dynamic Type, effects, contrast, VoiceOver | It is a checklist, not completed evidence |
| Accessibility certification record | `AFEP021AccessibilityCertificationProgram` | Explicit claim ceiling | Records screenshots, VoiceOver, Dynamic Type, contrast, motor, physical-device, certification, and release claims as false |

Evidence: E-RP08-008, E-RP08-017.

## Shell accessibility analysis

| Selected shell characteristic | Status | Finding |
|---|---|---|
| Four roots have semantic labels and selected state | `SUPPORTED` as source | Current bottom dock uses native `Button` and explicit accessibility values/hints. |
| Root/global grouping is deterministic | `PARTIALLY_SUPPORTED` | Header and dock groups exist; complete root reading order unverified. |
| Crown preserves identity at large text | `PARTIALLY_SUPPORTED` | Header adapts, but compact symbol/title constraints make direct rendered proof necessary. |
| Search/Capture access is equivalent | `PARTIALLY_SUPPORTED` | Buttons, external routes, and Cmd-K Capture exist; Search shortcut and edge-dock access do not. |
| Keyboard-present behavior | `UNKNOWN` current shell; `ABSENT` selected posture model | No direct test or Hidden/Peek/Expanded keyboard transition. |
| RTL mirroring | `PARTIALLY_SUPPORTED` | Back gesture mirrors; proposed right-edge dock equivalent absent. |
| Minimum interaction envelope | `SUPPORTED` as policy/source | 44/48-point policies and 44/50-point root controls; motor review unproven. |
| Labeled/opaque/lower-reach alternate dock | `ABSENT` | Required by provisional A11Y intent but not represented in source. |

Disposition: the semantic-equivalence requirement is `VISUAL_DIRECTION_SURVIVES`; the selected edge-dock adaptive behaviors require `UX_BLUEPRINT_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED`, and `RECONSTRUCTION_PLAN_ACTION_REQUIRED`.

## Visual-assumption comparison

| Provisional assumption | Status | Disposition | Direction IDs |
|---|---|---|---|
| Accessibility is semantic equivalence, not cosmetic reduction | `SUPPORTED` normatively | `VISUAL_DIRECTION_SURVIVES` | `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00` |
| Native controls and platform adaptation are default substrate | `PARTIALLY_SUPPORTED` | `TARGETED_VISUAL_REFINEMENT_REQUIRED` | `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00` |
| System text/Dynamic Type remain legible at all sizes | `PARTIALLY_SUPPORTED` | `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00` |
| VoiceOver preserves object identity, state, actions, consequence, and focus | `PARTIALLY_SUPPORTED`; focus application `PLANNED_NOT_IMPLEMENTED` | `RUNTIME_CAPABILITY_REQUIRED` | `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00` |
| Reduce Motion/Transparency/Contrast/non-color equivalents exist everywhere | `PARTIALLY_SUPPORTED` | `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00` |
| Edge dock has labeled/opaque/lower-reach/RTL alternatives | `ABSENT` | `UX_BLUEPRINT_DECISION_REQUIRED`, `RUNTIME_CAPABILITY_REQUIRED` | `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00` |
| iPad/Mac/visionOS adaptations are implied by native continuum | iPad/Mac `CONTRADICTED`; visionOS `ABSENT` | `UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE` from current claims | `AVF-COHERENCE-S07-R00` |
| Widgets/Live Activities/notifications/intents are production-ready | `PARTIALLY_SUPPORTED` source, not platform-ready | `IMPLEMENTATION_DETAIL_DEFERRED` pending proof | `AVF-COHERENCE-S07-R00` |
| Spotlight participates in the continuum | `PLANNED_NOT_IMPLEMENTED` | `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | `AVF-COHERENCE-S07-R00` |
| Localization/RTL continuity is established | `ABSENT` and `PARTIALLY_SUPPORTED` by subclaim | `RECONSTRUCTION_PLAN_ACTION_REQUIRED` | `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00` |

## Contradictions and unsupported assumptions

1. The selected edge-dock accessibility alternatives are required by visual intent, but no edge-dock state or equivalent-posture model exists. `ABSENT`.
2. The visual/native-continuum language can imply broad Apple-platform adaptation, while current target configuration deliberately excludes iPad, Mac Catalyst, landscape, and multiple windows. `CONTRADICTED` for those platforms.
3. Accessibility policy/source breadth exceeds current proof: the repository explicitly blocks manual/device and release claims. Any “complete accessibility” statement is `CONTRADICTED` by current proof metadata.
4. The canon requires deterministic focus restoration, but source contains only logical focus plans and no runtime focus binding. `PLANNED_NOT_IMPLEMENTED`.
5. Complete localization and RTL readiness cannot be claimed without localization resources, localized strings, and tests. Localization is `ABSENT`; RTL is `PARTIALLY_SUPPORTED`.
6. Widget, Live Activity, notification, App Intent, and Shortcuts presence must not be described as platform-ready; their own checklists say direct device proof remains required.

These assumptions must be removed from present-tense capability claims (`UNSUPPORTED_VISUAL_BEHAVIOR_REMOVE`) or kept explicitly provisional. The protected visual intent is not revised.

## Required decisions — not decided here

| Authority | Decision required |
|---|---|
| Devan | Whether the product remains strictly iPhone/portrait or future platform adaptation becomes product scope; whether edge-dock alternate postures remain protected requirements. |
| Architecture | Actual focus owner and application mechanism; localization infrastructure; shell input/focus ownership; external-surface privacy owner. |
| UX Blueprint | VoiceOver reading groups; dock posture equivalents; keyboard focus order; RTL order; long-text and sensitive-content behavior. |
| Runtime | Deterministic focus/announcement transitions, query/composer focus restoration, privacy-aware external-surface state, safe failure announcements. |
| Reconstruction planning | Direct-proof gates, localization/RTL test infrastructure, removal of unwired policy-only affordances after ownership decisions. |
| Accessibility/platform planning | Device/OS matrix; VoiceOver, Switch Control, Voice Control, FKA, Dynamic Type, reduced effects, contrast, motor, locked-device, widget, ActivityKit, Siri, and notification scripts. |
| Figma later | Depict only reconciled platform states and alternate postures; do not imply unselected platforms. |
| SwiftUI implementation later | Bind runtime focus and adaptations only after authority decisions and tests are specified. |

## Reconstruction and implementation gates

- Establish localization resources and replace hard-coded user-facing strings through an owned localization system before claiming localization readiness.
- Bind logical focus plans to one runtime focus owner, including overlays, mutation outcomes, errors, and return context.
- Add direct assistive-technology scripts and exact evidence capture for VoiceOver, Voice Control, Switch Control, and Full Keyboard Access.
- Add a supported Dynamic Type/device matrix, RTL and long-string fixtures, reduced-effects/contrast checks, and motor target review.
- Treat every external surface as `PARTIALLY_SUPPORTED` until its repository-listed device verification is completed.
- Keep Spotlight `PLANNED_NOT_IMPLEMENTED` until a source implementation and privacy-bounded index contract exist.
- Do not broaden iPad/Mac/visionOS/multi-window scope through visual implication; that requires an explicit product/platform decision.
- Do not begin the edge-dock implementation until RP-01 architecture and UX contradictions are reconciled.

## Evidence appendix

### E-RP08-001 — Normative accessibility contract

- **Claim:** Canon requires semantic equivalence, deterministic focus, all-size Dynamic Type, reduced-effects alternatives, input equivalence, and direct verification.
- **Capability status:** `SUPPORTED` as normative contract; implementation remains partial.
- **Source:** `docs/canon/standards/accessibility.md:28-160`
- **Section:** `A11Y-002` through `STANDARD-ACCEPTANCE-ACCESSIBILITY-001`
- **Authority/currentness:** Current normative canon.
- **Verification:** `python3 scripts/ambitions-canon.py check`
- **Result:** Canon validation passed.
- **Confidence:** High.
- **Remaining uncertainty:** Requirements do not prove runtime conformance.
- **Affected directions:** `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-002 — Dynamic Type policy

- **Claim:** Source declares semantic adaptation through accessibility5 and 44/48-point targets.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/Ambitions/DesignSystem/Accessibility/DynamicTypePolicy.swift:3-31`
- **Symbol:** `DynamicTypePolicy`
- **Authority/currentness:** Current production design-system source.
- **Verification/result:** Source inspection found single-column/stacked policies keyed by `isAccessibilitySize`.
- **Confidence:** High.
- **Remaining uncertainty:** Policy use and rendered behavior are not comprehensively proven.
- **Affected directions:** `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-003 — Focus policy without focus binding

- **Claim:** Logical VoiceOver focus targets exist, but applied focus state was not found.
- **Capability status:** `PLANNED_NOT_IMPLEMENTED`
- **Source:** `Native/Ambitions/DesignSystem/Accessibility/VoiceOverFocusPolicy.swift:3-33`; `Native/Ambitions/Stage/StageFocusCoordinator.swift:3-81`
- **Symbol:** `VoiceOverFocusPolicy`, `StageFocusCoordinator`
- **Authority/currentness:** Current policy/model source.
- **Verification:** `rg -n 'AccessibilityFocusState|accessibilityFocused' Native/Ambitions`
- **Result:** No hits.
- **Confidence:** High.
- **Remaining uncertainty:** No UIKit focus owner was found in the searched app source.
- **Affected directions:** `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-004 — Current shell semantics

- **Claim:** Root controls and custom shell chrome expose significant SwiftUI accessibility metadata.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/Ambitions/Stage/Chrome/StageDockRail.swift:4-66`; `Native/Ambitions/Stage/Chrome/AppShellHeaderRail.swift:16-220`; `Native/Ambitions/App/AppShellView.swift:49-177`
- **Symbol:** `StageDockRail`, `AppShellHeaderRail`, `AppShellScaffold`
- **Authority/currentness:** Current production source.
- **Verification/result:** Labels, values, hints, selected traits, custom Back button, and hidden gesture layer exist.
- **Confidence:** High.
- **Remaining uncertainty:** Traversal order and focus behavior require direct VoiceOver/FKA proof.
- **Affected directions:** `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`.

### E-RP08-005 — Keyboard support

- **Claim:** Cmd-K Capture is wired; root keys 1–4 are only a policy record.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift:244-257`; `Native/Ambitions/Interaction/KeyboardPolicy.swift:3-21`; `Native/Ambitions/Stage/Chrome/AppShellHeaderRail.swift:173-174`
- **Symbol:** `shellUtilityButtons`, `KeyboardPolicy.primaryShortcut`
- **Authority/currentness:** Current production source.
- **Verification:** Targeted `rg` for `keyboardShortcut` and `KeyboardPolicy` references.
- **Result:** Header applies Cmd-K to Capture; no root-shortcut application found.
- **Confidence:** High.
- **Remaining uncertainty:** Menu collapse and hardware-keyboard behavior unexecuted.
- **Affected directions:** `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`.

### E-RP08-006 — Localization inventory

- **Claim:** No localization resource files exist in the repository.
- **Capability status:** `ABSENT`
- **Source:** Repository-wide file inventory.
- **Symbol/search:** `*.xcstrings`, `*.strings`, `*.stringsdict`
- **Authority/currentness:** Current repository source inventory.
- **Verification:** `rg --files | rg '\.(xcstrings|strings|stringsdict)$'`
- **Result:** `NO_LOCALIZATION_RESOURCE_FILES`.
- **Confidence:** High.
- **Remaining uncertainty:** Framework-provided system strings are outside app-owned localization.
- **Affected directions:** `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-007 — Sensitive-content source

- **Claim:** Selected domain/external projections redact sensitive labels, but OS-managed privacy presentation is not comprehensively wired.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/Ambitions/Surfaces/Goals/Projection/GoalsFeatureModels+05-GoalPathStage.swift:149-238`; `Native/Ambitions/DesignSystem/ProductObjects/GoalLifePathSignaturePrimitives.swift:125-228`; `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceScopeAllowlist.swift:35-77`
- **Symbol:** privacy-sensitive projections; `ExternalSurfaceScopeAllowlist`
- **Authority/currentness:** Current production source.
- **Verification:** Targeted `rg` for `privacySensitive` and `.privacySensitive()`.
- **Result:** Redacted projection text exists; no SwiftUI `.privacySensitive()` modifier hit in app/widget source.
- **Confidence:** Medium-high.
- **Remaining uncertainty:** Absence of that modifier alone does not prove exposure.
- **Affected directions:** `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-008 — Explicit accessibility proof ceiling

- **Claim:** Repository records direct and public accessibility proof as unavailable.
- **Capability status:** `UNKNOWN` direct behavior
- **Source:** `Native/Ambitions/Quality/AFEP021AccessibilityCertificationProgram.swift:175-234`; `Native/Ambitions/Quality/RealDeviceRenderChecklist.swift:27-41`
- **Symbol:** `proofBoundary`, `claimFlags`, `RealDeviceRenderChecklist.items`
- **Authority/currentness:** Current quality/proof source.
- **Verification/result:** Manual VoiceOver, Dynamic Type screenshots, reduced-motion, measured contrast, motor, physical-device, certification, and release flags are false or blocked.
- **Confidence:** High.
- **Remaining uncertainty:** There may be older artifacts, but current source explicitly refuses these claims.
- **Affected directions:** `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-009 — Header and viewport large-text risks

- **Claim:** Current custom shell has line-limit, scaling, and clipped-viewport behaviors that require rendered large-text proof.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/Ambitions/Stage/Chrome/AppShellHeaderRail.swift:66-117,120-220`; `Native/Ambitions/App/AppShellView.swift:54-85`
- **Symbol:** header title/trailing controls, `AppShellScaffold.scaffoldedContent`
- **Authority/currentness:** Current production source.
- **Verification/result:** Accessibility-size branches exist alongside constrained title and clipped viewport behavior.
- **Confidence:** High as risk evidence.
- **Remaining uncertainty:** Actual clipping was not rendered.
- **Affected directions:** `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`.

### E-RP08-010 — Live Activity truncation

- **Claim:** Live Activity UI constrains title/detail lines and supplies a combined accessibility label.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift:5-86`
- **Symbol:** `NextStepLiveActivityWidget`
- **Authority/currentness:** Current extension source.
- **Verification/result:** Visual line limits and `accessibilityLabel(accessibilitySummary)` are present.
- **Confidence:** High.
- **Remaining uncertainty:** Device speech/rendering unverified.
- **Affected directions:** `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-011 — Root summary helpers

- **Claim:** Each root has source-level accessibility summary helpers.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/Ambitions/DesignSystem/Accessibility/TodayAccessibility.swift:3-17`; `Native/Ambitions/DesignSystem/Accessibility/GoalsAccessibility.swift:3-24`; `Native/Ambitions/DesignSystem/Accessibility/TimeAccessibility.swift:3-25`; `Native/Ambitions/DesignSystem/Accessibility/YouAccessibility.swift:3-17`; `Native/Ambitions/DesignSystem/Accessibility/CaptureAccessibility.swift:3-41`
- **Symbol:** root and Capture accessibility helpers.
- **Authority/currentness:** Current design-system source.
- **Verification/result:** Structured label/value/hint mapping exists.
- **Confidence:** High.
- **Remaining uncertainty:** Complete consumption and runtime order were not proven.
- **Affected directions:** `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-012 — iPhone-only target

- **Claim:** Current supported app target is iOS 26, iPhone-only, non-Catalyst, portrait, single-scene.
- **Capability status:** `SUPPORTED` for iPhone; excluded platforms `CONTRADICTED`
- **Source:** `project.yml:1-9,20-78,97-200`; `Native/Ambitions/Support/Info.plist:38-64`
- **Manifest keys:** deployment target, `TARGETED_DEVICE_FAMILY`, `SUPPORTS_MACCATALYST`, orientations, multiple scenes.
- **Authority/currentness:** Current XcodeGen source manifest and plist.
- **Verification:** `plutil -lint` passed for app/widget/share plists.
- **Result:** Target and extension configuration is valid and intentionally narrow.
- **Confidence:** High.
- **Remaining uncertainty:** Build not completed in this packet.
- **Affected directions:** `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-013 — Apple ecosystem canon

- **Claim:** Widgets, Lock Screen/Live Activities, Spotlight, and App Intents are current canonical projection contracts, not proof of implementation.
- **Capability status:** `PLANNED_NOT_IMPLEMENTED` to `PARTIALLY_SUPPORTED` by surface
- **Source:** `docs/canon/specifications/systems/apple-ecosystem.md:17-60,102-144`
- **Section:** Apple ecosystem projection contracts.
- **Authority/currentness:** Current normative canon.
- **Verification:** Canon query and `ambitions-canon.py check`.
- **Result:** Canon is valid; source coverage differs per surface.
- **Confidence:** High.
- **Remaining uncertainty:** Direct device readiness is surface-specific.
- **Affected directions:** `AVF-COHERENCE-S07-R00`.

### E-RP08-014 — Widget and Live Activity readiness ceiling

- **Claim:** Widget/Live Activity source exists, while current allowlists explicitly withhold platform readiness.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/AmbitionsWidgetExtension/AmbitionsWidgetBundle.swift:1-11`; `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift:1-86`; `Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceScopeAllowlist.swift:35-77`; `Native/Ambitions/Support/ExternalSurfaceVerificationChecklist.swift:45-132`
- **Symbol:** widget bundle, Live Activity widget, allowlist, verification records.
- **Authority/currentness:** Current production and verification source.
- **Verification/result:** Targets/source exist; readiness text requires device widget and ActivityKit lifecycle proof.
- **Confidence:** High.
- **Remaining uncertainty:** No device run.
- **Affected directions:** `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

### E-RP08-015 — App Intents, Siri, and Shortcuts

- **Claim:** App Shortcuts and intents exist but device discovery/invocation is not established.
- **Capability status:** `PARTIALLY_SUPPORTED`
- **Source:** `Native/Ambitions/App/Intents/AmbitionsShortcutsProvider.swift:1-105`; `Native/Ambitions/Support/ExternalSurfaceVerificationChecklist.swift:133-180`
- **Symbol:** `AmbitionsShortcutsProvider`, app-intent/shortcut verification records.
- **Authority/currentness:** Current production and verification source.
- **Verification/result:** Shortcut definitions exist; checklist requires Shortcuts/Siri device verification.
- **Confidence:** High.
- **Remaining uncertainty:** Metadata/runtime not exercised.
- **Affected directions:** `AVF-COHERENCE-S07-R00`.

### E-RP08-016 — Spotlight absence

- **Claim:** No Core Spotlight implementation was found.
- **Capability status:** `PLANNED_NOT_IMPLEMENTED`
- **Source:** `Native`, `project.yml`; canonical intent in Apple ecosystem specification.
- **Symbol/search:** `CoreSpotlight`, `CSSearchable`
- **Authority/currentness:** Current source inventory plus normative canon.
- **Verification:** `rg -n 'CoreSpotlight|CSSearchable' Native project.yml`
- **Result:** `NO_CORESPOTLIGHT_SOURCE_HITS`.
- **Confidence:** High within searched scope.
- **Remaining uncertainty:** None for current app source; future implementation remains possible.
- **Affected directions:** `AVF-COHERENCE-S07-R00`.

### E-RP08-017 — Test definitions and failed execution

- **Claim:** Accessibility-oriented tests and UI scenarios exist, but this audit produced no executable test result.
- **Capability status:** `UNKNOWN` runtime behavior
- **Source:** `Native/AmbitionsTests/App/AccessibilityAdaptiveInterfaceDesignSystemTests.swift:4-178`; `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`; `Native/AmbitionsTests/App/AppShellNavigationTests.swift`; `Native/AmbitionsUITests/BootstrapShellUITests.swift`
- **Test names:** adaptive review, nutrition checklist, shell navigation, bootstrap shell UI scenarios.
- **Authority/currentness:** Current test source.
- **Verification/result:** Coordinator's targeted XCTest batch failed before execution: `FAILURE_CLASS=simulator_boot_failure`, `EXECUTED_TESTS=0`.
- **Confidence:** High for the proof ceiling.
- **Remaining uncertainty:** All runtime outcomes remain unverified in this run.
- **Affected directions:** `AVF-SHELL-S07-R00`, `AVF-A11Y-S07-R00`, `AVF-COHERENCE-S07-R00`.

## Verification performed

- `python3 scripts/ambitions-canon.py check` — passed: 66 documents, 466 requirements, 47 UX screens, 39 visual contracts, 16 local links, 18 JSON files.
- `plutil -lint Native/Ambitions/Support/Info.plist Native/AmbitionsWidgetExtension/Info.plist Native/AmbitionsShareExtension/Info.plist` — all OK.
- Localization inventory — `NO_LOCALIZATION_RESOURCE_FILES`.
- Spotlight search — `NO_CORESPOTLIGHT_SOURCE_HITS`.
- Scene restoration search — `NO_SCENE_RESTORATION_SOURCE_HITS`.
- Targeted source/test inventory with `rg`, `nl -ba`, and canon queries.
- Repository identity rechecked: `main` at `29872755f705f6bd8e276aeac86dcf376ac5f0d8`; `git diff --check` passed before documentation writes.
- Targeted simulator test batch: failed before test execution; zero tests executed.

No simulator, physical-device, screenshot, VoiceOver, Voice Control, Switch Control, Full Keyboard Access, RTL, localization, widget-gallery, ActivityKit lifecycle, notification-delivery, or Siri/Shortcuts invocation claim is made.
