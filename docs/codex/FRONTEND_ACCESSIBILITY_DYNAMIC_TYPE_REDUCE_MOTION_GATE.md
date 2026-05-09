# Frontend Accessibility Dynamic Type Reduce Motion Gate

<!-- markdownlint-disable MD013 -->

Status: Active FET gate
Date: 2026-05-09
Batch: FET08

## Purpose

Accessibility is part of product quality, not a late checklist. Identifiers alone do not prove accessible UI.

## Gate Rules

- No icon-only meaning.
- No color-only meaning.
- Dynamic Type must not collapse primary objects into clutter.
- VoiceOver labels, values, hints, and traversal must match visual priority.
- Touch targets must remain usable, with 44pt minimum and 48pt preferred for primary actions.
- Reduce Motion equivalents are required where motion matters.
- Cognitive load is an accessibility issue.
- Privacy-sensitive content must remain safely summarized in screenshots and VoiceOver.

## Required Evidence

UI-touching reports must include Dynamic Type, VoiceOver, touch target, contrast/non-color, cognitive-load, and Reduce Motion notes. Public accessibility conformance remains a non-claim unless human/device proof exists.

## Red

Accessibility identifiers exist but Dynamic Type, VoiceOver, tap target, contrast/non-color, Reduce Motion, or cognitive-load evidence is missing for touched visible UI.
