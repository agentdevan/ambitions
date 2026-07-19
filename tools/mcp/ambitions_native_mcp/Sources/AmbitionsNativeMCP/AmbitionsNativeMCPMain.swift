import AmbitionsNativeMCPCore
import Foundation
import MCP

@main
struct AmbitionsNativeMCPMain {
    static func main() async throws {
        let arguments = Array(CommandLine.arguments.dropFirst())
        let toolset = Toolset(arguments: arguments)
        let context = RepoContext.discover()
        let registry = ToolRegistry(context: context, toolset: toolset)

        if arguments.contains("--self-test") {
            let selfTestTool: String = switch toolset {
            case .all, .repo: "repo_posture"
            case .visual: "visual_surface_matrix"
            case .accessibility: "accessibility_gate_matrix"
            case .swiftSemantic: "swift_sourcekit_status"
            case .instruments: "instruments_xctrace_status"
            case .appleDocs: "apple_source_atlas_index"
            case .sourceAtlas: "source_atlas_pipeline_status"
            }
            let output = try registry.call(name: selfTestTool, arguments: [:])
            print(output)
            return
        }

        if arguments.contains("--list-tools") {
            for tool in registry.mcpTools() {
                print(tool.name)
            }
            return
        }

        let server = Server(
            name: "ambitions-native-mcp-\(toolset.rawValue)",
            version: "0.1.0",
            instructions: registry.instructions,
            capabilities: .init(tools: .init(listChanged: false))
        )

        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: registry.mcpTools())
        }

        await server.withMethodHandler(CallTool.self) { params in
            do {
                let output = try registry.call(name: params.name, arguments: params.arguments ?? [:])
                return CallTool.Result(
                    content: [Tool.Content.text(text: output, annotations: nil, _meta: nil)],
                    isError: false
                )
            } catch {
                let output = registry.errorPayload(error)
                return CallTool.Result(
                    content: [Tool.Content.text(text: output, annotations: nil, _meta: nil)],
                    isError: true
                )
            }
        }

        let transport = StdioTransport()
        try await server.start(transport: transport)
        await server.waitUntilCompleted()
        await server.stop()
    }
}
