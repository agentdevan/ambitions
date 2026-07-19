import Foundation

struct KeyboardShortcutPolicy: Equatable, Sendable {
    let surface: StageMutationTargetSurface
    let key: String
    let accessibilityLabel: String
}

enum KeyboardPolicy {
    static func primaryShortcut(for surface: StageMutationTargetSurface) -> KeyboardShortcutPolicy {
        switch surface {
        case .today:
            return KeyboardShortcutPolicy(surface: surface, key: "1", accessibilityLabel: "Keyboard shortcut opens Today")
        case .goals:
            return KeyboardShortcutPolicy(surface: surface, key: "2", accessibilityLabel: "Keyboard shortcut opens Goals")
        case .time:
            return KeyboardShortcutPolicy(surface: surface, key: "3", accessibilityLabel: "Keyboard shortcut opens Time")
        case .you:
            return KeyboardShortcutPolicy(surface: surface, key: "4", accessibilityLabel: "Keyboard shortcut opens You")
        }
    }
}
