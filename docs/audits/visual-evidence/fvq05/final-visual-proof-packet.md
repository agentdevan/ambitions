# FVQ05 Final Visual Proof Packet Integration Hook
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Status: Active visual proof packet hook; not final signoff

## Purpose

This packet gives FCP28, FCP29, PFC39, PFC40, and final handoff batches one
place to find current FVQ evidence, unresolved Yellow owners, and hard no-claim
boundaries.

This packet does not claim final visual signoff, public accessibility
conformance, physical-device proof, App Store readiness, TestFlight readiness,
release readiness, legal/privacy compliance, or human visual approval.

## Evidence Inventory

| Area | Evidence | Status | Owner for next proof |
| --- | --- | --- | --- |
| Today default visual | `docs/audits/visual-evidence/fvq01/today-default.png` | Accepted Yellow | Future visual QA / FCP28 |
| Today freshness | `docs/audits/visual-evidence/fvq01/screenshot-freshness.json` | Accepted Yellow because app-self build SHA is absent | Future app-self freshness owner |
| Today accessibility summary | `docs/audits/visual-evidence/fvq01/today-accessibility-summary.md` | Accepted Yellow | FCP29 / accessibility proof owner |
| Five top-level tabs | `docs/audits/visual-evidence/fvq02/*.png` | Accepted Yellow | FCP28 / FCP29 |
| Top-level scorecard | `docs/audits/visual-evidence/fvq02/visual-scorecard.md` | Accepted Yellow | FCP28 |
| Top-level Reduce Motion notes | `docs/audits/visual-evidence/fvq02/top-level-reduce-motion.md` | Accepted Yellow; no rendered Reduce Motion screenshots | FCP29 |
| Drill-down detail screenshots | `docs/audits/visual-evidence/fvq03/*.png` | Accepted Yellow | FCP28 / object owners |
| Drill-down scorecard | `docs/audits/visual-evidence/fvq03/visual-scorecard.md` | Accepted Yellow | FCP28 |
| Recurring rendered proof protocol | `docs/audits/fvq04-recurring-ui-batch-rendered-proof-protocol-report.md` | Green | Every future UI-affecting batch |
| Advanced rendering eligibility | `docs/audits/meg01-advanced-rendering-eligibility-report.md` | Green; no renderer approved by default | Future named primitive owner |

## Required Final Packet Inputs

Before any final visual, handoff, release, App Store, TestFlight, public
accessibility, or device claim, a future proof packet must include:

- all five top-level screens
- critical drill-downs
- widgets and Live Activities if implemented
- App Intent or Shortcut visible confirmation if implemented
- notification content previews if implemented
- light and dark appearance if supported
- Dynamic Type
- Reduce Motion
- privacy-sensitive states
- empty, loading, stale, blocked, recovery, degraded, and overloaded states
- screenshot freshness proof tied to repo/build and, when available, app-self
  build identity
- manual VoiceOver traversal notes or explicit human-proof stop
- measured contrast notes or explicit human-proof stop
- physical-device checklist or explicit human-proof stop
- human visual review checklist or explicit human-proof stop
- unresolved Yellow owner list

## Yellow Owner Ledger

| Yellow | Current evidence | Required closure |
| --- | --- | --- |
| App-self screenshot freshness absent | Repo/toolchain freshness metadata exists | App exposes build identity or an equivalent operator-verifiable freshness path |
| Dynamic Type screenshots absent | Source and partial preview evidence exist | Rendered Dynamic Type screenshots for top-level and critical detail surfaces |
| Reduce Motion screenshots absent | Source policy and notes exist | Rendered Reduce Motion screenshots or recording evidence |
| Manual VoiceOver absent | Accessibility labels/source evidence exist | Human/manual traversal notes |
| Measured contrast absent | Visual scorecards exist | Contrast measurement or human visual QA notes |
| Physical-device proof absent | Simulator evidence exists | Device proof or explicit launch/handoff stop |
| Human visual review absent | Codex visual review exists | Human design review notes |
| Widget rendered proof absent | PFC13 strategy exists | Widget gallery screenshot and privacy-safe state proof |
| Live Activity rendered proof absent | Strategy/source exists | Lock Screen / Dynamic Island proof if implemented |
| App Intent confirmation proof absent | App Intent source and compatibility proof exist | Visible confirmation/result proof if implemented |
| Goals LifePath/TimeSpine still visually Yellow | FVQ02/FVQ03 screenshots exist | FCP10/FCP11/FCP12/FCP28 proof |
| Plan/You density and accessibility still Yellow | FVQ02/FVQ03 screenshots exist | FCP22/FCP24/FCP28/FCP29 proof |

## Hard Red Checks For Future Final Gates

Final visual proof must stop or repair if:

- any top-level surface loses its primary object identity
- any screen becomes a stack of undifferentiated panels
- Capture behaves as an inbox/feed
- Plan becomes a calendar clone or analytics surface
- Goals becomes project-management software
- You becomes a settings dump
- external surfaces expose sensitive Found Life content
- screenshot freshness cannot be established for a claimed proof
- accessibility or Reduce Motion equivalents are impossible
- a release/legal/privacy/App Store/TestFlight/device claim outruns evidence

## Required Handoff References

Future FCP28, FCP29, FCP30, PFC39, and PFC40 reports must reference this packet
or a successor final visual proof packet before making any visual-quality,
accessibility, device, external-surface, release, or handoff claim.

## Current Continuation Decision

FVQ05 is a Green integration hook if the report, order, registry/context, and
run-state docs point final visual proof consumers to this packet and all
unproven claims remain explicitly unmade.
