import XCTest
@testable import Ambitions

@MainActor
final class CommandSearchObviousnessGauntletTests: XCTestCase {
    func testCommandSheetRecordsThreeHundredPlusDeterministicScenariosWithCanonicalLabels() {
        let intents: [ShellCommandIntent?] = [nil] + ShellCommandIntent.allCases.map(Optional.some)
        let sources: [ShellCommandEntrySource] = [
            .shellCompose,
            .shellUtility,
            .goalsCreate,
            .todayQuickCapture,
            .globalCaptureComposer,
            .deepLink,
            .appIntent,
            .notification,
            .widget,
            .shareExtension,
            .external
        ]
        let contexts: [ShellCommandPresentationContext] = [
            .neutral,
            .quickCapture,
            .createGoal,
            .recall,
            .recovery,
            .focus,
            .time
        ]

        XCTAssertGreaterThanOrEqual(intents.count * sources.count * contexts.count, 300)

        for intent in intents {
            for source in sources {
                for context in contexts {
                    let navigation = AppNavigationModel(selectedTab: .today)

                    navigation.presentCommandSheet(
                        intent: intent,
                        source: source,
                        presentationContext: context
                    )

                    let expectedTitle = intent?.title ?? "Add something"
                    XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
                    XCTAssertEqual(navigation.activeOverlay?.intent, intent)
                    XCTAssertEqual(navigation.activeOverlay?.entrySource, source)
                    XCTAssertEqual(navigation.activeOverlay?.presentationContext, context)
                    XCTAssertEqual(navigation.recentCommandHistory.first?.title, expectedTitle)
                    XCTAssertEqual(
                        navigation.recentCommandHistory.first?.subtitle,
                        expectedHistorySubtitle(for: context)
                    )
                    XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Add something")
                    XCTAssertEqual(navigation.recentCommandHistory.first?.source, source)
                    XCTAssertEqual(navigation.recentCommandHistory.first?.presentationContext, context)
                    XCTAssertFalse(expectedTitle.localizedCaseInsensitiveContains("chat"))
                    XCTAssertFalse(expectedTitle.localizedCaseInsensitiveContains("assistant"))
                    XCTAssertFalse(expectedTitle.localizedCaseInsensitiveContains("dashboard"))
                }
            }
        }
    }

    func testMemoryLensAndSearchCopyStayLocalFirstAndInspectablyNamed() {
        let navigation = AppNavigationModel(selectedTab: .time)

        navigation.presentMemoryLens(
            intent: .memoryLens,
            source: .shellUtility,
            presentationContext: .recall,
            query: "why now",
            goalID: nil,
            captureID: nil
        )

        XCTAssertEqual(ShellCommandIntent.memoryLens.title, "Search Ambitions")
        XCTAssertEqual(ShellCommandIntent.memoryLens.subtitle, "Search goals, captures, steps, settings, and recent changes.")
        XCTAssertEqual(
            ShellCommandIntent.openCapture.subtitle,
            "Open Capture."
        )
        XCTAssertEqual(navigation.activeOverlay?.kind, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.intent, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .shellUtility)
        XCTAssertEqual(navigation.activeOverlay?.presentationContext, .recall)
        XCTAssertEqual(navigation.recentCommandHistory.first?.title, "Search Ambitions")
        XCTAssertEqual(navigation.recentCommandHistory.first?.subtitle, "Looked up \"why now\".")
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Search Ambitions")
        XCTAssertTrue(
            ShellCommandIntent.memoryLens.externalBrainCommandContract.safetySummary.localizedCaseInsensitiveContains("source-grounded")
        )
        XCTAssertTrue(
            ShellCommandIntent.memoryLens.externalBrainCommandContract.isSafeForExternalBrainCommandSurface
        )
    }

    private func expectedHistorySubtitle(for context: ShellCommandPresentationContext) -> String {
        switch context {
        case .neutral:
            "Opened from Add something."
        case .quickCapture:
            "Saved without leaving the global quick action surface."
        case .createGoal:
            "Started from the goal setup path."
        case .recall:
            "Opened what Ambitions knows without showing raw history."
        case .recovery:
            "Returned to a calmer recovery posture."
        case .focus:
            "Returned to the current step session posture."
        case .time:
            "Opened the week-shaping context."
        }
    }
}
