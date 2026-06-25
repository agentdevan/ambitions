import Foundation
import CryptoKit
import MCP

public enum Toolset: String, CaseIterable, Sendable {
    case all
    case repo
    case visual
    case accessibility
    case swiftSemantic = "swift-semantic"
    case instruments
    case appleDocs = "apple-docs"
    case sourceAtlas = "source-atlas"

    public init(arguments: [String]) {
        if let index = arguments.firstIndex(of: "--toolset"),
           arguments.indices.contains(index + 1),
           let parsed = Toolset(rawValue: arguments[index + 1]) {
            self = parsed
        } else if let raw = arguments.first(where: { !$0.hasPrefix("-") }),
                  let parsed = Toolset(rawValue: raw) {
            self = parsed
        } else {
            self = .all
        }
    }
}

public struct RepoContext: Sendable {
    public let repoRoot: URL

    public init(repoRoot: URL) {
        self.repoRoot = repoRoot.standardizedFileURL
    }

    public static func discover() -> RepoContext {
        let environment = ProcessInfo.processInfo.environment
        if let root = environment["AMBITIONS_REPO_ROOT"], !root.isEmpty {
            return RepoContext(repoRoot: URL(fileURLWithPath: root))
        }

        let fileManager = FileManager.default
        var candidate = URL(fileURLWithPath: fileManager.currentDirectoryPath).standardizedFileURL
        while candidate.path != "/" {
            let marker = candidate.appendingPathComponent("docs/truth/README.md")
            if fileManager.fileExists(atPath: marker.path) {
                return RepoContext(repoRoot: candidate)
            }
            candidate.deleteLastPathComponent()
        }

        return RepoContext(repoRoot: URL(fileURLWithPath: "/Users/devan/Documents/GitHub/ambitions"))
    }

    public func resolve(_ path: String) throws -> URL {
        guard !path.isEmpty, !path.contains("\0") else {
            throw ToolFailure.invalid("path is empty or invalid")
        }

        let candidate = (path.hasPrefix("/") ? URL(fileURLWithPath: path) : repoRoot.appendingPathComponent(path)).standardizedFileURL
        let rootPath = repoRoot.path
        guard candidate.path == rootPath || candidate.path.hasPrefix(rootPath + "/") else {
            throw ToolFailure.invalid("path escapes repo root: \(path)")
        }
        return candidate
    }

    public func relativePath(_ url: URL) -> String {
        let rootPath = repoRoot.path
        if url.path == rootPath {
            return "."
        }
        if url.path.hasPrefix(rootPath + "/") {
            return String(url.path.dropFirst(rootPath.count + 1))
        }
        return url.path
    }

    public func exists(_ path: String) -> Bool {
        guard let url = try? resolve(path) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    public func readText(_ path: String, maxBytes: UInt64 = 1_000_000) throws -> String {
        let url = try resolve(path)
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw ToolFailure.notFound(path)
        }
        guard !isDirectory.boolValue else {
            throw ToolFailure.invalid("not a file: \(path)")
        }
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        if let size = attributes[.size] as? NSNumber, size.uint64Value > maxBytes {
            throw ToolFailure.invalid("file too large for MCP read: \(path)")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    public func safeListFiles(roots: [String], extensions allowedExtensions: Set<String>, skipGenerated: Bool = true) -> [String] {
        let fileManager = FileManager.default
        var files: [String] = []
        for root in roots {
            guard let rootURL = try? resolve(root), fileManager.fileExists(atPath: rootURL.path) else {
                continue
            }
            guard let enumerator = fileManager.enumerator(
                at: rootURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsPackageDescendants]
            ) else { continue }

            for case let url as URL in enumerator {
                let relative = relativePath(url)
                if skipGenerated && shouldSkip(relative) {
                    continue
                }
                guard allowedExtensions.contains(url.pathExtension.lowercased()) else {
                    continue
                }
                files.append(relative)
            }
        }
        return files.sorted()
    }
}

public enum ToolFailure: Error, CustomStringConvertible, Sendable {
    case invalid(String)
    case notFound(String)
    case commandFailed(String)

    public var description: String {
        switch self {
        case .invalid(let message): return message
        case .notFound(let path): return "not found: \(path)"
        case .commandFailed(let message): return message
        }
    }
}

public struct NativeTool: Sendable {
    public let name: String
    public let description: String
    public let inputSchema: Value
    public let readOnly: Bool
    public let openWorld: Bool
    public let handler: @Sendable ([String: Value]) throws -> String

    public init(
        name: String,
        description: String,
        inputSchema: Value = ToolSchemas.object(),
        readOnly: Bool = true,
        openWorld: Bool = false,
        handler: @escaping @Sendable ([String: Value]) throws -> String
    ) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
        self.readOnly = readOnly
        self.openWorld = openWorld
        self.handler = handler
    }

    public func mcpTool() -> Tool {
        Tool(
            name: name,
            description: description,
            inputSchema: inputSchema,
            annotations: .init(
                title: name,
                readOnlyHint: readOnly,
                destructiveHint: false,
                idempotentHint: true,
                openWorldHint: openWorld
            )
        )
    }
}

public enum ToolSchemas {
    public static func object(_ properties: [String: Value] = [:], required: [String] = []) -> Value {
        .object([
            "type": .string("object"),
            "properties": .object(properties),
            "required": .array(required.map { .string($0) }),
            "additionalProperties": .bool(false),
        ])
    }

    public static func string(_ description: String? = nil) -> Value {
        var schema: [String: Value] = ["type": .string("string")]
        if let description {
            schema["description"] = .string(description)
        }
        return .object(schema)
    }

    public static func stringArray(_ description: String? = nil) -> Value {
        var schema: [String: Value] = [
            "type": .string("array"),
            "items": .object(["type": .string("string")]),
        ]
        if let description {
            schema["description"] = .string(description)
        }
        return .object(schema)
    }

    public static func integer(_ description: String? = nil) -> Value {
        var schema: [String: Value] = ["type": .string("integer")]
        if let description {
            schema["description"] = .string(description)
        }
        return .object(schema)
    }
}

public final class ToolRegistry: @unchecked Sendable {
    private let context: RepoContext
    private let toolset: Toolset
    private let tools: [String: NativeTool]

    public init(context: RepoContext, toolset: Toolset) {
        self.context = context
        self.toolset = toolset
        self.tools = Dictionary(uniqueKeysWithValues: ToolRegistry.makeTools(context: context, toolset: toolset).map { ($0.name, $0) })
    }

    public var instructions: String {
        """
        Ambitions Native MCP exposes read-only repo, visual, accessibility, Swift semantic, Instruments, and Apple documentation tools for the Ambitions iOS app. It never mutates source, never stores private user data, and never converts routing guidance into release proof.
        """
    }

    public func mcpTools() -> [Tool] {
        tools.values.sorted { $0.name < $1.name }.map { $0.mcpTool() }
    }

    public func call(name: String, arguments: [String: Value]) throws -> String {
        guard let tool = tools[name] else {
            throw ToolFailure.invalid("unknown tool: \(name)")
        }
        return try tool.handler(arguments)
    }

    public func errorPayload(_ error: Error) -> String {
        let message = (error as? ToolFailure)?.description ?? String(describing: error)
        return jsonString(.object([
            "error": .string(message),
            "toolset": .string(toolset.rawValue),
            "repoRoot": .string(context.repoRoot.path),
        ]))
    }

    private static func makeTools(context: RepoContext, toolset: Toolset) -> [NativeTool] {
        var selected: [NativeTool] = []
        func append(_ set: Toolset, _ tools: [NativeTool]) {
            if toolset == .all || toolset == set {
                selected.append(contentsOf: tools)
            }
        }

        append(.repo, repoTools(context: context))
        append(.visual, visualTools(context: context))
        append(.accessibility, accessibilityTools(context: context))
        append(.swiftSemantic, swiftSemanticTools(context: context))
        append(.instruments, instrumentsTools(context: context))
        append(.appleDocs, appleDocsTools(context: context))
        append(.sourceAtlas, sourceAtlasTools(context: context))
        return selected
    }
}

