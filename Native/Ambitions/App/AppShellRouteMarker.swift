import Foundation

struct AppShellRouteMarker: Sendable, Equatable {
    let identifier: String
    let statusText: String
    let isFinishedSurface: Bool

    init(title: String) {
        let cleaned = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        identifier = "shell.route-marker.\(cleaned.isEmpty ? "untitled" : cleaned)"
        statusText = "Route marker"
        isFinishedSurface = false
    }
}

