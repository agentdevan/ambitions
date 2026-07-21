import SwiftUI
import AmbitionsPresentationContracts
import AmbitionsFlagshipFoundation

public struct FlagshipShell: View {
    @State private var selectedRoot: FlagshipRoot

    public init(selectedRoot: FlagshipRoot = .today) {
        _selectedRoot = State(initialValue: selectedRoot)
    }

    public var body: some View {
        TabView(selection: $selectedRoot) {
            ForEach(FlagshipRoot.allCases, id: \.self) { root in
                NavigationStack {
                    FlagshipRootLoadingView(root: root)
                }
                .tag(root)
                .tabItem {
                    Label(root.title, systemImage: root.systemImage)
                }
            }
        }
    }
}

private struct FlagshipRootLoadingView: View {
    let root: FlagshipRoot

    var body: some View {
        ProgressView("Loading \(root.title)")
        .navigationTitle(root.title)
        .background(FlagshipSemanticColor.canvas)
        .accessibilityIdentifier("flagship.root.\(root.rawValue)")
    }
}

private extension FlagshipRoot {
    var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .time: "Time"
        case .you: "You"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .goals: "scope"
        case .time: "calendar"
        case .you: "person.crop.circle"
        }
    }
}
