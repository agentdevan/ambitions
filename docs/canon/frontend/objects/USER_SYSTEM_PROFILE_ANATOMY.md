# User System Profile Anatomy

Status: Active primary-object canon
Destination: You

## User-Facing Role

User System Profile exposes the local runtime, planning setup, trust controls, privacy, defaults, and reset/forget actions.

## Runtime Control Room

```text
User System Profile
  ├─ personal runtime root
  ├─ trust panel
  ├─ defaults / planning setup
  ├─ privacy / local-only boundary
  └─ reset / forget path
```

## What It Must Hold

- a serious local runtime control room
- trust that can be inspected and edited
- privacy and reset paths that are obvious
- learning that never becomes hidden automation

## Read When Labels Are Off

- The surface should still read as a control room, not a settings page.
- The trust panel should be the first thing the eye understands.
- Privacy and reset should feel like high-consequence controls.
- Plain language must win over settings-clone jargon.

## Interaction Grammar

- inspect trust
- change defaults
- preview automation
- reset or forget locally
- reject a learned pattern
- reduce automation
- change availability with a visible consequence
- exit without losing control

## Failure Modes

- settings clone
- hidden full automation
- vague privacy wording
- no preview for destructive reset
- account-dashboard language sneaking in

## Trust Rule

The surface should say whether a value was user-set, suggested, learned, or stale, and it must stay editable.

## Accessibility Notes

- VoiceOver path: object, runtime state, trust, privacy, then reset/forget.
- Dynamic Type must keep the primary controls reachable.
- Reduce Motion should use static state changes rather than motion-only transitions.
- Reduce Transparency should fall back to opaque graphite layers.

## Native Believability

- Reads like a serious local runtime control room.
- Avoids a generic settings clone.
- Keeps privacy and reset trustworthy.

## Why It Exists

User System Profile exists so the user can inspect and control what the local runtime knows without implying a hosted account backend.

## Label-Off Visual Signature

Local-runtime note: ASCII Anatomy, Required Zones, Zone Order, Density Budget, Anti-Generic Failure Examples, Source-Link Status Summary, and Label-Off Recognition Criteria stay aligned to local runtime trust so You does not drift into a settings mimic.

- anchor:Personal Runtime hero
- anchor:local runtime trust panel
- anchor:privacy plain language
- anchor:no settings clone
