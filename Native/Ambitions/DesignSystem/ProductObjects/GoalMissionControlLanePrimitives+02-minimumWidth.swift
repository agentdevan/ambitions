import AmbitionsDesignSystem
import SwiftUI

extension MissionControlLaneDensity {
    var minimumWidth: CGFloat {
        switch self {
        case .compact:
            142
        case .standard:
            154
        case .expanded:
            184
        }
    }


    var minimumHeight: CGFloat {
        switch self {
        case .compact:
            132
        case .standard:
            152
        case .expanded:
            176
        }
    }


    var detailLineLimit: Int {
        switch self {
        case .compact:
            2
        case .standard:
            3
        case .expanded:
            4
        }
    }
}
