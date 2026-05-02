# Visual QA Preview Fixture Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Ensure SI UI work has deterministic preview states, screenshot or preview
evidence where possible, and a reviewable visual QA package.

## When It Applies

Use for every UI-changing SI batch and for PD/AOS24 batches that compose SI
primitives.

## Source-Truth Hierarchy

User prompt, `AGENTS.md`, PXOS visual/accessibility canon, SI canon, preview
fixtures under `Native/Ambitions/PreviewSupport/**`, and current tests.

## Review Inputs

Preview list, fixture source, state matrix, screenshots if scriptable, visual
QA report, file-size report, and known manual-proof gaps.

## Review Checklist

- Normal, empty, loading, degraded, privacy-sensitive, Dynamic Type, and
  reduced-motion states are represented when relevant.
- Screenshots/previews are named and reproducible where tooling allows.
- Visual QA separates simulator evidence from human approval.
- Fixtures are deterministic and local.
- No fake screenshot, fake device proof, or hidden generated artifact.

## Green / Yellow / Red Criteria

- Green: evidence package covers current UI risk.
- Yellow: screenshot automation unavailable but previews/state matrix and
  manual instructions are adequate.
- Red: UI changed without preview/state evidence, fake proof, non-deterministic
  fixture, or missing visual QA for a top-level surface.

## Forbidden Approvals

Do not approve human visual approval, device proof, or public accessibility
proof unless actually performed.

## Required Evidence

Preview names, fixture names, state matrix, screenshot status, visual QA report,
and non-claims.

## Repair Guidance

Add fixtures, add previews, capture screenshots if supported, or stop if UI
cannot be reviewed safely.

## Claims

May claim visual QA evidence exists for the touched scope. Must not claim human
approval or device/platform proof.
