import Foundation

enum RuntimePrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case publicMetadata = "public_metadata"
    case systemOwned = "system_owned"
    case standard
    case sensitive
    case privateUserText = "private_user_text"
    case localOnly = "local_only"
    case privateSensitive = "private_sensitive"
    case proofRestricted = "proof_restricted"
    case replayRestricted = "replay_restricted"
    case lineageRestricted = "lineage_restricted"
    case calendarDerived = "calendar_derived"
    case syncMetadata = "sync_metadata"

    var requiresRedaction: Bool {
        switch self {
        case .publicMetadata, .systemOwned, .standard, .syncMetadata:
            return false
        case .sensitive, .privateUserText, .localOnly, .privateSensitive, .proofRestricted, .replayRestricted, .lineageRestricted, .calendarDerived:
            return true
        }
    }

    var canEnterPublicReferencePack: Bool {
        self == .publicMetadata || self == .systemOwned
    }

    var canLeaveDeviceWithoutReview: Bool {
        switch self {
        case .publicMetadata, .systemOwned, .standard:
            return true
        case .syncMetadata, .sensitive, .privateUserText, .localOnly, .privateSensitive, .proofRestricted, .replayRestricted, .lineageRestricted, .calendarDerived:
            return false
        }
    }

    var requiresLocalAuthentication: Bool {
        switch self {
        case .privateUserText, .privateSensitive, .proofRestricted, .replayRestricted, .lineageRestricted:
            return true
        case .publicMetadata, .systemOwned, .standard, .sensitive, .localOnly, .calendarDerived, .syncMetadata:
            return false
        }
    }

    var defaultStoragePrivacyClass: AFEPStoragePrivacyClass {
        switch self {
        case .publicMetadata:
            return .publicMetadata
        case .systemOwned, .standard, .syncMetadata:
            return .systemOwned
        case .sensitive, .privateUserText, .privateSensitive:
            return .privateSensitive
        case .localOnly, .calendarDerived:
            return .localOnly
        case .proofRestricted:
            return .proofRestricted
        case .replayRestricted:
            return .replayRestricted
        case .lineageRestricted:
            return .lineageRestricted
        }
    }
}

struct PrivacyClassifiedObject: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: String
    let title: String
    let privacyClass: RuntimePrivacyClass
    let eventPrivacy: EventLedgerPrivacyClassification?
    let storagePrivacy: AFEPStoragePrivacyClass
    let containsUserText: Bool
    let sourcePath: String?

    init(
        id: String,
        family: String,
        title: String,
        privacyClass: RuntimePrivacyClass,
        eventPrivacy: EventLedgerPrivacyClassification? = nil,
        storagePrivacy: AFEPStoragePrivacyClass? = nil,
        containsUserText: Bool? = nil,
        sourcePath: String? = nil
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.family = family.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.privacyClass = privacyClass
        self.eventPrivacy = eventPrivacy
        self.storagePrivacy = storagePrivacy ?? privacyClass.defaultStoragePrivacyClass
        self.containsUserText = containsUserText ?? privacyClass.requiresRedaction
        self.sourcePath = sourcePath?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PrivacyClassifier: Sendable, Equatable, Hashable {
    func classifyEvent(
        id: String,
        family: String,
        title: String,
        privacy: EventLedgerPrivacyClassification,
        sourcePath: String? = nil
    ) -> PrivacyClassifiedObject {
        PrivacyClassifiedObject(
            id: id,
            family: family,
            title: title,
            privacyClass: RuntimePrivacyClass(eventPrivacy: privacy),
            eventPrivacy: privacy,
            sourcePath: sourcePath
        )
    }

    func classifyStorage(
        id: String,
        family: String,
        title: String,
        privacy: AFEPStoragePrivacyClass,
        sourcePath: String? = nil
    ) -> PrivacyClassifiedObject {
        PrivacyClassifiedObject(
            id: id,
            family: family,
            title: title,
            privacyClass: RuntimePrivacyClass(storagePrivacy: privacy),
            storagePrivacy: privacy,
            sourcePath: sourcePath
        )
    }
}

extension RuntimePrivacyClass {
    init(eventPrivacy: EventLedgerPrivacyClassification) {
        switch eventPrivacy {
        case .standard:
            self = .standard
        case .sensitive:
            self = .sensitive
        case .privateUserText:
            self = .privateUserText
        case .calendarDerived:
            self = .calendarDerived
        case .syncMetadata:
            self = .syncMetadata
        }
    }

    init(storagePrivacy: AFEPStoragePrivacyClass) {
        switch storagePrivacy {
        case .publicMetadata:
            self = .publicMetadata
        case .systemOwned:
            self = .systemOwned
        case .localOnly:
            self = .localOnly
        case .privateSensitive:
            self = .privateSensitive
        case .proofRestricted:
            self = .proofRestricted
        case .replayRestricted:
            self = .replayRestricted
        case .lineageRestricted:
            self = .lineageRestricted
        }
    }
}
