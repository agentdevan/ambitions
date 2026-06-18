import Foundation

struct AppMeridianDestination: Equatable, Identifiable {
    let tab: AppTab
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String

    var id: AppTab { tab }

    static var all: [AppMeridianDestination] {
        AppTab.allCases.map { tab in
            AppMeridianDestination(
                tab: tab,
                title: tab.title,
                systemImage: tab.systemImage,
                accessibilityIdentifier: "shell.meridian.destination.\(tab.rawValue)"
            )
        }
    }
}

struct AppMeridianShellChromeState: Equatable {
    let title: String
    let destinationRailLabel: String
    let receiptOverlayZoneLabel: String
    let globalActionLabel: String
    let safeAreaLabel: String
    let rollbackLabel: String
    let destinations: [AppMeridianDestination]

    var accessibilitySummary: String {
        [
            title,
            destinationRailLabel,
            receiptOverlayZoneLabel,
            globalActionLabel,
            safeAreaLabel
        ].joined(separator: ". ")
    }

    static let launchDefault = AppMeridianShellChromeState(
        title: "Ambition Meridian",
        destinationRailLabel: "Four destinations: Today, Goals, Time, You.",
        receiptOverlayZoneLabel: "Receipt overlay zone stays temporary and dismissible.",
        globalActionLabel: "Global add opens capture or command choices without changing tabs.",
        safeAreaLabel: "Shell chrome stays inside safe areas and keeps native navigation available.",
        rollbackLabel: "Rollback by reverting the Train 3 Stage shell commit; no alternate root shell is exposed.",
        destinations: AppMeridianDestination.all
    )
}
