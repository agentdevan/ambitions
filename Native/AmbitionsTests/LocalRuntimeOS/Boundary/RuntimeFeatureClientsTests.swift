import Foundation
import XCTest
@testable import Ambitions

final class RuntimeFeatureClientsTests: XCTestCase {
    func testRegistryOwnsEveryTypedCaseExactlyOnceInStableOrder() throws {
        let registry = try RuntimeFeatureRegistrationRegistry(modules())

        XCTAssertEqual(registry.modules.map(\.featureID), RuntimePreparationFeature.allCases)
        XCTAssertEqual(registry.modules.map(\.order), Array(0..<RuntimePreparationFeature.allCases.count))
        let ownership = registry.modules.flatMap(\.handler.cases)
        XCTAssertEqual(Set(ownership.map(\.caseID)), RuntimeCommandCaseID.all)
        XCTAssertEqual(ownership.count, RuntimeCommandCaseID.all.count)
        XCTAssertEqual(
            ownership.filter { $0.route == .navigation }.map(\.caseID.rawValue).sorted(),
            ["history.openDestination", "repair.openDestination"]
        )
        XCTAssertEqual(RuntimeFeatureHandlerAvailability(registry: registry).features, Set(RuntimePreparationFeature.allCases))
    }

    func testDuplicateAndMissingRegistrationFailDeterministically() throws {
        let all = modules()
        XCTAssertThrowsError(try RuntimeFeatureRegistrationRegistry(all + [all[0]])) { error in
            XCTAssertEqual(error as? RuntimeFeatureRegistrationError, .duplicateFeature(.capture))
        }
        XCTAssertThrowsError(try RuntimeFeatureRegistrationRegistry(Array(all.dropLast()))) { error in
            XCTAssertEqual(error as? RuntimeFeatureRegistrationError, .missingFeature(.compensation))
        }

        let duplicateOrder = AnyRuntimeFeatureRegistrationModule(TestRegistrationModule(
            base: all[7],
            cases: all[7].handler.cases,
            order: 0
        ))
        XCTAssertThrowsError(try RuntimeFeatureRegistrationRegistry(Array(all.dropLast()) + [duplicateOrder])) { error in
            XCTAssertEqual(error as? RuntimeFeatureRegistrationError, .duplicateOrder(0))
        }

        let external = all[6]
        let duplicateCase = try XCTUnwrap(RuntimeCommandCaseID(rawValue: "externalOperation.reminder"))
        let duplicateExternal = AnyRuntimeFeatureRegistrationModule(TestRegistrationModule(
            base: external,
            cases: [
                RuntimeCommandCaseOwnership(caseID: duplicateCase, route: .mutation),
                RuntimeCommandCaseOwnership(caseID: duplicateCase, route: .mutation),
                RuntimeCommandCaseOwnership(
                    caseID: try XCTUnwrap(RuntimeCommandCaseID(rawValue: "externalOperation.calendar_event")),
                    route: .mutation
                ),
            ]
        ))
        XCTAssertThrowsError(try RuntimeFeatureRegistrationRegistry(
            Array(all.dropLast(2)) + [duplicateExternal, all[7]]
        )) { error in
            XCTAssertEqual(error as? RuntimeFeatureRegistrationError, .duplicateCommandCase(duplicateCase))
        }

        let missingCase = try XCTUnwrap(RuntimeCommandCaseID(rawValue: "externalOperation.reminder"))
        let incompleteExternal = AnyRuntimeFeatureRegistrationModule(TestRegistrationModule(
            base: external,
            cases: [RuntimeCommandCaseOwnership(
                caseID: try XCTUnwrap(RuntimeCommandCaseID(rawValue: "externalOperation.calendar_event")),
                route: .mutation
            )]
        ))
        XCTAssertThrowsError(try RuntimeFeatureRegistrationRegistry(
            Array(all.dropLast(2)) + [incompleteExternal, all[7]]
        )) { error in
            XCTAssertEqual(error as? RuntimeFeatureRegistrationError, .missingCommandCase(missingCase))
        }
    }

