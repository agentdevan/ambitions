import Foundation

public enum FlagshipRoot: String, Codable, Sendable, CaseIterable {
    case today
    case goals
    case time
    case you
}

public enum FlagshipSurface: String, Codable, Sendable, CaseIterable {
    case today
    case goals
    case time
    case you
    case search
    case capture
    case objectDetail = "object-detail"
    case receipt
    case history
    case recovery
}

public struct FlagshipCaptureDraft: Codable, Sendable, Equatable {
    public let id: String
    public let text: String

    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

public enum FlagshipNavigationDestination: Codable, Sendable, Equatable {
    case search(query: String)
    case object(kind: String, id: String)
    case receipt(id: String)
    case history(objectID: String?)
    case recovery(code: String)
}

public enum FlagshipPresentedSheet: Codable, Sendable, Equatable {
    case capture(FlagshipCaptureDraft)
    case search(query: String)
    case receipt(id: String)
}

public struct FlagshipInterruptedIntent: Codable, Sendable, Equatable {
    public let intent: FlagshipIntent
    public let idempotencyKey: String
    public let expectedRevision: Int64?

    public init(
        intent: FlagshipIntent,
        idempotencyKey: String,
        expectedRevision: Int64?
    ) {
        self.intent = intent
        self.idempotencyKey = idempotencyKey
        self.expectedRevision = expectedRevision
    }
}

public struct FlagshipRestorationState: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let root: FlagshipRoot
    public let path: [FlagshipNavigationDestination]
    public let presentedSheet: FlagshipPresentedSheet?
    public let interruptedIntent: FlagshipInterruptedIntent?

    public init(
        schemaVersion: Int = 1,
        root: FlagshipRoot,
        path: [FlagshipNavigationDestination],
        presentedSheet: FlagshipPresentedSheet?,
        interruptedIntent: FlagshipInterruptedIntent?
    ) {
        self.schemaVersion = schemaVersion
        self.root = root
        self.path = path
        self.presentedSheet = presentedSheet
        self.interruptedIntent = interruptedIntent
    }
}

public enum FlagshipFixtureEnvironment: String, Codable, Sendable, CaseIterable {
    case standard
    case accessibility
    case dark
    case offline
    case privacy
    case largeStore = "large-store"
}

public enum FlagshipFixtureKeyError: Error, Sendable, Equatable {
    case invalidFormat(String)
    case unknownSurface(String)
    case unknownEnvironment(String)
    case invalidSchemaVersion(String)
}

public struct FlagshipFixtureKey: Codable, Sendable, Equatable, Hashable {
    public let surface: FlagshipSurface
    public let fixture: String
    public let environment: FlagshipFixtureEnvironment
    public let schemaVersion: Int

    public init(
        surface: FlagshipSurface,
        fixture: String,
        environment: FlagshipFixtureEnvironment,
        schemaVersion: Int
    ) {
        self.surface = surface
        self.fixture = fixture
        self.environment = environment
        self.schemaVersion = schemaVersion
    }

    public init(rawValue: String) throws {
        let components = rawValue.split(separator: "/", omittingEmptySubsequences: false)
        guard components.count == 4 else {
            throw FlagshipFixtureKeyError.invalidFormat(rawValue)
        }
        guard let surface = FlagshipSurface(rawValue: String(components[0])) else {
            throw FlagshipFixtureKeyError.unknownSurface(String(components[0]))
        }
        let fixture = String(components[1])
        guard !fixture.isEmpty else {
            throw FlagshipFixtureKeyError.invalidFormat(rawValue)
        }
        guard let environment = FlagshipFixtureEnvironment(
            rawValue: String(components[2])
        ) else {
            throw FlagshipFixtureKeyError.unknownEnvironment(String(components[2]))
        }
        let version = components[3]
        guard version.first == "v",
              let schemaVersion = Int(version.dropFirst()),
              schemaVersion > 0
        else {
            throw FlagshipFixtureKeyError.invalidSchemaVersion(String(version))
        }
        self.init(
            surface: surface,
            fixture: fixture,
            environment: environment,
            schemaVersion: schemaVersion
        )
    }

