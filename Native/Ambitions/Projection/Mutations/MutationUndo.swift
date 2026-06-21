import Foundation

struct MutationUndo: Equatable, Sendable {
    let isAvailable: Bool
    let label: String
}
