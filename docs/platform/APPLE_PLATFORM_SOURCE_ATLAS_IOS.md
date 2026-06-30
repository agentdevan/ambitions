# Apple Platform Source Atlas for Ambitions — iOS Only

**Recommended repo path:** `docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md`  
**Purpose:** Codex implementation reference for Ambitions native iPhone work.  
**Generated:** 2026-06-18  
**Scope:** iOS-only Apple platform source atlas for SwiftUI, UIKit interop, SwiftData/persistence, App Intents, WidgetKit/Live Activities, Notifications, BackgroundTasks, Local Authentication/privacy, Accessibility, Human Interface Guidelines, iOS design resources, and sample code relevant to native iPhone architecture.  
**Non-goal:** This is not a copied Apple documentation mirror. It is a source map, implementation contract, and Codex decision guide.

---

## 0. Authority Stack

Codex must treat the following authority order as binding:

1. **Ambitions product/design canon** — `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
2. **Current repo source** — live code, tests, project settings, package manifests, entitlements, permissions, and release configuration.
3. **Current Apple documentation and Xcode documentation** — official Apple Developer Documentation, Human Interface Guidelines, WWDC sessions, release notes, and sample code.
4. **Testing evidence** — current Ambitions release testing report and screenshots.

When Apple capabilities conflict with Ambitions product law, Ambitions product law wins. When Ambitions product law requires Apple-native behavior, Apple documentation defines the correct platform implementation path.

---

## 1. Ambitions Platform Law Summary

Ambitions is a **premium native iPhone-first, local-first Personal Life OS**.

Persistent stage surfaces:

```text
Today / Goals / Time / You
```

Global composer:

```text
Capture
```

Cross-surface behavior layer:

```text
Motion
```

Inspectable trust layer:

```text
Proof / Source / Privacy / History / Receipts
```

Every meaningful action must produce:

```text
runtime mutation
visible stage mutation
accessible state change
safe fallback
proof artifact
```

Codex must not rebuild Ambitions as:

- a tab app
- a task app
- a calendar clone
- a habit tracker
- a chatbot
- a dashboard
- a generic AI productivity wrapper
- a web-app shell
- a cloud-LLM-dependent app
- a hosted personal-data backend

---

## 2. Apple Source Index

Use these as canonical starting points. Before implementing a specific API, Codex must inspect the current Apple page in Xcode documentation or Apple Developer Documentation because platform docs and beta APIs can change.

| Area | Apple source | URL | Ambitions use |
|---|---|---|---|
| SwiftUI framework | SwiftUI Documentation | https://developer.apple.com/documentation/swiftui | Native declarative UI, Stage, surfaces, overlays, materials, accessibility environment, previews |
| SwiftUI WWDC26 | What’s new in SwiftUI | https://developer.apple.com/videos/play/wwdc2026/269/ | iOS 27-era SwiftUI additions; gate iOS 27-only APIs behind availability |
| WWDC26 SwiftUI guide | WWDC26 SwiftUI Guide | https://developer.apple.com/wwdc26/guides/swiftui/ | Updated source map for SwiftUI sessions |
| UIKit integration | SwiftUI UIKit integration | https://developer.apple.com/documentation/swiftui/uikit-integration | Controlled UIKit escape hatches for keyboard, text input, hosting, gestures, native controls |
| UIViewRepresentable / UIViewControllerRepresentable | SwiftUI tutorial: Interfacing with UIKit | https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit | Wrapping UIKit objects without making UIKit own the root architecture |
| WWDC26 UIKit interop | Use SwiftUI with AppKit and UIKit | https://developer.apple.com/videos/play/wwdc2026/272/ | Observation, embedding SwiftUI components, UIKit gesture recognizers, incremental adoption |
| SwiftData | SwiftData Documentation | https://developer.apple.com/documentation/swiftdata | Local persistence, model containers, repositories, migrations, local-only runtime store |
| SwiftData persistence | Preserving your app’s model data across launches | https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches | Baseline local persistence pattern |
| SwiftData history | Fetching and filtering time-based model changes | https://developer.apple.com/documentation/swiftdata/fetching-and-filtering-time-based-model-changes | Local proof/history/mutation ledger patterns |
| SwiftData WWDC26 | What’s new in SwiftData | https://developer.apple.com/videos/play/wwdc2026/274/ | Codable persisted types, sectioned fetches, ResultsObserver, HistoryObserver; gate by availability |
| App Intents | App Intents Documentation | https://developer.apple.com/documentation/appintents | System actions for Capture, Start Step, Complete Step, Move Step, Protect Window, Search |
| App Intents intro | Creating your first app intent | https://developer.apple.com/documentation/appintents/creating-your-first-app-intent | Baseline intent structure and action exposure |
| App Intents sample | Adopting App Intents to support system experiences | https://developer.apple.com/documentation/AppIntents/adopting-app-intents-to-support-system-experiences | Main app + widget extension + shared package pattern |
| App Intents WWDC26 | iOS What’s New — App Intents | https://developer.apple.com/ios/whats-new/ | Siri, semantic index, View Annotations, App Intents Testing; iOS 27 availability gates required |
| WidgetKit | WidgetKit Documentation | https://developer.apple.com/documentation/widgetkit | Optional Today/Start Here widget surfaces and glanceable projections |
| Live Activities | ActivityKit Documentation | https://developer.apple.com/documentation/ActivityKit/ | Active Step / protected window live state when user-initiated and valuable |
| Live Activities guide | Displaying live data with Live Activities | https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities | ActivityKit lifecycle, WidgetKit UI construction |
| Widget interactivity | Adding interactivity to widgets and Live Activities | https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities | Done / Move / Open Step actions through App Intents |
| Widget deep links | Linking to specific app scenes from widgets or Live Activities | https://developer.apple.com/documentation/widgetkit/linking-to-specific-app-scenes-from-your-widget-or-live-activity | Deep link into Stage routes without making widgets own state |
| Live Activity sample | Emoji Rangers | https://developer.apple.com/documentation/widgetkit/emoji-rangers-supporting-live-activities-interactivity-and-animations | Patterns only; do not copy gamified behavior |
| Notifications | User Notifications Documentation | https://developer.apple.com/documentation/usernotifications | Local reminders, permission-aware alerts, user-controlled actions |
| Notification permissions | Asking permission to use notifications | https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications | Contextual permission ask, fallback behavior |
| Notification center | UNUserNotificationCenter | https://developer.apple.com/documentation/usernotifications/unusernotificationcenter | Scheduling, managing, removing local notifications |
| Notification actions | Handling notifications and notification-related actions | https://developer.apple.com/documentation/usernotifications/handling-notifications-and-notification-related-actions | Done / Move / Review action entry points |
| BackgroundTasks | Background Tasks Documentation | https://developer.apple.com/documentation/BackgroundTasks | Source Atlas refresh, local maintenance, widget snapshot preparation |
| Background task strategy | Choosing Background Strategies for Your App | https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app | Pick the correct runtime class and user expectation |
| Background updates | Using background tasks to update your app | https://developer.apple.com/documentation/uikit/using-background-tasks-to-update-your-app | BGAppRefreshTask / BGProcessingTask patterns |
| SwiftUI background task modifier | Scene.backgroundTask | https://developer.apple.com/documentation/SwiftUI/Scene/backgroundTask%28_%3Aaction%3A%29 | Attach background work to SwiftUI app lifecycle |
| Local Authentication | LocalAuthentication Documentation | https://developer.apple.com/documentation/localauthentication | Face ID / passcode gates for sensitive local data, export, destructive actions |
| LAContext | LAContext | https://developer.apple.com/documentation/localauthentication/lacontext | Authentication policy evaluation |
| Face ID / Touch ID login | Logging a user into your app with Face ID or Touch ID | https://developer.apple.com/documentation/localauthentication/logging-a-user-into-your-app-with-face-id-or-touch-id | Optional account/session unlock pattern |
| Keychain + biometrics | Accessing Keychain Items with Face ID or Touch ID | https://developer.apple.com/documentation/LocalAuthentication/accessing-keychain-items-with-face-id-or-touch-id | Secure local secrets and export keys |
| Keychain | Keychain Services | https://developer.apple.com/documentation/security/keychain-services | Store small secrets, account tokens, local encryption keys |
| CryptoKit | Apple CryptoKit | https://developer.apple.com/documentation/cryptokit | Hashing, signing, local cryptographic utilities when needed |
| Privacy manifests | Privacy manifest files | https://developer.apple.com/documentation/bundleresources/privacy-manifest-files | PrivacyInfo.xcprivacy, required-reason APIs, release review |
| App Privacy Details | App Privacy Details | https://developer.apple.com/app-store/app-privacy-details/ | App Store privacy nutrition label inputs |
| Accessibility framework | Accessibility Documentation | https://developer.apple.com/documentation/accessibility | VoiceOver, Dynamic Type, Reduce Motion, semantic equivalents |
| Accessibility HIG | HIG: Accessibility | https://developer.apple.com/design/human-interface-guidelines/accessibility | User-facing accessibility standards |
| Accessibility testing | Performing accessibility testing for your app | https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app | VoiceOver, Dynamic Type, Reduce Motion, system feature testing |
| SwiftUI environment values | EnvironmentValues | https://developer.apple.com/documentation/swiftui/environmentvalues | `accessibilityReduceMotion`, `dynamicTypeSize`, color scheme, contrast |
| HIG foundation | Human Interface Guidelines | https://developer.apple.com/design/human-interface-guidelines/ | Platform behavior, layout, motion, materials, color, typography, writing |
| Designing for iOS | HIG: Designing for iOS | https://developer.apple.com/design/human-interface-guidelines/designing-for-ios | iOS-specific appearance, Dynamic Type, Dark Mode, orientation expectations |
| Materials | HIG: Materials | https://developer.apple.com/design/human-interface-guidelines/materials | Legible foreground/background separation; glass/material discipline |
| Liquid Glass | Adopting Liquid Glass | https://developer.apple.com/documentation/TechnologyOverviews/adopting-liquid-glass | Functional glass only; legibility, reduce transparency/motion gates |
| Typography | HIG: Typography | https://developer.apple.com/design/human-interface-guidelines/typography | Native type hierarchy, legibility, dynamic type |
| Color | HIG: Color | https://developer.apple.com/design/human-interface-guidelines/color | Semantic color, Dark Mode, contrast, accessibility settings |
| Layout | HIG: Layout | https://developer.apple.com/design/human-interface-guidelines/layout | Safe areas, content relationships, iPhone viewport hierarchy |
| Motion | HIG: Motion | https://developer.apple.com/design/human-interface-guidelines/motion | Meaningful motion and reduced motion expectations |
| SF Symbols | HIG: SF Symbols | https://developer.apple.com/design/human-interface-guidelines/sf-symbols | Native iconography, localization, symbol weights/scales |
| Apple design resources | Apple Design Resources | https://developer.apple.com/design/resources/ | iOS 26/27 UI kits, Live Activities template, Siri/App Shortcuts template, Sign in with Apple assets, fonts, SF Symbols, Icon Composer, iPhone bezels |
| Sample Code Library | Apple Sample Code Library | https://developer.apple.com/documentation/SampleCode | Official sample discovery root |
| App Dev Tutorials | App Dev Training | https://developer.apple.com/tutorials/app-dev-training | Basic SwiftUI/UIKit data flow, persistence, navigation patterns; use as low-level reference only |

---

## 3. Deployment Target and Availability Rules

Ambitions canon currently states **iOS 26 minimum**. Apple’s public 2026 documentation now includes **iOS 27 / Xcode 27 beta** content. Codex must therefore separate platform source awareness from shipping availability.

### 3.1 Baseline rule

```swift
// Canon baseline
IPHONEOS_DEPLOYMENT_TARGET = 26.0
```

Do not adopt iOS 27-only APIs as unguarded production requirements unless the repo’s canon and project settings explicitly raise the minimum OS.

### 3.2 Availability rule

All APIs introduced after iOS 26 must be gated:

```swift
if #available(iOS 27.0, *) {
    // iOS 27-only implementation
} else {
    // iOS 26 fallback that preserves the same product law
}
```

### 3.3 Product fallback rule

A platform fallback is only acceptable if it preserves:

- runtime mutation
- visible stage mutation
- accessible state change
- safe fallback
- proof artifact
- local-first behavior

A fallback that merely hides a feature is Yellow at best and Red if it blocks core use.

---

## 4. Codex Operating Protocol

Before touching code, Codex must:

1. Inspect `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
2. Inspect the live repo architecture.
3. Confirm whether `AmbitionsStageHost` exists and whether runtime still launches through a tab controller.
4. Confirm `IPHONEOS_DEPLOYMENT_TARGET`.
5. Inspect entitlements, Info.plist privacy usage descriptions, app groups, notification settings, background task identifiers, and widget targets.
6. Inspect current persistence models and migrations.
7. Inspect release build feature flags.
8. Inspect preview/scenario infrastructure.
9. Run or add relevant audits before claiming Green.