private func repoTools(context: RepoContext) -> [NativeTool] {
    [
        NativeTool(
            name: "repo_truth_stack",
            description: "Return the current Ambitions truth read order and existence checks."
        ) { _ in
            jsonString(.object([
                "repoRoot": .string(context.repoRoot.path),
                "truthStack": .array(truthStack.map { path in
                    .object([
                        "path": .string(path),
                        "exists": .bool(context.exists(path)),
                    ])
                }),
                "precedence": .string("docs/truth/* wins conflicts; AGENTS.md routes agents; live source/tests/logs own implementation evidence."),
            ]))
        },
        NativeTool(
            name: "repo_posture",
            description: "Return Ambitions repo/product posture without stale Capture-tab, Motion-tab, or release claims."
        ) { _ in
            jsonString(.object([
                "app": .string("Ambitions native iPhone-first local-first Personal Life OS"),
                "topLevelSurfaces": .array(["Today", "Goals", "Time", "You"].map { .string($0) }),
                "globalComposer": .string("Capture"),
                "motionRole": .string("Stage/Motion behavior layer, not a tab or destination"),
                "coreMoat": .string("Private Life Runtime: local, inspectable, user-controlled life graph"),
                "offlineCoreValue": .bool(true),
                "accountBoundary": .string("optional Ambitions Account may support identity, entitlement, and R2 freshness/reference packs; private life graph is not a backend payload"),
                "releaseClaimsAllowed": .bool(false),
                "obsoleteScaffoldsPresent": .array(obsoleteScaffoldPaths.filter { context.exists($0) }.map { .string($0) }),
            ]))
        },
        NativeTool(
            name: "repo_changed_file_impact",
            description: "Classify changed file paths against current Ambitions architecture owners and validation needs.",
            inputSchema: ToolSchemas.object([
                "paths": ToolSchemas.stringArray("Repo-relative file paths. If omitted, current git status paths are used."),
            ])
        ) { args in
            let paths = stringArray(args["paths"])
            let effectivePaths = paths.isEmpty ? gitChangedPaths(context: context) : paths
            return jsonString(.object([
                "paths": .array(effectivePaths.map { path in
                    let owner = architectureOwner(for: path)
                    return .object([
                        "path": .string(path),
                        "owner": .string(owner.owner),
                        "status": .string(owner.status),
                        "validation": .array(owner.validation.map { .string($0) }),
                        "architectureDebt": .bool(owner.debt),
                    ])
                }),
                "note": .string("Routing guidance only. It is not proof, closure, or approval to keep non-canonical paths."),
            ]))
        },
        NativeTool(
            name: "repo_claim_scan",
            description: "Scan selected files for Ambitions forbidden release, accessibility, privacy, AI, and shame-pressure claim triggers.",
            inputSchema: ToolSchemas.object([
                "paths": ToolSchemas.stringArray("Repo-relative files. If omitted, current git status files are used."),
            ])
        ) { args in
            let providedPaths = stringArray(args["paths"])
            let paths = providedPaths.isEmpty ? gitChangedPaths(context: context) : providedPaths
            let findings = scanForbiddenClaims(context: context, paths: paths)
            return jsonString(.object([
                "findingCount": .int(findings.count),
                "findings": .array(findings.map { $0.value }),
                "note": .string("Findings are review triggers. Historical examples and no-claim boundaries still require human judgment."),
            ]))
        },
        NativeTool(
            name: "repo_architecture_owner_report",
            description: "Report canonical/non-canonical owner status for source paths.",
            inputSchema: ToolSchemas.object([
                "paths": ToolSchemas.stringArray("Repo-relative paths to classify."),
            ])
        ) { args in
            let paths = stringArray(args["paths"])
            return jsonString(.object([
                "finalArchitectureTreeInspected": .bool(context.exists("docs/truth/PRODUCT_DESIGN_TRUTH.md")),
                "paths": .array(paths.map { path in
                    let owner = architectureOwner(for: path)
                    return .object([
                        "path": .string(path),
                        "owner": .string(owner.owner),
                        "status": .string(owner.status),
                        "debt": .bool(owner.debt),
                    ])
                }),
                "hardRules": .array([
                    .string("Features/ is legacy compatibility only."),
                    .string("Motion belongs under Stage/Motion, not a root surface."),
                    .string("Capture belongs under Composer/Capture, not Surfaces/Capture or a tab."),
                ]),
            ]))
        },
        NativeTool(
            name: "repo_skill_registry_status",
            description: "Inspect repo-local skill registry consistency at a lightweight read-only level."
        ) { _ in
            let skillFiles = context.safeListFiles(roots: [".agents/skills"], extensions: ["md"])
                .filter { $0.hasSuffix("/SKILL.md") }
            let retained = parseRetainedSkillRows(context: context)
            return jsonString(.object([
                "registryExists": .bool(context.exists(".agents/skills/README.md")),
                "skillFiles": .array(skillFiles.map { .string($0) }),
                "retainedRows": .array(retained.map { .string($0) }),
                "count": .int(skillFiles.count),
                "note": .string("Authoritative validation remains scripts/ambitions-skill-registry-check.py."),
            ]))
        },
    ]
}

private func visualTools(context: RepoContext) -> [NativeTool] {
    [
        NativeTool(
            name: "visual_surface_matrix",
            description: "Return the Ambitions visual proof matrix expected for native iPhone surface work."
        ) { _ in
            jsonString(.object([
                "surfaces": .array(["Today", "Goals", "Time", "You", "Capture overlay", "Search overlay", "Closure overlay", "Inspection overlay"].map { .string($0) }),
                "states": .array(["empty", "seeded", "dense", "blocked", "waiting", "protected", "offline", "permission-denied", "reduce-motion", "dynamic-type-xxxl"].map { .string($0) }),
                "viewports": .array(["iPhone 17 portrait", "small iPhone portrait", "large text", "dark mode", "light mode"].map { .string($0) }),
                "proofBoundary": .string("A matrix is a plan until backed by real screenshots, runtime snapshots, and reviewed artifacts."),
            ]))
        },
        NativeTool(
            name: "visual_validate_packet",
            description: "Validate a visual proof packet folder for screenshots, manifest, and surface/state coverage signals.",
            inputSchema: ToolSchemas.object([
                "packetPath": ToolSchemas.string("Repo-relative or absolute packet folder."),
            ], required: ["packetPath"])
        ) { args in
            let path = try requiredString(args, "packetPath")
            let url = try context.resolve(path)
            let relative = context.relativePath(url)
            let files = context.safeListFiles(roots: [relative], extensions: ["png", "jpg", "jpeg", "json", "md"])
            let imageFiles = files.filter { ["png", "jpg", "jpeg"].contains(URL(fileURLWithPath: $0).pathExtension.lowercased()) }
            let manifestFiles = files.filter { $0.lowercased().contains("manifest") || $0.lowercased().contains("readme") }
            let coverage = visualCoverage(files: files)
            return jsonString(.object([
                "packetPath": .string(relative),
                "exists": .bool(context.exists(relative)),
                "imageCount": .int(imageFiles.count),
                "manifestFiles": .array(manifestFiles.map { .string($0) }),
                "coverage": coverage,
                "validPacketShape": .bool(!imageFiles.isEmpty && !manifestFiles.isEmpty),
                "proofBoundary": .string("Packet-shape validation is not Visual Green. Human visual review and runtime provenance remain required."),
            ]))
        },
        NativeTool(
            name: "visual_xcode_proof_plan",
            description: "Return the XcodeBuildMCP/Xcode bridge sequence for visual runtime proof capture."
        ) { _ in
            jsonString(.object([
                "requiredStart": .array([
                    .string("mcp__xcodebuildmcp.session_show_defaults"),
                    .string("mcp__xcodebuildmcp.build_run_sim"),
                    .string("mcp__xcodebuildmcp.snapshot-ui"),
                    .string("mcp__xcodebuildmcp.screenshot"),
                ]),
                "xcode26Bridge": .array([
                    .string("mcp__xcode.XcodeRefreshCodeIssuesInFile for active Swift files"),
                    .string("mcp__xcode.RenderPreview for preview-backed component proof when Xcode has an active workspace tab"),
                ]),
                "packetMinimum": .array(["runtime log path", "screenshot paths", "UI snapshot json", "surface/state manifest", "known non-claims"].map { .string($0) }),
            ]))
        },
    ]
}

