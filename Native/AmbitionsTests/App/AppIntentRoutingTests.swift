import XCTest
@testable import Ambitions

final class AppIntentRoutingTests: XCTestCase {
    func testShortcutDestinationsStayBoundedToCanonicalNavigationRoutes() {
        XCTAssertEqual(Set(AmbitionsAppShortcutDestination.allCases), [
            .today,
            .plan,
            .capturesInbox,
            .command,
            .memoryLens,
            .quickCapture,
            .startNextStep,
            .markDone,
            .saveTheDay,
            .quickRecovery,
            .quickFocus,
            .quickPlanPatch,
        ])
    }

    func testShortcutDestinationsUseCanonicalRouteURLs() {
        XCTAssertEqual(AmbitionsAppShortcutDestination.today.routeURL?.absoluteString, "ambitions://tab/today?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.plan.routeURL?.absoluteString, "ambitions://tab/plan?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.capturesInbox.routeURL?.absoluteString, "ambitions://captures/inbox?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.command.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.memoryLens.routeURL?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickCapture.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.startNextStep.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.markDone.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.saveTheDay.routeURL?.absoluteString, "ambitions://tab/today?context=recovery&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickRecovery.routeURL?.absoluteString, "ambitions://tab/today?context=recovery&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickFocus.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickPlanPatch.routeURL?.absoluteString, "ambitions://tab/plan?origin=app_intent")
    }

    func testD25ShortcutCommandDescriptorsUseContractPrivacyAndConfirmationBoundaries() {
        let descriptors = Dictionary(
            uniqueKeysWithValues: AmbitionsAppShortcutDestination.allCases.map { ($0, $0.d25CommandDescriptor) }
        )

        XCTAssertEqual(descriptors[.quickCapture]?.commandKind, .quickCapture)
        XCTAssertEqual(descriptors[.quickCapture]?.executionPosture, .queuesLocalCapture)
        XCTAssertEqual(descriptors[.quickCapture]?.producesReceipt, true)
        XCTAssertEqual(descriptors[.startNextStep]?.commandKind, .startFocus)
        XCTAssertEqual(descriptors[.markDone]?.commandKind, .completeAction)
        XCTAssertEqual(descriptors[.markDone]?.requiresConfirmation, true)
        XCTAssertEqual(descriptors[.markDone]?.producesReceipt, true)
        XCTAssertEqual(descriptors[.saveTheDay]?.commandKind, .recoverAction)
        XCTAssertEqual(descriptors[.saveTheDay]?.requiresConfirmation, true)
        XCTAssertEqual(descriptors[.saveTheDay]?.producesReceipt, true)
        XCTAssertEqual(descriptors[.plan]?.commandKind, .openDestination)

        for descriptor in descriptors.values {
            XCTAssertEqual(descriptor.contractKind, .appIntents)
            XCTAssertEqual(descriptor.privacySummary, "Details stay private until you open Ambitions.")
            XCTAssertFalse(descriptor.dialog.localizedCaseInsensitiveContains("AI"))
            XCTAssertFalse(descriptor.dialog.localizedCaseInsensitiveContains("confidence"))
        }
    }

    func testD25ShortcutsExposeCanonCommandSetWithoutSilentDestructiveActions() {
        let activeShortcutDestinations: Set<AmbitionsAppShortcutDestination> = [
            .quickCapture,
            .startNextStep,
            .markDone,
            .saveTheDay,
            .plan,
        ]
        let descriptors = activeShortcutDestinations.map(\.d25CommandDescriptor)

        XCTAssertEqual(Set(descriptors.map(\.title)), ["Capture", "Start Next Step", "Mark Done", "Save the Day", "Plan"])
        XCTAssertTrue(descriptors.filter(\.requiresConfirmation).allSatisfy { descriptor in
            descriptor.commandKind == .completeAction || descriptor.commandKind == .recoverAction
        })
    }

    @MainActor
    func testIntentLaunchRouterQueuesAndConsumesOnePendingURL() throws {
        let router = AppIntentLaunchRouter.shared
        let url = try XCTUnwrap(URL(string: "ambitions://tab/plan"))

        router.queue(url)

        XCTAssertEqual(router.consumePendingURL(), url)
        XCTAssertNil(router.consumePendingURL())
    }
}