Codex closeouts must include:

```text
Status: Green / Yellow / Red
Scope completed:
Files changed:
Product law preserved:
Apple platform sources used:
Validation run:
Validation not run:
Proof artifacts:
Known risks:
Follow-up required:
Rollback plan:
```

---

# 5. SwiftUI Atlas

## 5.1 Apple source set

- SwiftUI Documentation — https://developer.apple.com/documentation/swiftui
- WWDC26 SwiftUI Guide — https://developer.apple.com/wwdc26/guides/swiftui/
- What’s new in SwiftUI — https://developer.apple.com/videos/play/wwdc2026/269/
- SwiftUI scenes — https://developer.apple.com/documentation/swiftui/scenes
- SwiftUI NavigationStack — https://developer.apple.com/documentation/SwiftUI/NavigationStack
- SwiftUI Canvas / GraphicsContext — https://developer.apple.com/documentation/swiftui/canvas and https://developer.apple.com/documentation/swiftui/graphicscontext
- SwiftUI EnvironmentValues — https://developer.apple.com/documentation/swiftui/environmentvalues

## 5.2 Ambitions role

SwiftUI is the primary app UI architecture. It owns:

- `AmbitionsApp`
- `AmbitionsRootScene`
- `AmbitionsStageHost`
- `AmbitionsStage`
- `ObjectStage`
- `ContextCrown`
- `ContinuityDock`
- `CaptureSurface`
- `RealityMeridianView`
- `ConstellationAtlasView`
- `LifeShapeFieldView`
- `UserSystemProfileView`
- overlays for Capture, Search, Closure, and Inspection
- previews and scenario matrices
- Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, and High Contrast adaptation

## 5.3 Codex implementation contract

Codex must implement SwiftUI as a **single adaptive object stage**, not a stack of screen-level prototypes.

Required structure:

```swift
@main
struct AmbitionsApp: App {
    var body: some Scene {
        AmbitionsRootScene()
    }
}

struct AmbitionsRootScene: Scene {
    var body: some Scene {
        WindowGroup {
            AmbitionsStageHost()
        }
    }
}
```

`AmbitionsStageHost` must inject:

- clock
- runtime
- local store
- repositories
- permission coordinator
- notification scheduler
- background task coordinator
- local authentication policy
- surface copy policy
- design tokens
- feature flags
- account / entitlement state
- Source Atlas state

`AmbitionsSurface` must remain:

