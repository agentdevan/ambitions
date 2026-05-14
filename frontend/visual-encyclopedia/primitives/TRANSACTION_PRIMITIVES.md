# Transaction Primitives

Status: Active primitive contract

## Purpose

Represent intent, preview, commit, receipt, and undo.

## Canonical Anatomy

- intent
- preview
- commit
- receipt
- undo

## Allowed Use

- meaningful changes
- reversible changes
- recovery

## Forbidden Use

- silent mutation
- hidden automation

## Allowed Surfaces

- Today
- Capture
- Goals
- Time
- You

## Forbidden Surfaces

- generic background state
- unexplained automation

## Visual Ingredients

- preview row
- confirmation seam
- undo action

## State Variants

- pending
- previewed
- committed
- reversed

## Source / Proof / Receipt Behavior

Transactions should leave an inspectable receipt.

## Accessibility Fallback

The transaction path must stay navigable with VoiceOver.

## ADHD Safety Note

Keep the next safe action visible.

## Misuse Examples

- instant commit with no preview
- destructive action with no undo

## Recipe Examples

- reflow preview tray
- local data reset / forget
- capture receipt

## Validator Hooks

- transaction
- hidden automation
- false green
