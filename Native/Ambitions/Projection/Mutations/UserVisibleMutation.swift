import Foundation

struct UserVisibleMutation: Equatable, Sendable {
    let stageMutation: StageMutation
    let headline: String
    let detail: String

    var isCanonComplete: Bool {
        stageMutation.isCanonComplete && headline.isEmpty == false && detail.isEmpty == false
    }
}
