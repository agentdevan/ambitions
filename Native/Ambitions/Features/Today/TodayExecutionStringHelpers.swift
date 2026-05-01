import Foundation

extension String {
    var todayShortSentence: String {
        let normalized = split(whereSeparator: \.isNewline).joined(separator: " ")
        let first = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true).first.map(String.init) ?? normalized
        return first.shortened(maxLength: 64)
    }

    func shortened(maxLength: Int) -> String {
        guard count > maxLength else { return self }
        let end = index(startIndex, offsetBy: max(0, maxLength - 1), limitedBy: endIndex) ?? endIndex
        return String(self[..<end]).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
    }
}
