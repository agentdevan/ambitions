---
name: ambitions-xcode-codex-bridge
description: Use for Ambitions Xcode/Codex integration, Apple-native Xcode MCP detection, xcodebuildmcp fallback, SDK 27 guardrails, simulator/device proof hooks, and proof-bound closeouts.
---

# Ambitions Xcode Codex Bridge

## Authority Boundary

This skill is operating support only. It is subordinate to `docs/truth/*`, `AGENTS.md`, live source, current Xcode/compiler evidence, current validation logs, and the active `AMB-*` issue or Goal Mode program when one exists.

It does not prove app behavior, build success, test success, UI quality, accessibility conformance, device behavior, release readiness, TestFlight readiness, App Store readiness, privacy/legal approval, or owner approval.

Before non-trivial Ambitions work, read:

1. `docs/truth/README.md`
2. `docs/truth/PRODUCT_DESIGN_TRUTH.md`
3. `docs/truth/PRODUCT_MOAT_TRUTH.md`
4. `docs/truth/IMPLEMENTATION_TRUTH.md`
5. `docs/truth/RELEASE_TRUTH.md`
6. `docs/truth/CODEX_PROCESS_TRUTH.md`
7. `docs/truth/HISTORICAL_POLICY.md`
8. `AGENTS.md`
9. Relevant project, source, scripts, proof artifacts, and program skills

Active IA remains `Today / Goals / Time / Motion / You`; `Capture` is global, not a tab. Preserve local-first architecture, proof honesty, native iPhone quality, and direct-`main` repo hygiene unless the user explicitly authorizes another branch policy.

## Tool Preference Order

1. Use Apple-native Xcode MCP tools when they are visible to Codex on the current machine and current commands prove their availability.
2. Use the existing `xcodebuildmcp` bridge as the fallback for build, test, simulator, screenshot, launch, and UI inspection workflows.
3. Use Ambitions deterministic scripts for proof, especially `scripts/ambitions-xcode-validate.sh`, `scripts/codex/xcode-codex-bridge-doctor.sh`, and focused program gates.
4. Use manual owner/device proof only where local automation cannot prove the claim.

Never claim native Xcode 27 agent skills are available unless local commands prove them. Under an Xcode 26.x proof compiler, treat Xcode 27 material as future-readiness guidance only.

## Xcode MCP Detection

At the start of bridge work, capture:

```bash
git status --short --branch
git rev-parse HEAD
xcodebuild -version
xcode-select -p
codex mcp list
xcrun --find agent || true
xcrun agent skills export || true
```

If `codex mcp list`, `xcrun --find agent`, or `xcrun agent skills export` fails, record the exact failure. That is Yellow when `xcodebuildmcp` and repo validation scripts are still configured; it is not proof that Xcode 27 agent skills exist.

## Fallback Validation

Prefer wrapper-first validation from `ambitions-ios-validation-xcode-wrapper`:

```bash
scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane none --json
scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane build --json
scripts/ambitions-xcode-validate.sh --batch <BATCH_ID> --lane focused-test --test <TEST_ID> --json
```

Use raw `xcodebuild` only inside existing wrappers or when a focused fallback is explicitly justified and logged.

## SwiftUI Review Requirements

For SwiftUI source changes, require a SwiftUI-specialist-style review of:

- native SwiftUI ownership and state flow
- safe areas, Dynamic Type, VoiceOver order, Reduce Motion, Reduce Transparency, Increase Contrast, tap targets, and scroll behavior
- Ambitions product canon, canonical copy, and anti-dashboard/card-stack/chatbot/calendar drift
- screenshot or preview evidence before any visual-quality claim

This review requirement does not claim Apple Xcode 27 native skills are installed under Xcode 26.x.

Use SwiftUI-whats-new-27-style review only as future-readiness guidance. SDK 27-only APIs are blocked from app source while Xcode 26.x is the proof compiler unless a future scoped migration has Xcode 27 availability proof.

Blocked SDK 27-only API names include:

- `toolbarMinimizeBehavior`
- `topBarPinnedTrailing`
- `toolbarOverflowMenu`
- `visibilityPriority`
- `swipeActionsContainer`
- `ContentBuilder`
- `asyncImageURLSession`

Run:

```bash
bash scripts/codex/scan-sdk27-swiftui-usage.sh
```

## UIQL and Device Interaction Proof

For UIQL, root shell, Context Crown, Continuity Dock, Capture, safe areas, Liquid Glass-adjacent materials, preview matrices, screenshot proof, accessibility variants, Dynamic Type, VoiceOver order, Reduce Motion, and screenshot diffing, use this bridge with `uiql-quality-lockdown`, `ambitions-visual-product-quality`, and `ambitions-accessibility-proof`.

Device-interaction-style proof should capture, when tooling can provide it:

- screenshot evidence tied to the current build/commit
- hierarchy or accessibility tree inspection
- tap target checks
- scroll and collapse behavior
- dock and header legibility
- safe-area checks
- Dynamic Type, Reduce Motion, Reduce Transparency, and Increase Contrast variants

Screenshot paths alone are not visual proof. Screenshots must be visually evaluated before visual Green.

## Security Boundaries

Do not add or enable any of the following without explicit approval and policy gates:

- write-capable MCP
- secret-reading MCP
- signing automation
- App Store upload automation
- hosted CI
- analytics, telemetry, crash SDKs, or tracking
- networked automation that can affect production or user data
- required cloud LLM/backend paths for core Ambitions behavior

## Closeout Requirements

Closeouts using this skill must report:

- Xcode version
- selected developer directory
- baseline and final commit SHA when committed
- whether Apple-native Xcode MCP was detected by Codex
- whether Xcode agent skill export worked
- whether `xcodebuildmcp` fallback was used or remains configured
- whether simulator/device proof was captured
- whether SDK 27 APIs were avoided
- validation commands, exit codes, and results
- Green/Yellow/Red status
- proof boundaries and non-claims

Green requires scoped completion, validation appropriate to the docs/tooling or source scope, no SDK 27 API drift, and no proof overclaim. Yellow is appropriate when Apple-native Xcode MCP or agent skills are not visible but the fallback bridge remains configured, or when manual simulator/device proof is pending. Red requires missing Xcode, missing repo validation bridge, forbidden source/release/security changes, SDK 27 API source usage under Xcode 26.x, or false readiness claims.
