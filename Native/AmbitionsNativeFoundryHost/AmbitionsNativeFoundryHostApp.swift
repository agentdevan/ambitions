import AmbitionsNativeVisualFoundry
import SwiftUI

@main
struct AmbitionsNativeFoundryHostApp: App {
    var body: some Scene {
        WindowGroup {
            FoundryHostRoot(variant: .fromProcessArguments)
        }
    }
}

private struct FoundryHostRoot: View {
    let variant: FoundryVariant

    var body: some View {
        Group {
            if variant.usesBootstrap {
                TodayBootstrapView(
                    content: TodayBootstrapFixture.preparingForBaby,
                    onOpenStep: {},
                    onOpenDock: {}
                )
            } else {
                TodayFlagshipCalibrationHost(variant: variant)
            }
        }
        .preferredColorScheme(variant.colorScheme)
        .dynamicTypeSize(variant.dynamicTypeSize)
        .environment(\.locale, Locale(identifier: variant.localeIdentifier))
        .environment(\.layoutDirection, variant.rightToLeft ? .rightToLeft : .leftToRight)
    }
}

private struct TodayFlagshipCalibrationHost: View {
    @State private var state: TodayFlagshipJourneyState

    let variant: FoundryVariant
    let content: TodayFlagshipCalibrationContent

    init(variant: FoundryVariant) {
        self.variant = variant
        content = variant.content
        _state = State(
            initialValue: TodayFlagshipJourneyState.preview(
                content: variant.content,
                phase: variant.initialPhase
            )
        )
    }

    var body: some View {
        TodayFlagshipCalibrationView(
            content: content,
            state: $state,
            initialDockExpanded: variant.dockExpanded,
            onCommitProposal: {
                try? await Task.sleep(for: .milliseconds(2_400))
                return true
            }
        )
        .task {
            await playJourneyIfRequested()
        }
    }

    @MainActor
    private func playJourneyIfRequested() async {
        switch variant.demoJourney {
        case .none:
            return
        case .successful, .accessibility:
            await pause(2_200)
            _ = state.openStartHere()
            await pause(2_000)
            _ = state.selectStillCounts()
            await pause(2_400)
            _ = state.beginCommit()
            await pause(2_000)
            _ = state.settle()
            await pause(1_600)
            _ = state.openHistory()
            await pause(1_800)
            _ = state.closeHistory()
            await pause(900)
            _ = state.returnToToday()
            await pause(3_000)
        case .interrupted:
            await pause(2_200)
            _ = state.openStartHere()
            await pause(2_000)
            _ = state.interrupt()
            await pause(2_400)
            _ = state.openRecoveryReview()
            await pause(2_600)
            _ = state.continueFromSavedProgress()
            await pause(3_000)
        case .interruptedAwaitingReview:
            await pause(4_000)
            _ = state.openStartHere()
            await pause(3_000)
            _ = state.interrupt()
        }
    }

    @MainActor
    private func pause(_ milliseconds: Int) async {
        try? await Task.sleep(for: .milliseconds(milliseconds))
    }
}

private enum FoundryDemoJourney {
    case none
    case successful
    case interrupted
    case interruptedAwaitingReview
    case accessibility
}

private enum FoundryVariant: String {
    case typicalLight = "typical-light"
    case typicalDark = "typical-dark"
    case accessibilityDark = "accessibility-dark"
    case tfcsF01 = "tfcs-f01"
    case tfcsF02 = "tfcs-f02"
    case tfcsF03 = "tfcs-f03"
    case tfcsF04 = "tfcs-f04"
    case tfcsF05 = "tfcs-f05"
    case tfcsF06 = "tfcs-f06"
    case tfcsF07 = "tfcs-f07"
    case tfcsF08 = "tfcs-f08"
    case tfcsF09 = "tfcs-f09"
    case tfcsF10 = "tfcs-f10"
    case stateSaving = "tfcs-state-saving"
    case stateCancelled = "tfcs-state-cancelled"
    case stateInterrupted = "tfcs-state-interrupted"
    case stateDense = "tfcs-state-dense"
    case stressLongRTL = "tfcs-stress-long-rtl"
    case stressContrast = "tfcs-stress-contrast"
    case reviewAccessibility = "tfcs-review-accessibility"
    case journeySuccessful = "tfcs-j01"
    case journeyInterrupted = "tfcs-j02"
    case journeyAccessibility = "tfcs-j03"
    case journeyInterruptedManual = "tfcs-j02-manual"
    case journeyAccessibilityManual = "tfcs-j03-manual"

    static var fromProcessArguments: FoundryVariant {
        let arguments = ProcessInfo.processInfo.arguments
        for flag in ["-FoundryVariant", "-FoundryJourney"] {
            guard
                let flagIndex = arguments.firstIndex(of: flag),
                arguments.indices.contains(flagIndex + 1),
                let variant = FoundryVariant(rawValue: arguments[flagIndex + 1])
            else {
                continue
            }
            return variant
        }
        return .tfcsF01
    }

    var usesBootstrap: Bool {
        self == .typicalLight || self == .typicalDark || self == .accessibilityDark
    }

    var colorScheme: ColorScheme {
        self == .typicalLight || self == .tfcsF01 ? .light : .dark
    }

    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .accessibilityDark, .tfcsF05, .reviewAccessibility,
                .journeyAccessibility, .journeyAccessibilityManual:
            .accessibility1
        default:
            .large
        }
    }

    var initialPhase: TodayFlagshipJourneyPhase {
        switch self {
        case .tfcsF06, .stateCancelled, .stressLongRTL:
            .focusedCurrent
        case .tfcsF07, .stressContrast, .reviewAccessibility:
            .reviewingProposal
        case .tfcsF08:
            .settled
        case .tfcsF09:
            .todayReturned
        case .tfcsF10:
            .recoveryReview
        case .stateInterrupted:
            .interrupted
        case .stateSaving:
            .savingAcceptedTruth
        default:
            .todayInitial
        }
    }

    var content: TodayFlagshipCalibrationContent {
        switch self {
        case .tfcsF03, .stateDense:
            TodayFlagshipCalibrationFixture.preparingForBaby.denseToday
        case .stressLongRTL:
            TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation
        default:
            TodayFlagshipCalibrationFixture.preparingForBaby
        }
    }

    var dockExpanded: Bool { self == .tfcsF04 }

    var rightToLeft: Bool { self == .stressLongRTL }

    var localeIdentifier: String {
        self == .stressLongRTL ? "ar-SA" : "en-US"
    }

    var demoJourney: FoundryDemoJourney {
        switch self {
        case .journeySuccessful:
            .successful
        case .journeyInterrupted:
            .interrupted
        case .journeyInterruptedManual:
            .interruptedAwaitingReview
        case .journeyAccessibility:
            .accessibility
        default:
            .none
        }
    }
}
