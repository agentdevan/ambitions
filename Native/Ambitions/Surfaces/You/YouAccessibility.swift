import Foundation

enum YouAccessibility {
    static func rootSummary(
        profileState: String,
        privacyState: String,
        accountState: String,
        receiptState: String
    ) -> String {
        [
            "You",
            "Personal system: \(profileState)",
            "Privacy: \(privacyState)",
            "Account: \(accountState)",
            "Receipts and history: \(receiptState)"
        ].filter { $0.isEmpty == false }.joined(separator: ". ")
    }
}