    func testPreparationAndTerminalTruthForwardUnchanged() async throws {
        let command = captureCommand()
        let typed = try XCTUnwrap(RuntimeCaptureCommand(command))
        let preparation = try makePreparation(command: command)
        let failure = RuntimePreparationFailure(
            commandID: command.id,
            reason: .invalidSemanticInput,
            recovery: .inspect(.invalidSemanticInput, target: command.target),
            originalBytes: nil
        )
        let preparationOutcomes: [RuntimePreparationOutcome] = [
            .ready(preparation),
            .requiresConfirmation(preparation),
            .blocked(failure),
            .unsupported(failure),
        ]
        for expected in preparationOutcomes {
            let seam = FeatureClientSeam(preparation: expected, terminal: .unsupported(terminal(preparation)))
            let client = CaptureRuntimeMutationClient(preparer: seam, submitter: seam)
            let actual = await client.prepare(typed, context: try context())
            XCTAssertEqual(actual, expected)
        }

        let terminalOutcomes: [RuntimeCommandOutcome] = [
            .changed(RuntimeCommittedMutation(
                preparationID: preparation.preparationID,
                commandID: preparation.commandID,
                authorityReceiptID: try XCTUnwrap(RuntimeReceiptID(rawValue: "authority-receipt")),
                projectionDegradation: []
            )),
            .unchanged(terminal(preparation)),
            .blocked(terminal(preparation)),
            .failed(terminal(preparation)),
            .unsupported(terminal(preparation)),
        ]
        for expected in terminalOutcomes {
            let seam = FeatureClientSeam(preparation: .ready(preparation), terminal: expected)
            let client = CaptureRuntimeMutationClient(preparer: seam, submitter: seam)
            let actual = await client.commit(preparation, confirmation: nil)
            XCTAssertEqual(actual, expected)
        }
    }

    func testCrossFamilyCommitAndOpenDestinationCannotReachMutationSeams() async throws {
        let capture = captureCommand()
        let capturePreparation = try makePreparation(command: capture)
        let seam = FeatureClientSeam(
            preparation: .ready(capturePreparation),
            terminal: .changed(RuntimeCommittedMutation(
                preparationID: capturePreparation.preparationID,
                commandID: capturePreparation.commandID,
                authorityReceiptID: try XCTUnwrap(RuntimeReceiptID(rawValue: "authority-receipt")),
                projectionDegradation: []
            ))
        )
        let profileClient = ProfileRuntimeMutationClient(preparer: seam, submitter: seam)
        guard case let .unsupported(crossFamily) = await profileClient.commit(capturePreparation, confirmation: nil) else {
            return XCTFail("Cross-family commit must be unsupported")
        }
        XCTAssertEqual(crossFamily.reason, .identityMismatch)
        let crossFamilyCommitCount = await seam.commitCount()
        XCTAssertEqual(crossFamilyCommitCount, 0)

        let open = openDestinationCommand(destination: .goals)
        let typed = try XCTUnwrap(RuntimeHistoryRepairCommand(open))
        let historyClient = HistoryRepairRuntimeMutationClient(preparer: seam, submitter: seam)
        guard case .unsupported = await historyClient.prepare(typed, context: try context()) else {
            return XCTFail("openDestination must leave mutation preparation")
        }
        let openDestinationPrepareCount = await seam.prepareCount()
        XCTAssertEqual(openDestinationPrepareCount, 0)

        let navigation = RuntimeNavigationClient { request in
            .routed(RuntimeNavigationRoute(destination: request.destination))
        }
        let request = try XCTUnwrap(RuntimeNavigationRequest(openDestination: typed))
        let navigationOutcome = await navigation.navigate(request)
        XCTAssertEqual(
            navigationOutcome,
            .routed(RuntimeNavigationRoute(destination: .goals))
        )
        XCTAssertNil(RuntimeNavigationRequest(openDestination: try XCTUnwrap(RuntimeHistoryRepairCommand(
            openDestinationCommand(destination: nil)
        ))))
    }

