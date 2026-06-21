import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsTypography {
    let theme: AmbitionTheme

    var hero: Font { theme.typography.heroDisplay }
    var objectTitle: Font { theme.typography.titleCompact }
    var sectionTitle: Font { theme.typography.sectionTitle }
    var body: Font { theme.typography.body }
    var caption: Font { theme.typography.caption }
    var micro: Font { theme.typography.micro }

    static let dynamicTypeContract = "Primary object typography uses system fonts and preserves Dynamic Type scaling."
}