```swift
enum AmbitionsSurface: String, CaseIterable, Identifiable, Codable, Hashable {
    case today
    case goals
    case time
    case you

    var id: String { rawValue }
}
```

No `motion`. No `capture`.

## 5.4 SwiftUI root-shell rules

Codex may use `NavigationStack` internally, but the user model cannot be a generic tab app.

Required:

- Stage owns surface switching.
- Root dock appears only on Today / Goals / Time / You root surfaces.
- Drilldowns hide root dock.
- Native back gesture works on drilldowns.
- Context crown respects safe area and scroll edge.
- Capture opens as overlay/composer.
- Search opens as overlay.
- Closure opens as focused outcome flow.
- Inspection opens only when requested or required.

Forbidden:

- `TabView` as product root.
- fifth persistent surface.
- Motion tab.
- Capture tab.
- persistent floating generic add button.
- root-level dashboard card stack.
- scroll content hidden under custom chrome.
- hardcoded current time in SwiftUI previews leaking into production.

## 5.5 SwiftUI state and mutation

Codex must separate:

- **Domain state** — local private life graph.
- **Runtime projection** — deterministic view of what fits now.
- **Stage state** — current surface, overlay, route, focus, chrome state.
- **View state** — transient UI-only state.

SwiftUI views may not directly mutate persistent models. Meaningful actions must flow through:

```text
View event
→ StageAction
→ StageReducer
→ CommandValidation
→ AmbitionsCommand
→ RuntimeValidator
→ RuntimeMutation
→ StageMutation
→ UserVisibleMutation
→ StageMotionEvent
→ StageEffect
→ visible stage result
→ accessibility announcement
→ proof artifact
```

## 5.6 SwiftUI Canvas rules

SwiftUI `Canvas` is approved only for semantic product objects:

- Reality Meridian
- Constellation Atlas
- LifeShape Field
- Motion layer effects

Every Canvas object must have:

- semantic model
- VoiceOver reading order
- accessible actions
- Dynamic Type fallback
- Reduce Motion fallback
- Reduce Transparency fallback
- High Contrast fallback
- text-only fallback
- snapshot coverage
- performance budget

Canvas must not be used for decorative celestial wallpaper, particle systems, meaningless node constellations, or fake premium visuals.

## 5.7 SwiftUI previews

Every root surface and overlay must have a preview matrix:

```text
root / drilldown / overlay
empty / dense / broken-source / post-mutation / recovery
Dynamic Type default / XXXL
Reduce Motion on / off
Reduce Transparency on / off
High Contrast on / off
Light / dark if light mode remains supported
```

Preview clocks must use `PreviewClock`. Production must use `SystemClock` through `AmbitionsClock`.

## 5.8 Acceptance gates

Green only when:

- Today live now marker matches the injected clock.
- Every root surface has one primary object.
- Capture opens and expands without crash.
- Root dock is hidden in drilldowns and overlays where required.
- Keyboard never traps composer between dock and keyboard.
- No duplicate nav shelf appears.
- Every mutation produces visible stage change and accessibility announcement.
- Dynamic Type does not cause vertical letter wrapping.
- SwiftUI previews cover root, drilldown, overlay, and accessibility states.

---

# 6. UIKit Interop Atlas

## 6.1 Apple source set

- UIKit integration — https://developer.apple.com/documentation/swiftui/uikit-integration
- Interfacing with UIKit — https://developer.apple.com/tutorials/swiftui/interfacing-with-uikit
- Use SwiftUI with AppKit and UIKit — https://developer.apple.com/videos/play/wwdc2026/272/
- Modernize your UIKit app — https://developer.apple.com/videos/play/wwdc2026/278/
- UIViewRepresentable — https://developer.apple.com/documentation/swiftui/uiviewrepresentable
- UIViewControllerRepresentable — https://developer.apple.com/documentation/swiftui/uiviewcontrollerrepresentable
- UIHostingController — https://developer.apple.com/documentation/swiftui/uikit-integration

## 6.2 Ambitions role

UIKit interop is an escape hatch, not the app architecture.

Approved uses:

- advanced text input when SwiftUI text controls cannot meet Capture quality
- keyboard measurement and choreography if SwiftUI APIs are insufficient
- native sheet/presentation behavior when custom overlay fails platform behavior
- scroll instrumentation and content offset if required for Context Crown behavior
- gesture recognizers not yet cleanly modeled in SwiftUI
- system controllers that are UIKit-based
- input accessory behavior
- specific haptic/input refinements

Not approved:

- UIKit root controller replacing `AmbitionsStage`
- UIKit tab controller as product architecture
- UIKit navigation controller as primary surface model
- one-off UIKit hacks without ownership files and tests
- custom keyboard avoidance that breaks safe areas

## 6.3 Wrapper law

Every UIKit wrapper must define:

```text
why SwiftUI was insufficient
which product object owns the wrapper
which lifecycle methods are used
how updates flow from SwiftUI to UIKit
how UIKit events flow back to StageAction
how accessibility is mirrored
how safe areas and keyboard are handled
how cleanup/dismantle works
how tests/previews cover the wrapper
rollback path
```

UIKit wrappers belong under a clear implementation namespace, for example:

```text
Interaction/UIKitInterop/
  KeyboardObserverView.swift
  TextInputBridge.swift
  GestureRecognizerBridge.swift
  HostingMeasurementBridge.swift
```

## 6.4 Capture-specific interop

Capture is the strongest candidate for UIKit interop if native SwiftUI text behavior cannot meet the required composer quality.

Requirements:

- Focused composer slides above keyboard.
- Root dock hides or safely displaces.
- Text input grows multiline.
- At max height, text scrolls internally.
- Voice / mic / attachment controls remain reachable.
- Full-screen expansion does not crash.
- Dismissal restores focus predictably.
- No capture UI is trapped between dock and keyboard.

## 6.5 Acceptance gates

Green only when:

- every wrapper has a product owner and lifecycle cleanup
- no UIKit interop creates duplicate chrome
- VoiceOver reaches wrapped controls in correct order
- Dynamic Type remains legible
- keyboard-safe screenshots pass on real iPhone
- Reduce Motion and Reduce Transparency fallbacks still work

---

# 7. SwiftData / Persistence Atlas

## 7.1 Apple source set

- SwiftData — https://developer.apple.com/documentation/swiftdata
- Adding and editing persistent data — https://developer.apple.com/documentation/SwiftData/Adding-and-editing-persistent-data-in-your-app
- Preserving model data across launches — https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches
- ModelContainer — https://developer.apple.com/documentation/swiftdata/modelcontainer
- `@Model` — https://developer.apple.com/documentation/swiftdata/model%28%29
- SwiftData history — https://developer.apple.com/documentation/swiftdata/fetching-and-filtering-time-based-model-changes
- Syncing model data across devices — https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices
- Adopting SwiftData for a Core Data app — https://developer.apple.com/documentation/CoreData/adopting-swiftdata-for-a-core-data-app
- What’s new in SwiftData — https://developer.apple.com/videos/play/wwdc2026/274/

## 7.2 Ambitions role

SwiftData is the local persistence candidate for the Private Life Runtime. It must preserve local-first product law.

Persisted categories:

- goals
- life areas
- captures
- held items
- steps
- closure events
- proof events
- receipts
- protected time
- schedule assumptions
- planning defaults
- recovery history
- personalization and corrections
- recommendation history
- permission/account/reference-pack state

## 7.3 Critical architecture rule

Domain models must not blindly become SwiftData models.

Use this separation:

