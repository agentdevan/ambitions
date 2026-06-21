import Foundation

struct LifeShapeRuleID: RawRepresentable, ExpressibleByStringLiteral, Sendable, Hashable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}
