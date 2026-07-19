import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class LiquidGlassTokenLayerTests: XCTestCase {
    func testShellGlassTokensProvideNativeVariantsAcrossBothThemeModes() {
        for mode in AmbitionThemeMode.allCases {
            let theme = AmbitionTheme.theme(for: mode)

            XCTAssertGreaterThan(theme.shell.glass.containerSpacing, 0)
            XCTAssertGreaterThan(theme.panel.minimumTapTarget, 43)

            if #available(iOS 26, *) {
                XCTAssertNotEqual(theme.shell.glass.controlGlass, .identity)
                XCTAssertNotEqual(theme.shell.glass.headerGlass, .identity)
                XCTAssertNotEqual(theme.shell.glass.bottomBarGlass, .identity)
            }
        }
    }

    func testLiquidGlassDecisionDisablesForReduceTransparencyAndIncreasedContrast() {
        XCTAssertFalse(
            ambitionShouldUseLiquidGlass(
                reduceTransparency: true,
                colorSchemeContrast: .standard
            )
        )
        XCTAssertFalse(
            ambitionShouldUseLiquidGlass(
                reduceTransparency: false,
                colorSchemeContrast: .increased
            )
        )

        if #available(iOS 26, *) {
            XCTAssertTrue(
                ambitionShouldUseLiquidGlass(
                    reduceTransparency: false,
                    colorSchemeContrast: .standard
                )
            )
        } else {
            XCTAssertFalse(
                ambitionShouldUseLiquidGlass(
                    reduceTransparency: false,
                    colorSchemeContrast: .standard
                )
            )
        }
    }
}
