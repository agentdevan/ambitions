import Foundation

let projectionDefinitionSchemaVersion = "runtime_projection_definition.native.v1"

enum ProjectionID: String, Codable, Equatable, Hashable, CaseIterable, Comparable {
    case today
    case goals
    case time
    case you
    case search
    case widget
    case appIntent = "app_intent"
    case receipt
    case privacy

    static func < (lhs: ProjectionID, rhs: ProjectionID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum ProjectionFamily: String, Codable, Equatable, Hashable, CaseIterable {
    case surface
    case search = "search"
    case externalSurface = "external_surface"
    case trust
    case privacy
}

enum ProjectionMaterializationMode: String, Codable, Equatable, Hashable, CaseIterable {
    case eventCursor = "event_cursor"
    case fullRebuild = "full_rebuild"
    case privacyFiltered = "privacy_filtered"
}

struct ProjectionReadModelInventoryEntry: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let sourcePath: String
    let responsibility: String
    let migrationTarget: ProjectionID
    let mutationAuthorityAllowed: Bool

    init(
        sourcePath: String,
        responsibility: String,
        migrationTarget: ProjectionID,
        mutationAuthorityAllowed: Bool = false
    ) {
        self.id = sourcePath
        self.sourcePath = sourcePath
        self.responsibility = responsibility
        self.migrationTarget = migrationTarget
        self.mutationAuthorityAllowed = mutationAuthorityAllowed
    }
}

struct ProjectionDefinition: Codable, Equatable, Hashable, Identifiable {
    let id: ProjectionID
    let family: ProjectionFamily
    let consumesEventKinds: [RuntimeEventKind]
    let materializationMode: ProjectionMaterializationMode
    let privacyClasses: [EventLedgerPrivacyClassification]
    let readModelInventory: [ProjectionReadModelInventoryEntry]
    let schemaVersion: String

    init(
        id: ProjectionID,
        family: ProjectionFamily,
        consumesEventKinds: [RuntimeEventKind],
        materializationMode: ProjectionMaterializationMode = .eventCursor,
        privacyClasses: [EventLedgerPrivacyClassification] = [
            .standard,
            .sensitive,
            .privateUserText,
            .calendarDerived,
            .syncMetadata
        ],
        readModelInventory: [ProjectionReadModelInventoryEntry],
        schemaVersion: String = projectionDefinitionSchemaVersion
    ) {
        self.id = id
        self.family = family
        self.consumesEventKinds = Array(Set(consumesEventKinds)).sorted { $0.rawValue < $1.rawValue }
        self.materializationMode = materializationMode
        self.privacyClasses = Array(Set(privacyClasses)).sorted { $0.rawValue < $1.rawValue }
        self.readModelInventory = readModelInventory.sorted { $0.sourcePath < $1.sourcePath }
        self.schemaVersion = schemaVersion
    }

    func accepts(_ envelope: RuntimeEventEnvelope) -> Bool {
        consumesEventKinds.contains(envelope.event.kind) && privacyClasses.contains(envelope.event.privacy)
    }
}

extension ProjectionDefinition {
    static let allCanonical: [ProjectionDefinition] = ProjectionID.allCases.map(ProjectionDefinition.canonical)

