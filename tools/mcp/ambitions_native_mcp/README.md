# Ambitions Native MCP

Status: implemented Swift SDK-backed MCP package.

This package hosts Ambitions-native read-only MCP toolsets through the official Swift MCP SDK:

- `repo`
- `visual`
- `accessibility`
- `swift-semantic`
- `instruments`
- `apple-docs`
- `source-atlas`

Each Codex MCP server in `~/.codex/config.toml` points at the same executable with a different `--toolset` value.

## Validation

```bash
swift test --package-path tools/mcp/ambitions_native_mcp
scripts/ambitions-native-mcp-lifecycle-check.sh
for t in repo visual accessibility swift-semantic instruments apple-docs source-atlas; do
  swift run --package-path tools/mcp/ambitions_native_mcp ambitions-native-mcp --toolset "$t" --self-test
done
```

The lifecycle check closes stdin for every toolset and requires the stdio server
to exit promptly. It prevents closed Codex sessions from leaving orphaned MCP
processes behind.

The tools are operating support only. They do not produce release proof, device proof, public accessibility proof, privacy/legal signoff, or owner acceptance.
