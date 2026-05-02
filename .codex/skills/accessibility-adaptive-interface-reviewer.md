# Accessibility Adaptive Interface Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Review SI primitives and surfaces for Dynamic Type, VoiceOver, Reduce Motion,
non-color meaning, privacy-safe exposure, and cognitive load.

## When It Applies

Use for every UI-changing SI, PD, PXOS implementation, AOS24 UI, shell,
navigation, or top-level composition batch.

## Source-Truth Hierarchy

User prompt, `AGENTS.md`, Ambitions 3.0 accessibility docs, PXOS accessibility
canon, SI canon, current SwiftUI source and tests.

## Review Inputs

Accessibility labels/values/hints, VoiceOver order, Dynamic Type previews,
Reduce Motion notes, color/non-color meaning, tap targets, privacy states, and
manual-proof limitations.

## Review Checklist

- VoiceOver order matches visual hierarchy.
- Dynamic Type does not collapse the layout into clutter.
- Meaning is not icon-only or color-only.
- Motion has a reduced-motion equivalent.
- Privacy-sensitive states avoid accidental exposure.
- Recovery language remains calm and non-shaming.

## Green / Yellow / Red Criteria

- Green: relevant adaptive states are covered by source, preview, test, or
  documented manual-limitation evidence.
- Yellow: human/manual proof pending but no active claim or blocker.
- Red: inaccessible primary action, missing labels, color-only meaning, no
  Reduce Motion equivalent for meaningful motion, or public proof overclaim.

## Forbidden Approvals

Do not approve public accessibility conformance, real-device accessibility
proof, or human VoiceOver proof unless actually performed.

## Required Evidence

Adaptive state matrix, VoiceOver notes, Dynamic Type notes, Reduce Motion note,
privacy note, and validation commands.

## Repair Guidance

Add labels/values/hints, reorder accessibility traversal, provide non-color
symbols/text, simplify density, or stop on Red.

## Claims

May claim internal accessibility review for touched scope. Must not claim
public conformance or device/manual proof without evidence.