    func testQueryTruthStatesAreForwardedWithoutMutationFallback() async throws {
        let objectID = try XCTUnwrap(RuntimeDomainObjectID(rawValue: "object-1"))
        let request = RuntimeObjectInspectionQuery(objectID: objectID, requestedAt: "2026-07-24T12:00:00Z")
        let snapshot = RuntimeObjectInspectionSnapshot(objectID: objectID, receipts: [], cursor: nil)
        let clients: [ObjectInspectionRuntimeQueryClient] = [
            ObjectInspectionRuntimeQueryClient { _ in
                .available(RuntimeObjectInspectionSnapshot(objectID: objectID, receipts: [], cursor: nil))
            },
            ObjectInspectionRuntimeQueryClient { _ in
                .stale(RuntimeObjectInspectionSnapshot(objectID: objectID, receipts: [], cursor: nil))
            },
            ObjectInspectionRuntimeQueryClient { _ in .missing(nil) },
            ObjectInspectionRuntimeQueryClient { _ in .unavailable(.inspect(.authorityUnavailable)) },
        ]
        let expected: [RuntimeQueryTruth<RuntimeObjectInspectionSnapshot>] = [
            .available(snapshot), .stale(snapshot), .missing(nil), .unavailable(.inspect(.authorityUnavailable)),
        ]
        for (client, truth) in zip(clients, expected) {
            let actual = await client.query(request)
            XCTAssertEqual(actual, truth)
        }
    }