    public var rawValue: String {
        "\(surface.rawValue)/\(fixture)/\(environment.rawValue)/v\(schemaVersion)"
    }
}

public enum FlagshipProjectionRequest: Codable, Sendable, Equatable {
    case root(FlagshipRoot)
    case search(query: String)
    case object(kind: String, id: String)
    case receipt(id: String)
    case history(objectID: String?)
    case recovery(code: String)
}

public struct FlagshipProjectionItem: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let privacyLabel: String?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        privacyLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.privacyLabel = privacyLabel
    }
}

public struct FlagshipProjectionContent: Codable, Sendable, Equatable {
    public let title: String
    public let items: [FlagshipProjectionItem]

    public init(title: String, items: [FlagshipProjectionItem]) {
        self.title = title
        self.items = items
    }
}

public enum FlagshipRecoveryAction: String, Codable, Sendable, CaseIterable {
    case editIntent = "edit-intent"
    case refreshAndRetry = "refresh-and-retry"
    case retryExternalEffect = "retry-external-effect"
    case waitForProjection = "wait-for-projection"
    case restoreBackup = "restore-backup"
    case contactSupport = "contact-support"
}

public enum FlagshipDegradedReason: String, Codable, Sendable, CaseIterable {
    case projectionCatchUp = "projection-catch-up"
    case offline
    case externalEffectFailure = "external-effect-failure"
    case storeRecovery = "store-recovery"
    case localOnly = "local-only"
}

public struct FlagshipDegradedState: Codable, Sendable, Equatable {
    public let reason: FlagshipDegradedReason
    public let message: String
    public let recoveryAction: FlagshipRecoveryAction?

    public init(
        reason: FlagshipDegradedReason,
        message: String,
        recoveryAction: FlagshipRecoveryAction?
    ) {
        self.reason = reason
        self.message = message
        self.recoveryAction = recoveryAction
    }
}

public enum FlagshipProjectionState: Codable, Sendable, Equatable {
    case loading
    case ready(FlagshipProjectionContent)
    case empty(message: String)
    case error(message: String, recoveryAction: FlagshipRecoveryAction?)
    case offline(FlagshipProjectionContent?)
    case privacy(message: String)
    case degraded(FlagshipDegradedState)
}

public struct FlagshipProjectionEnvelope: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let request: FlagshipProjectionRequest
    public let cursor: String
    public let generatedAt: Date
    public let state: FlagshipProjectionState

    public init(
        schemaVersion: Int = 1,
        request: FlagshipProjectionRequest,
        cursor: String,
        generatedAt: Date,
        state: FlagshipProjectionState
    ) {
        self.schemaVersion = schemaVersion
        self.request = request
        self.cursor = cursor
        self.generatedAt = generatedAt
        self.state = state
    }
}

public enum FlagshipQuickCaptureEntryPoint: String, Codable, Sendable, CaseIterable {
    case shellCompose
    case shellUtility
    case goalsCreate
    case todayQuickCapture
    case goalsQuickCapture
    case timeQuickCapture
    case youQuickCapture
    case globalCaptureComposer
    case deepLink
    case appIntent
    case notification
    case widget
    case shareExtension
    case external
}

public enum FlagshipCaptureSourceType: String, Codable, Sendable, CaseIterable {
    case todayQuickCapture = "today_quick_capture"
    case shellComposer = "shell_composer"
    case notification
    case shareExtensionText = "share_extension_text"
    case shareExtensionURL = "share_extension_url"
    case appIntent = "app_intent"
}

public enum FlagshipQuickCaptureRoute: String, Codable, Sendable, CaseIterable {
    case task
    case goal
    case idea
    case proofItem = "proof_item"
    case waitingItem = "waiting_item"
    case plan
    case contextualNote = "contextual_note"
    case reminder
    case ritual
    case archive
    case decision
}

public struct FlagshipQuickCaptureContext: Codable, Sendable, Equatable {
    public let entryPoint: FlagshipQuickCaptureEntryPoint
    public let sourceType: FlagshipCaptureSourceType
    public let sourceSurface: String
    public let route: FlagshipQuickCaptureRoute
    public let requestedAt: Date

