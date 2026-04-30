# Ambitions 3.0 — Build Skills And Dependency Management

Status: Active Codex/build governance

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
