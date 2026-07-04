import Foundation

actor CaptureRoutingJSONFileStore<Value: Codable & Sendable> {
    private let fileURL: URL
    private let emptyValue: Value
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileURL: URL, emptyValue: Value) {
        self.fileURL = fileURL
        self.emptyValue = emptyValue
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
    }

    func load() throws -> Value {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return emptyValue
        }
        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else {
            return emptyValue
        }
        return try decoder.decode(Value.self, from: data)
    }

    func save(_ value: Value) throws {
        let fileManager = FileManager.default
        let directory = fileURL.deletingLastPathComponent()
        if fileManager.fileExists(atPath: directory.path) == false {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: [.atomic])
        CaptureRoutingLocalFileProtection.apply(to: fileURL)
    }

    static func defaultRootDirectory() -> URL {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        return supportDirectory.appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
            .appendingPathComponent("CaptureRouting", isDirectory: true)
    }

    static func fileURL(rootDirectory: URL, fileName: String) -> URL {
        rootDirectory.appendingPathComponent(fileName, isDirectory: false)
    }
}

enum CaptureRoutingLocalFileProtection {
    static func apply(to fileURL: URL) {
        #if os(iOS)
        try? FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: fileURL.path
        )
        #else
        _ = fileURL
        #endif
    }
}
