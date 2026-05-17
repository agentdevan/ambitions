# Ambitions 3.0 — Build Skills And Dependency Management

Status: Historical supporting canon; subordinate to `docs/truth/*`

## Purpose

This document connects the repo-local skill system with dependency discipline. Ambitions should become easier to build without becoming dependency-heavy.

## Rules

- Use skills before inventing a new workflow.
- Use local Markdown, shell, XcodeGen, SwiftPM, and Xcode first.
- Do not add runtime app dependencies in a Codex tooling pass.
- Do not add paid services.
- Do not add Fastlane, Tuist, SwiftGen, Sourcery, Danger, analytics SDKs, backend SDKs, or AI SDKs without a later explicit product/build decision.
- Any dependency proposal must name purpose, install path, risk, removal path, and validation command.

## Skill/Dependency Gate

Before adding a dependency, Codex must run or document:

1. `.codex/skills/dependency-auditor.md`
2. `.codex/skills/dependency-addition-gatekeeper.md`
3. `.codex/validation/dependency-drift-pack.md`
4. `.codex/playbooks/dependency-addition-review.md`

## Preferred Tools

Required: Xcode, XcodeGen, Swift Package Manager, git, zsh/bash, ruby, python3, ripgrep.

Optional recommended: gh CLI, jq, xcbeautify, markdownlint-cli2, markdown link checker.

Avoid by default: Fastlane, Tuist, SwiftGen, Sourcery, Danger, paid QA services, analytics SDKs, backend SDKs, AI SDKs.

## Adopted Local Developer Tools

Ambitions 3.0 now adopts these optional recommended tools as local developer tools through `Brewfile`: `gh`, `jq`, `xcbeautify`, `markdownlint-cli2`, and `lychee`.

These tools are isolated from the app runtime. They improve Codex inspection, log readability, and documentation QA, but they do not change shipped Swift code or generated app artifacts.

Use:

```bash
brew bundle
scripts/validate-dev-tools.sh
scripts/run-doc-qa.sh
scripts/build-local.sh
scripts/test-local.sh || true
```

SwiftLint, SwiftFormat, and Fastlane remain staged-only in `Brewfile.optional-later`. They are not active gates and should not be used to block Ambitions 3.0 work until the dependency policy promotes them.
