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
            } else if variant == .r13TimeTransferEvaluation {
                TodayFlagshipTimeTransferEvaluationView(
                    content: variant.content,
                    onCancel: {}
                )
            } else {
                TodayFlagshipCalibrationHost(variant: variant)
            }
        }
        .preferredColorScheme(variant.colorScheme)
        .dynamicTypeSize(variant.dynamicTypeSize)
        .environment(\.locale, Locale(identifier: variant.localeIdentifier))
        .environment(\.layoutDirection, variant.rightToLeft ? .rightToLeft : .leftToRight)
        .environment(
            \._accessibilityDifferentiateWithoutColor,
            variant.differentiateWithoutColor
        )
        .environment(\._accessibilityReduceMotion, variant.reduceMotion)
        .environment(\._accessibilityReduceTransparency, variant.reduceTransparency)
    }
}

private struct TodayFlagshipCalibrationHost: View {
    @State private var state: TodayFlagshipJourneyState

    let variant: FoundryVariant
    let content: TodayFlagshipCalibrationContent

    init(variant: FoundryVariant) {
        self.variant = variant
        content = variant.content
        var initialState = TodayFlagshipJourneyState.preview(
            content: variant.content,
            phase: variant.initialPhase
        )
        if variant.fullDayOrigin != nil {
            _ = initialState.openFullDay()
        }
        if variant == .b02SettlementHistory {
            _ = initialState.openHistory()
        }
        if let supportingRoute = variant.supportingRoute {
            _ = initialState.openSupportingRoute(supportingRoute)
        }
        _state = State(
            initialValue: initialState
        )
    }

