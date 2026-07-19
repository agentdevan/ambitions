import Foundation

enum ScreenContractValidator {
    static let canonicalTopLevelTabs = ["Today", "Goals", "Time", "You"]

    static let forbiddenTopLevelTabTitles = [
        "Capture",
        "Motion",
        "Tasks",
        "Insights",
        "Habits",
        "Calendar"
    ]

    static let forbiddenCopyFragments = ForbiddenTopLevelTerms.terms + [
        "AI Explanation",
        "Model Reasoning",
        "Confidence score",
        "Fix AI",
        "Mission Control",
        "User System You",
        "Action Closure",
        "Proof Rail",
        "Believability hero",
        "Low score",
        "You are behind",
        "Neglected",
        "Unoptimized",
        "Failed"
    ]

    static func validate(
        snapshot: ScreenContractImplementationSnapshot,
        against contract: ScreenContract
    ) -> [ScreenContractValidationIssue] {
        var issues: [ScreenContractValidationIssue] = []

        for content in contract.requiredFirstScreenContent {
            if !snapshot.firstScreenContent.contains(where: { matches($0, content) }) {
                issues.append(issue(.missingFirstScreenContent, contract.id, content, "First-screen content is missing."))
            }
        }

        let snapshotPanels = Set(snapshot.panels)
        for panel in contract.requiredPanels where !snapshotPanels.contains(panel) {
            issues.append(issue(.missingRequiredPanel, contract.id, panel.rawValue, "Required panel is missing."))
        }

        let snapshotActions = Set(snapshot.actions)
        for action in contract.primaryActions where !snapshotActions.contains(action) {
            issues.append(issue(.missingPrimaryAction, contract.id, action.rawValue, "Primary action is missing."))
        }

        let textSamples = snapshot.firstScreenContent + snapshot.copySamples
        for forbidden in contract.forbiddenFirstScreenContent {
            if textSamples.contains(where: { contains($0, forbidden) }) {
                issues.append(issue(.forbiddenFirstScreenContent, contract.id, forbidden, "Forbidden first-screen content is present."))
            }
        }

        for forbidden in forbiddenCopyFragments {
            if textSamples.contains(where: { contains($0, forbidden) }) {
                issues.append(issue(.forbiddenCopy, contract.id, forbidden, "Forbidden copy fragment is present."))
            }
        }

        if !snapshot.topLevelTabTitles.isEmpty {
            if snapshot.topLevelTabTitles != canonicalTopLevelTabs ||
                snapshot.topLevelTabTitles.contains(where: { forbiddenTopLevelTabTitles.contains($0) }) {
                issues.append(issue(.invalidTopLevelTabs, contract.id, snapshot.topLevelTabTitles.joined(separator: ", "), "Top-level tabs must remain Today, Goals, Time, You."))
            }
        }

        if !snapshot.supportsDensityBehavior {
            issues.append(issue(.missingDensityBehavior, contract.id, contract.densityBehavior, "Density behavior is not represented."))
        }

        if !snapshot.supportsPanelSizeBehavior {
            issues.append(issue(.missingPanelSizeBehavior, contract.id, contract.panelSizeBehavior, "Panel size behavior is not represented."))
        }

        if !snapshot.hasAccessibilitySummary {
            issues.append(issue(.missingAccessibilitySummary, contract.id, contract.accessibilityRequirements.joined(separator: " | "), "Accessibility summary is missing."))
        }

        if !snapshot.hasPrivacySafeState {
            issues.append(issue(.missingPrivacySafeState, contract.id, contract.trustPrivacyRequirements.joined(separator: " | "), "Privacy-safe state is missing."))
        }

        if !snapshot.hasGestureAlternative {
            issues.append(issue(.missingGestureAlternative, contract.id, ScreenContractGuardrail.noGestureOnlyNavigation.rawValue, "Visible gesture alternative is missing."))
        }

        return issues
    }

    static func validateRegistry(_ contracts: [ScreenContract]) -> [ScreenContractValidationIssue] {
        let topLevelTitles = contracts.compactMap(\.canonicalTopLevelTitle)
        guard topLevelTitles != canonicalTopLevelTabs else { return [] }

        return [
            issue(
                .invalidTopLevelTabs,
                .today,
                topLevelTitles.joined(separator: ", "),
                "Contract registry top-level screens must remain Today, Goals, Time, You."
            )
        ]
    }

    static func issue(
        _ kind: ScreenContractValidationIssueKind,
        _ screenID: ScreenContractID,
        _ requirement: String,
        _ message: String
    ) -> ScreenContractValidationIssue {
        ScreenContractValidationIssue(
            screenID: screenID,
            kind: kind,
            requirement: requirement,
            message: message
        )
    }

    static func matches(_ candidate: String, _ requirement: String) -> Bool {
        candidate.compare(requirement, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }

    static func contains(_ candidate: String, _ fragment: String) -> Bool {
        candidate.range(of: fragment, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}
