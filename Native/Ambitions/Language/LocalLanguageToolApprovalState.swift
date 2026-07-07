import Foundation

enum LocalLanguageToolApprovalState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notAllowed = "not_allowed"
    case reviewOnly = "review_only"
    case prepareProposal = "prepare_proposal"
    case userApproved = "user_approved"
    case userRejected = "user_rejected"
    case requiresSourceReview = "requires_source_review"
    case requiresPrivacyReview = "requires_privacy_review"
    case requiresHumanReview = "requires_human_review"
    case blockedBySensitivity = "blocked_by_sensitivity"
    case blockedByFallback = "blocked_by_fallback"
}
