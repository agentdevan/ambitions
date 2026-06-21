import SwiftUI

struct GoalsObjectView: View {
    let overview: GoalsOverview
    let screenshotProofState: GoalsScreenshotProofState
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void

    var body: some View {
        ConstellationAtlasView(
            overview: overview,
            onPrimaryAction: onPrimaryAction,
            screenshotProofState: screenshotProofState
        )
        .accessibilityLabel(GoalsAccessibility.rootSummary(
            atlasState: overview.bands.isEmpty ? "Empty" : "Ready",
            selectedThread: overview.orbitalLens.activeThreadTitle,
            todayRelationship: overview.constellationAtlasYouSummaryForProjection,
            proofState: overview.constellationAtlasReceiptSummary
        ))
    }
}