    func testBoundarySourcesExcludeMutableAuthorityAndNavigationArtifacts() throws {
        let clientsRoot = sourceRoot().appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Boundary/Clients")
        let declarations = [
            "RuntimeFeatureMutationClient.swift", "RuntimeProjectionQueryClients.swift",
            "RuntimeInspectionQueryClients.swift", "RuntimeNavigationClient.swift", "RuntimeFeatureClients.swift",
        ]
        let forbidden = [
            "AppRepositories", "SwiftData", "ModelContext", "FileManager", "URLSession", "ProjectionStoreSQLite(",
            "FTSIndex(", "RuntimeEventStore", "Journal", "Repository", "Store(", "EventKit", "CloudKit",
        ]
        for file in declarations {
            let source = try String(contentsOf: clientsRoot.appendingPathComponent(file), encoding: .utf8)
            for token in forbidden {
                XCTAssertFalse(source.contains(token), "\(file) exposes forbidden dependency \(token)")
            }
        }

        let navigation = try String(
            contentsOf: clientsRoot.appendingPathComponent("RuntimeNavigationClient.swift"),
            encoding: .utf8
        )
        for artifact in ["RuntimeCommandOutcome", "RuntimeCommittedMutation", "RuntimeReceiptID", "RuntimeEvent", "ProjectionCursor", "affectedObject"] {
            XCTAssertFalse(navigation.contains(artifact), "Navigation exposes authority artifact \(artifact)")
        }
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: sourceRoot().appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Boundary/RuntimeCommandClient.swift").path
            ),
            "Existing combined compatibility client must remain present"
        )
        let projectionAdapter = try String(
            contentsOf: sourceRoot().appendingPathComponent(
                "Native/Ambitions/Core/LocalRuntimeOS/Projections/ProjectionStoreSurfaceReadAdapter.swift"
            ),
            encoding: .utf8
        )
        XCTAssertTrue(projectionAdapter.contains("func readReceipt("))
        XCTAssertTrue(projectionAdapter.contains("readProjection(.receipt, as: ReceiptProjection.self"))
    }

    private func modules() -> [AnyRuntimeFeatureRegistrationModule] {
        let seam = FeatureClientSeam.placeholder
        return [
            AnyRuntimeFeatureRegistrationModule(CaptureRuntimeFeatureModule(
                mutationClient: CaptureRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(GoalStepRuntimeFeatureModule(
                mutationClient: GoalStepRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(ScheduleReminderRuntimeFeatureModule(
                mutationClient: ScheduleReminderRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(ProfileRuntimeFeatureModule(
                mutationClient: ProfileRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(HistoryRepairRuntimeFeatureModule(
                mutationClient: HistoryRepairRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(ImportDeletionRuntimeFeatureModule(
                mutationClient: ImportDeletionRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(ExternalOperationRuntimeFeatureModule(
                mutationClient: ExternalOperationRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(AttachmentRuntimeFeatureModule(
                mutationClient: AttachmentRuntimeMutationClient(preparer: seam, submitter: seam)
            )),
            AnyRuntimeFeatureRegistrationModule(CompensationRuntimeFeatureModule(
                mutationClient: CompensationRuntimeMutationClient(
                    preparer: seam,
                    submitter: seam,
                    offering: { _, _, _, _ in .unavailable(.unavailable) }
                )
            )),
        ]
    }

    private func captureCommand() -> AmbitionsCommand {
        AmbitionsCommand(
            id: "feature-client-capture",
            source: .capture,
            typedPayload: .capture(CaptureCommand(
                action: .quickCapture(externalCreation: nil),
                target: AmbitionsCommandTarget(),
                content: RuntimeCommandContent(AmbitionsCommandPayload(rawText: "Private capture"))
            )),
            createdAt: "2026-07-24T12:00:00Z",
            privacy: .privateUserText
        )
    }

    private func openDestinationCommand(destination: AmbitionsCommandDestination?) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "feature-client-open-destination",
            source: .today,
            typedPayload: .history(HistoryCommand(
                action: .openDestination,
                target: AmbitionsCommandTarget(destination: destination),
                content: RuntimeCommandContent()
            )),
            createdAt: "2026-07-24T12:00:00Z"
        )
    }

    private func makePreparation(command: AmbitionsCommand) throws -> RuntimePreparation {
        let preparationID = try XCTUnwrap(RuntimePreparationID(rawValue: "feature-client-preparation"))
        let commandID = try XCTUnwrap(RuntimeCommandID(rawValue: command.id))
        let fingerprint = try XCTUnwrap(RuntimeCommandFingerprint(rawValue: String(repeating: "a", count: 64)))
        let decisionDigest = try XCTUnwrap(RuntimeCommandFingerprint(rawValue: String(repeating: "b", count: 64)))
        let decision = RuntimeReducerDecision(
            family: RuntimeFeatureMutationRouter().feature(for: command.typedPayload).rawValue,
            action: command.typedPayload.diagnosticCase,
            disposition: .apply,
            readSet: RuntimeMutationReadSet(objects: [], cursors: [], privacy: command.privacy),
            writeSet: RuntimeMutationWriteSet(
                transitions: [],
                events: [],
                projectionInvalidations: [],
                receiptIntentID: nil,
                compensation: nil,
                externalEffect: .none
            ),
            confirmationScope: nil,
            reason: nil,
            recovery: .inspect(.preparedMutation, target: command.target)
        )
        return RuntimePreparation(
            preparationID: preparationID,
            command: command,
            commandID: commandID,
            commandFingerprint: fingerprint,
            commandVersion: runtimeCommandSchemaVersion,
            decision: decision,
            decisionDigest: decisionDigest,
            authorization: RuntimePreparationAuthorization(
                state: .authorized,
                actor: command.actor,
                source: command.source,
                expectedRevision: command.expectedRevision,
                observedRevision: command.expectedRevision,
                privacyBoundary: PrivacyBoundary.forCommand(command),
                sideEffectPolicy: .localOnly,
                reasonCodes: []
            ),
            confirmationRequest: nil,
            issuedAt: Date(timeIntervalSince1970: 1_774_526_400),
            expiresAt: Date(timeIntervalSince1970: 1_774_526_700),
            schemaVersion: runtimePreparationSchemaVersion
        )
    }

    private func terminal(_ preparation: RuntimePreparation) -> RuntimeTerminalResult {
        RuntimeTerminalResult(
            preparationID: preparation.preparationID,
            commandID: preparation.commandID.rawValue,
            reason: .noMutation,
            recovery: .inspect(.noMutation, target: preparation.command.target)
        )
    }

    private func context() throws -> RuntimePreparationContext {
        RuntimePreparationContext(
            preparationID: try XCTUnwrap(RuntimePreparationID(rawValue: "feature-client-preparation")),
            confirmationToken: try XCTUnwrap(RuntimeConfirmationToken(rawValue: "feature-client-confirmation")),
            proposedObjectID: try XCTUnwrap(RuntimeDomainObjectID(rawValue: "feature-client-object")),
            eventID: try XCTUnwrap(RuntimeEventID(rawValue: "feature-client-event")),
            receiptID: try XCTUnwrap(RuntimeReceiptID(rawValue: "feature-client-receipt")),
            rollbackPlanID: try XCTUnwrap(RuntimeRollbackPlanID(rawValue: "feature-client-rollback")),
            externalOperationID: try XCTUnwrap(RuntimeExternalOperationID(rawValue: "feature-client-effect")),
            issuedAt: Date(timeIntervalSince1970: 1_774_526_400),
            expiresAt: Date(timeIntervalSince1970: 1_774_526_700),
            boundary: .localOnly
        )
    }

    private func sourceRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
    }
}

private struct TestRegistrationModule: RuntimeFeatureRegistrationModule {
    let mutationClient: RuntimeFeatureMutationClientRegistration
    let featureID: RuntimePreparationFeature
    let order: Int
    let handler: RuntimeFeatureHandlerRegistration
    let mutationClientRegistration: RuntimeFeatureMutationClientRegistration
    let projectorRegistrations: [RuntimeProjectorRegistration]
    let materializerRegistrations: [RuntimeMaterializerRegistration]
    let queryRegistrations: [RuntimeFeatureQueryRegistration]

    init(
        base: AnyRuntimeFeatureRegistrationModule,
        cases: [RuntimeCommandCaseOwnership],
        order: Int? = nil
    ) {
        featureID = base.featureID
        self.order = order ?? base.order
        handler = RuntimeFeatureHandlerRegistration(
            feature: base.handler.feature,
            reducerType: base.handler.reducerType,
            cases: cases
        )
        mutationClientRegistration = base.mutationClientRegistration
        mutationClient = base.mutationClientRegistration
        projectorRegistrations = base.projectorRegistrations
        materializerRegistrations = base.materializerRegistrations
        queryRegistrations = base.queryRegistrations
    }
}

private actor FeatureClientSeam: RuntimeMutationPreparing, RuntimeMutationSubmitting {
    static var placeholder: FeatureClientSeam {
        let failure = RuntimePreparationFailure(
            commandID: nil,
            reason: .unsupportedInput,
            recovery: .inspect(.unsupportedInput),
            originalBytes: nil
        )
        let terminal = RuntimeTerminalResult(
            preparationID: nil,
            commandID: nil,
            reason: .unsupportedInput,
            recovery: .inspect(.unsupportedInput)
        )
        return FeatureClientSeam(preparation: .unsupported(failure), terminal: .unsupported(terminal))
    }

    private let preparation: RuntimePreparationOutcome
    private let terminal: RuntimeCommandOutcome
    private var preparations = 0
    private var commits = 0

    init(preparation: RuntimePreparationOutcome, terminal: RuntimeCommandOutcome) {
        self.preparation = preparation
        self.terminal = terminal
    }

    func prepare(_ command: AmbitionsCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome {
        preparations += 1
        return preparation
    }

    func commit(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeCommandOutcome {
        commits += 1
        return terminal
    }

    func prepareCount() -> Int { preparations }
    func commitCount() -> Int { commits }
}