    static func canonical(_ id: ProjectionID) -> ProjectionDefinition {
        switch id {
        case .today:
            return ProjectionDefinition(
                id: .today,
                family: .surface,
                consumesEventKinds: [.commandExecution, .captureRouteDecided, .closureRecorded, .correctionRecorded, .domainMutation, .timePlacementProposed, .tombstoneRecorded],
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Surfaces/Today/Projection/TodayReadModelProjector.swift", responsibility: "Today execution read model assembly", migrationTarget: .today),
                    .init(sourcePath: "Native/Ambitions/Surfaces/Today/Projection/TodayExecutionProjector.swift", responsibility: "Today Stage execution projection", migrationTarget: .today),
                    .init(sourcePath: "Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService+02-RepositoryBackedTodayService.swift", responsibility: "Repository-backed Today read path", migrationTarget: .today)
                ]
            )
        case .goals:
            return ProjectionDefinition(
                id: .goals,
                family: .surface,
                consumesEventKinds: [
                    .commandExecution, .closureRecorded, .correctionRecorded, .domainMutation,
                    .proofAttached, .tombstoneRecorded
                ],
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Surfaces/Goals/Projection/GoalsOverviewProjector.swift", responsibility: "Goals overview board projection", migrationTarget: .goals),
                    .init(sourcePath: "Native/Ambitions/Surfaces/Goals/Projection/GoalsFeatureService.swift", responsibility: "Repository-backed Goals surface read path", migrationTarget: .goals),
                    .init(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Projections/LifeAreaAtlasProjector.swift", responsibility: "Life area atlas projector scaffold", migrationTarget: .goals)
                ]
            )
        case .time:
            return ProjectionDefinition(
                id: .time,
                family: .surface,
                consumesEventKinds: [.commandExecution, .correctionRecorded, .domainMutation, .timePlacementProposed, .tombstoneRecorded],
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Surfaces/Time/Projection/TimeProjectionService.swift", responsibility: "Time projection service source reads", migrationTarget: .time),
                    .init(sourcePath: "Native/Ambitions/Surfaces/Time/Projection/TimeSurfaceProjectionAssembly.swift", responsibility: "Time surface assembly", migrationTarget: .time),
                    .init(sourcePath: "Native/Ambitions/Surfaces/Time/Projection/TimeLifeSuiteProjector.swift", responsibility: "Life calendar suite projection", migrationTarget: .time)
                ]
            )
        case .you:
            return ProjectionDefinition(
                id: .you,
                family: .surface,
                consumesEventKinds: [.commandExecution, .correctionRecorded, .proofAttached, .tombstoneRecorded, .compactionSnapshot],
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Surfaces/You/Projection/YouFeatureService.swift", responsibility: "You surface repository read path", migrationTarget: .you),
                    .init(sourcePath: "Native/Ambitions/Surfaces/You/Projection/YouHistoryProjectionService.swift", responsibility: "You history projection service", migrationTarget: .you),
                    .init(sourcePath: "Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceTrustProjection.swift", responsibility: "You trust read model projection", migrationTarget: .you)
                ]
            )
        case .search:
            return ProjectionDefinition(
                id: .search,
                family: .search,
                consumesEventKinds: RuntimeEventKind.allCases.filter { $0 != .compactionSnapshot },
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Surfaces/You/Projection/SearchLens.swift", responsibility: "Search overlay read model", migrationTarget: .search),
                    .init(sourcePath: "Native/Ambitions/Surfaces/You/Projection/YouFeatureServiceEverythingSearchProjection.swift", responsibility: "Everything search projection scaffold", migrationTarget: .search)
                ]
            )
        case .widget:
            return ProjectionDefinition(
                id: .widget,
                family: .externalSurface,
                consumesEventKinds: [.commandExecution, .closureRecorded, .timePlacementProposed],
                materializationMode: .privacyFiltered,
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Projection/ExternalSnapshots/ExternalWidgetProjection.swift", responsibility: "Widget-safe projection scaffold", migrationTarget: .widget),
                    .init(sourcePath: "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift", responsibility: "External snapshot builder", migrationTarget: .widget)
                ]
            )
        case .appIntent:
            return ProjectionDefinition(
                id: .appIntent,
                family: .externalSurface,
                consumesEventKinds: [.commandExecution, .closureRecorded, .timePlacementProposed],
                materializationMode: .privacyFiltered,
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/App/AppIntentLaunchRouter.swift", responsibility: "App Intent launch routing", migrationTarget: .appIntent),
                    .init(sourcePath: "Native/Ambitions/App/Intents/AmbitionsCreationIntents.swift", responsibility: "Creation App Intents", migrationTarget: .appIntent),
                    .init(sourcePath: "Native/Ambitions/App/Intents/AmbitionsStepInspectionIntents.swift", responsibility: "Step inspection App Intents", migrationTarget: .appIntent)
                ]
            )
        case .receipt:
            return ProjectionDefinition(
                id: .receipt,
                family: .trust,
                consumesEventKinds: [.commandExecution, .closureRecorded, .proofAttached, .correctionRecorded, .tombstoneRecorded],
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Inspection/ActionReceiptClosureStateProjection.swift", responsibility: "Action receipt projection scaffold", migrationTarget: .receipt),
                    .init(sourcePath: "Native/Ambitions/Projection/Mutations/MutationReceipt.swift", responsibility: "Mutation receipt projection", migrationTarget: .receipt),
                    .init(sourcePath: "Native/Ambitions/Trust/ReceiptInspectionView.swift", responsibility: "Receipt inspection surface", migrationTarget: .receipt)
                ]
            )
        case .privacy:
            return ProjectionDefinition(
                id: .privacy,
                family: .privacy,
                consumesEventKinds: RuntimeEventKind.allCases,
                materializationMode: .privacyFiltered,
                readModelInventory: [
                    .init(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/Boundary/PrivacyBoundary.swift", responsibility: "Runtime privacy boundary scaffold", migrationTarget: .privacy),
                    .init(sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/StoragePrivacySecurityBoundary.swift", responsibility: "Storage privacy boundary validation", migrationTarget: .privacy),
                    .init(sourcePath: "Native/Ambitions/Trust/PrivacyInspectionView.swift", responsibility: "Privacy inspection surface", migrationTarget: .privacy)
                ]
            )
        }
    }
}
