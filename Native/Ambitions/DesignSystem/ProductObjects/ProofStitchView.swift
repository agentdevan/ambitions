import AmbitionsDesignSystem
import SwiftUI

struct ProofStitchView: View {
    @Environment(\.ambitionTheme) private var theme

    let source: String
    let proof: String
    let receipt: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ReceiptSurface(source: source, receipt: receipt, status: proof)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("product.proof-stitch")
    }
}
