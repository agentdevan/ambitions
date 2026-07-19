import Foundation

enum PrivacyFileProtectionLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case completeUntilFirstUserAuthentication = "complete_until_first_user_authentication"
    case complete
    case standard

    var blobStoreProtectionClass: BlobStoreProtectionClass {
        switch self {
        case .completeUntilFirstUserAuthentication:
            return .completeUntilFirstUserAuthentication
        case .complete:
            return .complete
        case .standard:
            return .none
        }
    }
}

struct FileProtectionDecision: Codable, Sendable, Equatable, Hashable {
    let objectID: String
    let privacyClass: RuntimePrivacyClass
    let protectionLevel: PrivacyFileProtectionLevel
    let requiresEncryptedBlobVault: Bool
    let reason: String
}

struct FileProtectionPolicy: Sendable, Equatable, Hashable {
    func decision(for object: PrivacyClassifiedObject) -> FileProtectionDecision {
        let level: PrivacyFileProtectionLevel
        switch object.privacyClass {
        case .privateUserText, .privateSensitive, .proofRestricted, .replayRestricted, .lineageRestricted:
            level = .complete
        case .sensitive, .localOnly, .calendarDerived:
            level = .completeUntilFirstUserAuthentication
        case .publicMetadata, .systemOwned, .standard, .syncMetadata:
            level = .standard
        }

        return FileProtectionDecision(
            objectID: object.id,
            privacyClass: object.privacyClass,
            protectionLevel: level,
            requiresEncryptedBlobVault: object.privacyClass.requiresRedaction,
            reason: "\(object.privacyClass.rawValue) maps to \(level.rawValue) file protection."
        )
    }
}
