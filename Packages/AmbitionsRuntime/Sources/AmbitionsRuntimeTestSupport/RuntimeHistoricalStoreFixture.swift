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
        let descriptor = url.path.withCString { path -> Int32 in
            #if canImport(Darwin)
            Darwin.open(path, O_RDONLY | O_NOFOLLOW)
            #else
            Glibc.open(path, O_RDONLY | O_NOFOLLOW)
            #endif
        }
        guard descriptor >= 0 else {
            throw RuntimeHistoricalStoreFixtureError.notRegularFile(url)
        }
        defer {
            #if canImport(Darwin)
            _ = Darwin.close(descriptor)
            #else
            _ = Glibc.close(descriptor)
            #endif
        }
        var status = stat()
        #if canImport(Darwin)
        let statusResult = Darwin.fstat(descriptor, &status)
        #else
        let statusResult = Glibc.fstat(descriptor, &status)
        #endif
        guard statusResult == 0, status.st_mode & S_IFMT == S_IFREG else {
            throw RuntimeHistoricalStoreFixtureError.notRegularFile(url)
        }
        let observedDigest: String
        do {
            observedDigest = try digest(descriptor)
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

    private static func digest(_ descriptor: Int32) throws -> String {
        #if canImport(Darwin)
        guard Darwin.lseek(descriptor, 0, SEEK_SET) >= 0 else {
            throw POSIXError(.EIO)
        }
        #else
        guard Glibc.lseek(descriptor, 0, SEEK_SET) >= 0 else {
            throw POSIXError(.EIO)
        }
        #endif
        var hasher = SHA256()
        var buffer = [UInt8](repeating: 0, count: 1_048_576)
        while true {
            let count: Int
            #if canImport(Darwin)
            count = Darwin.read(descriptor, &buffer, buffer.count)
            #else
            count = Glibc.read(descriptor, &buffer, buffer.count)
            #endif
            guard count >= 0 else { throw POSIXError(.EIO) }
            guard count > 0 else { break }
            hasher.update(data: Data(buffer[0..<count]))
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
