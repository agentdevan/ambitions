@testable import Ambitions
import Foundation
import XCTest

final class FeatureServiceMutationAuthorityTests: XCTestCase {
    func testFeatureServiceRepositoryWritesAreClassifiedBySharedManifest() throws {
        let root = repoRoot().resolvingSymlinksInPath()
        let manifestPath = "docs/qa/local-runtime-proof/feature-service-mutation-authority.json"
        let manifestURL = root.appendingPathComponent(manifestPath)
        let manifest = try JSONDecoder().decode(
            FeatureServiceMutationAuthorityManifest.self,
            from: Data(contentsOf: manifestURL)
        )

        XCTAssertEqual(manifest.schemaVersion, "feature_service_mutation_authority.v1")
        XCTAssertTrue(manifest.allowedClassifications.contains("command_owned"))
        XCTAssertTrue(manifest.allowedClassifications.contains("transaction_owned"))
        XCTAssertTrue(manifest.allowedClassifications.contains("test_only"))
        XCTAssertTrue(manifest.allowedClassifications.contains("explicitly_non_canonical"))

        let allowedPairs = Set(manifest.allowedWritePaths.flatMap { entry in
            entry.allowedCalls.map { "\(entry.path)#\($0)" }
        })
        let callPattern = try NSRegularExpression(
            pattern: #"\b((?:repositories\.[A-Za-z0-9_]+|[A-Za-z0-9_]*(?:Repository|repository)|repository|eventLedger|reminderRepository|appStateRepository|capturePromotionUnitOfWork)\.(?:save[A-Za-z0-9_]*|append|create|update|delete|archive|persist|upsert|record[A-Za-z0-9_]*))\s*\("#
        )

        for fileURL in productionSwiftFiles(root: root) {
            let relativePath = relativePath(for: fileURL, root: root)
            guard manifest.scanIncludedPrefixes.contains(where: { relativePath.hasPrefix($0) }) else {
                continue
            }

            let source = try String(contentsOf: fileURL, encoding: .utf8)
            let nsSource = source as NSString
            let matches = callPattern.matches(
                in: source,
                range: NSRange(location: 0, length: nsSource.length)
            )
            for match in matches {
                let call = nsSource.substring(with: match.range(at: 1))
                let line = lineNumber(in: source, atUTF16Offset: match.range.location)
                XCTAssertTrue(
                    allowedPairs.contains("\(relativePath)#\(call)"),
                    "\(relativePath):\(line) has unclassified service/repository write \(call)"
                )
            }
        }

        for entry in manifest.allowedWritePaths {
            XCTAssertTrue(
                manifest.allowedClassifications.contains(entry.classification),
                "\(entry.path) uses unknown classification \(entry.classification)"
            )
            let sourceURL = root.appendingPathComponent(entry.path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path), entry.path)
            let source = try String(contentsOf: sourceURL, encoding: .utf8)
            for call in entry.allowedCalls {
                XCTAssertTrue(
                    source.contains("\(call)("),
                    "\(entry.path) manifest allows stale call \(call)"
                )
            }
        }
    }

    private func productionSwiftFiles(root: URL) -> [URL] {
        [
            root.appendingPathComponent("Native/Ambitions"),
            root.appendingPathComponent("Native/AmbitionsWidgetExtension"),
            root.appendingPathComponent("Native/AmbitionsShareExtension")
        ]
        .flatMap { sourceRoot -> [URL] in
            guard let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil) else {
                return []
            }
            return enumerator.compactMap { element -> URL? in
                guard let url = element as? URL, url.pathExtension == "swift" else {
                    return nil
                }
                return url.resolvingSymlinksInPath()
            }
        }
        .sorted { $0.path < $1.path }
    }

    private func relativePath(for fileURL: URL, root: URL) -> String {
        fileURL.resolvingSymlinksInPath().path.replacingOccurrences(of: root.path + "/", with: "")
    }

    private func lineNumber(in source: String, atUTF16Offset offset: Int) -> Int {
        let prefix = (source as NSString).substring(to: offset)
        return prefix.reduce(1) { line, character in
            character == "\n" ? line + 1 : line
        }
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("docs/qa/local-runtime-proof/feature-service-mutation-authority.json")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private struct FeatureServiceMutationAuthorityManifest: Decodable {
    let schemaVersion: String
    let scanIncludedPrefixes: [String]
    let allowedClassifications: [String]
    let allowedWritePaths: [FeatureServiceMutationAuthorityEntry]
}

private struct FeatureServiceMutationAuthorityEntry: Decodable {
    let path: String
    let classification: String
    let allowedCalls: [String]
    let rationale: String
}
