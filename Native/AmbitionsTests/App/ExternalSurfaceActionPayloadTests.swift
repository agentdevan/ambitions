import XCTest
@testable import Ambitions

final class ExternalSurfaceActionPayloadTests: XCTestCase {
    func testCanonicalCommandPayloadPreservesLegacyKeysAndRedactsUserText() throws {
        let payload = ExternalSurfaceActionPayload.commandPayload(
            action: .complete,
            surface: .goalDetail,
            goalID: "goal-private-id",
            stepID: "step-private-id",
            tab: "goals"
        )

        XCTAssertEqual(payload["action"], "complete")
        XCTAssertEqual(payload["surface"], "goal-detail")
        XCTAssertEqual(payload["goalID"], "goal-private-id")
        XCTAssertEqual(payload["stepID"], "step-private-id")
        XCTAssertEqual(payload["tab"], "goals")

        let json = try XCTUnwrap(String(data: JSONEncoder().encode(payload), encoding: .utf8))
        XCTAssertFalse(json.contains("Private Therapy Goal"))
        XCTAssertFalse(json.contains("Call my therapist about the notes"))
        XCTAssertFalse(json.contains("capture text"))
    }

    func testCanonicalURLsUseStableRoutesOnly() throws {
        let goalURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .goalDetail, goalID: "goal-123"))
        let todayURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: "today"))
        let capturesURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .captureInbox))
        let widgetURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: "today", origin: .widget))
        let fallbackURL = try XCTUnwrap(ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .goalDetail, goalID: nil, origin: .widget))

        XCTAssertEqual(goalURL.absoluteString, "ambitions://goal/goal-123")
        XCTAssertEqual(todayURL.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(capturesURL.absoluteString, "ambitions://captures/inbox")
        XCTAssertEqual(widgetURL.absoluteString, "ambitions://tab/today?origin=widget")
        XCTAssertEqual(fallbackURL.absoluteString, "ambitions://tab/today?origin=widget")
        XCTAssertFalse(goalURL.absoluteString.contains("Private"))
    }

    func testD22ExternalSurfaceContractsCoverCanonSurfaces() {
        let contracts = ExternalSurfaceContractRegistry.contracts

        XCTAssertEqual(Set(contracts.map(\.kind)), Set(ExternalSurfaceKind.allCases))
        XCTAssertEqual(contracts.count, ExternalSurfaceKind.allCases.count)

        for contract in contracts {
            XCTAssertFalse(contract.allowedContent.isEmpty, "\(contract.kind) must name allowed content.")
            XCTAssertFalse(contract.forbiddenContent.isEmpty, "\(contract.kind) must name forbidden content.")
            XCTAssertTrue(contract.hidesSensitiveDetailsByDefault, "\(contract.kind) must hide sensitive details by default.")
            XCTAssertFalse(contract.allowedActions.isEmpty, "\(contract.kind) must name allowed actions.")
            XCTAssertFalse(contract.snapshotRule.isEmpty)
            XCTAssertFalse(contract.degradedStateLabel.isEmpty)
            XCTAssertFalse(contract.accessibilityRequirement.isEmpty)
        }
    }

    func testD22ContractsGateCommandsReceiptsAndSensitiveEffects() {
        let mutatingKinds: Set<ExternalSurfaceKind> = [.notifications, .widgets, .liveActivities, .appIntents, .shortcuts]

        for kind in mutatingKinds {
            let contract = ExternalSurfaceContractRegistry.contract(for: kind)

            XCTAssertTrue(contract.requiresSharedCommandPipeline, "\(kind) must use the shared command pipeline.")
            XCTAssertTrue(contract.requiresReceiptForMutation, "\(kind) must require receipts for mutations.")
            XCTAssertTrue(contract.requiresConfirmationForSensitiveExternalDestructiveEffects, "\(kind) must gate sensitive/external/destructive effects.")
        }

        let focusFilters = ExternalSurfaceContractRegistry.contract(for: .focusFilters)
        XCTAssertFalse(focusFilters.requiresSharedCommandPipeline)
        XCTAssertFalse(focusFilters.requiresReceiptForMutation)
        XCTAssertTrue(focusFilters.requiresConfirmationForSensitiveExternalDestructiveEffects)
    }

    func testGlanceStatePrefersNowStateAndFallsBackToOldNextActionSnapshots() throws {
        let oldNextAction = ExternalSurfaceNextAction(
            goalID: "goal-old",
            stepID: "step-old",
            display: ExternalSurfaceDisplayMetadata(
                templateKey: "next_tiny_step",
                goalMode: .project,
                stepState: .planned,
                urgency: .normal,
                timing: .deadline
            )
        )
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: oldNextAction,
            nowState: ExternalSurfaceNowState(
                todayPosture: .waiting,
                pressureLevel: .elevated,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-now", stepID: "step-now"),
                activeFocus: nil,
                openCaptureUrgency: .low,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 1, blockedCount: 2),
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ]
            )
        )

        let glance = ExternalSurfaceGlanceState(snapshot: snapshot)

        XCTAssertEqual(glance.primaryReference?.goalID, "goal-now")
        XCTAssertEqual(glance.primaryReference?.stepID, "step-now")
        XCTAssertEqual(glance.todayPosture, .waiting)
        XCTAssertEqual(glance.pressureLevel, .elevated)
        XCTAssertEqual(glance.openCaptureUrgency, .low)
        XCTAssertEqual(glance.continuity.syncHealth.label, "Local-first and stable")

        let legacy = ExternalSurfaceGlanceState(
            snapshot: ExternalSurfaceSnapshot(
                generatedAt: "2026-04-15T12:00:00Z",
                nextAction: oldNextAction
            )
        )

        XCTAssertEqual(legacy.primaryReference?.goalID, "goal-old")
        XCTAssertEqual(legacy.primaryReference?.stepID, "step-old")
        XCTAssertEqual(legacy.todayPosture, .active)
        XCTAssertEqual(legacy.pressureLevel, .steady)
    }

    func testGlanceStatePreservesActiveFocusPriorityOverBestNextStep() throws {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: nil,
            nowState: ExternalSurfaceNowState(
                todayPosture: .active,
                pressureLevel: .steady,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-best", stepID: "step-best"),
                activeFocus: ExternalSurfaceActionReference(goalID: "goal-focus", stepID: "step-focus"),
                openCaptureUrgency: .none,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ]
            )
        )

        let glance = ExternalSurfaceGlanceState(snapshot: snapshot)

        XCTAssertEqual(glance.primaryReference?.goalID, "goal-focus")
        XCTAssertEqual(glance.primaryReference?.stepID, "step-focus")
    }

    func testGlanceStateUsesCalmUnavailableLanguageWhenSnapshotIsMissing() throws {
        let glance = ExternalSurfaceGlanceState(snapshot: nil)

        XCTAssertEqual(glance.continuity.lease.status, .unavailable)
        XCTAssertEqual(glance.continuity.lease.freshnessLabel, "Open Ambitions to refresh")
        XCTAssertEqual(glance.continuity.syncHealth.state, .unavailable)
        XCTAssertEqual(glance.continuity.syncHealth.label, "This surface may be behind")
        XCTAssertEqual(glance.continuity.syncHealth.detail, "Local app truth is available when Ambitions opens")
        XCTAssertEqual(glance.primaryURL?.absoluteString, "ambitions://tab/today?origin=widget")
    }

    func testAFRI029SpotlightIndexRecordsStayGatedAndRedacted() throws {
        let projector = ExternalObjectReopeningProjector()
        let sensitiveGoal = ExternalObjectReopeningCandidate(
            kind: .goal,
            id: "goal-private",
            title: "Private Therapy Goal",
            detail: "Call my therapist about the notes",
            goalID: "goal-private",
            isSensitive: true
        )
        let safeCapture = ExternalObjectReopeningCandidate(
            kind: .capture,
            id: "capture-safe",
            title: "Review inbox",
            detail: "Capture waiting for review",
            captureID: "capture-safe",
            isSensitive: false
        )

        XCTAssertTrue(projector.indexRecords(for: [sensitiveGoal], gate: .disabledUntilProof).isEmpty)

        let records = projector.indexRecords(for: [sensitiveGoal, safeCapture], gate: .internalOptIn)

        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0].title, "Goal in Ambitions")
        XCTAssertEqual(records[0].contentDescription, "Details stay private until you open Ambitions.")
        XCTAssertEqual(records[0].redaction, .redactedPrivate)
        XCTAssertEqual(records[0].routeURL.absoluteString, "ambitions://goal/goal-private?origin=spotlight")
        XCTAssertFalse(records[0].eligibleForPublicIndexing)
        XCTAssertFalse(records[0].title.contains("Therapy"))
        XCTAssertFalse(records[0].contentDescription.contains("therapist"))

        XCTAssertEqual(records[1].title, "Review inbox")
        XCTAssertEqual(records[1].contentDescription, "Capture waiting for review")
        XCTAssertEqual(records[1].routeURL.absoluteString, "ambitions://captures/inbox?origin=spotlight&captureID=capture-safe")
    }

    func testAFRI029IndexRecordsCoverGoalsStepsReceiptsAndCaptures() {
        let projector = ExternalObjectReopeningProjector()
        let records = projector.indexRecords(
            for: [
                ExternalObjectReopeningCandidate(kind: .goal, id: "goal-1", title: "Goal", detail: "Goal detail", goalID: "goal-1", isSensitive: false),
                ExternalObjectReopeningCandidate(kind: .currentStep, id: "step-1", title: "Step", detail: "Step detail", goalID: "goal-1", stepID: "step-1", isSensitive: false),
                ExternalObjectReopeningCandidate(kind: .receipt, id: "receipt-1", title: "Receipt", detail: "Receipt detail", receiptID: "receipt-1", isSensitive: true),
                ExternalObjectReopeningCandidate(kind: .capture, id: "capture-1", title: "Capture", detail: "Capture detail", captureID: "capture-1", isSensitive: true),
            ],
            gate: .internalOptIn
        )

        XCTAssertEqual(Set(records.map(\.kind)), Set(ExternalObjectReopeningKind.allCases))
        XCTAssertEqual(records.first { $0.kind == .currentStep }?.routeURL.absoluteString, "ambitions://goal/goal-1?origin=spotlight&stepID=step-1")
        XCTAssertEqual(records.first { $0.kind == .receipt }?.routeURL.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&q=receipt:receipt-1&origin=spotlight")
        XCTAssertEqual(records.first { $0.kind == .capture }?.title, "Capture in Ambitions")
    }

    func testAFRI029HandoffRecordsReopenActiveStepAndGoalDetailOnly() throws {
        let projector = ExternalObjectReopeningProjector()
        let goal = ExternalObjectReopeningCandidate(
            kind: .goal,
            id: "goal-1",
            title: "Launch",
            detail: "Ready",
            goalID: "goal-1",
            isSensitive: false
        )
        let step = ExternalObjectReopeningCandidate(
            kind: .currentStep,
            id: "step-1",
            title: "Recommended step",
            detail: "Open step",
            goalID: "goal-1",
            stepID: "step-1",
            isSensitive: true
        )
        let receipt = ExternalObjectReopeningCandidate(
            kind: .receipt,
            id: "receipt-1",
            title: "Receipt",
            detail: "Receipt detail",
            receiptID: "receipt-1"
        )

        let goalHandoff = try XCTUnwrap(projector.handoffRecord(for: goal))
        let stepHandoff = try XCTUnwrap(projector.handoffRecord(for: step))

        XCTAssertEqual(goalHandoff.activityType, "com.ambitions.reopen.goal")
        XCTAssertEqual(goalHandoff.routeURL.absoluteString, "ambitions://goal/goal-1?origin=handoff")
        XCTAssertEqual(goalHandoff.userInfo["goalID"], "goal-1")
        XCTAssertEqual(stepHandoff.title, "Step in Ambitions")
        XCTAssertEqual(stepHandoff.routeURL.absoluteString, "ambitions://goal/goal-1?origin=handoff&stepID=step-1")
        XCTAssertEqual(stepHandoff.userInfo["stepID"], "step-1")
        XCTAssertNil(projector.handoffRecord(for: receipt))
    }

    func testAFEP016CanonicalRootRecordsStayPrivacySafeAndUseCanonicalFallbackRoots() throws {
        let projector = ExternalObjectReopeningProjector()
        let records = projector.canonicalRecords(gate: .internalOptIn)

        XCTAssertEqual(records.count, ExternalObjectReopeningRoot.allCases.count)
        XCTAssertEqual(records.map(\.root), ExternalObjectReopeningRoot.allCases)
        XCTAssertEqual(records.map(\.title), [
            "Reality Meridian",
            "Constellation Atlas",
            "Atmosphere Composer",
            "LifeShape Field",
            "User System Profile"
        ])
        XCTAssertEqual(records.map(\.rootFallbackURL.absoluteString), [
            "ambitions://tab/today",
            "ambitions://tab/goals",
            "ambitions://tab/capture",
            "ambitions://tab/time",
            "ambitions://tab/you"
        ])
        XCTAssertTrue(records.allSatisfy { $0.metadataClass == .canonicalRoot })
        XCTAssertTrue(records.allSatisfy { $0.redaction == .safeSummary })

        let json = try XCTUnwrap(String(data: JSONEncoder().encode(records), encoding: .utf8))
        XCTAssertFalse(json.contains("Private Therapy Goal"))
        XCTAssertFalse(json.contains("Call my therapist about the notes"))
        XCTAssertFalse(json.contains("capture text"))
        XCTAssertFalse(json.contains("receipt:"))
    }

    func testAFEP016ContinuationTokensCarrySafeIDsAndAvoidRawPrivateText() throws {
        let tokens = [
            ExternalObjectContinuationToken(
                kind: .goal,
                root: .goals,
                goalID: "goal-123",
                stepID: nil,
                receiptID: nil,
                captureID: nil,
                metadataClass: .exactReopen,
                redaction: .safeSummary
            ),
            ExternalObjectContinuationToken(
                kind: .currentStep,
                root: .goals,
                goalID: "goal-123",
                stepID: "step-456",
                receiptID: nil,
                captureID: nil,
                metadataClass: .exactReopen,
                redaction: .safeSummary
            ),
            ExternalObjectContinuationToken(
                kind: .receipt,
                root: .today,
                goalID: nil,
                stepID: nil,
                receiptID: "receipt-789",
                captureID: nil,
                metadataClass: .fallbackRoot,
                redaction: .redactedPrivate
            ),
            ExternalObjectContinuationToken(
                kind: .capture,
                root: .capture,
                goalID: nil,
                stepID: nil,
                receiptID: nil,
                captureID: "capture-321",
                metadataClass: .exactReopen,
                redaction: .safeSummary
            )
        ]

        XCTAssertEqual(ExternalSurfaceActionPayload.continuationPayload(for: tokens[0])["kind"], "goal")
        XCTAssertEqual(ExternalSurfaceActionPayload.continuationPayload(for: tokens[0])["root"], "goals")
        XCTAssertEqual(ExternalSurfaceActionPayload.continuationPayload(for: tokens[1])["stepID"], "step-456")
        XCTAssertEqual(ExternalSurfaceActionPayload.continuationPayload(for: tokens[2])["receiptID"], "receipt-789")
        XCTAssertEqual(ExternalSurfaceActionPayload.continuationPayload(for: tokens[3])["captureID"], "capture-321")

        XCTAssertEqual(tokens[0].routeURL(origin: .spotlight)?.absoluteString, "ambitions://goal/goal-123?origin=spotlight")
        XCTAssertEqual(tokens[1].routeURL(origin: .spotlight)?.absoluteString, "ambitions://goal/goal-123?origin=spotlight&stepID=step-456")
        XCTAssertEqual(tokens[2].routeURL(origin: .spotlight)?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&q=receipt:receipt-789&origin=spotlight")
        XCTAssertEqual(tokens[3].routeURL(origin: .spotlight)?.absoluteString, "ambitions://captures/inbox?origin=spotlight&captureID=capture-321")

        let fallbackGoal = ExternalObjectContinuationToken(
            kind: .goal,
            root: .goals,
            goalID: nil,
            stepID: nil,
            receiptID: nil,
            captureID: nil,
            metadataClass: .fallbackRoot,
            redaction: .redactedPrivate
        )
        let fallbackReceipt = ExternalObjectContinuationToken(
            kind: .receipt,
            root: .today,
            goalID: nil,
            stepID: nil,
            receiptID: nil,
            captureID: nil,
            metadataClass: .fallbackRoot,
            redaction: .redactedPrivate
        )

        XCTAssertEqual(fallbackGoal.routeURL(origin: .spotlight)?.absoluteString, "ambitions://tab/goals?origin=spotlight")
        XCTAssertEqual(fallbackReceipt.routeURL(origin: .spotlight)?.absoluteString, "ambitions://tab/today?origin=spotlight")

        let json = try XCTUnwrap(String(data: JSONEncoder().encode(tokens + [fallbackGoal, fallbackReceipt]), encoding: .utf8))
        XCTAssertFalse(json.contains("Private Therapy Goal"))
        XCTAssertFalse(json.contains("Call my therapist about the notes"))
        XCTAssertFalse(json.contains("schedule detail"))
        XCTAssertFalse(json.contains("proof content"))
        XCTAssertFalse(json.contains("receipt body"))
    }
}
