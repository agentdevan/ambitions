import AmbitionsDesignSystem
import SwiftUI

struct StageContextHeader: View {
    let title: String
    let contextPhrase: String

    var body: some View {
        ContextCrownHeader(
            title: title,
            contextPhrase: contextPhrase
        )
    }
}
