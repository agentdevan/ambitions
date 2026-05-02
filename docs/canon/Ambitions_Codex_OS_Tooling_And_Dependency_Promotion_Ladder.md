# Ambitions Codex OS Tooling And Dependency Promotion Ladder

Status: Future Codex OS tooling canon; docs-only

## Levels

### Level 0 - Already Required

Xcode, XcodeGen, SwiftPM, git, zsh, ripgrep / rg.

### Level 1 - Adopted Local Dev Tools

gh, jq, xcbeautify, markdownlint-cli2, lychee.

### Level 2 - Optional Recommended For Beyond 3.0

SwiftFormat advisory, SwiftLint advisory, Periphery advisory, xcresult parsing, Xcode version checker, simulator cleanup/reset helper, UI test log summarizer, privacy manifest lint script, accessibility identifier scan, string catalog/localization scan, doc frontmatter/index checker, large-file ownership analyzer, test flake classifier, path coverage matrix generator, traceability matrix generator, compatibility seam scanner, route/raw-value scanner, import/export payload scanner, validation log ledger generator.

### Level 3 - Optional Later For Release Scale

Fastlane only when signing/TestFlight automation is near-term; enforced SwiftFormat/SwiftLint only after baselines; Periphery strict mode only after false-positive policy; snapshot testing only if stable; accessibility audit helper only if evidence improves; xcresult parser required only if failures need it.

### Level 4 - Requires Major Architecture Approval

backend SDK, analytics SDK, AI SDK, telemetry SDK, sync service, account/auth provider, database replacement, dependency injection framework, code generation framework, Tuist, Sourcery, SwiftGen, Danger, paid QA service, crash reporting SDK, remote config.

### Level 5 - Forbidden Until Product Strategy Changes

generic analytics tracking, hidden behavior telemetry, ad SDKs, social SDKs, growth hacking SDKs, unreviewed AI memory services, cloud sync, user scoring systems, habit streak gamification packages, dependencies that widen Ambitions.

## Script Rules

All future scripts are advisory unless separately promoted, local-only, no network, non-CI-blocking in this batch, and must print what they checked, skipped, and do not prove.

## Codex OS Continuity Rules

Update BATCH_REGISTRY and CONTEXT_INDEX, create/select a manifest, define Green/Yellow/Red gates, keep one active batch unless authorized, stage/commit/push each Green batch before continuing, preserve validation logs, record next user decision, never infer release readiness from simulator proof, never infer implementation from canon, and never run future trains automatically after a canon batch.