```text
Core/Domain/
  Step.swift
  GoalThread.swift
  LifeArea.swift
  RealityWindow.swift
  CapacityShape.swift
  CaptureIntake.swift
  ClosureOutcome.swift
  ProofEvent.swift
  RecoveryState.swift
  UserSystemProfile.swift

Core/Persistence/SwiftDataModels/
  StepRecord.swift
  GoalThreadRecord.swift
  LifeAreaRecord.swift
  CaptureRecord.swift
  ClosureEventRecord.swift
  ProofEventRecord.swift
  ReceiptRecord.swift
  UserSystemProfileRecord.swift

Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift

Core/Persistence/Repositories/
  StepRepository.swift
  GoalRepository.swift
  CaptureRepository.swift
  ProofRepository.swift
  UserProfileRepository.swift
```

Repositories translate between domain and persistence records.

## 7.4 Local-only data law

Do not enable iCloud/CloudKit sync for the private life graph unless future canon explicitly approves user-owned sync.

Disallowed by current canon:

- hosted personal-data backend
- R2 receiving goals, captures, calendar data, closure history, proof, personalization, behavioral history, inferred priorities, or private context
- account sign-in required for core local use
- CloudKit sync silently becoming product truth

## 7.5 SwiftData schema rules

Each persisted record must define:

- stable local id
- schema version
- createdAt
- updatedAt
- privacy classification
- local-only flag if needed
- soft-delete / tombstone policy if required
- migration plan
- repository mapping tests
- sample records for scenarios

Use explicit migration plans before release. If migrations are not tested, release status is Yellow or Red depending on data-risk scope.

## 7.6 Proof and history

SwiftData history capabilities may inform Ambitions proof/history implementation, but product proof is not the same thing as storage transaction history.

Maintain two layers:

```text
Storage history: what changed in persisted records.
Product proof: user-inspectable evidence that meaningful progress/change happened.
```

Product proof must survive:

- imperfect completion
- Still counts
- moved step
- blocked step
- recovery
- undo
- local store migration

## 7.7 Widgets and app groups

If widgets or Live Activities need local state, do not expose the full private life graph to extensions by default.

Preferred pattern:

```text
Main app owns SwiftData private graph.
Main app writes redacted projection snapshots to App Group store.
Widget reads only snapshot required for widget UI.
Widget action invokes App Intent.
Main app/runtime validates mutation.
Proof artifact is created by runtime, not widget UI.
```

## 7.8 Store health

Add or preserve:

```text
Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift
Core/LocalRuntimeOS/Storage/
Core/Persistence/StoreHealthCheck.swift
Core/Persistence/Migrations/
```

StoreHealthCheck must detect:

- unavailable local store
- migration failure
- corrupt store
- read/write failure
- schema mismatch
- extension snapshot write failure

Top-level UI must show calm fallback, not a debug error.

## 7.9 Acceptance gates

Green only when:

- offline core works with no account
- no private life graph leaves device
- migration tests pass
- SwiftData models are not directly exposed to UI
- repositories are covered by tests
- proof/history state is inspectable when requested
- store failure leaves manual planning useful
- widget extension cannot mutate private graph directly

---

# 8. App Intents Atlas

## 8.1 Apple source set

- App Intents — https://developer.apple.com/documentation/appintents
- Creating your first app intent — https://developer.apple.com/documentation/appintents/creating-your-first-app-intent
- App intents overview — https://developer.apple.com/documentation/appintents/app-intents
- AppIntent protocol — https://developer.apple.com/documentation/appintents/appintent
- Getting started with App Intents — https://developer.apple.com/documentation/appintents/getting-started-with-the-app-intents-framework
- Adopting App Intents sample — https://developer.apple.com/documentation/AppIntents/adopting-app-intents-to-support-system-experiences
- Accelerating app interactions with App Intents — https://developer.apple.com/documentation/appintents/acceleratingappinteractionswithappintents
- Displaying static and interactive snippets — https://developer.apple.com/documentation/AppIntents/displaying-static-and-interactive-snippets
- WWDC26 iOS App Intents update — https://developer.apple.com/ios/whats-new/
- Bring your app’s core features to users with App Intents — https://developer.apple.com/videos/play/wwdc2024/10210/

## 8.2 Ambitions role

App Intents should expose **user-controlled Ambitions actions** to iOS system surfaces without turning Ambitions into an AI assistant or leaking the private life graph.

Candidate intents:

```text
CaptureIntent
StartStepIntent
CompleteStepIntent
StillCountsIntent
MoveStepIntent
BlockStepIntent
ProtectWindowIntent
OpenTodayIntent
OpenGoalThreadIntent
SearchAmbitionsIntent
OpenSettingsAreaIntent
```

## 8.3 Privacy rules

App Intents must not expose broad private graph search or raw personal context by default.

Rules:

- Every intent must have a narrow action boundary.
- Every intent that mutates user data must validate through the runtime.
- Every mutation must create proof/receipt behavior where required.
- Siri/Shortcuts phrases must use user-facing language, not runtime jargon.
- Entities must avoid oversharing titles, notes, proof, calendar-derived context, or sensitive details into system surfaces.
- System snippets must be redacted by default unless user intent is clear.

## 8.4 iOS 26 vs iOS 27

Baseline App Intents are compatible with the current Ambitions direction. iOS 27 adds App Intents features such as entity schemas, intent schemas, View Annotations, and App Intents Testing according to Apple’s iOS 27 material. Use these only behind availability gates until canon raises the deployment target.

Pattern:

```swift
struct CompleteStepIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Step Done"

    func perform() async throws -> some IntentResult {
        // Call CommandRouter / RuntimeValidator.
        // Never mutate SwiftData directly from intent code.
    }
}
```

## 8.5 Shared package structure

Recommended:

```text
Packages/AmbitionsIntents/
  Sources/AmbitionsIntents/
    CaptureIntent.swift
    StepIntents.swift
    TimeIntents.swift
    AmbitionsEntities.swift
    AmbitionsIntentResults.swift
    IntentPrivacyPolicy.swift
```

But the shared package must not import unrestricted app internals. It should communicate through a small local command bridge.

## 8.6 Testing

Codex must add:

- intent unit tests for validation and fallback
- App Intents Testing framework tests where available and availability-gated
- privacy redaction tests for entity display
- widget-action integration tests if WidgetKit uses intents
- screenshot or transcript proof that Siri/Shortcuts labels are user-facing

## 8.7 Acceptance gates

Green only when:

- App Intents cannot bypass runtime validation
- no intent directly writes SwiftData private records without command validation
- no raw runtime language appears in intent titles/descriptions
- private details are redacted in system UI unless the user explicitly asks
- iOS 27-only App Intents APIs are availability-gated
- failed intents return useful user-facing fallback language

---

# 9. WidgetKit / Live Activities Atlas

## 9.1 Apple source set

- WidgetKit — https://developer.apple.com/documentation/widgetkit
- ActivityKit — https://developer.apple.com/documentation/ActivityKit/
- Live Activities collection — https://developer.apple.com/documentation/widgetkit/liveactivities-collection
- Displaying live data with Live Activities — https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities
- Adding interactivity to widgets and Live Activities — https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities
- Linking to specific app scenes — https://developer.apple.com/documentation/widgetkit/linking-to-specific-app-scenes-from-your-widget-or-live-activity
- Previewing widgets and Live Activities — https://developer.apple.com/documentation/widgetkit/previewing-widgets-and-live-activities-in-xcode
- Emoji Rangers sample — https://developer.apple.com/documentation/widgetkit/emoji-rangers-supporting-live-activities-interactivity-and-animations
- Live Activities essentials — https://developer.apple.com/videos/play/wwdc2026/223/
- WidgetKit foundations — https://developer.apple.com/videos/wwdc2026/ or Apple Developer video search

## 9.2 Ambitions role

Widgets and Live Activities are **extensions of the object stage**, not parallel dashboards.

Approved widget concepts:

- Today Start Here glance
- current protected window
- next fixed point
- lightweight “what fits now” prompt
- one-tap Capture entry
- one-tap open Today

Potential Live Activity concepts:

