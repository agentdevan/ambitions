import AmbitionsDesignSystem
import SwiftUI

struct TodayEmptyPathAction: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let action: TodayInlineAction
}

enum TodayMeridianZoom: String, CaseIterable {
    case window
    case day

    var title: String {
        switch self {
        case .window: "Start Here"
        case .day: "Meridian"
        }
    }
}
