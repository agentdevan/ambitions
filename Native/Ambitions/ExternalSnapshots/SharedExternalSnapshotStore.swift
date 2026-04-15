import Foundation

enum SharedExternalSnapshotStore {
    static let appGroupIdentifier = "group.com.ambitions.shared"
    static let relativeDirectory = "ExternalSnapshots"
    static let fileName = "external-snapshot.v1.json"

    static func snapshotFileURL(fileManager: FileManager = .default) -> URL {
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return groupURL
                .appendingPathComponent(relativeDirectory, isDirectory: true)
                .appendingPathComponent(fileName)
        }

        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            return appSupport
                .appendingPathComponent(relativeDirectory, isDirectory: true)
                .appendingPathComponent(fileName)
        }

        return fileManager.temporaryDirectory
            .appendingPathComponent(relativeDirectory, isDirectory: true)
            .appendingPathComponent(fileName)
    }
}
