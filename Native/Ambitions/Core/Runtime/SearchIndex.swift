import Foundation

enum LocalSearchObjectFamily: String, CaseIterable, Sendable, Equatable {
    case step
    case goal
    case capture
    case thought
    case proof
    case receipt
    case timeWindow
    case setting

    var title: String {
        switch self {
        case .step: "Step"
        case .goal: "Goal"
        case .capture: "Capture"
        case .thought: "Thought"
        case .proof: "Proof"
        case .receipt: "Receipt"
        case .timeWindow: "Time"
        case .setting: "You"
        }
    }

    var systemImage: String {
        switch self {
        case .step: "checkmark.circle"
        case .goal: "target"
        case .capture: "tray.full"
        case .thought: "text.bubble"
        case .proof: "checkmark.seal"
        case .receipt: "doc.text.magnifyingglass"
        case .timeWindow: "calendar"
        case .setting: "gearshape"
        }
    }
}

struct LocalSearchRecord: Identifiable, Sendable, Equatable {
    let id: String
    let family: LocalSearchObjectFamily
    let title: String
    let context: String
    let sourceArea: String
    let state: String
    let primaryActionTitle: String
    let inspectActionTitle: String?
    let destination: ShellCommandDestination
    let updatedAt: String
    let searchableText: String
    let originBias: [AmbitionsSurface]

    var normalizedSearchableText: String {
        LocalSearchIndex.normalized([title, context, sourceArea, state, searchableText])
    }
}

struct LocalSearchIndex: Sendable, Equatable {
    let records: [LocalSearchRecord]

    func search(
        query: String,
        origin: AmbitionsSurface?,
        familyPriority: [LocalSearchObjectFamily: Int],
        limit: Int = 32
    ) -> [LocalSearchRecord] {
        let normalizedQuery = Self.normalized([query])
        let filtered = records.filter { record in
            normalizedQuery.isEmpty || record.normalizedSearchableText.contains(normalizedQuery)
        }

        return Array(filtered.sorted { lhs, rhs in
            let lhsScore = score(lhs, query: normalizedQuery, origin: origin, familyPriority: familyPriority)
            let rhsScore = score(rhs, query: normalizedQuery, origin: origin, familyPriority: familyPriority)
            if lhsScore != rhsScore { return lhsScore > rhsScore }
            if lhs.updatedAt != rhs.updatedAt { return lhs.updatedAt > rhs.updatedAt }
            if lhs.family.rawValue != rhs.family.rawValue { return lhs.family.rawValue < rhs.family.rawValue }
            return lhs.title < rhs.title
        }.prefix(limit))
    }

    private func score(
        _ record: LocalSearchRecord,
        query: String,
        origin: AmbitionsSurface?,
        familyPriority: [LocalSearchObjectFamily: Int]
    ) -> Int {
        var value = 100 - (familyPriority[record.family] ?? 80)
        if let origin, record.originBias.contains(origin) {
            value += 30
        }
        if query.isEmpty == false {
            let title = Self.normalized([record.title])
            if title == query {
                value += 50
            } else if title.contains(query) {
                value += 25
            }
        }
        return value
    }

    static func normalized(_ values: [String]) -> String {
        values
            .joined(separator: " ")
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9]+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
