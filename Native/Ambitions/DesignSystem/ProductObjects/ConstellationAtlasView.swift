import AmbitionsDesignSystem
import SwiftUI

struct ConstellationAtlasView: View {
    @Environment(\.ambitionTheme) var theme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @State var isOrbitalLensExpanded: Bool
    @State var selectedLifeAreaID: String?
    let overview: GoalsOverview
    let onPrimaryAction: (GoalsAtlasPrimaryAction) -> Void
    let screenshotProofState: GoalsScreenshotProofState

    init(
        overview: GoalsOverview,
        onPrimaryAction: @escaping (GoalsAtlasPrimaryAction) -> Void,
        screenshotProofState: GoalsScreenshotProofState = .defaultAtlas
    ) {
        self.overview = overview
        self.onPrimaryAction = onPrimaryAction
        self.screenshotProofState = screenshotProofState
        _isOrbitalLensExpanded = State(initialValue: screenshotProofState.expandsOrbitalLens)
        _selectedLifeAreaID = State(initialValue: screenshotProofState.highlightsSelectedLifeArea ? overview.lifeAreas.items.first(where: { $0.title == overview.orbitalLens.selectedLifeAreaTitle })?.id : nil)
    }

    var body: some View {
        let stageScene = GoalsLens.makeStageScene(for: overview)

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            contextCrown
            if screenshotProofState.prioritizesOrbitalLens {
                orbitalLens
                equalWeightLifeAreaBand
                atlasObject
            } else {
                equalWeightLifeAreaBand
                atlasObject
                orbitalLens
            }
            sourceProofTrustAffordance
            nativeDock
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("goals.constellation-atlas.stage")
        .accessibilityValue(overview.constellationAtlasAccessibilityValue)
        .accessibilityHint(stageScene.satisfiesArchitectureTree
            ? "Life Areas, proof, and the Today connection stay available for review."
            : "Goal relationships stay available for review.")
    }
}