    public init(
        entryPoint: FlagshipQuickCaptureEntryPoint,
        sourceType: FlagshipCaptureSourceType,
        sourceSurface: String,
        route: FlagshipQuickCaptureRoute,
        requestedAt: Date
    ) {
        self.entryPoint = entryPoint
        self.sourceType = sourceType
        self.sourceSurface = sourceSurface
        self.route = route
        self.requestedAt = requestedAt
    }
}

public enum FlagshipIntent: Codable, Sendable, Equatable {
    case quickCapture(
        draftID: String,
        text: String,
        placementID: String?,
        context: FlagshipQuickCaptureContext
    )
    case createGoal(id: String, title: String)
    case updateGoal(id: String, title: String, completed: Bool)
    case schedule(objectID: String, start: Date, end: Date)
    case correctHistory(objectID: String, note: String)
    case semanticUndo(receiptID: String)
    case retryExternalEffect(receiptID: String, effectID: String)
}

public enum FlagshipObjectKind: String, Codable, Sendable, CaseIterable {
    case capture
    case goal
    case timeItem = "time-item"
    case receipt
}

public struct FlagshipObjectReference: Codable, Sendable, Equatable {
    public let kind: FlagshipObjectKind
    public let id: String

    public init(kind: FlagshipObjectKind, id: String) {
        self.kind = kind
        self.id = id
    }
}

public struct FlagshipReceiptReference: Codable, Sendable, Equatable {
    public let id: String
    public let projectionCursors: [String: String]
    public let recoveryAction: FlagshipRecoveryAction?
    public let semanticUndoEligible: Bool
    public let summary: String?
    public let affectedObjects: [FlagshipObjectReference]

    public init(
        id: String,
        projectionCursors: [String: String],
        recoveryAction: FlagshipRecoveryAction?,
        semanticUndoEligible: Bool,
        summary: String? = nil,
        affectedObjects: [FlagshipObjectReference] = []
    ) {
        self.id = id
        self.projectionCursors = projectionCursors
        self.recoveryAction = recoveryAction
        self.semanticUndoEligible = semanticUndoEligible
        self.summary = summary
        self.affectedObjects = affectedObjects
    }
}

public enum FlagshipIntentState: String, Codable, Sendable, CaseIterable {
    case committedProjectionReady = "committed-projection-ready"
    case committedCatchUpRequired = "committed-catch-up-required"
    case rejectedBeforeMutation = "rejected-before-mutation"
    case revisionConflict = "revision-conflict"
    case externalEffectPending = "external-effect-pending"
    case externalEffectReconciled = "external-effect-reconciled"
    case externalEffectFailed = "external-effect-failed"
}

public enum FlagshipIntentResult: Codable, Sendable, Equatable {
    case committedProjectionReady(FlagshipReceiptReference)
    case committedCatchUpRequired(FlagshipReceiptReference)
    case rejectedBeforeMutation(code: String, recoveryAction: FlagshipRecoveryAction?)
    case revisionConflict(expected: Int64?, actual: Int64, recoveryAction: FlagshipRecoveryAction)
    case externalEffectPending(FlagshipReceiptReference, effectIDs: [String])
    case externalEffectReconciled(FlagshipReceiptReference, effectIDs: [String])
    case externalEffectFailed(
        FlagshipReceiptReference,
        effectIDs: [String],
        recoveryAction: FlagshipRecoveryAction
    )

    public var state: FlagshipIntentState {
        switch self {
        case .committedProjectionReady: .committedProjectionReady
        case .committedCatchUpRequired: .committedCatchUpRequired
        case .rejectedBeforeMutation: .rejectedBeforeMutation
        case .revisionConflict: .revisionConflict
        case .externalEffectPending: .externalEffectPending
        case .externalEffectReconciled: .externalEffectReconciled
        case .externalEffectFailed: .externalEffectFailed
        }
    }
}

public protocol FlagshipProjectionReading: Sendable {
    func snapshot(
        for request: FlagshipProjectionRequest
    ) async throws -> FlagshipProjectionEnvelope
}

public protocol FlagshipIntentSending: Sendable {
    func send(
        _ intent: FlagshipIntent,
        idempotencyKey: String,
        expectedRevision: Int64?
    ) async -> FlagshipIntentResult
}