private func accessibilityTools(context: RepoContext) -> [NativeTool] {
    [
        NativeTool(
            name: "accessibility_gate_matrix",
            description: "Return the Ambitions accessibility gates for native iPhone changes."
        ) { _ in
            jsonString(.object([
                "gates": .array([
                    "VoiceOver labels, traits, order, rotor usefulness",
                    "Dynamic Type through accessibility sizes without overlap",
                    "Reduce Motion with Stage/Motion reduction policy",
                    "Reduce Transparency and increased contrast",
                    "Differentiate Without Color",
                    "Switch Control and keyboard/focus traversal",
                    "Hit target and gesture alternatives",
                    "Privacy/proof language remains non-shaming and inspectable",
                ].map { .string($0) }),
                "hardBoundary": .string("No accessibility-compliant claim without device/runtime proof and owner review."),
            ]))
        },
        NativeTool(
            name: "accessibility_validate_packet",
            description: "Validate an accessibility proof packet folder for required gate evidence markers.",
            inputSchema: ToolSchemas.object([
                "packetPath": ToolSchemas.string("Repo-relative or absolute packet folder."),
            ], required: ["packetPath"])
        ) { args in
            let path = try requiredString(args, "packetPath")
            let url = try context.resolve(path)
            let relative = context.relativePath(url)
            let files = context.safeListFiles(roots: [relative], extensions: ["md", "json", "txt", "png", "jpg", "jpeg"])
            let text = files.compactMap { try? context.readText($0, maxBytes: 250_000) }.joined(separator: "\n").lowercased()
            let required = ["voiceover", "dynamic type", "reduce motion", "contrast", "reduce transparency", "differentiate", "keyboard", "hit target"]
            let present = required.filter { text.contains($0) }
            let missing = required.filter { !text.contains($0) }
            return jsonString(.object([
                "packetPath": .string(relative),
                "exists": .bool(context.exists(relative)),
                "filesReviewed": .int(files.count),
                "presentMarkers": .array(present.map { .string($0) }),
                "missingMarkers": .array(missing.map { .string($0) }),
                "validPacketShape": .bool(missing.isEmpty && !files.isEmpty),
                "proofBoundary": .string("Packet-shape validation is not public accessibility proof or compliance."),
            ]))
        },
        NativeTool(
            name: "accessibility_xcode_proof_plan",
            description: "Return a runtime accessibility proof sequence using XcodeBuildMCP UI automation."
        ) { _ in
            jsonString(.object([
                "sequence": .array([
                    .string("session_show_defaults"),
                    .string("build_run_sim"),
                    .string("snapshot-ui for semantic labels/traits/order"),
                    .string("screenshot at default and accessibility Dynamic Type"),
                    .string("repeat with Reduce Motion / Increase Contrast / Reduce Transparency where scoped"),
                    .string("record non-claims and unresolved gates"),
                ]),
                "minimumEvidence": .array(["UI snapshot", "screenshots", "settings/state notes", "manual review notes", "known issues"].map { .string($0) }),
            ]))
        },
    ]
}

private func swiftSemanticTools(context: RepoContext) -> [NativeTool] {
    [
        NativeTool(
            name: "swift_sourcekit_status",
            description: "Return SourceKit-LSP availability from the active Xcode toolchain."
        ) { _ in
            let find = runProcess("/usr/bin/xcrun", ["--find", "sourcekit-lsp"])
            let help = runProcess("/usr/bin/xcrun", ["sourcekit-lsp", "--help"])
            return jsonString(.object([
                "available": .bool(find.exitCode == 0),
                "path": .string(find.stdout.trimmingCharacters(in: .whitespacesAndNewlines)),
                "helpExitCode": .int(help.exitCode),
                "helpSnippet": .string(String(help.stdout.prefix(2_000))),
                "basis": .string("Active Xcode toolchain SourceKit-LSP. Outline/reference tools are read-only repo indexes with SourceKit availability proof, not compiler-success proof."),
            ]))
        },
        NativeTool(
            name: "swift_symbol_outline",
            description: "Return a read-only Swift symbol outline for a repo file.",
            inputSchema: ToolSchemas.object([
                "path": ToolSchemas.string("Swift file path."),
            ], required: ["path"])
        ) { args in
            let path = try requiredString(args, "path")
            let text = try context.readText(path)
            return jsonString(.object([
                "path": .string(path),
                "symbols": .array(swiftSymbols(in: text).map { $0.value }),
                "sourcekitLSPAvailable": .bool(runProcess("/usr/bin/xcrun", ["--find", "sourcekit-lsp"]).exitCode == 0),
            ]))
        },
        NativeTool(
            name: "swift_find_symbol",
            description: "Find Swift symbol references in repo source roots without mutating indexes.",
            inputSchema: ToolSchemas.object([
                "symbol": ToolSchemas.string("Symbol or identifier to find."),
                "roots": ToolSchemas.stringArray("Optional roots. Defaults to Native/Ambitions and tests."),
            ], required: ["symbol"])
        ) { args in
            let symbol = try requiredString(args, "symbol")
            let roots = stringArray(args["roots"])
            let effectiveRoots = roots.isEmpty ? ["Native/Ambitions", "Native/AmbitionsTests", "Native/AmbitionsUITests"] : roots
            let files = context.safeListFiles(roots: effectiveRoots, extensions: ["swift"])
            let findings = findSymbol(context: context, symbol: symbol, files: files)
            return jsonString(.object([
                "symbol": .string(symbol),
                "findingCount": .int(findings.count),
                "findings": .array(findings.prefix(200).map { $0.value }),
                "truncated": .bool(findings.count > 200),
                "sourcekitLSPAvailable": .bool(runProcess("/usr/bin/xcrun", ["--find", "sourcekit-lsp"]).exitCode == 0),
            ]))
        },
        NativeTool(
            name: "swift_architecture_owner_report",
            description: "Classify Swift files against the Final Architecture Tree owners.",
            inputSchema: ToolSchemas.object([
                "paths": ToolSchemas.stringArray("Swift paths. If omitted, scans Native/Ambitions Swift files."),
            ])
        ) { args in
            let paths = stringArray(args["paths"])
            let effectivePaths = paths.isEmpty ? context.safeListFiles(roots: ["Native/Ambitions"], extensions: ["swift"]) : paths
            let reports = effectivePaths.map { path -> Value in
                let owner = architectureOwner(for: path)
                return .object([
                    "path": .string(path),
                    "owner": .string(owner.owner),
                    "status": .string(owner.status),
                    "debt": .bool(owner.debt),
                ])
            }
            let debtCount = effectivePaths.filter { architectureOwner(for: $0).debt }.count
            return jsonString(.object([
                "fileCount": .int(effectivePaths.count),
                "architectureDebtCount": .int(debtCount),
                "reports": .array(Array(reports.prefix(500))),
                "truncated": .bool(reports.count > 500),
            ]))
        },
    ]
}

private func instrumentsTools(context: RepoContext) -> [NativeTool] {
    [
        NativeTool(
            name: "instruments_xctrace_status",
            description: "Return xctrace availability and current Xcode template support."
        ) { _ in
            let find = runProcess("/usr/bin/xcrun", ["--find", "xctrace"])
            let templates = runProcess("/usr/bin/xcrun", ["xctrace", "list", "templates"])
            return jsonString(.object([
                "available": .bool(find.exitCode == 0),
                "path": .string(find.stdout.trimmingCharacters(in: .whitespacesAndNewlines)),
                "templatesExitCode": .int(templates.exitCode),
                "requiredTemplatesPresent": requiredTraceTemplatesValue(templates.stdout),
            ]))
        },
        NativeTool(
            name: "instruments_list_templates",
            description: "List installed xctrace templates."
        ) { _ in
            let templates = runProcess("/usr/bin/xcrun", ["xctrace", "list", "templates"])
            return jsonString(.object([
                "exitCode": .int(templates.exitCode),
                "templates": .array(parseTraceTemplates(templates.stdout).map { .string($0) }),
                "stderr": .string(templates.stderr),
            ]))
        },
        NativeTool(
            name: "instruments_budget_plan",
            description: "Return launch, hitch, memory, and SwiftUI performance budget plan for Ambitions runtime proof.",
            inputSchema: ToolSchemas.object([
                "flow": ToolSchemas.string("Optional flow name, e.g. Today start here or Capture to recommended step."),
            ])
        ) { args in
            let flow = args["flow"]?.stringValue ?? "core Today / Goals / Time / You runtime flow"
            return jsonString(.object([
                "flow": .string(flow),
                "budgets": .array([
                    performanceBudget("launch", template: "App Launch", gate: "cold and warm launch traced; first interactive surface has no unreviewed blocker"),
                    performanceBudget("hitch", template: "Animation Hitches", gate: "critical Stage/Motion transitions have no unresolved user-visible hitch evidence"),
                    performanceBudget("memory", template: "Allocations + Leaks", gate: "no unresolved leak/growth after repeated capture, step open, closure, and undo loops"),
                    performanceBudget("swiftui", template: "SwiftUI + Time Profiler", gate: "body/layout/update work is bounded enough for flagship interaction proof"),
                ]),
                "proofBoundary": .string("This creates budgets and commands, not performance proof. Proof requires saved .trace bundles and reviewed summaries."),
            ]))
        },
        NativeTool(
            name: "instruments_trace_command",
            description: "Build a dry-run xctrace record command for a simulator/device/app trace.",
            inputSchema: ToolSchemas.object([
                "template": ToolSchemas.string("xctrace template name, e.g. App Launch, Animation Hitches, Allocations, SwiftUI."),
                "device": ToolSchemas.string("Optional device or simulator name/UDID."),
                "attach": ToolSchemas.string("Optional process name or pid to attach."),
                "launchPath": ToolSchemas.string("Optional app/tool path for --launch."),
                "output": ToolSchemas.string("Optional output .trace path."),
                "timeLimitSeconds": ToolSchemas.integer("Optional time limit seconds."),
            ], required: ["template"])
        ) { args in
            let template = try requiredString(args, "template")
            var command = ["xcrun", "xctrace", "record", "--template", template]
            if let device = args["device"]?.stringValue, !device.isEmpty {
                command.append(contentsOf: ["--device", device])
            }
            if let seconds = args["timeLimitSeconds"]?.intValue, seconds > 0 {
                command.append(contentsOf: ["--time-limit", "\(seconds)s"])
            }
            if let output = args["output"]?.stringValue, !output.isEmpty {
                command.append(contentsOf: ["--output", output])
            }
            if let attach = args["attach"]?.stringValue, !attach.isEmpty {
                command.append(contentsOf: ["--attach", attach])
            } else if let launchPath = args["launchPath"]?.stringValue, !launchPath.isEmpty {
                command.append(contentsOf: ["--launch", "--", launchPath])
            } else {
                command.append("--all-processes")
            }
            return jsonString(.object([
                "command": .array(command.map { .string($0) }),
                "dryRun": .bool(true),
                "note": .string("Command is not executed by this MCP. Run only after the target app/simulator context is correct."),
            ]))
        },
    ]
}

