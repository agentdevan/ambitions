# Frontend Primitive Misuse And Density Gate

<!-- markdownlint-disable MD013 -->

Status: Active FET gate
Date: 2026-05-09
Batch: FET06

## Purpose

Signature objects must not degrade into generic rounded cards with unlimited content. This gate constrains primitives before they become dashboards.

## Required Density Roles

Every new or materially changed primitive usage must name one role:

- `flagshipPrimary`
- `supportCompact`
- `detailDisclosure`
- `receiptDrawer`
- `listRow`
- `settingsGroup`

## Gate Rules

- Hero primitives cannot accept unlimited arbitrary vertical content.
- Primary surfaces need constrained slots: primary object, title, one reason line, max two proof/support signals, one primary action, optional collapsed detail drawer, optional receipt seam.
- Generic panels cannot be used as flagship objects without composition proof.
- Chip grids are not allowed above the fold unless explicitly justified and within budget.
- Nested panels inside panels are Red for top-level primary objects.
- New primitive usage needs anatomy, state matrix, accessibility, motion fallback, and screenshot/preview evidence when UI-touching.

## Red

`AmbitionRichPanel`, `HeroDecisionPanel`, `AppCard`, rounded rectangles, chip grids, or VStack panels become the visible identity instead of the Ambitions object.