- active Step in progress
- protected focus/recovery window
- time-bounded life event that the user explicitly starts

Not approved:

- productivity score
- streaks
- leaderboard
- dashboard metrics
- full day task list
- persistent pressure feed
- notifications disguised as widgets
- always-on activity for passive planning

## 9.3 Data boundary

Widget extension must read only a redacted projection snapshot:

```swift
struct WidgetProjectionSnapshot: Codable {
    var generatedAt: Date
    var visibleTitle: String
    var visibleSubtitle: String?
    var currentWindowLabel: String?
    var nextFixedPointLabel: String?
    var allowedActions: [WidgetAction]
    var privacyLevel: WidgetPrivacyLevel
}
```

The widget must not own the Private Life Runtime.

## 9.4 Live Activity lifecycle

Live Activities must be user-initiated or clearly tied to an active user operation.

Allowed:

- Start when user starts a Step or protected window.
- Update with runtime-validated state.
- End when the Step closes, moves, blocks, or window expires.
- Deep link back to the exact Stage route.

Forbidden:

- background-starting personal Live Activities without user control
- using Live Activities as engagement pressure
- exposing sensitive Step titles on Lock Screen without privacy policy
- rendering detailed proof/receipts on Lock Screen

## 9.5 Interactivity

Widget/Live Activity buttons must route through App Intents:

- Done
- Still counts
- Move it
- Blocked
- Open Step
- Capture

Each action must create a normal runtime mutation path. If the app cannot validate safely, the action must open the app to confirm.

## 9.6 Acceptance gates

Green only when:

- widget extension reads only redacted snapshots
- no widget directly mutates private graph
- Live Activity only appears for user-initiated active state
- privacy redaction works on Lock Screen
- deep links restore correct Stage route
- interactivity uses App Intents and runtime validation
- previews exist for all widget families and privacy states

---

# 10. Notifications Atlas

## 10.1 Apple source set

- User Notifications — https://developer.apple.com/documentation/usernotifications
- Asking permission to use notifications — https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications
- UNUserNotificationCenter — https://developer.apple.com/documentation/usernotifications/unusernotificationcenter
- Handling notifications and notification-related actions — https://developer.apple.com/documentation/usernotifications/handling-notifications-and-notification-related-actions
- Generating a remote notification — https://developer.apple.com/documentation/usernotifications/generating-a-remote-notification
- UNNotificationServiceExtension — https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension

## 10.2 Ambitions role

Notifications should support user intent and protection, not engagement pressure.

Approved notification categories:

- user-created Step reminder
- protected window start/end reminder
- user-requested deadline reminder
- closure prompt for an active Step
- permission-aware fallback reminder
- account/reference-pack status only if explicitly useful and user-controlled

Not approved:

- streak pressure
- productivity shaming
- generic “come back” notifications
- “AI has optimized your day” alerts
- silent plan mutation alerts
- red-badge anxiety

## 10.3 Permission strategy

Do not ask for notification permission at first launch.

Ask only when the user creates a reminder, alarm reminder, protected window, or notification-dependent behavior.

Denial fallback:

- keep local Step and visible Today state
- show calm inline status where relevant
- allow manual planning
- expose permission management in You

## 10.4 Notification actions

Actions may include:

```text
Done
Still counts
Move it
Blocked
Open Step
```

But actions must route through App Intents / CommandRouter and obey runtime validation.

## 10.5 Scheduling model

Create:

```text
Core/Permissions/NotificationPermission.swift
Core/Notifications/NotificationScheduler.swift
Core/Notifications/NotificationActionRouter.swift
Core/Notifications/NotificationRequestFactory.swift
```

Notifications should be derived from runtime projections, but must not silently mutate user state.

## 10.6 Acceptance gates

Green only when:

- permission prompt is contextual
- denial does not block local core value
- notification copy is user-facing and non-shaming
- scheduled notifications are cancellable and inspectable
- action taps validate through runtime
- no notification exposes private details unexpectedly on Lock Screen
- You contains notification settings and permission state

---

# 11. BackgroundTasks Atlas

## 11.1 Apple source set

- Background Tasks — https://developer.apple.com/documentation/BackgroundTasks
- Choosing Background Strategies — https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app
- Using background tasks to update your app — https://developer.apple.com/documentation/uikit/using-background-tasks-to-update-your-app
- BGTaskScheduler — https://developer.apple.com/documentation/backgroundtasks/bgtaskscheduler
- BGAppRefreshTask — https://developer.apple.com/documentation/backgroundtasks/bgapprefreshtask
- BGProcessingTask — https://developer.apple.com/documentation/backgroundtasks/bgprocessingtask
- Scene.backgroundTask — https://developer.apple.com/documentation/SwiftUI/Scene/backgroundTask%28_%3Aaction%3A%29
- Performing long-running tasks on iOS and iPadOS — https://developer.apple.com/documentation/BackgroundTasks/performing-long-running-tasks-on-ios-and-ipados

## 11.2 Ambitions role

Background work may keep supporting data fresh and prepare local projections, but it must not become hidden automation.

Approved background jobs:

- Source Atlas public/reference pack refresh
- account entitlement refresh
- local store health check
- migration preflight / repair when safe
- widget snapshot generation
- notification schedule reconciliation
- cleanup of expired projection snapshots
- local index refresh for search

Requires caution:

- precomputing recommendations
- updating Today projection
- running closure/recovery logic

Forbidden:

- silently moving Steps
- silently changing protected time
- silently closing loops
- uploading private graph data
- blocking core app when R2/reference refresh fails
- server-driven planning

## 11.3 Background task coordinator

Create:

```text
Core/Background/
  BackgroundTaskCoordinator.swift
  BackgroundTaskIdentifier.swift
  SourceAtlasRefreshTask.swift
  StoreMaintenanceTask.swift
  WidgetSnapshotRefreshTask.swift
  NotificationReconciliationTask.swift
```

Register identifiers once at launch. Keep identifiers in Info.plist and tests.

## 11.4 Mutation boundary

Background jobs may prepare candidate projections. They may not execute meaningful user-visible mutations unless:

- the user explicitly enabled that automation
- runtime validates it
- the change is visible on next launch
- proof/receipt is created
- undo/review is available if required

## 11.5 Acceptance gates

Green only when:

- background task identifiers are registered and documented
- tasks are idempotent
- tasks respect battery/network constraints
- tasks fail silently only when no user-visible consequence is required
- local core still works if all background tasks fail
- no private graph is uploaded
- background refresh cannot produce hidden plan changes

---

# 12. Local Authentication / Privacy Atlas

## 12.1 Apple source set

- LocalAuthentication — https://developer.apple.com/documentation/localauthentication
- LAContext — https://developer.apple.com/documentation/localauthentication/lacontext
- Logging a user into your app with Face ID or Touch ID — https://developer.apple.com/documentation/localauthentication/logging-a-user-into-your-app-with-face-id-or-touch-id
- Accessing Keychain Items with Face ID or Touch ID — https://developer.apple.com/documentation/LocalAuthentication/accessing-keychain-items-with-face-id-or-touch-id
- Keychain Services — https://developer.apple.com/documentation/security/keychain-services
- Storing keys in the keychain — https://developer.apple.com/documentation/security/storing-keys-in-the-keychain
- Protecting keys with Secure Enclave — https://developer.apple.com/documentation/security/protecting-keys-with-the-secure-enclave
- CryptoKit — https://developer.apple.com/documentation/cryptokit
- Privacy manifest files — https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- App Privacy Details — https://developer.apple.com/app-store/app-privacy-details/
- AuthenticationServices — https://developer.apple.com/documentation/authenticationservices
- Sign in with Apple implementation — https://developer.apple.com/documentation/AuthenticationServices/implementing-user-authentication-with-sign-in-with-apple
- Sign in with Apple HIG — https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple

