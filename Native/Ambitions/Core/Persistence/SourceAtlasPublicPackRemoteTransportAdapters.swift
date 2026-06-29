import Foundation

struct SourceAtlasPublicPackRemoteEndpoint: Codable, Sendable, Equatable, Hashable {
    static let sourceAtlasPublicGatewayBaseURLString = "https://ambitions-source-atlas-public-gateway.devanwarner.workers.dev"
    static let sourceAtlasPublicGateway = SourceAtlasPublicPackRemoteEndpoint(
        baseURLString: sourceAtlasPublicGatewayBaseURLString
    )

    let baseURLString: String

    init(baseURLString: String) {
        self.baseURLString = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func url(for request: SourceAtlasPublicPackRemoteObjectRequest) -> URL? {
        guard validationIssues.isEmpty, request.validationIssues.isEmpty else {
            return nil
        }
        let base = Self.trimmingTrailingSlashes(baseURLString)
        let objectKey = Self.trimmingLeadingSlashes(request.objectKey)
        return URL(string: "\(base)/\(objectKey)")
    }

    var validationIssues: [SourceAtlasPublicPackRemoteTransportIssue] {
        guard let url = URL(string: baseURLString),
              let scheme = url.scheme?.lowercased(),
              scheme == "https",
              url.host?.isEmpty == false,
              url.user == nil,
              url.password == nil,
              url.query == nil,
              url.fragment == nil
        else {
            return [.invalidEndpoint]
        }
        return []
    }

    private static func trimmingTrailingSlashes(_ value: String) -> String {
        var result = value
        while result.hasSuffix("/") {
            result.removeLast()
        }
        return result
    }

    private static func trimmingLeadingSlashes(_ value: String) -> String {
        var result = value
        while result.hasPrefix("/") {
            result.removeFirst()
        }
        return result
    }
}

struct SourceAtlasURLSessionPublicPackRemoteTransport: SourceAtlasPublicPackRemoteTransport {
    let endpoint: SourceAtlasPublicPackRemoteEndpoint

    init(endpoint: SourceAtlasPublicPackRemoteEndpoint) {
        self.endpoint = endpoint
    }

    func fetch(_ objectRequest: SourceAtlasPublicPackRemoteObjectRequest) async throws -> Data {
        guard let url = endpoint.url(for: objectRequest) else {
            throw SourceAtlasPublicPackRemoteTransportError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        if let http = response as? HTTPURLResponse,
           (200...299).contains(http.statusCode) == false {
            throw SourceAtlasPublicPackRemoteTransportError.httpStatus(http.statusCode)
        }
        return data
    }
}

struct SourceAtlasStaticPublicPackRemoteTransport: SourceAtlasPublicPackRemoteTransport {
    let objectsByKey: [String: Data]

    init(objectsByKey: [String: Data]) {
        self.objectsByKey = objectsByKey
    }

    func fetch(_ request: SourceAtlasPublicPackRemoteObjectRequest) async throws -> Data {
        guard let data = objectsByKey[request.objectKey] else {
            throw SourceAtlasPublicPackRemoteTransportError.missingObject(request.objectKey)
        }
        return data
    }
}
