import AmbitionsDesignSystem
import SwiftUI

struct LaunchGateView: View {
    @Bindable var bootstrapper: AppBootstrapper

    var body: some View {
        AppCanvasView {
            switch bootstrapper.phase {
            case .idle, .launching:
                loadingView
            case let .ready(container):
                AmbitionsStageHost(container: container)
            case let .failed(message):
                failureView(message: message)
            }
        }
        .task {
            await bootstrapper.start()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 24) {
            HeroCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ambitions")
                        .font(.largeTitle.bold())

                    Text("Preparing your native planning workspace.")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    ProgressView()
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func failureView(message: String) -> some View {
        VStack(spacing: 24) {
            AppCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ambitions could not finish launching")
                        .font(.title2.bold())

                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Button("Retry") {
                        Task {
                            await bootstrapper.retry()
                        }
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .warning))
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