## 12.2 Ambitions role

Local authentication protects sensitive local actions. It is not a replacement for the local-first architecture.

Approved gates:

- view/export private graph
- delete all local data
- unlock sensitive proof/history
- access account tokens
- reveal hidden/private Step details
- change privacy/security settings
- enable high-impact automation

Not approved:

- requiring Face ID every launch by default
- blocking Today/Goals/Time/You core local use
- using biometrics as performative privacy theater
- hiding failure states without manual fallback

## 12.3 Keychain policy

Use Keychain for small secrets:

- account tokens
- local encryption keys if used
- export signing keys if used
- App Attest or server validation keys if future account scope requires it

Do not store large private graph data in Keychain.

## 12.4 Privacy manifest and App Store privacy

Codex must maintain:

```text
PrivacyInfo.xcprivacy
App Store privacy answers source file
permission purpose strings
third-party SDK review log
required-reason API inventory
```

Because Ambitions is local-first, the expected privacy posture is strict:

- no third-party analytics SDK by default
- no third-party crash/session replay SDK by default
- no tracking domains
- no server-side user profiling
- no private graph upload
- R2 receives public/reference requests only, never private user context

## 12.5 Permission copy

Permission prompts must be contextual and truthful.

Examples:

```text
Calendar: Ambitions can use calendar events as fixed points. Your goals and captures stay on this device.
Speech: Use voice capture for this entry. You can keep typing instead.
Notifications: Remind you about this Step at the time you chose.
Face ID: Protect sensitive local history and export controls.
```

## 12.6 Acceptance gates

Green only when:

- core app works without account
- core app works offline
- local auth is contextual and not mandatory for basic use
- PrivacyInfo.xcprivacy is present and reviewed
- permission prompts have accurate usage strings
- third-party SDK inventory is empty or explicitly approved
- account tokens are Keychain-protected
- destructive data actions require confirmation and optional local auth
- export/delete flows produce proof/receipt where relevant

---

# 13. Accessibility Atlas

## 13.1 Apple source set

- Accessibility Documentation — https://developer.apple.com/documentation/accessibility
- HIG Accessibility — https://developer.apple.com/design/human-interface-guidelines/accessibility
- Performing accessibility testing — https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app
- Testing system accessibility features — https://developer.apple.com/documentation/accessibility/testing-system-accessibility-features-in-your-app
- SwiftUI EnvironmentValues — https://developer.apple.com/documentation/swiftui/environmentvalues
- HIG Motion — https://developer.apple.com/design/human-interface-guidelines/motion
- HIG Color — https://developer.apple.com/design/human-interface-guidelines/color
- HIG Typography — https://developer.apple.com/design/human-interface-guidelines/typography

## 13.2 Ambitions role

Accessibility is architecture, not polish. Every Ambitions product object must remain usable without visual geometry, color, motion, glow, haptic, or celestial metaphor.

Required for every primary object:

- object-level VoiceOver summary
- semantic grouping
- accessible actions
- Dynamic Type support
- Reduce Motion support
- Reduce Transparency support
- Increase Contrast support
- Differentiate Without Color support
- minimum 44 pt hit targets
- text-only fallback for Canvas-heavy objects
- source/trust path access when relevant
- closure/recovery access

## 13.3 Surface-specific accessibility contracts

### Today

VoiceOver summary must communicate:

```text
current time
current window
recommended step if present
next fixed point
protected boundary if present
urgent/waiting/blocked state if present
primary action
```

### Goals

VoiceOver summary must communicate:

```text
life areas
active goal threads
recommended step feeding Today
blocked/waiting threads
completed milestones
```

### Time

VoiceOver summary must communicate:

```text
current date
now marker
fixed points
open capacity
protected windows
pressure seams
current zoom level
Today anchor
```

### You

VoiceOver structure should resemble native Settings:

```text
profile header
settings groups
rows with status/toggle/chevron
clear drilldown titles
native back behavior
```

### Capture

VoiceOver must support:

```text
focused input
dictation/mic state
attachment tray
routing preview
save/place action
close/collapse action
permission denial fallback
```

## 13.4 Dynamic Type collapse order

Collapse first:

1. atmospheric detail
2. decorative trace
3. secondary metadata
4. dense readings
5. optional labels

Never collapse first:

- primary object
- primary action
- closure/recovery action
- route state
- trust path
- receipt/proof when it is the current result
- manual fallback

## 13.5 Required audits

Implement or preserve:

```text
Quality/AccessibilityAudit.swift
Quality/DynamicTypeAudit.swift
Quality/MotionReductionAudit.swift
Quality/SafeAreaAudit.swift
Quality/VisualRegressionHarness.swift
DesignSystem/Accessibility/VoiceOverFocusPolicy.swift
DesignSystem/Accessibility/DynamicTypePolicy.swift
DesignSystem/Accessibility/ReduceMotionPolicy.swift
DesignSystem/Accessibility/ReduceTransparencyPolicy.swift
DesignSystem/Accessibility/ContrastPolicy.swift
```

## 13.6 Acceptance gates

Green only when:

- VoiceOver can operate every meaningful action
- Dynamic Type XXXL does not cause vertical letter wrapping
- Reduce Motion does not remove meaning
- Reduce Transparency preserves legibility
- high contrast remains usable
- controls meet hit target requirements
- Stage focus is restored after surface changes and overlays
- Canvas has semantic mirrors

---

# 14. Human Interface Guidelines Atlas

## 14.1 Apple source set

- Human Interface Guidelines — https://developer.apple.com/design/human-interface-guidelines/
- Designing for iOS — https://developer.apple.com/design/human-interface-guidelines/designing-for-ios
- Accessibility — https://developer.apple.com/design/human-interface-guidelines/accessibility
- Materials — https://developer.apple.com/design/human-interface-guidelines/materials
- Dark Mode — https://developer.apple.com/design/human-interface-guidelines/dark-mode/
- Typography — https://developer.apple.com/design/human-interface-guidelines/typography
- Color — https://developer.apple.com/design/human-interface-guidelines/color
- Layout — https://developer.apple.com/design/human-interface-guidelines/layout
- Motion — https://developer.apple.com/design/human-interface-guidelines/motion
- SF Symbols — https://developer.apple.com/design/human-interface-guidelines/sf-symbols
- Sign in with Apple — https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple
- Communicate your brand identity on iOS — https://developer.apple.com/videos/play/wwdc2026/251/
- Principles of great design — linked from iOS What’s New / WWDC26

## 14.2 Ambitions HIG translation

Apple HIG is not a visual cloning license. It defines platform expectations. Ambitions must be native and premium while retaining its own product identity.

Translation rules:

| HIG area | Ambitions implementation |
|---|---|
| Navigation | Stage routes, native back behavior, root-only dock, context crown |
| Layout | Full-screen object stage, no hidden content under chrome, safe-area correctness |
| Materials | Quiet Glass and Liquid Glass only where controls/navigation need separation |
| Typography | SF-native hierarchy, short copy budgets, no architecture prose in root surfaces |
| Color | Semantic graphite/OLED palette with accessible contrast and non-color indicators |
| Motion | Object continuity only when it clarifies consequence; reduced-motion fallback always |
| Accessibility | Semantic mirrors, VoiceOver actions, Dynamic Type, Reduce Motion, Reduce Transparency |
| SF Symbols | Use native symbols for controls; avoid ornamental icon spam |
| Dark Mode | Default graphite/OLED quality; legibility beats atmosphere |

## 14.3 Liquid Glass law

Liquid Glass must be functional:

Approved:

- Context Crown controls
- Continuity Dock
- Capture access/control tray
- Search overlay field
- selected route indicators when legible
- system-aligned sheets or bars

Not approved:

