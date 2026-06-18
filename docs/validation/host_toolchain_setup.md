# Host Toolchain Setup

Status: Local host setup note
Scope: Codex + Xcode 26.6 iOS development host tooling only. This is not product implementation proof, app validation proof, release proof, device proof, accessibility proof, privacy proof, TestFlight proof, or App Store proof.

## Host Helpers

- User helper: `/Users/devan/bin/ambitions-toolchain-check`
- Repo helper: `scripts/ambitions-host-toolchain-check.sh`

Both helpers are read-only checks. They print tool availability and bounded Xcode simulator status. The repo helper does not require Homebrew and does not fail the entire run because an optional tool is missing.

## Path Contract

`/Users/devan/bin` is added through `~/.zshrc` for interactive zsh shells.

Do not globally prepend GNU coreutils `gnubin` to PATH. Use `gtimeout` explicitly for bounded shell execution.

## Xcode / Codex Bridge

- Selected Xcode: `/Users/devan/Downloads/Xcode.app/Contents/Developer`
- Xcode version: 26.6
- Apple-native Xcode MCP command: `xcrun mcpbridge`
- Fallback XcodeBuildMCP remains enabled.

`xcrun agent skills export` reported no available Xcode agent skills to export on this host.

## Known Optional Gap

`periphery` was skipped because Homebrew has no bottle for this Intel/Tier 3 configuration. The suggested source-build fallback was not attempted during this setup pass.
