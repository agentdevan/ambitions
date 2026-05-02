# Interaction Motion Haptics Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Ensure SI motion, transitions, microinteractions, and haptics orient, confirm,
or reduce uncertainty without becoming decorative or gamified.

## When It Applies

Use for rail selection, panel expansion, receipt toasts, Capture route reveal,
LifePath emphasis, LifeShape scope changes, grouped row feedback, haptics, and
surface transitions.

## Source-Truth Hierarchy

User prompt, `AGENTS.md`, PXOS visual interaction canon, SI canon, SwiftUI
source, Reduce Motion requirements, and accessibility evidence.

## Review Inputs

Interaction description, animation triggers, haptic triggers, Reduce Motion
equivalent, preview/video/screenshot status, and tests where available.

## Review Checklist

- Motion has a functional purpose.
- User-initiated confirmation is the only haptic class unless justified.
- Reduced Motion has a meaningful non-motion equivalent.
- Motion does not hide state changes or increase cognitive load.
- Timing is restrained and native-feeling.

## Green / Yellow / Red Criteria

- Green: purpose, fallback, accessibility, and evidence are documented.
- Yellow: optional polish evidence missing but fallback and behavior are safe.
- Red: decorative/gamified motion, missing Reduce Motion equivalent, inaccessible
  transition, or fake human/device proof.

## Forbidden Approvals

Do not approve animation for spectacle, dopamine loops, fake AI glow, or haptic
reward systems.

## Required Evidence

Motion purpose, trigger, fallback, accessibility note, preview/screenshot/video
status if available, and validation commands.

## Repair Guidance

Remove decorative motion, add static emphasis fallback, shorten transitions,
or stop if motion is essential but untestable.

## Claims

May claim interaction review for the current scope. Must not claim device
haptic proof unless performed on device.