- fake glass panels everywhere
- decorative translucent blobs
- illegible blur over active content
- glass hiding weak hierarchy
- custom chrome that breaks Reduce Transparency
- glass as a substitute for product object design

## 14.4 Copy law

Root surfaces must not read like product specs.

Allowed primary language:

```text
Start here
Recommended step
Start now
Open step
Step
Today
Goal
Time
Capture
You
Done
Still counts
Move it
Blocked
Waiting
Not needed
Protected
Review
Undo
Manual
```

Inspection-only language:

```text
Why this?
Source
Proof
Receipt
History
Privacy
Local data
Public reference
Source Atlas
Changed by
R2 freshness
Account entitlement
Privacy boundary
```

Forbidden in active top-level UI:

```text
runtime-backed
fixture-only
route reveal
receipt before save
proof seam
open seam
local projection
mutation pipeline
source unavailable
review before reflow
ready before change
blocked-pending-model
correction-shaped ledger
Motion Current
Capture Anything
Close Today
```

## 14.5 Acceptance gates

Green only when:

- every root surface is understandable in under 3 seconds
- every root surface has one primary object
- every root surface has one primary action max in first viewport
- native back behavior works
- You resembles premium native Settings/profile organization
- chrome does not look like a web-app shell
- Liquid Glass preserves legibility and accessibility
- copy budget passes

---

# 15. iOS Design Resources Atlas

## 15.1 Apple source set

- Apple Design Resources — https://developer.apple.com/design/resources/
- iOS 26 / iPadOS 26 UI Kit — linked from Apple Design Resources
- iOS 27 / iPadOS 27 UI Kit — linked from Apple Design Resources
- Live Activities template — linked from Apple Design Resources
- Siri and App Shortcuts template — linked from Apple Design Resources
- Sign in with Apple buttons and logo — linked from Apple Design Resources
- SF Pro — linked from Apple Design Resources
- SF Symbols — linked from Apple Design Resources
- Icon Composer — linked from Apple Design Resources
- iPhone 17 product bezels — linked from Apple Design Resources

## 15.2 Ambitions role

Use design resources for accuracy, not decoration.

Approved uses:

- validate iOS 26/27 control proportions
- validate native row heights and settings structure
- validate nav/tab/search material behavior
- validate Live Activity sizes
- validate Sign in with Apple button rendering
- validate SF Symbols weights/scales
- validate app icon layered Liquid Glass export
- validate iPhone 17 marketing/device frame mockups

Not approved:

- copying Apple app UI wholesale
- replacing Ambitions design system with generic UI kit objects
- using iPhone bezels as product proof
- creating celestial wallpaper from design resources
- using SF Symbols as dense decorative filler

## 15.3 Codex / design handoff contract

When implementing frontend changes, Codex should produce:

```text
root screenshots on iPhone target
root + drilldown screenshots
keyboard/capture screenshots
Dynamic Type screenshots
Reduce Motion screenshots
Reduce Transparency screenshots
High Contrast screenshots
widget/Live Activity previews if touched
```

Design review should compare against Apple resources for:

- safe area
- control density
- corner radius discipline
- material legibility
- typography hierarchy
- symbol sizing
- settings row behavior
- Lock Screen/Dynamic Island constraints

---

# 16. Sample Code Atlas

## 16.1 Apple source set

- Sample Code Library — https://developer.apple.com/documentation/SampleCode
- App Dev Tutorials — https://developer.apple.com/tutorials/app-dev-training
- Scrumdinger tutorial — https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger
- Persisting data tutorial — https://developer.apple.com/tutorials/app-dev-training/persisting-data
- Fruta sample — discover via Sample Code Library
- Adopting App Intents to support system experiences — https://developer.apple.com/documentation/AppIntents/adopting-app-intents-to-support-system-experiences
- Accelerating app interactions with App Intents — https://developer.apple.com/documentation/appintents/acceleratingappinteractionswithappintents
- Emoji Rangers Live Activities sample — https://developer.apple.com/documentation/widgetkit/emoji-rangers-supporting-live-activities-interactivity-and-animations
- Adopting SwiftData for a Core Data app — https://developer.apple.com/documentation/CoreData/adopting-swiftdata-for-a-core-data-app
- Fetching and filtering time-based model changes — https://developer.apple.com/documentation/swiftdata/fetching-and-filtering-time-based-model-changes
- Storing CryptoKit keys in Keychain — https://developer.apple.com/documentation/cryptokit/storing-cryptokit-keys-in-the-keychain

## 16.2 Sample-code usage law

Sample code is for patterns, not product identity.

Codex may borrow:

- target setup patterns
- entitlements wiring
- shared package structure
- App Intent/entity/action conventions
- WidgetKit/ActivityKit lifecycle patterns
- SwiftData model container and migration patterns
- accessibility modifier examples
- keychain/local auth patterns
- app lifecycle event handling

Codex must not borrow:

- sample app IA
- sample app visual grammar
- gamification mechanics
- dashboard layouts
- generic task list structure
- sample app copy
- cloud/network assumptions that conflict with Ambitions canon

## 16.3 Relevant sample mapping

| Sample / tutorial | Extract pattern | Ambitions target | Do not copy |
|---|---|---|---|
| Scrumdinger | SwiftUI app structure, simple data flow, persistence tutorial | beginner-level reference for state and persistence | meeting/task app identity |
| Fruta | SwiftUI-rich app, widgets, App Clip patterns | widget and native SwiftUI packaging ideas | shopping/product UI identity |
| Adopting App Intents | shared package, app + widget extension, discoverability | AmbitionsIntents package | sample entity model |
| Accelerating App Intents | system action discovery and shortcuts | Capture/Step/Time intents | broad private graph exposure |
| Emoji Rangers | Live Activity lifecycle, interactivity, animations | active Step or protected window Live Activity | game mechanics, scores, urgency |
| SwiftData persistence samples | local model setup, container use, migrations | `ObjectStoreSwiftData` / repositories | direct UI-to-model mutation |
| SwiftData history samples | transaction history patterns | proof/history implementation support | equating storage history with product proof |
| CryptoKit keychain sample | secure local key storage | optional export/encryption keys | overbuilding crypto beyond approved scope |

---

# 17. Ambitions-Specific Apple Platform Implementation Matrix

| Ambitions object | Primary Apple frameworks | Secondary frameworks | Critical product law | Proof required |
|---|---|---|---|---|
| AmbitionsStage | SwiftUI | UIKit interop only if needed | one adaptive object stage, not tab app | root screenshots, dock behavior, route restoration |
| ContextCrown | SwiftUI, HIG materials | UIKit scroll interop if needed | seamless shell header, safe-area correct | scroll-edge screenshots, VoiceOver order |
| ContinuityDock | SwiftUI, Liquid Glass | Haptics | root-only dock, no duplicate nav shelf | root/drilldown screenshot matrix |
| Today / Reality Meridian | SwiftUI, Canvas, Accessibility | UserNotifications | live clock, Start Here, visible mutation | before/action/after screenshots |
| Goals / Constellation Atlas | SwiftUI, Canvas, Accessibility | App Intents | relational goal threads, not generic list | life area/thread/step screenshots |
| Time / LifeShape Field | SwiftUI, Canvas, BackgroundTasks | Calendar permission if used | capacity field, not calendar clone | day/week/month/list screenshots |
| Capture / Atmosphere Composer | SwiftUI, UIKit interop, Speech permission if used | Photos/Files/Vision later | global composer, keyboard-safe, no crash | keyboard/full-screen/permission screenshots |
| Closure | SwiftUI | App Intents, Notifications | fast outcomes, visible Today mutation | before/save/after/undo proof |
| Trust inspection | SwiftUI, LocalAuthentication | Keychain, CryptoKit | inspectable, not ambient audit console | detail route screenshots, auth states |
| You / User System Profile | SwiftUI, HIG Settings patterns | LocalAuthentication, AuthenticationServices | native settings/profile, actionable privacy | top-level and drilldown screenshots |
| Widgets | WidgetKit, App Intents | App Groups | redacted projections only | widget previews, privacy states |
| Live Activities | ActivityKit, WidgetKit, App Intents | Notifications | user-initiated active state only | start/update/end proof |
| Source Atlas refresh | BackgroundTasks, URLSession | R2/account entitlement | public/reference only, no private graph | network payload review, offline fallback |

