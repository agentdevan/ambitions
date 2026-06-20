import Foundation

struct GoalThread: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let ambitionID: String
    let lifeAreaID: String?
    let name: String
    let goalIDs: [String]
    let isActive: Bool
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        ambitionID: String,
        lifeAreaID: String? = nil,
        name: String,
        goalIDs: [String] = [],
        isActive: Bool = true,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.ambitionID = ambitionID
        self.lifeAreaID = lifeAreaID
        self.name = name
        self.goalIDs = ambitionGraphStableUnique(goalIDs)
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
