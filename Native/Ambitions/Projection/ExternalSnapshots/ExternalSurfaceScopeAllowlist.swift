import Foundation

enum ExternalWidgetFamilyIdentifier: String, CaseIterable, Codable, Sendable, Equatable {
    case systemSmall
    case systemMedium
    case systemLarge
    case accessoryInline
    case accessoryCircular
    case accessoryRectangular
}

struct ExternalWidgetSurfaceAllowlist: Codable, Sendable, Equatable {
    let surfaceID: String
    let widgetKind: String
    let contractKind: ExternalSurfaceKind
    let supportedFamilyIdentifiers: [ExternalWidgetFamilyIdentifier]
    let allowedVariantKinds: [ExternalSurfaceVariantKind]
    let snapshotKind: String
    let projectionTypeName: String
    let consumesSharedSnapshotRecord: Bool
    let productionReadinessClaim: String
}

struct ExternalLiveActivitySurfaceCandidate: Codable, Sendable, Equatable {
    let surfaceID: String
    let widgetTypeName: String
    let attributesTypeName: String
    let contractKind: ExternalSurfaceKind
    let requiresConcreteStep: Bool
    let requiresUserInitiatedActiveOperation: Bool
    let hasBoundedEndTime: Bool
    let isPlatformReady: Bool
    let productionReadinessClaim: String
}

enum ExternalSurfaceScopeAllowlist {
    static let nextStepWidget = ExternalWidgetSurfaceAllowlist(
        surfaceID: "next-step-widget",
        widgetKind: "AmbitionsNextStepWidget",
        contractKind: .widgets,
        supportedFamilyIdentifiers: [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
        ],
        allowedVariantKinds: [
            .currentStep,
            .todayPressure,
            .protectedTime,
            .captureEntry,
            .recovery,
            .today,
            .focus,
            .goal,
            .timeShape,
        ],
        snapshotKind: SharedExternalSnapshotStore.snapshotKind,
        projectionTypeName: "ExternalWidgetProjection",
        consumesSharedSnapshotRecord: true,
        productionReadinessClaim: "Not platform-ready until rendered widget families are verified on device."
    )

    static let liveActivityCandidates = [
        ExternalLiveActivitySurfaceCandidate(
            surfaceID: "next-step-live-activity",
            widgetTypeName: "NextStepLiveActivityWidget",
            attributesTypeName: "NextStepActivityAttributes",
            contractKind: .liveActivities,
            requiresConcreteStep: true,
            requiresUserInitiatedActiveOperation: true,
            hasBoundedEndTime: true,
            isPlatformReady: false,
            productionReadinessClaim: "Not platform-ready until ActivityKit start, update, end, Lock Screen, and Dynamic Island behavior are verified on device."
        ),
    ]

    static let firstAllowedSnapshotSurfaceID = nextStepWidget.surfaceID
}
