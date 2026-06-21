import Foundation

enum CopyBudget {
    case title
    case action
    case detail
    case accessibilitySummary

    var maximumCharacters: Int {
        switch self {
        case .title:
            return 48
        case .action:
            return 28
        case .detail:
            return 160
        case .accessibilitySummary:
            return 240
        }
    }

    func isExceeded(by copy: String) -> Bool {
        copy.count > maximumCharacters
    }
}
