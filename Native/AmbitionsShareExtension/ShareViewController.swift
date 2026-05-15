import SwiftUI
import UniformTypeIdentifiers
import UIKit

final class ShareViewController: UIViewController {
    private let store = SharedExternalCreationStore()
    private var initialPayload = ShareExtensionPayload()

    override func viewDidLoad() {
        super.viewDidLoad()

        let host = UIHostingController(
            rootView: ShareIntakeView(
                initialPayload: initialPayload,
                onSave: { [weak self] text, landing in
                    self?.save(text: text, landing: landing)
                },
                onCancel: { [weak self] in
                    self?.cancelShareRequest()
                }
            )
        )
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)

        Task { await loadPayload() }
    }

    private func loadPayload() async {
        let payload = await ShareExtensionPayloadLoader(context: extensionContext).load()
        initialPayload = payload
        if let hosting = children.first as? UIHostingController<ShareIntakeView> {
            hosting.rootView = ShareIntakeView(
                initialPayload: payload,
                onSave: { [weak self] text, landing in
                    self?.save(text: text, landing: landing)
                },
                onCancel: { [weak self] in
                    self?.cancelShareRequest()
                }
            )
        }
    }

    private func save(text: String, landing: ExternalCreationLanding) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        let request = ExternalCreationRequest(
            id: "share-\(UUID().uuidString)",
            createdAt: ISO8601DateFormatter().string(from: Date()),
            text: trimmed,
            source: initialPayload.url == nil ? .shareExtensionText : .shareExtensionURL,
            sourceApplication: initialPayload.sourceApplication,
            sourceURL: initialPayload.url?.absoluteString,
            landing: landing
        )

        do {
            try store.append(request)
            openAmbitions(landing: landing)
        } catch {
            extensionContext?.cancelRequest(withError: error)
        }
    }

    private func openAmbitions(landing: ExternalCreationLanding) {
        let url: URL? = {
            switch landing {
            case .captureInbox:
                return ExternalSurfaceActionPayload.deepLinkURL(
                    surface: .captureInbox,
                    origin: .shareExtension
                )
            case .createGoal:
                var components = URLComponents()
                components.scheme = "ambitions"
                components.host = "overlay"
                components.path = "/create-goal"
                components.queryItems = [
                    URLQueryItem(name: "origin", value: ExternalSurfaceOrigin.shareExtension.rawValue),
                ]
                return components.url
            }
        }()

        guard let url else {
            completeShareRequest()
            return
        }

        extensionContext?.open(url) { [weak self] _ in
            Task { @MainActor in
                self?.completeShareRequest()
            }
        }
    }

    private func cancelShareRequest() {
        extensionContext?.cancelRequest(withError: ShareExtensionError.cancelled)
    }

    private func completeShareRequest() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}

private enum ShareExtensionError: LocalizedError {
    case cancelled

    var errorDescription: String? {
        "Share cancelled."
    }
}

struct ShareExtensionPayload: Equatable {
    var text: String = ""
    var url: URL?
    var sourceApplication: String?
}

private struct ShareExtensionPayloadLoader {
    let context: NSExtensionContext?

    func load() async -> ShareExtensionPayload {
        guard let item = context?.inputItems.compactMap({ $0 as? NSExtensionItem }).first else {
            return ShareExtensionPayload()
        }

        let providers = item.attachments ?? []
        var payload = ShareExtensionPayload(sourceApplication: item.attributedContentText?.string)

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
               let url = await loadURL(from: provider) {
                payload.url = url
                payload.text = url.absoluteString
                return payload
            }
        }

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier),
               let text = await loadString(from: provider) {
                payload.text = text
                return payload
            }
        }

        return payload
    }

    private func loadURL(from provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    continuation.resume(returning: url)
                } else if let string = item as? String {
                    continuation.resume(returning: URL(string: string))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    private func loadString(from provider: NSItemProvider) async -> String? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, _ in
                if let string = item as? String {
                    continuation.resume(returning: string)
                } else if let data = item as? Data {
                    continuation.resume(returning: String(data: data, encoding: .utf8))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
