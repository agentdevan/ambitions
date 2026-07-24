import Foundation

enum RuntimeFoundationError: Error, Codable, Sendable, Equatable, Hashable {
    case invalidIdentity(RuntimeIdentityKind)
    case invalidSchema
    case unsupportedSchema
    case validation
    case authorization
    case revisionConflict(expected: RuntimeExpectedRevision, actual: UInt64?)
    case duplicate(RuntimeDomainObjectID)
    case idempotencyCollision(RuntimeCommandID)
    case persistence
    case corruption
    case migration(RuntimeMigrationID?)
    case projection(RuntimeProjectionCursorID?)
    case externalOperation(RuntimeExternalOperationID?)
    case cancellationBeforeCommit
    case cancellationAfterCommit(RuntimeReceiptID?)
    case privacyDenial
    case unsupportedCapability

    var userFacingSummary: String {
        switch self {
        case .invalidIdentity:
            return "The requested item has an invalid identity."
        case .invalidSchema:
            return "The saved information is not in a valid format."
        case .unsupportedSchema:
            return "This saved information requires a supported app version."
        case .validation:
            return "The requested change could not be validated."
        case .authorization:
            return "This change is not authorized."
        case .revisionConflict:
            return "The item changed before this request could be applied."
        case .duplicate:
            return "This item has already been recorded."
        case .idempotencyCollision:
            return "This request conflicts with an earlier request."
        case .persistence:
            return "The change could not be saved locally."
        case .corruption:
            return "Saved information could not be read safely."
        case .migration:
            return "Saved information could not be upgraded safely."
        case .projection:
            return "The latest view could not be prepared."
        case .externalOperation:
            return "The external operation could not be completed."
        case .cancellationBeforeCommit:
            return "The request was cancelled before anything changed."
        case .cancellationAfterCommit:
            return "The request was cancelled after the local change was saved."
        case .privacyDenial:
            return "The request was blocked by privacy protections."
        case .unsupportedCapability:
            return "This capability is not available."
        }
    }
}