private func appleDocsTools(context: RepoContext) -> [NativeTool] {
    [
        NativeTool(
            name: "apple_source_atlas_index",
            description: "Return official Apple/HIG/WWDC source URLs indexed by the local Apple Platform Source Atlas."
        ) { _ in
            let atlasPath = "docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md"
            let text = (try? context.readText(atlasPath, maxBytes: 2_000_000)) ?? ""
            return jsonString(.object([
                "atlasPath": .string(atlasPath),
                "exists": .bool(context.exists(atlasPath)),
                "urls": .array(extractURLs(text).prefix(160).map { .string($0) }),
                "sourcePolicy": .string("Use official Apple documentation, HIG, sample code, WWDC pages, and availability checks; product canon still wins conflicts."),
            ]))
        },
        NativeTool(
            name: "apple_fetch_official_doc",
            description: "Fetch a live official Apple developer/HIG/WWDC URL and return a bounded text extraction.",
            inputSchema: ToolSchemas.object([
                "url": ToolSchemas.string("Official Apple developer, design, documentation, or WWDC URL."),
            ], required: ["url"]),
            openWorld: true
        ) { args in
            let urlString = try requiredString(args, "url")
            try validateAppleURL(urlString)
            let response = runProcess("/usr/bin/curl", ["-L", "--max-time", "20", "--silent", "--show-error", urlString])
            return jsonString(.object([
                "url": .string(urlString),
                "exitCode": .int(response.exitCode),
                "text": .string(stripHTML(response.stdout, limit: 6_000)),
                "stderr": .string(response.stderr),
                "proofBoundary": .string("Live docs lookup is source context. Availability still requires iOS 26 gating in code and validation."),
            ]))
        },
        NativeTool(
            name: "apple_api_availability_review",
            description: "Return an Apple-platform API availability and fallback review checklist.",
            inputSchema: ToolSchemas.object([
                "api": ToolSchemas.string("Apple API, framework, modifier, entitlement, or HIG topic."),
                "minimumIOS": ToolSchemas.string("Optional minimum deployment target."),
            ], required: ["api"])
        ) { args in
            let api = try requiredString(args, "api")
            let minimum = args["minimumIOS"]?.stringValue ?? "project deployment target"
            return jsonString(.object([
                "api": .string(api),
                "minimumIOS": .string(minimum),
                "checklist": .array([
                    "confirm official Apple documentation URL",
                    "verify iOS 26/Xcode 26.6 symbol availability",
                    "add @available or runtime fallback if symbol exceeds minimum target",
                    "confirm HIG/accessibility behavior for user-facing primitives",
                    "add proof note: source link, fallback decision, and validation command",
                ].map { .string($0) }),
                "nonClaim": .string("Checklist completion is not App Store, accessibility, privacy, or release approval."),
            ]))
        },
    ]
}

