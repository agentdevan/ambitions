# Active Canon Pack

## Purpose

Focused validation for active canon pack in Ambitions 3.0.

## Commands

```bash
git status --short
xcodegen generate
xcrun simctl list devices available | grep -E 'iPhone' | head -20
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
```

Add focused tests or scans based on touched paths. For copy or docs work, include stale guidance and copy guard scans. For dependency work, inspect `project.yml`, `Package.swift`, `Package.resolved`, `.github/workflows/ios-validate.yml`, and installed tools.

## Expected Evidence

- Commands run and exit status.
- Exact simulator destination.
- Tests/scans passed or failed.
- Known existing failures separated from new failures.

## Failure Interpretation

- Build failure: classify as repo, tooling, simulator, dependency, or signing/environment.
- Test failure: identify focused owner path and whether failure pre-existed.
- Scan failure: fix active guidance or document allowed historical hits.

## Escalation Rules

Run focused validation first. Escalate to full build/test only when touched code crosses shared seams, routing, shell, persistence, project config, release gates, or external surfaces.

## Focused Vs Full Validation

Focused validation is enough for docs-only or narrow tests. Full validation is required for shared domain, routing, project, persistence, release, or broad UI shell changes.

## Ambitions 3.0 Developer Tool Commands

```bash
scripts/run-doc-qa.sh || true
rg -n --hidden --glob '!/.git/**' 'Ambitions_2_0|v2 is now active|Batch 61|Waves 1-19|Master Product and Visual System Spec v2 is now the active|Batch 89-120' AGENTS.md README.md docs/README.md docs/codex docs/canon/Ambitions_3_0_* docs/canon/README.md || true
```

Historical/supporting references are allowed. Active read-order docs must continue to start from Ambitions 3.0.
