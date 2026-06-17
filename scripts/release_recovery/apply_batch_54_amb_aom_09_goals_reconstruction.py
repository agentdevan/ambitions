#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GOALS = ROOT / "Native" / "Ambitions" / "Features" / "Goals" / "GoalComponents.swift"
TEST = ROOT / "Native" / "AmbitionsTests" / "Goals" / "GoalsConstellationAtlasReconstructionTests.swift"
OUT = ROOT / "artifacts" / "object-stage-mega-train"
RECON = OUT / "reconciliation"
RECON.mkdir(parents=True, exist_ok=True)

text = GOALS.read_text(encoding="utf-8")

text = text.replace(
    "    @State private var isOrbitalLensExpanded: Bool\n",
    "    @State private var isOrbitalLensExpanded: Bool\n    @State private var selectedLifeAreaID: String?\n",
)
text = text.replace(
    "        _isOrbitalLensExpanded = State(initialValue: screenshotProofState.expandsOrbitalLens)\n",
    "        _isOrbitalLensExpanded = State(initialValue: screenshotProofState.expandsOrbitalLens)\n        _selectedLifeAreaID = State(initialValue: screenshotProofState.highlightsSelectedLifeArea ? overview.lifeAreas.items.first(where: { $0.title == overview.orbitalLens.selectedLifeAreaTitle })?.id : nil)\n",
)
old_display = '''    private var displayedLifeAreaItems: [GoalsLifeAreaItemState] {
        guard screenshotProofState.highlightsSelectedLifeArea,
              let selectedIndex = overview.lifeAreas.items.firstIndex(where: { $0.title == overview.orbitalLens.selectedLifeAreaTitle }) else {
            return overview.lifeAreas.items
        }

        var items = overview.lifeAreas.items
        let selected = items.remove(at: selectedIndex)
        return [selected] + items
    }
'''
new_display = '''    private var selectedLifeAreaTitle: String? {
        if let selectedLifeAreaID,
           let selected = overview.lifeAreas.items.first(where: { $0.id == selectedLifeAreaID }) {
            return selected.title
        }
        guard screenshotProofState.highlightsSelectedLifeArea else { return nil }
        return overview.orbitalLens.selectedLifeAreaTitle
    }

    private var displayedLifeAreaItems: [GoalsLifeAreaItemState] {
        guard let selectedLifeAreaTitle,
              let selectedIndex = overview.lifeAreas.items.firstIndex(where: { $0.title == selectedLifeAreaTitle }) else {
            return overview.lifeAreas.items
        }

        var items = overview.lifeAreas.items
        let selected = items.remove(at: selectedIndex)
        return [selected] + items
    }
'''
if old_display not in text:
    raise SystemExit("Expected displayedLifeAreaItems block not found")
text = text.replace(old_display, new_display)
text = text.replace(
    "                        isSelected: screenshotProofState.highlightsSelectedLifeArea\n                            && item.title == overview.orbitalLens.selectedLifeAreaTitle\n",
    "                        isSelected: item.id == selectedLifeAreaID\n                            || (screenshotProofState.highlightsSelectedLifeArea && item.title == overview.orbitalLens.selectedLifeAreaTitle)\n",
)
start = text.index("    private func equalWeightLifeAreaChip")
end = text.index("\n    private var atlasObject", start)
old_chip = text[start:end]
new_chip = '''    private func equalWeightLifeAreaChip(_ item: GoalsLifeAreaItemState, isSelected: Bool) -> some View {
        Button {
            let selection = {
                selectedLifeAreaID = item.id
                isOrbitalLensExpanded = true
            }
            if reduceMotion {
                selection()
            } else {
                withAnimation(.snappy(duration: 0.24), selection)
            }
        } label: {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                if isSelected {
                    Image(systemName: "scope")
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.accentPrimary)
                        .accessibilityHidden(true)
                }
                Text(equalWeightLifeAreaTitleLabel(for: item))
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .allowsTightening(true)
                Text(equalWeightLifeAreaTraceLabel(for: item))
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .frame(minHeight: 48, alignment: .topLeading)
            .padding(.vertical, theme.spacing.xs)
            .padding(.horizontal, theme.spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(isSelected ? theme.colors.accentPrimary.opacity(0.88) : theme.colors.strokeSubtle.opacity(0.46))
                .frame(height: isSelected || colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.66 : 0.24))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(isSelected ? theme.colors.accentPrimary.opacity(0.88) : theme.colors.strokeSubtle.opacity(0.34))
                .frame(width: isSelected || colorSchemeContrast == .increased ? 3 : 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(isSelected ? "Selected Life Area. \\(item.accessibilityValue)" : item.accessibilityValue)
        .accessibilityHint("Choose this Life Area to open its active thread lens. \\(item.accessibilityHint)")
        .accessibilityIdentifier("goals.life-area.\\(item.id).button")
    }
'''
text = text[:start] + new_chip + text[end:]

for marker in ["selectedLifeAreaID", "Choose this Life Area", "goals.life-area.\\(item.id).button", "withAnimation(.snappy"]:
    if marker not in text:
        raise SystemExit(f"Missing Goals reconstruction marker: {marker}")
GOALS.write_text(text, encoding="utf-8")

TEST.write_text(
    """import XCTest
@testable import Ambitions

final class GoalsConstellationAtlasReconstructionTests: XCTestCase {
    func testGoalsObjectStageContractOwnsConstellationAtlas() {
        let contract = GoalsObjectStagePrimitiveContract.current
        XCTAssertEqual(contract.ownerSurface, "Goals")
        XCTAssertEqual(contract.stageName, "Constellation Atlas")
        XCTAssertTrue(contract.avoidsGenericGoalRootOutput)
        XCTAssertTrue(contract.firstViewportStructure.contains("life-area"))
        XCTAssertTrue(contract.firstViewportStructure.contains("Today"))
    }

    func testGoalsContractKeepsInspectionProgressive() {
        let contract = GoalsObjectStagePrimitiveContract.current
        XCTAssertTrue(contract.firstViewportStructure.contains("progressive trust inspection"))
        XCTAssertTrue(contract.sourceTrustLineOrder.contains("Today link"))
    }
}
""",
    encoding="utf-8",
)

report = """# AMB-AOM-09 Goals Reconstruction

Status: `GREEN_SOURCE_DELTA`

This deterministic Autopilot batch starts AMB-AOM-09 by making Life Areas actionable inside the Constellation Atlas first viewport instead of leaving them as passive labels.

## Source changes

- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/AmbitionsTests/Goals/GoalsConstellationAtlasReconstructionTests.swift`

## Scope result

- Goals remains Constellation Atlas.
- Life Areas are actionable buttons with selected state.
- Choosing a Life Area opens the Orbital Lens inspection layer instead of creating or mutating a goal silently.
- Goal Threads remain available through the Orbital Lens open-thread action.
- Today connection remains in the Atlas relationship/trust language.
- Accessibility labels, values, hints, identifiers, Dynamic Type, and Reduce Motion behavior remain preserved.

## Next gate

Run AMB-AOM-09 follow-up validation for no dashboard/list regression and screenshot-proof readiness.
"""
(OUT / "AMB-AOM-09-report.md").write_text(report, encoding="utf-8")
(RECON / "AMB-AOM-09-goals-reconstruction.md").write_text(report, encoding="utf-8")
print("AMB-AOM-09 Goals reconstruction source delta written.")