private func sourceAtlasTools(context: RepoContext) -> [NativeTool] {
    [
        NativeTool(
            name: "source_atlas_pipeline_status",
            description: "Inspect Source Atlas pipeline scripts, local atlas docs, and public/reference-pack boundaries."
        ) { _ in
            let scripts = [
                "tools/source-atlas/source-atlas-foundry.py",
                "tools/source-atlas/foundry/README.md",
                "tools/source-atlas/ambitions-pack-crypto.py",
                "tools/source-atlas/ambitions-pack-diff.py",
                "tools/source-atlas/ambitions-freshness-broker.py",
                "tools/source-atlas/coverage.py",
                "tools/source-atlas/lakehouse-workbench/publisher.py",
            ]
            return jsonString(.object([
                "toolset": .string("source-atlas"),
                "scripts": .array(scripts.map { path in
                    .object([
                        "path": .string(path),
                        "exists": .bool(context.exists(path)),
                    ])
                }),
                "atlasDoc": .object([
                    "path": .string("docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md"),
                    "exists": .bool(context.exists("docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md")),
                ]),
                "foundryBlueprint": .object([
                    "path": .string("docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md"),
                    "exists": .bool(context.exists("docs/platform/SOURCE_ATLAS_FOUNDRY_BLUEPRINT.md")),
                ]),
                "privacyBoundary": .string("R2 is public/reference/freshness infrastructure only; no goals, captures, receipts, personalization, calendar data, or private life graph payloads."),
                "defaultOutputRoot": .string("output/source-atlas"),
            ]))
        },
        NativeTool(
            name: "source_atlas_foundry_status",
            description: "Run Source Atlas Foundry doctor and return source, pathway, privacy, and R2 posture."
        ) { _ in
            try runSourceAtlasFoundry(context: context, ["doctor"])
        },
        NativeTool(
            name: "source_atlas_foundry_compile_demo",
            description: "Compile the current official-source seed pathways into a local versioned Foundry bundle.",
            inputSchema: ToolSchemas.object([
                "versionID": ToolSchemas.string("Version identifier, e.g. source-atlas-foundry-demo."),
                "outputRoot": ToolSchemas.string("Repo-relative output root. Defaults to output/source-atlas/foundry."),
                "channel": ToolSchemas.string("Optional channel. Defaults to staging."),
            ], required: ["versionID"]),
            readOnly: false
        ) { args in
            let versionID = try requiredString(args, "versionID")
            let outputRoot = args["outputRoot"]?.stringValue ?? "output/source-atlas/foundry"
            let channel = args["channel"]?.stringValue ?? "staging"
            let outputURL = try context.resolve(outputRoot)
            return try runSourceAtlasFoundry(context: context, [
                "compile-demo",
                "--output-root", outputURL.path,
                "--version-id", versionID,
                "--channel", channel,
            ])
        },
        NativeTool(
            name: "source_atlas_foundry_validate_bundle",
            description: "Validate a Source Atlas Foundry bundle for schema, hashes, provenance, runtime boundary, and privacy triggers.",
            inputSchema: ToolSchemas.object([
                "bundleRoot": ToolSchemas.string("Repo-relative bundle root containing manifest.json."),
            ], required: ["bundleRoot"])
        ) { args in
            let bundleRoot = try requiredString(args, "bundleRoot")
            let bundleURL = try context.resolve(bundleRoot)
            return try runSourceAtlasFoundry(context: context, [
                "validate",
                "--bundle-root", bundleURL.path,
            ])
        },
        NativeTool(
            name: "source_atlas_foundry_r2_plan",
            description: "Create or preview a validation-backed R2 staging plan for a public/reference Foundry bundle without reading credentials.",
            inputSchema: ToolSchemas.object([
                "bundleRoot": ToolSchemas.string("Repo-relative bundle root containing manifest.json."),
                "bucket": ToolSchemas.string("R2 bucket name."),
                "prefix": ToolSchemas.string("Object-key prefix. Defaults to source-atlas/v1."),
                "channel": ToolSchemas.string("Channel manifest to write. Defaults to staging."),
                "outputPath": ToolSchemas.string("Optional repo-relative plan JSON output path."),
            ], required: ["bundleRoot", "bucket"]),
            readOnly: false
        ) { args in
            let bundleRoot = try requiredString(args, "bundleRoot")
            let bucket = try requiredString(args, "bucket")
            let prefix = args["prefix"]?.stringValue ?? "source-atlas/v1"
            let channel = args["channel"]?.stringValue ?? "staging"
            let bundleURL = try context.resolve(bundleRoot)
            var command = [
                "r2-plan",
                "--bundle-root", bundleURL.path,
                "--bucket", bucket,
                "--prefix", prefix,
                "--channel", channel,
            ]
            if let outputPath = args["outputPath"]?.stringValue, !outputPath.isEmpty {
                let outputURL = try context.resolve(outputPath)
                command.append(contentsOf: ["--output", outputURL.path])
            }
            return try runSourceAtlasFoundry(context: context, command)
        },
        NativeTool(
            name: "source_atlas_versioned_manifest_create",
            description: "Create a versioned Source Atlas release manifest with pack entries, hashes, freshness metadata, and non-claim boundaries.",
            inputSchema: ToolSchemas.object([
                "versionID": ToolSchemas.string("Version identifier, e.g. source-atlas-2026-06-24."),
                "outputPath": ToolSchemas.string("Repo-relative manifest JSON output path."),
                "packPaths": ToolSchemas.stringArray("Repo-relative pack JSON paths to include."),
                "channel": ToolSchemas.string("Optional channel, e.g. local, staging, public-r2."),
            ], required: ["versionID", "outputPath", "packPaths"]),
            readOnly: false
        ) { args in
            let versionID = try requiredString(args, "versionID")
            let outputPath = try requiredString(args, "outputPath")
            let channel = args["channel"]?.stringValue ?? "local"
            let packPaths = stringArray(args["packPaths"])
            guard !packPaths.isEmpty else {
                throw ToolFailure.invalid("packPaths must include at least one pack")
            }
            let entries = try packPaths.map { packPath -> Value in
                let url = try context.resolve(packPath)
                let pack = try decodeJSONValue(at: url)
                let id = pack.objectValue?["id"]?.stringValue ?? URL(fileURLWithPath: packPath).deletingPathExtension().lastPathComponent
                return .object([
                    "packID": .string(id),
                    "path": .string(context.relativePath(url)),
                    "sha256": .string(try sha256(url)),
                    "bytes": .int(fileSize(url)),
                    "claimCount": .int(pack.objectValue?["claims"]?.arrayValue?.count ?? 0),
                    "sourceCount": .int(pack.objectValue?["sources"]?.arrayValue?.count ?? 0),
                    "freshnessState": pack.objectValue?["metadata"]?.objectValue?["freshnessState"] ?? .string("unknown"),
                ])
            }
            let manifest: Value = .object([
                "schemaVersion": .int(1),
                "kind": .string("ambitions.sourceAtlas.versionedManifest"),
                "versionID": .string(versionID),
                "channel": .string(channel),
                "createdAt": .string(isoNow()),
                "packIndex": .array(entries),
                "privacyBoundary": .string("public/reference/freshness only; no private life graph or user data"),
                "nonClaims": .array(sourceAtlasNonClaims.map { .string($0) }),
            ])
            let outputURL = try context.resolve(outputPath)
            try writeJSONValue(manifest, to: outputURL)
            return jsonString(.object([
                "wrote": .string(context.relativePath(outputURL)),
                "packCount": .int(entries.count),
                "sha256": .string(try sha256(outputURL)),
            ]))
        },
        NativeTool(
            name: "source_atlas_pack_create",
            description: "Create a candidate Source Atlas reference pack from public/reference source paths or URLs.",
            inputSchema: ToolSchemas.object([
                "packID": ToolSchemas.string("Stable pack ID."),
                "versionID": ToolSchemas.string("Pack version ID."),
                "displayName": ToolSchemas.string("Human-readable pack name."),
                "outputPath": ToolSchemas.string("Repo-relative pack JSON output path."),
                "sourcePaths": ToolSchemas.stringArray("Repo-relative public/reference input files."),
                "sourceURLs": ToolSchemas.stringArray("Public/reference URLs."),
                "domains": ToolSchemas.stringArray("Optional domains."),
            ], required: ["packID", "versionID", "displayName", "outputPath"]),
            readOnly: false,
            openWorld: true
        ) { args in
            let packID = try requiredString(args, "packID")
            let versionID = try requiredString(args, "versionID")
            let displayName = try requiredString(args, "displayName")
            let outputPath = try requiredString(args, "outputPath")
            let sourcePaths = stringArray(args["sourcePaths"])
            let sourceURLs = stringArray(args["sourceURLs"])
            let domains = stringArray(args["domains"])
            guard !sourcePaths.isEmpty || !sourceURLs.isEmpty else {
                throw ToolFailure.invalid("sourcePaths or sourceURLs must include at least one public/reference source")
            }
            let sourceEntries = try sourceAtlasSourceEntries(context: context, sourcePaths: sourcePaths, sourceURLs: sourceURLs)
            let claims = sourceEntries.enumerated().map { index, source -> Value in
                let sourceID = source.objectValue?["id"]?.stringValue ?? "source-\(index + 1)"
                return .object([
                    "id": .string("\(packID).claim.\(index + 1)"),
                    "text": .string("Candidate claim requires official review before runtime use."),
                    "state": .string("source_needed"),
                    "freshness": .string("unknown"),
                    "sourceIDs": .array([.string(sourceID)]),
                ])
            }
            let pack: Value = .object([
                "schemaVersion": .int(1),
                "kind": .string("ambitions.sourceAtlas.referencePack"),
                "id": .string(packID),
                "version": .string(versionID),
                "displayName": .string(displayName),
                "domains": .array(domains.map { .string($0) }),
                "metadata": .object([
                    "createdAt": .string(isoNow()),
                    "createdBy": .string("ambitionsSourceAtlas MCP"),
                    "freshnessState": .string("candidate"),
                    "privacyBoundary": .string("public/reference/freshness only"),
                    "last_known_good_pack": .string("none"),
                    "last_known_good_hash": .string("none"),
                ]),
                "sources": .array(sourceEntries),
                "claims": .array(claims),
                "requirements": .array([]),
                "nonClaims": .array(sourceAtlasNonClaims.map { .string($0) }),
            ])
            let outputURL = try context.resolve(outputPath)
            try writeJSONValue(pack, to: outputURL)
            return jsonString(.object([
                "wrote": .string(context.relativePath(outputURL)),
                "packID": .string(packID),
                "sourceCount": .int(sourceEntries.count),
                "claimCount": .int(claims.count),
                "sha256": .string(try sha256(outputURL)),
            ]))
        },
        NativeTool(
            name: "source_atlas_pack_validate",
            description: "Validate a candidate Source Atlas pack for schema, privacy boundary, hash, revocation, and last-known-good posture.",
            inputSchema: ToolSchemas.object([
                "packPath": ToolSchemas.string("Repo-relative pack JSON path."),
                "expectedSHA256": ToolSchemas.string("Optional expected SHA-256."),
                "revocationListPath": ToolSchemas.string("Optional repo-relative revocation JSON path."),
            ], required: ["packPath"])
        ) { args in
            let packPath = try requiredString(args, "packPath")
            let packURL = try context.resolve(packPath)
            let pack = try decodeJSONValue(at: packURL)
            let schemaFindings = sourceAtlasPackSchemaFindings(pack)
            let privacyFindings = try sourceAtlasPrivacyFindings(context: context, paths: [packPath])
            let actualHash = try sha256(packURL)
            let expected = args["expectedSHA256"]?.stringValue
            var revocationStatus = "not_checked"
            if let revocationPath = args["revocationListPath"]?.stringValue, !revocationPath.isEmpty {
                revocationStatus = try sourceAtlasRevocationStatus(context: context, pack: pack, revocationPath: revocationPath)
            }
            return jsonString(.object([
                "packPath": .string(context.relativePath(packURL)),
                "valid": .bool(schemaFindings.isEmpty && privacyFindings.isEmpty && (expected == nil || expected == actualHash) && revocationStatus != "revoked"),
                "sha256": .string(actualHash),
                "expectedHashMatches": .bool(expected == nil || expected == actualHash),
                "schemaFindings": .array(schemaFindings.map { .string($0) }),
                "privacyFindings": .array(privacyFindings.map { .string($0) }),
                "revocationStatus": .string(revocationStatus),
                "nonClaims": .array(sourceAtlasNonClaims.map { .string($0) }),
            ]))
        },
        NativeTool(
            name: "source_atlas_freshness_diff",
            description: "Run the existing pack diff tool for old/new pack freshness and claim-impact changes.",
            inputSchema: ToolSchemas.object([
                "oldPackPath": ToolSchemas.string("Old pack JSON path."),
                "newPackPath": ToolSchemas.string("New pack JSON path."),
                "outputPath": ToolSchemas.string("Optional repo-relative diff JSON output path."),
            ], required: ["oldPackPath", "newPackPath"]),
            readOnly: false
        ) { args in
            let oldPackPath = try requiredString(args, "oldPackPath")
            let newPackPath = try requiredString(args, "newPackPath")
            let oldPackURL = try context.resolve(oldPackPath)
            let newPackURL = try context.resolve(newPackPath)
            let result = runProcess("/usr/bin/python3", [
                context.repoRoot.appendingPathComponent("tools/source-atlas/ambitions-pack-diff.py").path,
                oldPackURL.path,
                newPackURL.path,
            ])
            guard result.exitCode == 0 else {
                throw ToolFailure.commandFailed(result.stderr.isEmpty ? result.stdout : result.stderr)
            }
            let diffValue = try JSONDecoder().decode(Value.self, from: Data(result.stdout.utf8))
            if let outputPath = args["outputPath"]?.stringValue, !outputPath.isEmpty {
                let outputURL = try context.resolve(outputPath)
                try writeJSONValue(diffValue, to: outputURL)
                return jsonString(.object([
                    "wrote": .string(context.relativePath(outputURL)),
                    "sha256": .string(try sha256(outputURL)),
                    "diff": diffValue,
                ]))
            }
            return jsonString(diffValue)
        },
        NativeTool(
            name: "source_atlas_freshness_manifest_create",
            description: "Create a freshness broker manifest from one or more Source Atlas diff JSON files.",
            inputSchema: ToolSchemas.object([
                "versionID": ToolSchemas.string("Version ID for the freshness manifest."),
                "diffPaths": ToolSchemas.stringArray("Diff JSON files."),
                "outputPath": ToolSchemas.string("Repo-relative output JSON path."),
            ], required: ["versionID", "diffPaths", "outputPath"]),
            readOnly: false
        ) { args in
            let versionID = try requiredString(args, "versionID")
            let diffPaths = stringArray(args["diffPaths"])
            let outputPath = try requiredString(args, "outputPath")
            guard !diffPaths.isEmpty else {
                throw ToolFailure.invalid("diffPaths must include at least one diff")
            }
            let diffURLs = try diffPaths.map { try context.resolve($0) }
            let outputURL = try context.resolve(outputPath)
            try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            let commandArgs = [
                context.repoRoot.appendingPathComponent("tools/source-atlas/ambitions-freshness-broker.py").path,
                "--version-id",
                versionID,
                "--diff-files",
            ] + diffURLs.map(\.path) + [
                "--output",
                outputURL.path,
            ]
            let result = runProcess("/usr/bin/python3", commandArgs)
            guard result.exitCode == 0 else {
                throw ToolFailure.commandFailed(result.stderr.isEmpty ? result.stdout : result.stderr)
            }
            return jsonString(.object([
                "wrote": .string(context.relativePath(outputURL)),
                "sha256": .string(try sha256(outputURL)),
                "stdout": .string(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)),
            ]))
        },
        NativeTool(
            name: "source_atlas_r2_public_bundle_validate",
            description: "Validate a local R2-bound public/reference-pack bundle and return explicit upload commands without reading secrets.",
            inputSchema: ToolSchemas.object([
                "bundlePath": ToolSchemas.string("Repo-relative local bundle directory."),
                "bucket": ToolSchemas.string("R2 bucket name."),
                "prefix": ToolSchemas.string("Object key prefix."),
            ], required: ["bundlePath", "bucket", "prefix"])
        ) { args in
            let bundlePath = try requiredString(args, "bundlePath")
            let bucket = try requiredString(args, "bucket")
            let prefix = try requiredString(args, "prefix").trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let bundleURL = try context.resolve(bundlePath)
            let files = context.safeListFiles(roots: [context.relativePath(bundleURL)], extensions: ["json", "md"], skipGenerated: false)
            let privacyFindings = try sourceAtlasPrivacyFindings(context: context, paths: files)
            let manifestFiles = files.filter { $0.lowercased().contains("manifest") }
            let uploadCommands = try files.map { path -> Value in
                let fileURL = try context.resolve(path)
                let rel = String(path.dropFirst(context.relativePath(bundleURL).count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                return .array([
                    .string("wrangler"),
                    .string("r2"),
                    .string("object"),
                    .string("put"),
                    .string("\(bucket)/\(prefix)/\(rel)"),
                    .string("--file"),
                    .string(fileURL.path),
                ])
            }
            return jsonString(.object([
                "bundlePath": .string(context.relativePath(bundleURL)),
                "fileCount": .int(files.count),
                "manifestFiles": .array(manifestFiles.map { .string($0) }),
                "privacyFindings": .array(privacyFindings.map { .string($0) }),
                "validForPublicReferenceR2": .bool(!files.isEmpty && !manifestFiles.isEmpty && privacyFindings.isEmpty),
                "uploadCommands": .array(uploadCommands),
                "secretBoundary": .string("This MCP does not read or print R2 credentials. Run upload commands only in an approved shell with scoped R2 credentials."),
            ]))
        },
        NativeTool(
            name: "source_atlas_provenance_receipt_create",
            description: "Write a provenance receipt tying inputs, outputs, hashes, tools, R2 target, and non-claims together.",
            inputSchema: ToolSchemas.object([
                "receiptPath": ToolSchemas.string("Repo-relative receipt JSON output path."),
                "operation": ToolSchemas.string("Operation name."),
                "inputPaths": ToolSchemas.stringArray("Repo-relative input files."),
                "outputPaths": ToolSchemas.stringArray("Repo-relative output files."),
                "r2Bucket": ToolSchemas.string("Optional R2 bucket."),
                "r2Prefix": ToolSchemas.string("Optional R2 prefix."),
            ], required: ["receiptPath", "operation"]),
            readOnly: false
        ) { args in
            let receiptPath = try requiredString(args, "receiptPath")
            let operation = try requiredString(args, "operation")
            let inputPaths = stringArray(args["inputPaths"])
            let outputPaths = stringArray(args["outputPaths"])
            let receipt: Value = .object([
                "schemaVersion": .int(1),
                "kind": .string("ambitions.sourceAtlas.provenanceReceipt"),
                "operation": .string(operation),
                "createdAt": .string(isoNow()),
                "inputs": .array(try inputPaths.map { try pathHashValue(context: context, path: $0) }),
                "outputs": .array(try outputPaths.map { try pathHashValue(context: context, path: $0) }),
                "r2": .object([
                    "bucket": .string(args["r2Bucket"]?.stringValue ?? ""),
                    "prefix": .string(args["r2Prefix"]?.stringValue ?? ""),
                    "boundary": .string("public/reference/freshness only"),
                ]),
                "nonClaims": .array(sourceAtlasNonClaims.map { .string($0) }),
            ])
            let receiptURL = try context.resolve(receiptPath)
            try writeJSONValue(receipt, to: receiptURL)
            return jsonString(.object([
                "wrote": .string(context.relativePath(receiptURL)),
                "sha256": .string(try sha256(receiptURL)),
            ]))
        },
    ]
}

private let truthStack = [
    "docs/truth/README.md",
    "docs/truth/CODEX_START_HERE.md",
    "docs/truth/PRODUCT_DESIGN_TRUTH.md",
    "docs/truth/PRODUCT_ORIGIN_TRUTH.md",
    "docs/truth/PRODUCT_MOAT_TRUTH.md",
    "docs/truth/PRODUCT_EXPERIENCE_CANON.md",
    "docs/truth/IMPLEMENTATION_TRUTH.md",
    "docs/truth/IMPLEMENTATION_ACCEPTANCE_TRUTH.md",
    "docs/truth/RELEASE_TRUTH.md",
    "docs/truth/CODEX_PROCESS_TRUTH.md",
    "docs/truth/HISTORICAL_POLICY.md",
    "AGENTS.md",
    "README.md",
    "docs/README.md",
    "project.yml",
    "Package.swift",
    ".agents/skills/README.md",
    "docs/platform/APPLE_PLATFORM_SOURCE_ATLAS_IOS.md",
]

private let obsoleteScaffoldPaths = [
    "tools/mcp/ambitions_accessibility_mcp/README.md",
    "tools/mcp/ambitions_visual_mcp/README.md",
    "tools/mcp/ambitions_fixture_mcp/README.md",
    "tools/mcp/ambitions_source_atlas_mcp/README.md",
    "tools/mcp/ambitions_release_truth_mcp/README.md",
]

private let sourceAtlasNonClaims = [
    "not a private user-data backend",
    "not private life graph storage",
    "not official Apple/API/legal approval",
    "not runtime recommendation proof",
    "not release readiness",
    "not accessibility compliance",
]

private let forbiddenClaimPatterns: [(id: String, pattern: String)] = [
    ("release_ready", #"\brelease[- ]ready\b|\bproduction[- ]ready\b|\bApp Store[- ]ready\b|\bTestFlight[- ]ready\b"#),
    ("device_proof", #"\bdevice verified\b|\bphysical[- ]device proof\b|\breal[- ]device verified\b"#),
    ("accessibility_claim", #"\baccessibility compliant\b|\baccessibility verified\b|\bfully accessible\b"#),
    ("privacy_legal_claim", #"\bprivacy compliant\b|\blegal compliant\b|\bGDPR compliant\b|\bHIPAA compliant\b"#),
    ("ai_branding", #"\bAI confidence\b|\bmodel confidence\b|\bAI coach\b|\bchatbot\b"#),
    ("shame_pressure", #"\boverdue\b|\byou failed\b|\bfailed goal\b|\bstreak\b|\bscore\b"#),
]

private func architectureOwner(for path: String) -> (owner: String, status: String, debt: Bool, validation: [String]) {
    let normalized = path.replacingOccurrences(of: "\\", with: "/")
    let source = normalized.hasPrefix("Native/Ambitions/") ? String(normalized.dropFirst("Native/Ambitions/".count)) : normalized

    if source.hasPrefix("Features/") {
        return ("legacy Features compatibility", "non-canonical; move toward Final Architecture Tree when touched", true, ["architecture-tree check", "focused build/test if source changes"])
    }
    if source.hasPrefix("App/") { return ("App", "canonical", false, ["build", "shell/runtime smoke"]) }
    if source.hasPrefix("Stage/Motion/") { return ("Stage/Motion", "canonical", false, ["motion reduction", "visual runtime proof", "accessibility proof"]) }
    if source.hasPrefix("Stage/") { return ("Stage", "canonical", false, ["build", "visual runtime proof"]) }
    if source.hasPrefix("Core/Runtime/") { return ("Core/Runtime", "canonical", false, ["focused runtime tests", "proof ledger checks"]) }
    if source.hasPrefix("Core/Persistence/") { return ("Core/Persistence", "canonical", false, ["focused persistence tests", "privacy/local-first proof"]) }
    if source.hasPrefix("Core/") { return ("Core", "canonical", false, ["focused unit tests"]) }
    if source.hasPrefix("Projection/") { return ("Projection", "canonical", false, ["surface scenario tests", "visual proof if UI-facing"]) }
    if source.hasPrefix("Language/") { return ("Language", "canonical", false, ["forbidden-language audit", "copy tests"]) }
    if source.hasPrefix("Trust/") { return ("Trust", "canonical", false, ["proof/receipt tests", "privacy wording review"]) }
    if source.hasPrefix("Interaction/") { return ("Interaction", "canonical", false, ["gesture/focus validation", "accessibility proof"]) }
    if source.hasPrefix("Rendering/") { return ("Rendering", "canonical", false, ["performance budget", "visual proof"]) }
    if source.hasPrefix("DesignSystem/Accessibility/") { return ("DesignSystem/Accessibility", "canonical", false, ["accessibility proof packet"]) }
    if source.hasPrefix("DesignSystem/") { return ("DesignSystem", "canonical", false, ["snapshot/visual proof", "dynamic type proof if UI"]) }
    if source.hasPrefix("Surfaces/Today/") { return ("Surfaces/Today", "canonical", false, ["surface contract", "visual/a11y proof"]) }
    if source.hasPrefix("Surfaces/Goals/") { return ("Surfaces/Goals", "canonical", false, ["surface contract", "visual/a11y proof"]) }
    if source.hasPrefix("Surfaces/Time/") { return ("Surfaces/Time", "canonical", false, ["surface contract", "visual/a11y proof"]) }
    if source.hasPrefix("Surfaces/You/") { return ("Surfaces/You", "canonical", false, ["surface contract", "visual/a11y proof"]) }
    if source.hasPrefix("Surfaces/Capture/") || source.hasPrefix("Surfaces/Motion/") {
        return ("removed surface owner", "forbidden by Final Architecture Tree", true, ["architecture repair train required"])
    }
    if source.hasPrefix("Surfaces/") { return ("Surfaces", "canonical shared surface law", false, ["surface law tests"]) }
    if source.hasPrefix("Composer/Capture/") { return ("Composer/Capture", "canonical", false, ["capture scenario tests", "visual/a11y proof"]) }
    if source.hasPrefix("Composer/") { return ("Composer", "canonical", false, ["capture routing tests"]) }
    if source.hasPrefix("Scenarios/") { return ("Scenarios", "canonical", false, ["scenario matrix validation"]) }
    if source.hasPrefix("Diagnostics/") { return ("Diagnostics", "canonical", false, ["diagnostic output review"]) }
    if source.hasPrefix("Quality/") { return ("Quality", "canonical", false, ["quality gate validation"]) }
    if normalized.hasPrefix("Native/AmbitionsTests/") || normalized.hasPrefix("Native/AmbitionsUITests/") {
        return ("Tests", "test target", false, ["focused tests"])
    }
    if normalized.hasPrefix("tools/mcp/") {
        return ("Tooling/MCP", "repo tooling", false, ["MCP self-test", "swift test or pytest"])
    }
    if normalized.hasPrefix(".agents/skills/") {
        return ("Agent Skills", "operating support, not truth", false, ["skill registry check"])
    }
    if normalized.hasPrefix("docs/truth/") {
        return ("Truth", "canonical documentation", false, ["claim scan", "truth consistency review"])
    }
    return ("unclassified", "review required", false, ["owner-specific validation"])
}

private func requiredString(_ args: [String: Value], _ key: String) throws -> String {
    guard let value = args[key]?.stringValue, !value.isEmpty else {
        throw ToolFailure.invalid("\(key) is required")
    }
    return value
}

private func stringArray(_ value: Value?) -> [String] {
    guard let value else { return [] }
    if let string = value.stringValue {
        return [string]
    }
    return value.arrayValue?.compactMap { $0.stringValue } ?? []
}

private func jsonString(_ value: Value) -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    guard let data = try? encoder.encode(value),
          let string = String(data: data, encoding: .utf8) else {
        return #"{"error":"failed to encode value"}"#
    }
    return string
}

private func shouldSkip(_ relative: String) -> Bool {
    let parts = relative.split(separator: "/").map(String.init)
    let skipped = [".git", ".build", "DerivedData", "output", "__pycache__"]
    return parts.contains { skipped.contains($0) }
}

private func gitChangedPaths(context: RepoContext) -> [String] {
    let result = runProcess("/usr/bin/git", ["-C", context.repoRoot.path, "status", "--short"])
    guard result.exitCode == 0 else { return [] }
    return result.stdout.split(separator: "\n").compactMap { line in
        guard line.count >= 4 else { return nil }
        let value = String(line.dropFirst(3))
        if let range = value.range(of: " -> ") {
            return String(value[range.upperBound...])
        }
        return value
    }.sorted()
}

private func runSourceAtlasFoundry(context: RepoContext, _ arguments: [String]) throws -> String {
    let script = try context.resolve("tools/source-atlas/source-atlas-foundry.py")
    guard FileManager.default.fileExists(atPath: script.path) else {
        throw ToolFailure.notFound("tools/source-atlas/source-atlas-foundry.py")
    }
    let result = runProcess("/usr/bin/python3", [script.path] + arguments)
    guard result.exitCode == 0 else {
        let message = result.stderr.isEmpty ? result.stdout : result.stderr
        throw ToolFailure.commandFailed(message.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
}

private struct Finding {
    let value: Value
}

private func scanForbiddenClaims(context: RepoContext, paths: [String]) -> [Finding] {
    var findings: [Finding] = []
    for path in paths {
        guard let text = try? context.readText(path, maxBytes: 750_000) else { continue }
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        for (index, line) in lines.enumerated() {
            for pattern in forbiddenClaimPatterns {
                if line.range(of: pattern.pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                    findings.append(Finding(value: .object([
                        "path": .string(path),
                        "line": .int(index + 1),
                        "id": .string(pattern.id),
                        "text": .string(String(line.prefix(240))),
                    ])))
                }
            }
        }
    }
    return findings
}

private func parseRetainedSkillRows(context: RepoContext) -> [String] {
    guard let text = try? context.readText(".agents/skills/README.md", maxBytes: 250_000) else { return [] }
    var rows: [String] = []
    var inRetained = false
    for line in text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) {
        if line == "## Retained Skills" {
            inRetained = true
            continue
        }
        if inRetained, line.hasPrefix("## ") {
            break
        }
        if inRetained, line.contains(".agents/skills/"), line.contains("/SKILL.md") {
            rows.append(line)
        }
    }
    return rows
}

private func visualCoverage(files: [String]) -> Value {
    let lower = files.map { $0.lowercased() }
    let terms = ["today", "goals", "time", "you", "capture", "closure", "inspection", "search", "empty", "dense", "blocked", "dynamic", "motion"]
    return .object(Dictionary(uniqueKeysWithValues: terms.map { term in
        (term, .bool(lower.contains { $0.contains(term) }))
    }))
}

private func swiftSymbols(in text: String) -> [Finding] {
    let pattern = #"^\s*(?:public|private|fileprivate|internal|open)?\s*(?:final\s+)?(struct|class|enum|actor|protocol|func|var|let)\s+([A-Za-z_][A-Za-z0-9_]*)"#
    var findings: [Finding] = []
    for (index, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
        let string = String(line)
        guard let range = string.range(of: pattern, options: .regularExpression) else { continue }
        let matched = String(string[range])
        let parts = matched.split { $0 == " " || $0 == "\t" || $0 == "(" }
        guard let kind = parts.dropLast().last, let name = parts.last else { continue }
        findings.append(Finding(value: .object([
            "line": .int(index + 1),
            "kind": .string(String(kind)),
            "name": .string(String(name).trimmingCharacters(in: CharacterSet(charactersIn: "{(:"))),
        ])))
    }
    return findings
}

private func findSymbol(context: RepoContext, symbol: String, files: [String]) -> [Finding] {
    let escaped = NSRegularExpression.escapedPattern(for: symbol)
    let pattern = #"\b"# + escaped + #"\b"#
    var findings: [Finding] = []
    for file in files {
        guard let text = try? context.readText(file, maxBytes: 750_000) else { continue }
        for (index, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
            if String(line).range(of: pattern, options: .regularExpression) != nil {
                findings.append(Finding(value: .object([
                    "path": .string(file),
                    "line": .int(index + 1),
                    "text": .string(String(line.trimmingCharacters(in: .whitespaces).prefix(240))),
                ])))
            }
        }
    }
    return findings
}

private struct ProcessResult {
    let exitCode: Int
    let stdout: String
    let stderr: String
}

private func runProcess(_ executable: String, _ arguments: [String]) -> ProcessResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    let stdout = Pipe()
    let stderr = Pipe()
    process.standardOutput = stdout
    process.standardError = stderr
    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        return ProcessResult(exitCode: 127, stdout: "", stderr: String(describing: error))
    }
    let outData = stdout.fileHandleForReading.readDataToEndOfFile()
    let errData = stderr.fileHandleForReading.readDataToEndOfFile()
    return ProcessResult(
        exitCode: Int(process.terminationStatus),
        stdout: String(data: outData, encoding: .utf8) ?? "",
        stderr: String(data: errData, encoding: .utf8) ?? ""
    )
}

private func parseTraceTemplates(_ text: String) -> [String] {
    text.split(separator: "\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty && !$0.hasPrefix("==") }
}

private func requiredTraceTemplatesValue(_ text: String) -> Value {
    let templates = Set(parseTraceTemplates(text))
    let required = ["App Launch", "Animation Hitches", "Allocations", "Leaks", "SwiftUI", "Time Profiler", "Swift Concurrency"]
    return .object(Dictionary(uniqueKeysWithValues: required.map { ($0, .bool(templates.contains($0))) }))
}

private func performanceBudget(_ name: String, template: String, gate: String) -> Value {
    .object([
        "name": .string(name),
        "template": .string(template),
        "gate": .string(gate),
        "traceRequired": .bool(true),
    ])
}

private func extractURLs(_ text: String) -> [String] {
    let pattern = #"https?://[^\s\)\]">]+"#
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
    let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
    var urls: [String] = []
    regex.enumerateMatches(in: text, range: nsRange) { match, _, _ in
        guard let match, let range = Range(match.range, in: text) else { return }
        let url = String(text[range]).trimmingCharacters(in: CharacterSet(charactersIn: ".,;"))
        if !urls.contains(url) {
            urls.append(url)
        }
    }
    return urls
}

private func validateAppleURL(_ urlString: String) throws {
    guard let url = URL(string: urlString), let host = url.host?.lowercased() else {
        throw ToolFailure.invalid("invalid URL")
    }
    let allowedHosts = ["developer.apple.com", "www.developer.apple.com"]
    guard allowedHosts.contains(host) else {
        throw ToolFailure.invalid("only official developer.apple.com URLs are allowed")
    }
    let allowedPrefixes = ["/documentation", "/design", "/videos", "/wwdc", "/tutorials", "/sample-code", "/news"]
    guard allowedPrefixes.contains(where: { url.path.hasPrefix($0) }) else {
        throw ToolFailure.invalid("URL path is outside allowed Apple documentation/HIG/WWDC areas")
    }
}

private func stripHTML(_ html: String, limit: Int) -> String {
    var text = html
    text = text.replacingOccurrences(of: #"<script[\s\S]*?</script>"#, with: " ", options: .regularExpression)
    text = text.replacingOccurrences(of: #"<style[\s\S]*?</style>"#, with: " ", options: .regularExpression)
    text = text.replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
    let entities = [
        "&amp;": "&",
        "&quot;": "\"",
        "&#39;": "'",
        "&lt;": "<",
        "&gt;": ">",
        "&nbsp;": " ",
    ]
    for (entity, replacement) in entities {
        text = text.replacingOccurrences(of: entity, with: replacement)
    }
    text = text.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    return String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(limit))
}

private func isoNow() -> String {
    ISO8601DateFormatter().string(from: Date())
}

private func decodeJSONValue(at url: URL) throws -> Value {
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(Value.self, from: data)
}

private func writeJSONValue(_ value: Value, to url: URL) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(value)
    try data.write(to: url, options: .atomic)
}

private func sha256(_ url: URL) throws -> String {
    let data = try Data(contentsOf: url)
    let digest = SHA256.hash(data: data)
    return digest.map { String(format: "%02x", $0) }.joined()
}

private func fileSize(_ url: URL) -> Int {
    let attributes = (try? FileManager.default.attributesOfItem(atPath: url.path)) ?? [:]
    return (attributes[.size] as? NSNumber)?.intValue ?? 0
}

private func pathHashValue(context: RepoContext, path: String) throws -> Value {
    let url = try context.resolve(path)
    return .object([
        "path": .string(context.relativePath(url)),
        "sha256": .string(try sha256(url)),
        "bytes": .int(fileSize(url)),
    ])
}

private func sourceAtlasSourceEntries(context: RepoContext, sourcePaths: [String], sourceURLs: [String]) throws -> [Value] {
    var entries: [Value] = []
    for (index, path) in sourcePaths.enumerated() {
        let url = try context.resolve(path)
        entries.append(.object([
            "id": .string("local-source-\(index + 1)"),
            "kind": .string("local_reference_file"),
            "path": .string(context.relativePath(url)),
            "sha256": .string(try sha256(url)),
            "bytes": .int(fileSize(url)),
            "state": .string("candidate"),
            "freshness": .string("unknown"),
        ]))
    }
    for (index, urlString) in sourceURLs.enumerated() {
        guard let url = URL(string: urlString), let scheme = url.scheme?.lowercased(), ["https", "http"].contains(scheme) else {
            throw ToolFailure.invalid("sourceURLs[\(index)] is not a valid http(s) URL")
        }
        entries.append(.object([
            "id": .string("url-source-\(index + 1)"),
            "kind": .string("public_url"),
            "url": .string(urlString),
            "host": .string(url.host ?? ""),
            "state": .string("candidate"),
            "freshness": .string("unknown"),
        ]))
    }
    return entries
}

private func sourceAtlasPackSchemaFindings(_ pack: Value) -> [String] {
    guard let object = pack.objectValue else {
        return ["pack root must be a JSON object"]
    }
    var findings: [String] = []
    for required in ["id", "version", "metadata", "sources", "claims"] {
        if object[required] == nil {
            findings.append("missing required field: \(required)")
        }
    }
    if object["id"]?.stringValue?.isEmpty != false {
        findings.append("id must be a non-empty string")
    }
    if object["version"]?.stringValue?.isEmpty != false {
        findings.append("version must be a non-empty string")
    }
    if object["metadata"]?.objectValue == nil {
        findings.append("metadata must be an object")
    }
    if object["sources"]?.arrayValue == nil {
        findings.append("sources must be an array")
    }
    if object["claims"]?.arrayValue == nil {
        findings.append("claims must be an array")
    }
    if let claims = object["claims"]?.arrayValue {
        for (index, claim) in claims.enumerated() {
            guard let claimObject = claim.objectValue else {
                findings.append("claims[\(index)] must be an object")
                continue
            }
            if claimObject["id"]?.stringValue?.isEmpty != false {
                findings.append("claims[\(index)].id must be a non-empty string")
            }
            let state = claimObject["state"]?.stringValue ?? "unknown"
            let allowedStates = ["unknown", "source_needed", "stale", "contradicted", "revoked", "disputed", "verified_by_local_proof"]
            if !allowedStates.contains(state) {
                findings.append("claims[\(index)].state unsupported: \(state)")
            }
        }
    }
    return findings
}

private let sourceAtlasPrivateTerms = [
    "private life graph",
    "calendar data",
    "capture text",
    "personalization data",
    "behavior pattern",
    "inferred priority",
    "goal title",
    "receipt history",
    "user profile payload",
]

private func sourceAtlasPrivacyFindings(context: RepoContext, paths: [String]) throws -> [String] {
    var findings: [String] = []
    for path in paths {
        let text: String
        do {
            text = try context.readText(path, maxBytes: 3_000_000).lowercased()
        } catch {
            findings.append("\(path): unreadable")
            continue
        }
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        for (index, line) in lines.enumerated() {
            for term in sourceAtlasPrivateTerms where line.contains(term) && !isSourceAtlasBoundaryLine(line) {
                findings.append("\(path):\(index + 1): contains private-boundary trigger '\(term)'")
            }
        }
    }
    return findings
}

private func isSourceAtlasBoundaryLine(_ line: String) -> Bool {
    let negationMarkers = [
        "no ",
        "not ",
        "never ",
        "without ",
        "excludes ",
        "exclude ",
        "must not ",
        "does not ",
        " public/reference/freshness only",
    ]
    return negationMarkers.contains { line.contains($0) }
}

private func sourceAtlasRevocationStatus(context: RepoContext, pack: Value, revocationPath: String) throws -> String {
    let packID = pack.objectValue?["id"]?.stringValue ?? ""
    guard !packID.isEmpty else { return "pack_id_missing" }
    let revocationURL = try context.resolve(revocationPath)
    let revocation = try decodeJSONValue(at: revocationURL)
    let revokedIDs = revocation.objectValue?["revoked_pack_ids"]?.arrayValue?.compactMap { $0.stringValue } ?? []
    return revokedIDs.contains(packID) ? "revoked" : "not_revoked"
}
