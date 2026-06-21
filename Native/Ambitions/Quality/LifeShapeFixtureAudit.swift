import Foundation

struct LifeShapeSourceFile: Equatable, Sendable {
    let path: String
    let contents: String
}

struct LifeShapeAuditFinding: Equatable, Sendable {
    let id: String
    let path: String
    let detail: String
}

struct LifeShapeAuditReport: Equatable, Sendable {
    let findings: [LifeShapeAuditFinding]

    var passed: Bool { findings.isEmpty }

    func containsFinding(_ id: String) -> Bool {
        findings.contains { $0.id == id }
    }
}

enum LifeShapeAuditSupport {
    static func releaseScopedContents(_ contents: String) -> String {
        var output: [String] = []
        var debugDepth = 0

        for line in contents.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#if DEBUG") {
                debugDepth += 1
                continue
            }
            if trimmed.hasPrefix("#endif"), debugDepth > 0 {
                debugDepth -= 1
                continue
            }
            guard debugDepth == 0 else { continue }
            output.append(line)
        }

        return output.joined(separator: "\n")
    }

    static func swiftStringLiterals(in contents: String) -> [String] {
        var literals: [String] = []
        var current = ""
        var insideLiteral = false
        var escaping = false

        for character in contents {
            if insideLiteral {
                if escaping {
                    current.append(character)
                    escaping = false
                } else if character == "\\" {
                    escaping = true
                } else if character == "\"" {
                    literals.append(current)
                    current = ""
                    insideLiteral = false
                } else {
                    current.append(character)
                }
            } else if character == "\"" {
                insideLiteral = true
            }
        }

        return literals
    }
}

enum LifeShapeFixtureAudit {
    static let owner = "Quality/LifeShapeFixtureAudit"
    static let rule = "Release Time must not depend on preview, scenario, mock, fixture, or demo LifeShape input."

    private static let forbiddenReleaseSymbols = [
        "PreviewClock",
        "ScenarioCatalog",
        "MockLifeShape",
        "LifeShapeFixture",
        "FixtureProjection",
        "DemoLifeShapeBucket",
        "demo bucket"
    ]

    static func auditReleaseSources(_ files: [LifeShapeSourceFile]) -> LifeShapeAuditReport {
        var findings: [LifeShapeAuditFinding] = []

        for file in files {
            let releaseContents = LifeShapeAuditSupport.releaseScopedContents(file.contents)
            for symbol in forbiddenReleaseSymbols where releaseContents.localizedCaseInsensitiveContains(symbol) {
                findings.append(LifeShapeAuditFinding(
                    id: "fixture.\(normalized(symbol))",
                    path: file.path,
                    detail: "Release LifeShape source must not depend on \(symbol)."
                ))
            }
        }

        return LifeShapeAuditReport(findings: findings)
    }

    private static func normalized(_ symbol: String) -> String {
        symbol.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
    }
}
