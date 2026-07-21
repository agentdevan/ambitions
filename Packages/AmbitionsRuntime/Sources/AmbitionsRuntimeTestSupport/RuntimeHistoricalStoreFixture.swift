import CryptoKit
import Foundation

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

public struct RuntimeHistoricalStoreFixture: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let immutableURL: URL
    public let digest: String

    public static func load(
        immutableURL: URL,
        expectedDigest: String
    ) throws -> Self {
        let url = immutableURL.standardizedFileURL
        guard try isRegularFileWithoutFollowingLinks(url) else {
            throw RuntimeHistoricalStoreFixtureError.notRegularFile(url)
        }
        let observedDigest: String
        do {
            observedDigest = try digest(url)
        } catch {
            throw RuntimeHistoricalStoreFixtureError.fileReadFailed(
                String(describing: error)
            )
        }
        guard observedDigest == expectedDigest else {
            throw RuntimeHistoricalStoreFixtureError.digestMismatch(
                expected: expectedDigest,
                actual: observedDigest
            )
        }
        return Self(
            schemaVersion: 1,
            immutableURL: url,
            digest: observedDigest
        )
    }

    private static func isRegularFileWithoutFollowingLinks(_ url: URL) throws -> Bool {
        var fileStatus = stat()
        let result = url.path.withCString { path in
            lstat(path, &fileStatus)
        }
        guard result == 0 else { return false }
        return fileStatus.st_mode & S_IFMT == S_IFREG
    }

    private static func digest(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 1_048_576) ?? Data()
            guard !data.isEmpty else { break }
            hasher.update(data: data)
        }
        return hasher.finalize()
            .map { String(format: "%02x", $0) }
            .joined()
    }
}

public enum RuntimeHistoricalStoreFixtureError: Error, Sendable, Equatable {
    case notRegularFile(URL)
    case digestMismatch(expected: String, actual: String)
    case fileReadFailed(String)
}
