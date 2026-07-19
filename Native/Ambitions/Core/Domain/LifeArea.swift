import Foundation

struct LifeAreaID: RawRepresentable, Codable, Sendable, Equatable, Hashable, Comparable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(domain: LifeDomainKey) {
        self.init(rawValue: domain.rawValue)
    }

    static func < (lhs: LifeAreaID, rhs: LifeAreaID) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct LifeArea: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: LifeAreaID
    let domainKey: LifeDomainKey
    let displayName: String
    let summary: String
    let canonicalOrder: Int

    init(domainKey: LifeDomainKey, canonicalOrder: Int) {
        self.id = domainKey.lifeAreaID
        self.domainKey = domainKey
        self.displayName = domainKey.lifeAreaDisplayName
        self.summary = domainKey.lifeAreaSummary
        self.canonicalOrder = canonicalOrder
    }

    static let canonical: [LifeArea] = LifeDomainKey.allCases.enumerated().map { index, domain in
        LifeArea(domainKey: domain, canonicalOrder: index)
    }
}

extension LifeDomainKey {
    var lifeAreaID: LifeAreaID {
        LifeAreaID(domain: self)
    }

    var lifeAreaDisplayName: String {
        switch self {
        case .career:
            return "Career"
        case .education:
            return "Education"
        case .health:
            return "Health"
        case .finance:
            return "Money"
        case .home:
            return "Home"
        case .relationships:
            return "Relationships"
        case .creativity:
            return "Creativity"
        case .personalGrowth:
            return "Personal growth"
        }
    }

    var lifeAreaSummary: String {
        switch self {
        case .career:
            return "Work, calling, and visible contribution."
        case .education:
            return "Learning, credentials, and skill-building."
        case .health:
            return "Body, recovery, energy, and care."
        case .finance:
            return "Money decisions, security, and practical resources."
        case .home:
            return "Home, household, and the places life runs through."
        case .relationships:
            return "People, care, support, and shared responsibilities."
        case .creativity:
            return "Creative work, craft, and self-expression."
        case .personalGrowth:
            return "Identity, reflection, and becoming more yourself."
        }
    }
}

struct LifeAreaDefinition: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: LifeAreaID
    let domainKey: LifeDomainKey
    let displayName: String
    let summary: String?
    let accessibilityLabel: String
    let accessibilityHint: String
    let canonicalOrder: Int

    init(lifeArea: LifeArea) {
        self.id = lifeArea.id
        self.domainKey = lifeArea.domainKey
        self.displayName = lifeArea.displayName
        self.summary = lifeArea.summary
        self.accessibilityLabel = "Life Area, \(lifeArea.displayName)"
        self.accessibilityHint = "Organizes related goals and progress without adding a new tab."
        self.canonicalOrder = lifeArea.canonicalOrder
    }

    init(domainKey: LifeDomainKey, canonicalOrder: Int) {
        self.init(lifeArea: LifeArea(domainKey: domainKey, canonicalOrder: canonicalOrder))
    }

    static let canonical: [LifeAreaDefinition] = LifeArea.canonical.map(LifeAreaDefinition.init(lifeArea:))
}
