import Foundation

enum SourceInspectionCopyAudit {
    private static let forbiddenReadinessFragments = [
        "release",
        "app store",
        "testflight",
    ].map { "\($0) ready" }

    static let forbiddenUserFacingFragments = [
        "shard",
        "r2 object",
        "private graph",
        "manifest internals",
        "integration layer",
        "lattice",
        "compiler",
        "provenance internals",
        "debug",
        "diagnostic",
        "console",
        "dashboard",
    ] + forbiddenReadinessFragments

    static func validate(_ presentations: [SourceInspectionPresentation]) -> [String] {
        presentations.flatMap(validate(_:))
    }

    static func validate(_ presentation: SourceInspectionPresentation) -> [String] {
        let copy = [
            presentation.title,
            presentation.subtitle,
            presentation.publicDetail.sourceName,
            presentation.publicDetail.sourceKind,
            presentation.publicDetail.referenceTitle,
            presentation.publicDetail.retrievedLabel,
            presentation.publicDetail.freshnessLabel,
            presentation.publicDetail.useLabel,
            presentation.privacySummary,
            presentation.hiddenByDefaultSummary,
            presentation.accessibilityLabel,
            presentation.accessibilityValue,
            presentation.accessibilityHint,
            presentation.semanticAnnouncement,
            presentation.redactionSummary,
            presentation.reduceMotionSummary,
        ] + presentation.contextRows.flatMap { [$0.title, $0.detail] }

        let joined = copy.joined(separator: " ").lowercased()
        var failures = forbiddenUserFacingFragments
            .filter { joined.contains($0) }
            .map { "source inspection copy contains forbidden user-facing fragment: \($0)" }

        if presentation.hiddenByDefaultSummary.localizedCaseInsensitiveContains("only when requested") == false {
            failures.append("source inspection copy must preserve hidden-by-default review wording")
        }
        if presentation.privacySummary.localizedCaseInsensitiveContains("personal goals") == false ||
            presentation.privacySummary.localizedCaseInsensitiveContains("account secrets") == false {
            failures.append("source inspection copy must state that personal details and account secrets stay out")
        }
        if presentation.state.blocksCurrentUse &&
            presentation.subtitle.localizedCaseInsensitiveContains("guide") == false &&
            presentation.subtitle.localizedCaseInsensitiveContains("use") == false {
            failures.append("blocked source inspection states must honestly explain use limits")
        }

        return failures
    }
}
