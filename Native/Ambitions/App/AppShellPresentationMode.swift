import Foundation

enum AppShellPresentationMode: String, Equatable {
    case nativeFallback
    case meridian

    static let launchArgumentName = "--ambitions-shell"
    static let environmentName = "AMBITIONS_SHELL_PRESENTATION"

    static func resolved(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> AppShellPresentationMode {
        if let argumentValue = shellArgumentValue(in: arguments) {
            return mode(for: argumentValue)
        }

        if let environmentValue = environment[environmentName] {
            return mode(for: environmentValue)
        }

        return .nativeFallback
    }

    private static func shellArgumentValue(in arguments: [String]) -> String? {
        for argument in arguments {
            if argument == "\(launchArgumentName)=meridian" {
                return "meridian"
            }

            if argument == "\(launchArgumentName)=native" ||
                argument == "\(launchArgumentName)=nativeFallback" {
                return "native"
            }
        }

        guard let index = arguments.firstIndex(of: launchArgumentName),
              arguments.indices.contains(arguments.index(after: index)) else {
            return nil
        }

        return arguments[arguments.index(after: index)]
    }

    private static func mode(for rawValue: String) -> AppShellPresentationMode {
        switch rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "meridian", "on", "enabled", "true", "1":
            return .meridian
        default:
            return .nativeFallback
        }
    }
}

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
        rollbackLabel: "Rollback to --ambitions-shell=native. Meridian remains available with --ambitions-shell=meridian.",
        destinations: AppMeridianDestination.all
    )
}
