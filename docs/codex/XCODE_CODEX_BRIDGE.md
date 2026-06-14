# Xcode Codex Bridge

> Supporting note: This file supports current Ambitions work but does not override `docs/truth/`.

## Purpose

This document defines the Ambitions Xcode to Codex bridge: how Codex should use local Xcode tooling, Apple-native Xcode MCP when visible, the existing `xcodebuildmcp` fallback, Ambitions validation scripts, and proof-bound closeouts.

This is a tooling and skills contract only. It does not change app behavior, product canon, release posture, signing, deployment targets, privacy policy, runtime dependencies, or source architecture.

## Current Proof Compiler

Local proof must come from the Xcode installed on the current machine. The owner-declared current proof compiler baseline for this bridge is Xcode 26.5, but Codex must still record the actual result of:

```bash
xcodebuild -version
xcode-select -p
```

If local command output reports a different Xcode version, command output wins for the current run and the closeout must report the mismatch. On the current machine after the Xcode update, observed proof output may be newer than the owner-declared baseline, for example Xcode 26.6. Do not assume Xcode 27 is installed. Do not claim native Xcode 27 agent skills are available unless local commands prove them.

## Architecture

Preferred execution path:

1. Apple-native Xcode MCP tools when they are visible to Codex and local command output proves availability. The expected Codex registration is `xcode -> xcrun mcpbridge`.
2. Existing `xcodebuildmcp` for build, test, simulator launch, screenshot, hierarchy, and UI interaction fallback.
3. Repo scripts for deterministic proof, including `scripts/ambitions-xcode-validate.sh`, `scripts/codex/xcode-codex-bridge-doctor.sh`, `scripts/codex/scan-sdk27-swiftui-usage.sh`, and relevant Goal Mode program gates.
4. Manual owner/device proof only where automation cannot prove the claim.

Xcode MCP is enabled by the owner in Xcode settings, but local proof must still confirm which tools Codex can actually see through `codex mcp list`, `xcrun --find mcpbridge`, `xcrun --find agent`, and `xcrun agent skills export`.

Apple-native Xcode MCP bridge availability and Xcode agent skills are separate claims:

- MCP bridge available: `codex mcp list` shows `xcode` with command `xcrun` and args `mcpbridge`.
- Agent CLI available: `xcrun --find agent` resolves a local tool path.
- Agent skills available: `xcrun agent skills export` exports actual skill bundles. If it reports `No skills available to export`, do not claim native Xcode agent skills exist.

`xcodebuildmcp` remains the configured fallback bridge. It is not replaced by Apple-native Xcode MCP, and it should remain available for simulator workflow, build/test proof, and UI inspection where native MCP is unavailable.

## Bridge Skill

Use:

```text
.agents/skills/ambitions-xcode-codex-bridge/SKILL.md
```

Use it with these existing skills when relevant:

- `ambitions-ios-validation-xcode-wrapper`
- `ambitions-visual-product-quality`
- `ambitions-accessibility-proof`
- `ambitions-release-proof-honesty`
- `ambitions-reviewer-board`
- `uiql-quality-lockdown`

## SDK 27 Guardrail

While Xcode 26.x is the proof compiler, Swift source must not use SDK 27-only APIs unless a future scoped migration has Xcode 27 availability proof and explicit migration authority.

Blocked names include:

- `toolbarMinimizeBehavior`
- `topBarPinnedTrailing`
- `toolbarOverflowMenu`
- `visibilityPriority`
- `swipeActionsContainer`
- `ContentBuilder`
- `asyncImageURLSession`
- other SDK 27-only SwiftUI APIs discovered during future proof

Run:

```bash
bash scripts/codex/scan-sdk27-swiftui-usage.sh
```

The scan defaults to Swift source under `Native`, `Sources`, `AppUI`, and `Packages`. Docs and artifacts are ignored unless the scan is explicitly run with the docs flag.

## Ambitions UI Usage

Route these through the bridge skill and the relevant UI/accessibility skills:

- Root Shell
- Context Crown
- Continuity Dock
- Capture and Atmosphere Composer entry points
- safe-area behavior
- Liquid Glass-adjacent material choices
- preview matrices
- screenshot proof
- accessibility variants
- Dynamic Type
- VoiceOver order
- Reduce Motion
- Reduce Transparency
- Increase Contrast
- screenshot diffing

For UIQL/root shell work, proof should include screenshot inspection, hierarchy or accessibility-tree review, tap target checks, scroll/collapse checks, dock/header legibility, and safe-area checks where tooling can provide them.

Screenshot paths are not visual proof. Screenshots must be visually evaluated before any visual Green claim.

## Security Boundaries

Do not add or enable any of the following without explicit approval and policy gates:

- write-capable MCP
- secret-reading MCP
- signing automation
- App Store upload automation
- hosted CI
- analytics, telemetry, crash SDKs, or tracking
- production-affecting networked automation
- required cloud LLM/backend paths for core Ambitions behavior

Xcode and simulator automation must stay local, proof-bound, and non-production-affecting unless a future approved release/signing workflow says otherwise.

## Closeout Discipline

Bridge closeouts must report:

- actual Xcode version
- selected developer directory
- whether Apple-native Xcode MCP was visible to Codex
- whether Xcode agent skill export worked
- whether Xcode agent skills were actually exported
- whether `xcodebuildmcp` fallback remains configured
- validation commands and results
- whether SDK 27 APIs were found
- whether simulator/device proof was captured
- Green/Yellow/Red status
- proof boundaries

Proof boundary: this bridge does not prove app UI quality, release readiness, accessibility certification, TestFlight readiness, App Store readiness, privacy/legal approval, performance readiness, or physical-device behavior unless separate current proof artifacts exist.
