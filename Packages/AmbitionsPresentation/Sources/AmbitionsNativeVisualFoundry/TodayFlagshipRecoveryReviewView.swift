import SwiftUI

struct TodayFlagshipRecoveryReviewView: View {
    let content: TodayFlagshipCalibrationContent
    @Binding var state: TodayFlagshipJourneyState

    var body: some View {
        TodayVitalityRecoverySheetView(content: content, state: $state)
    }
}