    var body: some View {
        TodayFlagshipCalibrationView(
            content: content,
            state: $state,
            initialDockExpanded: variant.dockExpanded,
            onCommitProposal: {
                try? await Task.sleep(for: .milliseconds(2_400))
                return variant.commitShouldSucceed
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
    case b02RootLight = "b02-root-light"
    case b02RootDark = "b02-root-dark"
    case b02RootCompact = "b02-root-compact"
    case b02RootProMax = "b02-root-pro-max"
    case b02RootAccessibility5 = "b02-root-accessibility5"
    case b02RootRTL = "b02-root-rtl"
    case b02RootLongLTR = "b02-root-long-ltr"
    case b02FullDayTypical = "b02-full-day-typical"
    case b02FullDayReturned = "b02-full-day-returned"
    case b02FullDayDense = "b02-full-day-dense"
    case b02FullDayRTL = "b02-full-day-rtl"
    case b02FullDayCompact = "b02-full-day-compact"
    case b02FullDayAccessibility5 = "b02-full-day-accessibility5"
    case b02FocusedTypical = "b02-focused-typical"
    case b02FocusedDense = "b02-focused-dense"
    case b02FocusedAccessibility5 = "b02-focused-accessibility5"
    case b02FocusedRTL = "b02-focused-rtl"
    case b02FocusedContrast = "b02-focused-contrast"
    case b02FocusedLongLTR = "b02-focused-long-ltr"
    case b02ReviewTypical = "b02-review-typical"
    case b02ReviewAccessibility5 = "b02-review-accessibility5"
    case b02ReviewContrast = "b02-review-contrast"
    case b02ReviewNoColor = "b02-review-no-color"
    case b02RootReduceTransparency = "b02-root-reduce-transparency"
    case b02ReviewReduceMotion = "b02-review-reduce-motion"
    case b02ReviewRTL = "b02-review-rtl"
    case b02ReviewSaving = "b02-review-saving"
    case b02ReviewSavingRTL = "b02-review-saving-rtl"
    case r13ReviewTypical = "r13-review-typical"
    case r13ReviewSaving = "r13-review-saving"
    case r13ReviewFailed = "r13-review-failed"
    case r13ReviewFailureCallback = "r13-review-failure-callback"
    case r13ReviewIncreasedContrast = "r13-review-increased-contrast"
    case r13ReviewNoColor = "r13-review-differentiate-without-color"
    case r13ReviewReduceMotion = "r13-review-reduce-motion"
    case r13ReviewAccessibility5 = "r13-review-accessibility5"
    case r13FullDayTypical = "r13-full-day-typical"
    case r13FullDayReturned = "r13-full-day-returned"
    case r13FullDayDense = "r13-full-day-dense"
    case r13FullDayCompact = "r13-full-day-compact"
    case r13FullDayAccessibility5 = "r13-full-day-accessibility5"
    case r13RecoveryInterrupted = "r13-recovery-interrupted"
    case r13RecoverySheet = "r13-recovery-sheet"
    case r13RecoveryContinued = "r13-recovery-continued"
    case r13RecoveryAccessibility5 = "r13-recovery-accessibility5"
    case r13RecoveryLongEnglish = "r13-recovery-long-english"
    case r13RecoveryReduceMotion = "r13-recovery-reduce-motion"
    case r13GoalDetail = "r13-goal-detail"
    case r13ConsequenceDetails = "r13-consequence-details"
    case r13HistoryEntry = "r13-history-entry"
    case r13HistoryFilters = "r13-history-filters"
    case r13TimeTransferEvaluation = "r13-time-transfer-evaluation"
    case b02SettlementTypical = "b02-settlement-typical"
    case b02SettlementHistory = "b02-settlement-history"
    case b02SettlementLowBrightness = "b02-settlement-low-brightness"
    case b02SettlementCompact = "b02-settlement-compact"
    case b02SettlementProMax = "b02-settlement-pro-max"
    case b02SettlementRTL = "b02-settlement-rtl"
    case b02ReturnedTypical = "b02-returned-typical"
    case b02ReturnedRTL = "b02-returned-rtl"
    case b02RecoveryTypical = "b02-recovery-typical"
    case b02RecoveryInterrupted = "b02-recovery-interrupted"
    case b02RecoveryContinued = "b02-recovery-continued"
    case b02RecoveryRTL = "b02-recovery-rtl"
    case b02QuietToday = "b02-quiet-today"
    case b02VeryDenseToday = "b02-very-dense-today"
    case b02OfflineLocal = "b02-offline-local"
    case b02StaleExternal = "b02-stale-external"
    case b02ConflictTransfer = "b02-conflict-transfer"
    case b02MotionNormal = "b02-motion-normal"
    case b02MotionReduceMotion = "b02-motion-reduce-motion"

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
        self == .typicalLight || self == .tfcsF01 || self == .b02RootLight ? .light : .dark
    }

    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .accessibilityDark, .tfcsF05, .reviewAccessibility,
                .journeyAccessibility, .journeyAccessibilityManual:
            .accessibility1
        case .b02FullDayAccessibility5, .b02FocusedAccessibility5,
                .b02ReviewAccessibility5, .b02RootAccessibility5,
                .r13ReviewAccessibility5, .r13FullDayAccessibility5:
            .accessibility5
        case .r13RecoveryAccessibility5:
            .accessibility5
        default:
            .large
        }
    }

    var initialPhase: TodayFlagshipJourneyPhase {
        switch self {
        case .tfcsF06, .stateCancelled, .stressLongRTL, .r13GoalDetail,
                .b02FocusedTypical, .b02FocusedDense, .b02FocusedAccessibility5,
                .b02FocusedRTL, .b02FocusedContrast, .b02FocusedLongLTR:
            .focusedCurrent
        case .tfcsF07, .stressContrast, .reviewAccessibility,
                .b02ReviewTypical, .b02ReviewAccessibility5,
                .b02ReviewContrast, .b02ReviewNoColor,
                .b02ReviewReduceMotion, .b02ReviewRTL,
                .r13ReviewTypical, .r13ReviewFailureCallback,
                .r13ReviewIncreasedContrast, .r13ReviewNoColor,
                .r13ReviewReduceMotion, .r13ReviewAccessibility5,
                .r13ConsequenceDetails:
            .reviewingProposal
        case .r13ReviewFailed:
            .failedSettlement
        case .tfcsF08, .b02SettlementTypical, .b02SettlementHistory,
                .b02SettlementLowBrightness, .b02SettlementCompact,
                .b02SettlementProMax, .b02SettlementRTL,
                .r13HistoryEntry, .r13HistoryFilters:
            .settled
        case .tfcsF09, .b02ReturnedTypical, .b02ReturnedRTL, .b02FullDayReturned,
                .r13FullDayReturned:
            .todayReturned
        case .tfcsF10, .b02RecoveryTypical, .b02RecoveryRTL,
                .r13RecoverySheet, .r13RecoveryAccessibility5,
                .r13RecoveryLongEnglish, .r13RecoveryReduceMotion:
            .recoveryReview
        case .stateInterrupted, .b02RecoveryInterrupted, .r13RecoveryInterrupted:
            .interrupted
        case .b02RecoveryContinued, .r13RecoveryContinued:
            .recoveredContinuation
        case .stateSaving, .b02ReviewSaving, .b02ReviewSavingRTL,
                .r13ReviewSaving:
            .savingAcceptedTruth
        default:
            .todayInitial
        }
    }

