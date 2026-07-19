// AMB Needs Repair proof trigger: source-neutral comment to force Native validation.
import XCTest
@testable import Ambitions

final class AppIntentCommandRoutingInventoryTests: XCTestCase {
    func testAMB1808InventoryCoversEveryCurrentAppIntentType() {
        XCTAssertEqual(
            AppIntentCommandRoutingInventory.currentIntentTypeNames,
            [
                "CreateAmbitionsCaptureIntent",
                "CreateAmbitionsGoalDraftIntent",
                "OpenAmbitionsDestinationIntent",
                "OpenAmbitionsSystemControlIntent",
                "OpenAmbitionsCurrentStepIntent",
                "StartAmbitionsCurrentStepIntent",
                "GuardedCloseAmbitionsStepIntent",
                "ShowAmbitionsReceiptIntent",
                "InspectAmbitionsLocalKnowledgeIntent",
            ]
        )
    }

    func testAMB1808InventoryCoversAllParameterizedDestinationControlAndStepRoutes() {
        let records = AppIntentCommandRoutingInventory.records
        let destinationRouteIDs = Set(
            records
                .filter { $0.intentTypeName == "OpenAmbitionsDestinationIntent" }
                .map(\.routeID)
        )
        let systemControlRouteIDs = Set(
            records
                .filter { $0.intentTypeName == "OpenAmbitionsSystemControlIntent" }
                .map(\.routeID)
        )
        let deepActionRouteIDs = Set(
            records
                .filter { $0.id.hasPrefix("deep-action.") }
                .map(\.routeID)
        )

        XCTAssertEqual(destinationRouteIDs, Set(AmbitionsAppShortcutDestination.allCases.map(\.rawValue)))
        XCTAssertEqual(systemControlRouteIDs, Set(AmbitionsSystemControlShortcut.allCases.map(\.rawValue)))
        XCTAssertEqual(
            deepActionRouteIDs,
            ["open-current-step", "start-current-step", "guarded-close-step", "show-receipt", "inspect-local-knowledge"]
        )
    }

    func testAMB1808InventoryMatchesCurrentDescriptorRouteURLs() {
        for destination in AmbitionsAppShortcutDestination.allCases {
            let record = record(id: "destination.\(destination.rawValue)")
            XCTAssertEqual(record.routeURLString, destination.routeURL?.absoluteString, destination.rawValue)
        }

        for control in AmbitionsSystemControlShortcut.allCases {
            let record = record(id: "system-control.\(control.rawValue)")
            XCTAssertEqual(record.routeURLString, control.contract.deepLinkURL(origin: .appIntent)?.absoluteString, control.rawValue)
        }

        let deepActions: [(String, AmbitionsDeepActionShortcut, String?, String?, String?, String?)] = [
            ("deep-action.open-current-step", .openCurrentStep, "goal-placeholder", "step-placeholder", nil, nil),
            ("deep-action.start-current-step", .startCurrentStep, "goal-placeholder", "step-placeholder", nil, nil),
            ("deep-action.guarded-close-step", .guardedCloseStep, "goal-placeholder", "step-placeholder", nil, nil),
            ("deep-action.show-receipt", .showReceipt, nil, nil, "receipt-placeholder", nil),
            ("deep-action.inspect-local-knowledge", .inspectLocalKnowledge, nil, nil, nil, "topic-placeholder"),
        ]
        for (id, action, goalID, stepID, receiptID, knowledgeQuery) in deepActions {
            let record = record(id: id)
            XCTAssertEqual(
                record.routeURLString,
                action.descriptor(
                    goalID: goalID,
                    stepID: stepID,
                    receiptID: receiptID,
                    knowledgeQuery: knowledgeQuery
                ).routeURL?.absoluteString,
                id
            )
        }
    }

    func testAMB1808InventoryFindsNoUnsafeOrUnknownMutatingRoutes() {
        XCTAssertTrue(
            AppIntentCommandRoutingInventory.unsafeOrUnknownMutatingRecords.isEmpty,
            "Unsafe or unknown mutating App Intent routes: \(AppIntentCommandRoutingInventory.unsafeOrUnknownMutatingRecords.map(\.id))"
        )
    }

    func testAMB1808CaptureCommandsUseLocalCreationBoundaryAndReceiptEvidence() {
        let captureRecords = AppIntentCommandRoutingInventory.records.filter { $0.classification == .captureCommand }

        XCTAssertTrue(captureRecords.contains { $0.intentTypeName == "CreateAmbitionsCaptureIntent" })
        XCTAssertTrue(captureRecords.contains { $0.intentTypeName == "CreateAmbitionsGoalDraftIntent" })
        XCTAssertTrue(captureRecords.allSatisfy { record in
            record.boundary == .queuesLocalCreation ||
                record.boundary == .opensAppForAction
        })
        XCTAssertTrue(captureRecords.filter { $0.boundary == .queuesLocalCreation }.allSatisfy(\.producesReceipt))
        XCTAssertTrue(captureRecords.allSatisfy { record in
            record.evidence.joined(separator: " ").localizedCaseInsensitiveContains("directly mutate") == false ||
                record.evidence.joined(separator: " ").localizedCaseInsensitiveContains("does not directly mutate")
        })
    }

    func testAMB1808ActionCommandsCannotBypassAppOrConfirmationBoundary() {
        let actionRecords = AppIntentCommandRoutingInventory.records.filter { $0.classification == .actionCommand }
        let unsafeBoundaries: Set<AppIntentCommandRoutingBoundary> = [.unsafeDirectMutation, .unknown, .none]

        XCTAssertTrue(actionRecords.contains { $0.routeID == "mark_done" })
        XCTAssertTrue(actionRecords.contains { $0.routeID == "save_the_day" })
        XCTAssertTrue(actionRecords.contains { $0.routeID == "guarded-close-step" })
        XCTAssertTrue(actionRecords.allSatisfy { unsafeBoundaries.contains($0.boundary) == false })
        XCTAssertTrue(actionRecords.filter { $0.boundary == .requiresInAppConfirmation }.allSatisfy(\.producesReceipt))
        XCTAssertTrue(actionRecords.allSatisfy { record in
            record.routeURLString?.contains("origin=app_intent") == true
        })
    }

    func testAMB1808ProjectionQueryRoutesStayOpenOnlyAndPrivate() {
        let projectionRecords = AppIntentCommandRoutingInventory.records.filter { $0.classification == .projectionQuery }

        XCTAssertFalse(projectionRecords.isEmpty)
        XCTAssertTrue(projectionRecords.allSatisfy { $0.boundary == .opensAppForAction })
        XCTAssertTrue(projectionRecords.allSatisfy { $0.producesReceipt == false })
        XCTAssertTrue(projectionRecords.allSatisfy { record in
            record.routeURLString?.contains("origin=app_intent") == true
        })
        XCTAssertFalse(projectionRecords.compactMap(\.routeURLString).joined(separator: " ").contains("Private Therapy Goal"))
    }

    private func record(id: String) -> AppIntentCommandRoutingRecord {
        guard let record = AppIntentCommandRoutingInventory.records.first(where: { $0.id == id }) else {
            XCTFail("Missing App Intent routing inventory record \(id)")
            return AppIntentCommandRoutingRecord(
                id: id,
                intentTypeName: "missing",
                routeID: "missing",
                classification: .unknown,
                boundary: .unknown,
                commandKind: nil,
                routeURLString: nil,
                producesReceipt: false,
                evidence: []
            )
        }
        return record
    }
}
