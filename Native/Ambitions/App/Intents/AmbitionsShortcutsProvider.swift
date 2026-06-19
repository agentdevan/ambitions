import AppIntents

struct AmbitionsShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateAmbitionsCaptureIntent(),
            phrases: [
                "Capture in \(.applicationName)",
                "Add to \(.applicationName)",
            ],
            shortTitle: "Capture",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .today),
            phrases: [
                "Open Today in \(.applicationName)",
                "Show Today in \(.applicationName)",
            ],
            shortTitle: "Open Today",
            systemImageName: "sun.max"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .goals),
            phrases: [
                "Open Goals in \(.applicationName)",
                "Show Goals in \(.applicationName)",
            ],
            shortTitle: "Open Goals",
            systemImageName: "target"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .time),
            phrases: [
                "Open Time in \(.applicationName)",
                "Show Time in \(.applicationName)",
            ],
            shortTitle: "Open Time",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .capture),
            phrases: [
                "Open Capture in \(.applicationName)",
                "Show Capture in \(.applicationName)",
            ],
            shortTitle: "Open Capture",
            systemImageName: "tray.full"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .memoryLens),
            phrases: [
                "Open what \(.applicationName) knows",
                "Show what \(.applicationName) knows",
            ],
            shortTitle: "What Ambitions Knows",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .you),
            phrases: [
                "Open You in \(.applicationName)",
                "Show You in \(.applicationName)",
            ],
            shortTitle: "Open You",
            systemImageName: "person.crop.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .startNextStep),
            phrases: [
                "Start here in \(.applicationName)",
                "Start my recommended step in \(.applicationName)",
            ],
            shortTitle: "Start Here",
            systemImageName: "scope"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .markDone),
            phrases: [
                "Close the loop in \(.applicationName)",
                "Close my step in \(.applicationName)",
            ],
            shortTitle: "Close Loop",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .saveTheDay),
            phrases: [
                "Make today doable in \(.applicationName)",
                "Open recovery in \(.applicationName)",
            ],
            shortTitle: "Make Doable",
            systemImageName: "arrow.uturn.left.circle"
        )
    }

    static var shortcutTileColor: ShortcutTileColor {
        .teal
    }
}
