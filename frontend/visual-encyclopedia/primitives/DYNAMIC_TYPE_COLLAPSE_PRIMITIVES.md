# Dynamic Type Collapse Primitives

Status: Active primitive contract

## Purpose

Define what stays visible as text grows.

## Canonical Anatomy

- dominant object
- primary action
- source seam
- recovery seam

## Allowed Use

- responsive headers
- compact metadata
- progressive disclosure

## Forbidden Use

- text truncation that hides the object
- action loss

## Allowed Surfaces

- all primary surfaces

## Forbidden Surfaces

- tiny-only metadata

## Visual Ingredients

- stacked labels
- preserved action
- collapsible metadata

## State Variants

- compact
- expanded
- crowded

## Source / Proof / Receipt Behavior

Source and proof collapse before the primary action.

## Accessibility Fallback

Text size changes must not break the object order.

## ADHD Safety Note

Less room should reduce metadata first.

## Misuse Examples

- hidden label that only appears at small text
- lost cancel path

## Recipe Examples

- today root
- you root

## Validator Hooks

- accessibility and adhd
- native believability
