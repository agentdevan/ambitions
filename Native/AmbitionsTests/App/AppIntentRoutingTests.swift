import XCTest
@testable import Ambitions

final class AppIntentRoutingTests: XCTestCase {
    func testShortcutDestinationsStayBoundedToCanonicalNavigationRoutes() {
        XCTAssertEqual(Set(AmbitionsAppShortcutDestination.allCases), [
            .today,
            .time,
            .captureInbox,
            .command,
            .memoryLens,
            .quickCapture,
            .startNextStep,
            .markDone,
            .saveTheDay,
            .quickRecovery,
            .quickFocus,
            .quickTimePatch,
        ])
    }

    func testShortcutDestinationsUseCanonicalRouteURLs() {
        XCTAssertEqual(AmbitionsAppShortcutDestination.today.routeURL?.absoluteString, "ambitions://tab/today?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.time.routeURL?.absoluteString, "ambitions://tab/time?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.captureInbox.routeURL?.absoluteString, "ambitions://captures/inbox?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.command.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.memoryLens.routeURL?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickCapture.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.startNextStep.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.markDone.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.saveTheDay.routeURL?.absoluteString, "ambitions://tab/today?context=recovery&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickRecovery.routeURL?.absoluteString, "ambitions://tab/today?context=recovery&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickFocus.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickTimePatch.routeURL?.absoluteString, "ambitions://tab/time?origin=app_intent")
    }

    func testD25ShortcutCommandDescriptorsUseContractPrivacyAndConfirmationBoundaries() {
        let descriptors = Dictionary(
            uniqueKeysWithValues: AmbitionsAppShortcutDestination.allCases.map { ($0, $0.d25CommandDescriptor) }
        )

        XCTAssertEqual(descriptors[.quickCapture]?.commandKind, .quickCapture)
        XCTAssertEqual(descriptors[.quickCapture]?.executionPosture, .queuesLocalCapture)
        XCTAssertEqual(descriptors[.quickCapture]?.producesReceipt, true)
        XCTAssertEqual(descriptors[.startNextStep]?.commandKind, .startStepSession)
        XCTAssertEqual(descriptors[.markDone]?.commandKind, .completeAction)
        XCTAssertEqual(descriptors[.markDone]?.requiresConfirmation, true)
        XCTAssertEqual(descriptors[.markDone]?.producesReceipt, true)
        XCTAssertEqual(descriptors[.saveTheDay]?.commandKind, .recoverAction)
        XCTAssertEqual(descriptors[.saveTheDay]?.requiresConfirmation, true)
        XCTAssertEqual(descriptors[.saveTheDay]?.producesReceipt, true)
        XCTAssertEqual(descriptors[.time]?.commandKind, .openDestination)

        for descriptor in descriptors.values {
            XCTAssertEqual(descriptor.contractKind, .appIntents)
            XCTAssertEqual(descriptor.privacySummary, "Details stay private until you open Ambitions.")
            XCTAssertFalse(descriptor.dialog.localizedCaseInsensitiveContains("AI"))
            XCTAssertFalse(descriptor.dialog.localizedCaseInsensitiveContains("confidence"))
            XCTAssertFalse(descriptor.privacySummary.localizedCaseInsensitiveContains("travel radius"))
            XCTAssertFalse(descriptor.privacySummary.localizedCaseInsensitiveContains("injury"))
            XCTAssertFalse(descriptor.dialog.localizedCaseInsensitiveContains("eligibility"))
        }
    }

    func testD25ShortcutsExposeCanonCommandSetWithoutSilentDestructiveActions() {
        let activeShortcutDestinations: Set<AmbitionsAppShortcutDestination> = [
            .quickCapture,
            .startNextStep,
            .markDone,
            .saveTheDay,
            .time,
        ]
        let descriptors = activeShortcutDestinations.map(\.d25CommandDescriptor)

        XCTAssertEqual(
            Set(descriptors.map(\.title)),
            ["Start here", "Capture", "Make today doable", "Close the loop", "Time"]
        )
        XCTAssertTrue(descriptors.filter(\.requiresConfirmation).allSatisfy { descriptor in
            descriptor.commandKind == .completeAction || descriptor.commandKind == .recoverAction
        })
    }

    func testPFC18PublicLaunchCandidatesExcludeCompatibilityDestinations() {
        let publicCandidates = Set(
            AmbitionsAppShortcutDestination.allCases.filter(\.isPFC18PublicLaunchCandidate)
        )

        XCTAssertEqual(
            publicCandidates,
            [
                .today,
                .time,
                .captureInbox,
                .command,
                .memoryLens,
                .startNextStep,
                .markDone,
                .saveTheDay,
            ]
        )
        XCTAssertFalse(publicCandidates.contains(.quickCapture))
        XCTAssertFalse(publicCandidates.contains(.quickFocus))
        XCTAssertFalse(publicCandidates.contains(.quickRecovery))
        XCTAssertFalse(publicCandidates.contains(.quickTimePatch))
    }

    func testPFC18CaptureIntentBuildsLocalReviewRequestWithoutEchoingDialogText() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))

        let request = try CreateAmbitionsCaptureIntent.makeCaptureRequest(
            text: "  Private appointment note  ",
            now: now,
            id: "intent-test"
        )

        XCTAssertEqual(request.id, "intent-test")
        XCTAssertEqual(request.createdAt, "2026-04-15T12:00:00Z")
        XCTAssertEqual(request.text, "Private appointment note")
        XCTAssertEqual(request.source, .appIntent)
        XCTAssertEqual(request.landing, .captureInbox)
        XCTAssertThrowsError(
            try CreateAmbitionsCaptureIntent.makeCaptureRequest(text: "  ", now: now, id: "empty")
        )
    }

    func testPFC18MutationCapableShortcutsRequireInAppConfirmationAndReceipts() {
        let descriptors = AmbitionsAppShortcutDestination.allCases.map(\.d25CommandDescriptor)
        let mutationDescriptors = descriptors.filter { descriptor in
            descriptor.commandKind == .completeAction || descriptor.commandKind == .recoverAction
        }

        XCTAssertEqual(Set(mutationDescriptors.map(\.destination)), [.markDone, .saveTheDay, .quickRecovery])
        XCTAssertTrue(mutationDescriptors.allSatisfy(\.requiresConfirmation))
        XCTAssertTrue(mutationDescriptors.allSatisfy(\.producesReceipt))
        XCTAssertTrue(mutationDescriptors.allSatisfy { descriptor in
            descriptor.routeURL?.absoluteString.contains("origin=app_intent") == true
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
