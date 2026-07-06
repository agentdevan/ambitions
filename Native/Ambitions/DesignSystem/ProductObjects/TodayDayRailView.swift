import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsDayRailView: View {
    @Environment(\.ambitionTheme) var theme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void
    let clock: any AmbitionsClock

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in },
        onShowAnother: @escaping (DayRailHeroStepState) -> Void = { _ in },
        onNotThis: @escaping (DayRailHeroStepState) -> Void = { _ in },
        clock: any AmbitionsClock = SystemClock()
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
        self.onShowAnother = onShowAnother
        self.onNotThis = onNotThis
        self.clock = clock
    }

    var body: some View {
        let objectStageContract = TodayObjectStagePrimitiveContract.current
        let viewport = viewportSafety

        ZStack(alignment: .bottom) {
            meridianAtmosphere

            GeometryReader { proxy in
                let horizontalInset = usesExpandedViewport
                    ? theme.spacing.md
                    : max(theme.spacing.md, proxy.size.width * 0.055)
                let railWidth = usesExpandedViewport ? 34.0 : max(68.0, proxy.size.width * 0.19)

                VStack(alignment: .leading, spacing: 0) {
                    if usesExpandedViewport {
                        accessibilityContextCrown
                    } else {
                        compactContextCrown
                            .padding(.bottom, theme.spacing.md)
                    }

                    if viewport.usesStackedAccessibilityRail {
                        VStack(alignment: .leading, spacing: theme.spacing.lg) {
                            if let heroStep = state.heroStep {
                                currentMoment(heroStep)
                                    .padding(.top, theme.spacing.xs)
                            } else {
                                emptyMoment
                                    .padding(.top, theme.spacing.xs)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, theme.spacing.lg)
                    } else {
                        HStack(alignment: .top, spacing: theme.spacing.lg) {
                            timeSpine
                                .frame(width: railWidth)

                            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                                if let heroStep = state.heroStep {
                                    currentMoment(heroStep)
                                        .padding(.top, theme.spacing.sm)
                                } else {
                                    emptyMoment
                                        .padding(.top, theme.spacing.sm)
                                }

                                upNextList
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, theme.spacing.xl)
                    }

                    Spacer(minLength: theme.spacing.lg)
                }
                .padding(.horizontal, horizontalInset)
                .padding(.top, viewport.topChromeClearance)
                .padding(.bottom, viewport.railBottomContentClearance)
            }
        }
        .frame(maxWidth: .infinity, minHeight: viewport.railMinHeight, alignment: .top)
        .padding(.horizontal, -theme.spacing.lg)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(objectStageContract.firstViewportStructure)
        .accessibilityIdentifier("TodayRealityRail")
    }
}
