# Ambitions 3.0 — Dependency Management Policy

Status: Active dependency governance

## Purpose

Keep Ambitions fast to build, easy to audit, privacy-preserving, and local-first.

## Default Decision

Do not add a dependency.

A dependency is allowed only when it clearly reduces long-term complexity, has a low privacy/security footprint, is actively maintained, has a simple removal path, and is validated locally and in CI.

## Required Dependencies

- Xcode and iOS simulator runtimes.
- XcodeGen, because `project.yml` is the project source of truth.
- Swift Package Manager, through Xcode and `Package.swift`.
- Git.
- Shell tools already present on macOS/Xcode runners.
- ripgrep for fast source scans.

## Optional Recommended Tools

- `gh` for GitHub inspection when credentials exist.
- `jq` for JSON inspection.
- `xcbeautify` for readable local logs.
- `markdownlint-cli2` for docs hygiene when installed.
- markdown link checker for periodic documentation audits.

## Optional Later

- Fastlane only if signed archive/TestFlight automation becomes near-term and human-owned signing secrets exist.
- SwiftFormat/SwiftLint only after style rules are agreed and CI impact is tested.

## Avoid

- Tuist: do not replace XcodeGen.
- SwiftGen/Sourcery: not justified by current repo complexity.
- Danger: adds CI/process complexity without current need.
- Analytics SDKs: privacy and product risk until explicit instrumentation policy exists.
- Backend SDKs: Ambitions is local-first; backend/sync boundaries must be designed first.
- AI SDKs: Ambitions is intelligent, not an AI-wrapper product.
- Paid QA services: use local simulator, Xcode, and focused evidence first.

## Proposal Template

A dependency proposal must include: name, category, purpose, install command, runtime/build-time scope, license/security/privacy risk, local validation command, CI impact, fallback, removal path, and owner.
