import AmbitionsDesignSystem
import SwiftUI

extension ConstellationAtlasView {

    func atlasRelationshipTraceLabel(for item: GoalsLifeAreaItemState) -> String {
        item.todayTraceSummary.localizedCaseInsensitiveContains("Today") ? "Today" : "Linked"
    }


    func atlasRelationshipTitleLabel(for item: GoalsLifeAreaItemState) -> String {
        item.title == "Relationships" ? "Relations" : item.title
    }
}