---

# 18. Current Testing Evidence Integration

The current release testing evidence makes the platform priorities concrete. Codex should use Apple sources to repair these failures first:

## 18.1 P0 platform repairs

1. **Live time**
   - Apple areas: SwiftUI lifecycle, injected clock, scene phase, previews.
   - Ambitions files: `Core/Time/AmbitionsClock.swift`, `SystemClock.swift`, `PreviewClock.swift`, `TodayLens.swift`, `TimeLens.swift`.
   - Gate: production Now never comes from fixtures.

2. **Capture crash / keyboard layering**
   - Apple areas: SwiftUI overlay presentation, UIKit text interop, keyboard safe area, focus.
   - Ambitions files: `Composer/Capture/*`, `Interaction/KeyboardPolicy.swift`, `StageSafeAreaPolicy.swift`.
   - Gate: Capture opens, expands, and saves; root dock hidden or displaced; no crash.

3. **Duplicate nav shelf**
   - Apple areas: SwiftUI root presentation, NavigationStack, custom chrome discipline.
   - Ambitions files: `ContinuityDock.swift`, `StageChrome.swift`, `NativeChromePolicy.swift`.
   - Gate: no duplicate bottom chrome in screenshots.

4. **Closure no visible mutation**
   - Apple areas: SwiftUI state, Observation, accessibility announcements, haptics.
   - Ambitions files: `ClosureLens.swift`, `ClosureStageScene.swift`, `StageMutation.swift`, `MutationProof.swift`.
   - Gate: save closure visibly mutates Today and announces state change.

5. **Text wrapping / layout failure**
   - Apple areas: Dynamic Type, layout fundamentals, HIG typography/layout.
   - Ambitions files: `DynamicTypeAudit.swift`, `NativeSettingsRow.swift`, `LifeShapeFieldView.swift`.
   - Gate: no vertical letter wrapping at any supported Dynamic Type size.

6. **Runtime jargon in top-level UI**
   - Apple areas: HIG writing, navigation clarity, accessibility labels.
   - Ambitions files: `ForbiddenLanguageAudit.swift`, `SurfaceCopyPolicy.swift`, `UserFacingLanguage.swift`.
   - Gate: forbidden top-level language audit passes.

---

# 19. Explicit Out-of-Scope Apple Areas

These are iOS technologies, but they are not part of this atlas unless future canon approves them.

| Apple area | Status | Reason |
|---|---|---|
| Foundation Models / cloud model integrations | Out of core scope | Ambitions core cannot require hosted AI/cloud LLM. On-device model use would need separate canon and deterministic fallback. |
| Core AI / custom on-device ML | Future optional only | Could support local deterministic ranking later, but not needed for current P0/P1 repairs. |
| CloudKit private database sync | Not approved | Current canon does not approve user-owned sync or hosted private graph storage. |
| HealthKit | Not approved by default | Sensitive domain; requires explicit product law and permission purpose. |
| EventKit calendar write | Not approved by default | Calendar may inform fixed points; Ambitions must not become a calendar clone. |
| Third-party analytics/crash SDKs | Not approved by default | Diagnostics are Apple-first and user-respecting. |
| App Clips | Not relevant now | Capture must remain within core app unless future distribution strategy approves. |
| ARKit/RealityKit/Metal shaders | Not approved by default | Primitive approval boundary blocks decorative engines and one-off visual spectacle. |

---

# 20. Codex Source-Use Checklist

Before implementing any Apple-platform capability, Codex must answer:

```text
1. Which Ambitions product object owns this capability?
2. Which Apple framework is the primary source?
3. Which Apple doc/sample was inspected?
4. Is the API available on iOS 26?
5. If not, where is the iOS 26 fallback?
6. Does this preserve Today / Goals / Time / You as the only persistent surfaces?
7. Does this preserve Capture as composer/overlay?
8. Does this preserve Motion as behavior, not destination?
9. Does this preserve offline core value with no account?
10. Does this avoid uploading the private life graph?
11. Does this avoid raw runtime jargon in primary UI?
12. Does this provide accessibility semantics?
13. Does this provide Reduce Motion and Reduce Transparency behavior?
14. Does this create proof/receipt behavior for meaningful changes?
15. What screenshots/tests prove it?
```

---

# 21. Recommended Repo Additions

Create or preserve these platform documentation files:

```text
docs/platform/
  APPLE_PLATFORM_SOURCE_ATLAS_IOS.md
  APPLE_API_AVAILABILITY_MATRIX.md
  APPLE_DESIGN_RESOURCE_USAGE.md
  IOS_PERMISSION_PURPOSE_COPY.md
  PRIVACY_MANIFEST_SOURCE_OF_TRUTH.md
  APP_INTENTS_PRIVACY_POLICY.md
  WIDGET_LIVE_ACTIVITY_POLICY.md
  BACKGROUND_TASK_POLICY.md
```

Create or preserve these implementation support files:

```text
Core/Time/
  AmbitionsClock.swift
  SystemClock.swift
  PreviewClock.swift
  TimeZoneProvider.swift
  DayBoundaryScheduler.swift
  RuntimeTickPolicy.swift

Core/Persistence/
  StoreHealthCheck.swift
  SwiftDataModels/
  Repositories/
  Migrations/

Core/LocalRuntimeOS/Storage/
  ObjectStoreSwiftData.swift
  EventStoreSQLite.swift
  ProjectionStoreSQLite.swift
  SearchStoreFTS.swift

Core/Permissions/
  PermissionCoordinator.swift
  CalendarPermission.swift
  SpeechPermission.swift
  NotificationPermission.swift
  LocalAuthenticationPolicy.swift

Core/Background/
  BackgroundTaskCoordinator.swift
  BackgroundTaskIdentifier.swift
  SourceAtlasRefreshTask.swift
  StoreMaintenanceTask.swift
  WidgetSnapshotRefreshTask.swift
  NotificationReconciliationTask.swift

Core/Notifications/
  NotificationScheduler.swift
  NotificationActionRouter.swift
  NotificationRequestFactory.swift

Packages/AmbitionsIntents/
  Sources/AmbitionsIntents/

Quality/
  ShellChromeAudit.swift
  ForbiddenLanguageAudit.swift
  SafeAreaAudit.swift
  DynamicTypeAudit.swift
  MotionReductionAudit.swift
  VisualRegressionHarness.swift
  RealDeviceRenderChecklist.swift
```

---

# 22. Green Definition for This Atlas

A Codex implementation using this atlas is Green only when:

- official Apple sources were inspected for touched APIs
- iOS 26 availability is preserved or availability-gated
- Today / Goals / Time / You remain the only persistent surfaces
- Capture remains global composer/overlay
- Motion remains behavior layer
- private life graph remains local by default
- no R2/private data violation is introduced
- no hosted AI/cloud LLM dependency is introduced
- SwiftUI root stage is preserved
- UIKit interop is justified and contained
- SwiftData persistence has migrations/tests
- App Intents route through runtime validation
- widgets/Live Activities use redacted projections
- notifications are contextual and non-shaming
- BackgroundTasks cannot make hidden plan mutations
- LocalAuthentication protects sensitive actions without blocking core use
- accessibility audits pass
- HIG material/layout/type/motion expectations are respected
- screenshots and proof artifacts exist

This atlas is a source map and implementation contract. It is not proof that implementation exists.
