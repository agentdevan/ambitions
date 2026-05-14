# User System Profile Anatomy

Status: Active primary-object canon
Destination: You

## User-Facing Role

User System Profile exposes the local runtime, planning setup, trust controls, privacy, defaults, and reset/forget actions.

## Product Meaning

- personal runtime
- inspectable trust
- local control
- privacy and defaults

## Label-Off Visual Signature

- settings-like density is not enough
- the runtime and trust panel must be obvious
- privacy and reset must read as serious control, not admin clutter

## Canonical Structure

- personal runtime root
- trust panel
- planning setup
- schedule / availability
- defaults
- privacy and reset

## Visible Zones

- what Ambitions knows
- what it guesses
- what is local-only
- what the user set
- what can be reset or forgotten

## Allowed States

- local
- guided
- assisted preview
- hidden until needed
- reset preview

## Forbidden States

- social profile
- generic settings clone
- admin console
- hidden automation defaults

## Primary Actions

- inspect trust
- change defaults
- preview automation
- reset or forget locally

## Secondary Correction Paths

- edit learned pattern
- reject suggestion
- clear local data
- reduce automation

## Proof Behavior

Privacy, trust, and receipts must be inspectable and reversible where possible.

## Receipt Behavior

Changing runtime defaults should produce a compact receipt.

## Source / Trust Behavior

The surface should say whether a value was user-set, suggested, learned, or stale.

## Local-Runtime Behavior

This surface is the local runtime control room; it must not imply a hosted account backend.

## Evolution Over Time

The runtime can learn, but every learned pattern must remain editable and rejectable.

## Failure States

- settings clone
- hidden full automation
- privacy wording that is too vague
- no preview for destructive reset

## Recovery Behavior

- show what will be lost
- keep the exit path visible
- allow manual control
- keep learning inspectable

## ADHD Density Law

Keep one clear control question at a time and avoid burying the user in preferences.

## VoiceOver Summary / Order

Object -> runtime state -> trust -> privacy -> reset / forget.

## Dynamic Type Behavior

Primary controls remain reachable and readable at large sizes.

## Reduce Motion Behavior

Use clear static state changes instead of motion-only transitions.

## Reduce Transparency Behavior

The surface must stay readable with opaque graphite layers if needed.

## Increase Contrast Behavior

Strengthen trust and privacy boundaries.

## Differentiate Without Color Behavior

Use labels and shapes to show user-set, suggested, learned, and stale source states.

## Native iPhone Believability Requirements

- feels like a serious local runtime control room
- avoids a generic settings clone
- keeps privacy and reset trustworthy

## Anti-Generic Red Flags

- settings page
- profile page
- admin console
- account dashboard

## Recipe Dependencies

- you root
- local runtime trust panel
- planning setup section
- schedule & availability
- planning defaults
- local data / reset / forget

## Source-Link Status

Linked through the live You source candidates in `VISUAL_SOURCE_LINKS.yaml`.

## Good vs Bad Interpretation

- Good: "a visible local runtime profile with inspectable learning, privacy, and control."
- Bad: "a settings page with nicer typography."
