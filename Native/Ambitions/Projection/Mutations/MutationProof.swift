import Foundation

struct MutationProof: Equatable, Sendable {
    let artifactID: String
    let label: String
    let localOnly: Bool
}
