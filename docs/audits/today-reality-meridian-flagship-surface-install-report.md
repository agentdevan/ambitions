# Today Reality Meridian Flagship Surface Install Report

Status: Green for visual-encyclopedia canon installation; Yellow for local validation not run in connector session.
Date: 2026-05-15
Type: visual-canon / frontend-encyclopedia / repo-governance

## Summary

Installed the latest Today North Star direction directly into the active frontend visual encyclopedia path.

The new canon locks Today as a sparse, living temporal surface rather than a dense productivity dashboard. It also records the exact Reality Meridian temporal model: scheduled step node and live current-time cursor are separate, and the current-time cursor must show the exact left-side time label when visible.

This report does not claim SwiftUI implementation, screenshot parity, simulator proof, device proof, accessibility conformance, or release readiness.

## Files Changed

- `.github/README.md`
- `.github/workflows/swift6-modernization-scan.yml` deleted
- `.github/workflows/signature-visual-instruments-07.yml` deleted
- `docs/audits/hosted-workflow-removal-report.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/README.md`
- `frontend/visual-encyclopedia/recipes/today/README.md`
- `frontend/visual-encyclopedia/recipes/today/today_reality_meridian_flagship_surface.md`

## Today Canon Installed

### Primary Surface

`frontend/visual-encyclopedia/recipes/today/today_reality_meridian_flagship_surface.md`

### Product Role

Today is the flagship daily execution surface. It must answer:

- where the user is in the day
- what the grounded recommended step is
- what time reality the recommendation is based on
- what proof/recovery exists
- whether the behavior is local and inspectable

### Visual Positioning

Today is:

- living temporal surface
- native iPhone-first
- dark graphite / warm black / restrained gold
- sparse by default
- one-handable
- local-first and inspectable
- recovery-aware

Today is not:

- dashboard
- task list
- calendar clone
- chatbot surface
- dense card feed
- generic productivity home

## Reality Meridian Temporal Model

The Reality Meridian is the primary object.

The flagship recipe now requires two distinct time objects:

1. **Scheduled step node**: marks when a step belongs on the day spine.
2. **Live current-time cursor**: marks where the user actually is now.

Required example:

- If the Start Here step was scheduled at `10 AM`, the scheduled step node stays at `10 AM`.
- If the actual current time is `12:15 PM`, the live current-time glow sits at the exact `12:15 PM` rail position.
- The left-side label `12:15 PM` aligns to the live glow.
- The two markers must not collapse into one ambiguous node.

## Scroll Model

The Reality Meridian is a scrollable vertical day spine.

A screenshot/render is only one viewport state. The rail must imply continuation above and below the visible viewport so the user understands they can scroll through the day.

The scrollable day can include:

- scheduled commitments
- recommended steps
- protected blocks
- recovery moments
- open loops
- future lightweight moments
- proof/receipt transitions

## Start Here Model

Start Here emerges from the temporal field rather than appearing as a generic top hero card.

Default visible content is intentionally sparse:

- `Start here`
- step title, for example `Draft the interview story`
- metadata, for example `35 min · Work context`
- reason, for example `This open block fits with buffer.`
- proof line, for example `42m open · 7m buffer · Local`

The default state must not expose all chips, all receipts, all reasoning, all evidence tags, or all action alternatives.

## CTA Model

Primary CTA:

`Start now →`

Locked ergonomic rule:

- right half of screen
- at or below vertical center
- lower-middle / right thumb reach zone
- one primary CTA maximum at rest
- no equal-weight action row by default
- no hard wire/elbow/circuit connector from rail to CTA

The CTA should feel clean, floating, native, and reachable.

## Local Branding / Trust Chrome

Top-right chrome is locked as:

`Local · Ambitions`

Preferred treatment:

- small green local/privacy indicator ring
- quiet native status text
- aligned with compact Today header/status area
- not a banner
- not a large standalone logo
- not standalone `On-device` wording

## Proof / Recovery Model

Default compact surface:

`Still counts. Yesterday’s step was moved.`
`Receipt saved · 8:42`

Rules:

- compact
- calm
- graphite/glass-integrated
- emotionally safe
- not an error state
- not an overdue warning
- not expanded chips by default
- not an expanded receipt drawer by default

## Bottom IA

Locked top-level IA:

`Today / Goals / Capture / Time / You`

Forbidden in active top-level IA:

- `Plan`
- `Insights`
- `Profile`
- `Habits`

## FAANG Flagship Gate Additions

The new recipe adds explicit failure gates:

- fail if Today reads as a productivity dashboard
- fail if Reality Meridian can be replaced by a generic task list
- fail if Start Here reads as a top card in a stacked dashboard
- fail if scheduled node and live cursor are merged
- fail if current time is not exact when visible
- fail if `Start now →` is high or left-weighted
- fail if `Local · Ambitions` is missing from top chrome
- fail if proof/recovery is either absent or over-expanded
- fail if Today does not preserve one dominant object and one primary action

## GitHub Actions Auto-CI Removal

Deleted tracked workflow files that reintroduced automatic commit-time hosted workflows:

- `.github/workflows/swift6-modernization-scan.yml`
- `.github/workflows/signature-visual-instruments-07.yml`

Added `.github/README.md` to record the active no-hosted-auto-CI policy.

Important: this intentionally avoids hosted CI as proof. Current validation proof must come from local scripts, local terminal logs, local Xcode / `xcodebuild`, local simulator/device proof, checked-in reports, and release-truth review.

## Validation Performed

Connector-level checks performed:

- Direct fetch of `.github/workflows/swift6-modernization-scan.yml` on `main` returned `Not Found` after deletion.
- Direct fetch of `.github/workflows/signature-visual-instruments-07.yml` on `main` returned `Not Found` after deletion.
- Created and fetched active encyclopedia files through the GitHub connector.

Validation not performed in this connector session:

- `git status --short`
- `git diff --check`
- `test ! -d .github/workflows`
- repo-wide `rg` stale-reference scan
- local docs validators
- Swift/Xcode build validation

## Required Local Follow-Up

Run from a local checkout:

```bash
git status --short
git diff --check
find .github/workflows -type f -print 2>/dev/null
rg -n "\.github/workflows|GitHub Actions|hosted CI|Actions artifact|swift6-modernization-scan\.yml|signature-visual-instruments-07\.yml" README.md docs .codex .github frontend || true
```

Expected result:

- no workflow files unless a future manual-only workflow is intentionally restored
- active docs should not instruct hosted CI as proof
- remaining hosted-CI mentions should be historical or forbidden-current-proof language

## Implementation Boundary

This install is a canon/documentation update. It does not change SwiftUI source code. It should be consumed by future implementation prompts, visual QA gates, and frontend source-binding work.
