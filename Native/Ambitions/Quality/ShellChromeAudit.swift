import Foundation

enum ShellChromeAudit {
    struct Report: Equatable {
        let findings: [String]

        var passed: Bool { findings.isEmpty }
    }

    static let owner = "Stage/Chrome"
    static let rule = "Dock, crown, overlays, focus restoration, and route restoration are shell systems."

    static func audit(
        policy: StageChromePolicy,
        dockDestinations: [StageDockDestination] = StageDockDestination.all,
        hasDuplicateBottomNavigationShelf: Bool = false,
        nativeTabBarIsVisible: Bool = false
    ) -> Report {
        var findings: [String] = []

        if dockDestinations.map(\.surface) != AmbitionsSurface.allCases {
            findings.append("Root dock destinations must exactly mirror Today, Goals, Time, You.")
        }

        let disallowedDestinationText = dockDestinations.map { destination in
            "\(destination.title) \(destination.accessibilityIdentifier)"
        }
        if disallowedDestinationText.contains(where: { label in
            label.localizedCaseInsensitiveContains("capture") ||
            label.localizedCaseInsensitiveContains("motion") ||
            label.localizedCaseInsensitiveContains("plan")
        }) {
            findings.append("Capture, Motion, and Plan must not appear as root dock destinations.")
        }

        if hasDuplicateBottomNavigationShelf || nativeTabBarIsVisible {
            findings.append("Root shell must not expose duplicate bottom navigation chrome.")
        }

        if policy.showsDockBackdrop {
            findings.append("Root shell Stage OS rail must stay invisible and avoid a dock backdrop.")
        }

        switch policy.routeDepth {
        case .root:
            if policy.overlayPresentation == .none && policy.showsRootDock == false {
                findings.append("Root shell must expose exactly one Ambition Meridian dock.")
            }
        case .drilldown:
            if policy.showsRootDock {
                findings.append("Root dock must be hidden in drilldown routes.")
            }
            if policy.stageContentBottomClearance != 0 {
                findings.append("Drilldown routes must not reserve root dock clearance.")
            }
        }

        if policy.overlayPresentation == .activatedCaptureComposer {
            if policy.showsRootDock {
                findings.append("Activated Capture composer must hide root dock chrome.")
            }
            if policy.captureComposerClearance <= 0 {
                findings.append("Activated Capture composer must retain keyboard/composer clearance.")
            }
        }

        return Report(findings: findings)
    }
}
