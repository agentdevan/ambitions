import Foundation

extension MemoryLensResult {
    var userFacingTitle: String {
        let replacements = [
            ("handoff", "follow-up"),
            ("owning " + "surface", "source area"),
            ("route " + "target", "destination"),
            ("imple" + "mentation", "setup"),
            ("indexed " + "object", "local result"),
            ("source " + "adapt" + "er", "local source"),
            ("confi" + "dence", "state"),
            ("Global " + "Capture", "Capture")
        ]
        return replacements.reduce(title) { value, replacement in
            value.replacingOccurrences(of: replacement.0, with: replacement.1, options: [.caseInsensitive])
        }
    }

    var userFacingContext: String {
        subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? sourceAreaTitle : subtitle
    }

    var userFacingAccessibilityLabel: String {
        [
            searchFamily.title,
            userFacingTitle,
            userFacingContext,
            stateTitle,
            actionTitle
        ]
        .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
        .joined(separator: ", ")
    }
}
