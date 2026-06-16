#if canImport(SwiftUI)
import SwiftUI

public typealias ObjectStageSurface<Content: View> = AppCard<Content>
public typealias ObjectStageGlance<Content: View> = WidgetCard<Content>
public typealias ObjectStageHero<Content: View> = HeroCard<Content>
#endif
