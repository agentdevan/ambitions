import ActivityKit
import SwiftUI
import WidgetKit

@main
struct AmbitionsWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextStepWidget()
        if #available(iOS 16.1, *) {
            NextStepLiveActivityWidget()
        }
    }
}
