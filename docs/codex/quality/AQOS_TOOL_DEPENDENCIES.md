# AQOS Tool Dependencies
<!-- markdownlint-disable MD013 -->

Status: Active AQOS dependency policy.
Date: 2026-05-05

## Purpose

AQOS should improve quality without turning the repo into a fragile tool zoo. Dependencies must be minimal, local, reproducible, and justified.

## Default Dependencies

Required baseline tools already expected in the repo environment:

- macOS shell
- Bash
- Git
- grep / sed / awk / find / wc
- Python 3 standard library
- Xcode command-line tools
- xcodebuild
- xcrun simctl
- xcodegen, if already used by the repo

## Optional Tools

Optional only when already available or explicitly installed by a dedicated toolchain batch:

- XcodeBuildMCP for simulator build/run/screenshot automation
- SwiftFormat / SwiftLint if already part of repo workflow
- Periphery or equivalent dead-code tool only if approved by dependency policy
- xcbeautify only if already approved
- ImageMagick or perceptual diff tooling only if dependency policy approves

## Dependency Rules

- Do not add third-party dependencies casually.
- Do not add network services for quality checks.
- Do not add paid tools.
- Do not add binary-only tools.
- Do not add tools that require secrets.
- Prefer shell/Python standard library first.
- Any new dependency requires PFC dependency/supply-chain approval.

## Script Philosophy

AQOS scripts should be:

- non-mutating by default
- advisory by default
- strict when `AQOS_STRICT=1`
- deterministic where possible
- safe on CI and local machines
- understandable to a senior engineer
- documented with expected inputs/outputs

## Screenshot / Simulator Tools

Preferred stack:

1. xcodebuild
2. xcrun simctl
3. XcodeBuildMCP if available
4. manual operator proof checklist if automation unavailable

## Metal / Advanced Rendering Dependencies

Metal does not require external dependencies but does require MEG01 approval before use.

AQOS must not introduce Metal or shader tooling as part of quality infrastructure unless a specific rendering primitive is approved.
