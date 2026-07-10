# Article 30 — Design-system governance

## DESIGN-001 — Token hierarchy

The design system separates primitive tokens from semantic tokens. Product source consumes semantic tokens except inside token implementation.

## DESIGN-002 — Token domains

Canonical token domains cover color, typography, spacing, sizing, corner treatment, border, material, depth/lighting, motion, haptics, focus, destructive/warning/success states, and accessibility variants.

## DESIGN-003 — Theme completeness

Every theme defines light, dark, increased-contrast, Reduce Transparency, and relevant accessibility mappings without losing semantic meaning.

## DESIGN-004 — Token change control

A semantic-token change requires impact inventory, screenshot diff coverage, accessibility review where relevant, and deprecation/migration plan.

## DESIGN-005 — Ad hoc constant audit

Production SwiftUI is audited for unapproved local colors, font sizes, spacing, radius, shadows, materials, animations, and haptics when semantic tokens exist.

## DESIGN-006 — Stable component maturity

Components progress through Experimental, Internal, Candidate, Stable, Deprecated, Removed. Stable status requires documentation, previews, accessibility, tests, screenshot baselines, token compliance, and one owner.

## DESIGN-007 — Positive visual targets

Every flagship surface has an approved positive target, actual render, target-versus-actual critique, and independent visual acceptance.

---
