# Ambitions 3.0 — Dependency Management Policy

Status: Active dependency governance

## Purpose

Keep Ambitions fast to build, easy to audit, privacy-preserving, and local-first. Dependency changes must improve Codex speed or repo quality without polluting the iOS runtime.

## Dependency Classes

- App runtime dependency: code or SDK linked into the Ambitions app, extensions, widgets, App Intents, or shipped bundles.
- Build dependency: a tool needed to generate, compile, test, archive, or package native targets.
- Local developer tool: a tool used by Codex or humans on Mac to inspect, format, validate, or summarize work.
- CI developer tool: a tool installed or invoked by GitHub Actions.
- Documentation QA tool: a local or CI tool that scans Markdown, links, active-canon references, or deprecated language.
- Optional staged tool: a tool documented for later adoption but not required, blocking, or part of default setup.
- Forbidden dependency: a tool, SDK, or service that conflicts with Ambitions 3.0 privacy, local-first posture, build simplicity, or cost constraints.

## Default Decision

Do not add a dependency.

A dependency is allowed only when it clearly reduces long-term complexity, has a low privacy/security footprint, is actively maintained, has a simple removal path, and has a validation command.

## Current Accepted Tool Posture

### Required

- Xcode and iOS simulator runtimes.
- XcodeGen, because `project.yml` is the project source of truth.
- Swift Package Manager, through Xcode and `Package.swift`.
- Git.
- zsh/bash shell execution.
- ripgrep for fast source scans.

### Optional Recommended And Adopted As Developer Tools

These tools are adopted for local developer/Codex workflows and listed in `Brewfile`.

- `gh`: GitHub inspection when credentials exist. Does not replace local git truth.
- `jq`: JSON parsing for simulator, GitHub, and tool output.
- `xcbeautify`: local build/test log readability. Does not change build behavior.
- `markdownlint-cli2`: documentation linting. Advisory until the existing doc backlog is clean.
- `lychee`: Markdown link checking. Advisory by default because external links and network availability are flaky.

### Optional Later, Prepared Only

These are documented in `Brewfile.optional-later` and are not required setup.

- SwiftLint: staged only until legacy identifier migration and UI test modernization reduce false positives.
- SwiftFormat: staged only until formatting ownership and diff-noise policy are agreed.
- Fastlane: documentation-only until signing, TestFlight, and App Store automation become near-term and human-owned credentials exist.

### Avoid

- Tuist: do not replace XcodeGen.
- SwiftGen: not justified by current repo complexity.
- Sourcery: not justified by current repo complexity.
- Danger: adds CI/process complexity without current need.
- Analytics SDKs: privacy and product risk until explicit instrumentation policy exists.
- Backend SDKs: Ambitions is local-first; backend/sync boundaries must be designed first.
- AI SDKs: Ambitions is intelligent, not an AI-wrapper product.
- Paid QA services: use local simulator, Xcode, and focused evidence first.

## Policy Rules

1. No runtime dependency may be added without a written dependency proposal.
2. Developer tools must be isolated from app runtime.
3. New tools must have a validation command.
4. New tools must be documented in `docs/codex/MAC_CODEX_5_5_TOOLCHAIN_SETUP.md`.
5. Tool failures should not block app build unless intentionally promoted to a gate.
6. Markdown/link checks may be advisory until the existing doc backlog is clean.
7. SwiftLint and SwiftFormat stay staged/non-blocking until after legacy identifier migration and UI test modernization.
8. Fastlane stays documentation-only until signing/TestFlight/App Store automation becomes near-term.

## Active Validation Commands

```bash
brew bundle check || true
scripts/validate-dev-tools.sh
scripts/run-doc-qa.sh
DOC_QA_STRICT=1 scripts/run-doc-qa.sh
scripts/build-local.sh
scripts/test-local.sh || true
```

## Dependency Proposal Template

A dependency proposal must include: name, category, purpose, install command, runtime/build-time scope, license/security/privacy risk, local validation command, CI impact, fallback, removal path, and owner.
