import Foundation

struct MutationAccessibilityAnnouncement: Equatable, Sendable {
    let message: String
    let reasonIfSilent: String?
}
