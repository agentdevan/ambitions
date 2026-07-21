import XCTest
@testable import Ambitions

final class AppIntentRoutingTests: XCTestCase {
    func testShortcutDestinationsStayBoundedToCanonicalNavigationRoutes() {
        XCTAssertEqual(Set(AmbitionsAppShortcutDestination.allCases), [
            .today,
            .goals,
            .time,
            .capture,
            .you,
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
        XCTAssertEqual(AmbitionsAppShortcutDestination.goals.routeURL?.absoluteString, "ambitions://tab/goals?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.time.routeURL?.absoluteString, "ambitions://tab/time?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.capture.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.you.routeURL?.absoluteString, "ambitions://tab/you?origin=app_intent")
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
        XCTAssertEqual(descriptors[.goals]?.commandKind, .openDestination)
        XCTAssertEqual(descriptors[.you]?.commandKind, .openDestination)
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

    func testPFC18PublicLaunchCandidatesExcludeInternalQuickActions() {
        let publicCandidates = Set(
            AmbitionsAppShortcutDestination.allCases.filter(\.isPFC18PublicLaunchCandidate)
        )

        XCTAssertEqual(
            publicCandidates,
            [
                .today,
                .goals,
                .time,
                .capture,
                .you,
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
        XCTAssertEqual(request.landing, .captureComposer)
        XCTAssertThrowsError(
            try CreateAmbitionsCaptureIntent.makeCaptureRequest(text: "  ", now: now, id: "empty")
        )
    }

    func testAFRI028GoalDraftIntentBuildsLocalReviewRequestWithoutDurableMutation() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))

        let request = try CreateAmbitionsGoalDraftIntent.makeGoalDraftRequest(
            title: "  Rebuild the launch packet  ",
            now: now,
            id: "goal-intent-test"
        )

        XCTAssertEqual(request.id, "goal-intent-test")
        XCTAssertEqual(request.createdAt, "2026-04-15T12:00:00Z")
        XCTAssertEqual(request.text, "Rebuild the launch packet")
        XCTAssertEqual(request.source, .appIntent)
        XCTAssertEqual(request.landing, .createGoal)
        XCTAssertThrowsError(
            try CreateAmbitionsGoalDraftIntent.makeGoalDraftRequest(title: "  ", now: now, id: "empty")
        )
    }

    func testAFRI028DeepActionDescriptorsRouteParameterizedActionsThroughSafeAppHandoff() {
        let openStep = AmbitionsDeepActionShortcut.openCurrentStep.descriptor(
            goalID: "goal-1",
            stepID: "step-1"
        )
        let startStep = AmbitionsDeepActionShortcut.startCurrentStep.descriptor(
            goalID: "goal-1",
            stepID: "step-1"
        )
        let closeStep = AmbitionsDeepActionShortcut.guardedCloseStep.descriptor(
            goalID: "goal-1",
            stepID: "step-1"
        )
        let receipt = AmbitionsDeepActionShortcut.showReceipt.descriptor(receiptID: "receipt-1")
        let localKnowledge = AmbitionsDeepActionShortcut.inspectLocalKnowledge.descriptor(knowledgeQuery: "travel")

        XCTAssertEqual(openStep.routeURL?.absoluteString, "ambitions://goal/goal-1?origin=app_intent&stepID=step-1")
        XCTAssertEqual(openStep.executionPosture, .opensAppOnly)
        XCTAssertEqual(startStep.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(startStep.commandKind, .startStepSession)
        XCTAssertEqual(closeStep.routeURL?.absoluteString, "ambitions://goal/goal-1?origin=app_intent&stepID=step-1")
        XCTAssertEqual(closeStep.executionPosture, .requiresInAppConfirmation)
        XCTAssertTrue(closeStep.producesReceipt)
        XCTAssertEqual(receipt.routeURL?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&q=receipt:receipt-1&origin=app_intent")
        XCTAssertEqual(localKnowledge.routeURL?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&q=travel&origin=app_intent")
        XCTAssertEqual(localKnowledge.privacySummary, "Details stay private until you open Ambitions.")
    }

    func testAFRI028DeepActionSetCoversRequiredNativeActionsWithoutUnsafePrivateExposure() {
        XCTAssertEqual(
            Set(AmbitionsDeepActionShortcut.allCases),
            [
                .capture,
                .goalDraft,
                .openCurrentStep,
                .startCurrentStep,
                .guardedCloseStep,
                .showReceipt,
                .inspectLocalKnowledge,
            ]
        )

        let descriptors = AmbitionsDeepActionShortcut.allCases.map { action in
            action.descriptor(goalID: "goal-1", stepID: "step-1", receiptID: "receipt-1", knowledgeQuery: "source")
        }
        let mutationDescriptors = descriptors.filter { $0.commandKind == .completeAction }

        XCTAssertEqual(Set(mutationDescriptors.map(\.action)), [.guardedCloseStep])
        XCTAssertTrue(mutationDescriptors.allSatisfy(\.requiresConfirmation))
        XCTAssertTrue(mutationDescriptors.allSatisfy(\.producesReceipt))
        XCTAssertTrue(descriptors.allSatisfy {
            $0.routeURL?.absoluteString.contains("origin=app_intent") == true
        })
        XCTAssertTrue(descriptors.allSatisfy {
            $0.privacySummary.localizedCaseInsensitiveContains("private")
        })
    }

    func testAFRI028ShortcutPhraseReviewUsesCanonicalLanguage() {
        let reviewedPhrases = [
            "Capture in Ambitions",
            "Draft a goal in Ambitions",
            "Open my step in Ambitions",
            "Start now in Ambitions",
            "Close my step in Ambitions",
            "Show receipt in Ambitions",
            "Inspect what Ambitions knows",
        ]

        for phrase in reviewedPhrases {
            XCTAssertFalse(phrase.localizedCaseInsensitiveContains("Plan tab"))
            XCTAssertFalse(phrase.localizedCaseInsensitiveContains("recommended step"))
            XCTAssertFalse(phrase.localizedCaseInsensitiveContains("AI"))
            XCTAssertFalse(phrase.localizedCaseInsensitiveContains("score"))
        }
        XCTAssertTrue(reviewedPhrases.contains("Start now in Ambitions"))
        XCTAssertTrue(reviewedPhrases.contains("Open my step in Ambitions"))
        XCTAssertTrue(reviewedPhrases.contains("Inspect what Ambitions knows"))
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
    func testIntentLaunchRouterConsumesQueuedURLsInFirstInFirstOutOrder() throws {
        let router = AppIntentLaunchRouter()
        let firstURL = try XCTUnwrap(URL(string: "ambitions://tab/time"))
        let secondURL = try XCTUnwrap(URL(string: "ambitions://tab/today"))

        router.queue(firstURL)
        router.queue(secondURL)

        XCTAssertEqual(router.consumePendingURL(), firstURL)
        XCTAssertEqual(router.consumePendingURL(), secondURL)
        XCTAssertNil(router.consumePendingURL())
    }

    @MainActor
    func testIntentLaunchRouterInstancesDoNotSharePendingURLs() throws {
        let firstRouter = AppIntentLaunchRouter()
        let secondRouter = AppIntentLaunchRouter()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/time"))

        firstRouter.queue(url)

        XCTAssertNil(secondRouter.consumePendingURL())
        XCTAssertEqual(firstRouter.consumePendingURL(), url)
    }

    @MainActor
    func testBootstrapperConsumesItsInjectedIntentLaunchRouter() throws {
        let router = AppIntentLaunchRouter()
        let bootstrapper = AppBootstrapper(appIntentLaunchRouter: router)
        let firstURL = try XCTUnwrap(URL(string: "ambitions://tab/time"))
        let secondURL = try XCTUnwrap(URL(string: "ambitions://tab/today"))

        router.queue(firstURL)
        router.queue(secondURL)
        bootstrapper.consumePendingAppIntentLaunchIfNeeded()

        XCTAssertNil(router.consumePendingURL())
    }
}
