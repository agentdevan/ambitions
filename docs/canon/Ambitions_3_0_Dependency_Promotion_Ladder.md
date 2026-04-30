# Ambitions 3.0 Dependency Promotion Ladder

Status: Active dependency governance

## Purpose

Ambitions dependencies and tools move through explicit stages. No tool silently becomes required, CI-blocking, or app-runtime just because it is convenient for one run.

## States

| State | Meaning | Promotion requirements |
| --- | --- | --- |
| Proposed | Candidate tool or dependency | Written reason, owner, alternatives |
| Docs-only | Documented for later consideration | No setup required, no validation dependency |
| Local advisory | Helpful locally, non-blocking | Install command, verify command, removal path |
| Adopted developer tool | Expected for Codex/local work | Brewfile entry, validation script, setup guide |
| CI advisory | Runs in CI without blocking | Fast, deterministic, failure output archived |
| CI blocking | Blocks merge/release | Low flake rate, owner, documented repair path |
| App runtime | Shipped in app binary | Human approval, ADR, privacy/license/security review |
| Deprecated | Still present but discouraged | Replacement path, removal owner |
| Removed | No longer used | Cleanup proof and docs update |

## Current Posture

- `gh`, `jq`, `xcbeautify`, `markdownlint-cli2`, and `lychee` are adopted developer tools only.
- SwiftLint and SwiftFormat remain advisory/prepared, not blocking.
- Fastlane remains later/docs-only until signing, TestFlight, or App Store automation is an explicit near-term goal.
- Runtime SDKs for analytics, backend, AI, or paid QA remain forbidden without a separate approved dependency proposal.

## Promotion Bar

Every promotion requires purpose, install path, validation command, failure impact, owner, rollback path, and affected workflows.