    var content: TodayFlagshipCalibrationContent {
        switch self {
        case .tfcsF03, .stateDense, .b02FullDayDense, .b02FocusedDense,
                .r13FullDayDense:
            TodayFlagshipCalibrationFixture.preparingForBaby.denseToday
        case .stressLongRTL, .b02FullDayRTL, .b02FocusedRTL, .b02ReviewRTL,
                .b02ReviewSavingRTL, .b02RootRTL, .b02SettlementRTL,
                .b02ReturnedRTL, .b02RecoveryRTL:
            TodayFlagshipCalibrationFixture.preparingForBaby.arabicSaudiEvaluation
        case .b02FocusedLongLTR, .b02RootLongLTR, .r13RecoveryLongEnglish:
            TodayFlagshipCalibrationFixture.preparingForBaby.longContent
        case .b02QuietToday:
            TodayFlagshipCalibrationFixture.preparingForBaby.quietToday
        case .b02VeryDenseToday:
            TodayFlagshipCalibrationFixture.preparingForBaby.veryDenseToday
        case .b02OfflineLocal:
            TodayFlagshipCalibrationFixture.preparingForBaby.offlineLocalTruth
        case .b02StaleExternal:
            TodayFlagshipCalibrationFixture.preparingForBaby.staleExternalContext
        case .b02ConflictTransfer:
            TodayFlagshipCalibrationFixture.preparingForBaby.conflictTransfer
        default:
            TodayFlagshipCalibrationFixture.preparingForBaby
        }
    }

    var dockExpanded: Bool { self == .tfcsF04 }

    var rightToLeft: Bool {
        self == .stressLongRTL || self == .b02FullDayRTL
            || self == .b02FocusedRTL || self == .b02ReviewRTL
            || self == .b02ReviewSavingRTL || self == .b02RootRTL
            || self == .b02SettlementRTL || self == .b02ReturnedRTL
            || self == .b02RecoveryRTL
    }

    var localeIdentifier: String {
        rightToLeft ? "ar-SA" : "en-US"
    }

    var differentiateWithoutColor: Bool {
        self == .b02ReviewNoColor || self == .r13ReviewNoColor
    }

    var reduceMotion: Bool {
        self == .b02ReviewReduceMotion || self == .b02MotionReduceMotion
            || self == .r13ReviewReduceMotion || self == .r13RecoveryReduceMotion
    }

    var reduceTransparency: Bool {
        self == .b02RootReduceTransparency
    }

    var fullDayOrigin: TodayFlagshipFullDayOrigin? {
        switch self {
        case .b02FullDayReturned, .r13FullDayReturned:
            .todayReturned
        case .b02FullDayTypical, .b02FullDayDense, .b02FullDayRTL,
                .b02FullDayCompact, .b02FullDayAccessibility5,
                .r13FullDayTypical, .r13FullDayDense, .r13FullDayCompact,
                .r13FullDayAccessibility5:
            .todayInitial
        default:
            nil
        }
    }

    var demoJourney: FoundryDemoJourney {
        switch self {
        case .journeySuccessful:
            .successful
        case .b02MotionNormal, .b02MotionReduceMotion:
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

    var commitShouldSucceed: Bool {
        self != .r13ReviewFailureCallback
    }

    var supportingRoute: TodayFlagshipSupportingRoute? {
        switch self {
        case .r13GoalDetail:
            .goalDetail
        case .r13ConsequenceDetails:
            .consequenceDetails
        case .r13HistoryEntry:
            .historyEntry
        case .r13HistoryFilters:
            .historyFilters
        default:
            nil
        }
    }
}
