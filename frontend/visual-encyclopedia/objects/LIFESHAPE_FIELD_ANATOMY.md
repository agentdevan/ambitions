# LifeShape Field Anatomy

Status: Active primary-object canon
Destination: Time

## User-Facing Role

LifeShape Field shows capacity, protected time, pressure, reflow, and fit.

## Capacity Geometry

```text
LifeShape Field
  ├─ day / week / month horizons
  ├─ open capacity
  ├─ protected time
  ├─ pressure clusters
  └─ best-fit / reflow path
```

## What It Must Hold

- a field-like layout, not a calendar grid
- protected time that reads as carved space
- pressure that reads as compression
- reflow that reads as a before/after shape change

## Read When Labels Are Off

- The field should still feel like capacity, not event rows.
- Protected blocks should read as negative space.
- Pressure should feel compressed rather than alarm-colored.
- Reflow should be understandable as a shape change.

## Interaction Grammar

- inspect fit
- protect time
- reflow preview
- confirm change
- undo if the fit was wrong

## Failure Modes

- month view looks like a normal calendar grid
- reflow hides protected time
- pressure becomes color only
- source freshness disappears
- schedule spreadsheet cues take over

## Trust Rule

Show source authority, freshness, and why another slot was not chosen.

## Accessibility Notes

- Speak object, capacity, protected time, pressure, then reflow preview to VoiceOver users.
- Dynamic Type must keep time labels and protected blocks readable.
- Reduce Motion should replace motion-only meaning with static shape summaries.
- Reduce Transparency should fall back to opaque layers without losing the field.

## Native Believability

- Reads like a capacity field rather than a calendar.
- Avoids clone cues.
- Keeps fit and reflow decisions understandable.

## Why It Exists

LifeShape Field exists so Time stays a capacity object rather than a calendar clone.

## Label-Off Visual Signature

Capacity-geometry note: ASCII Anatomy, Required Zones, Zone Order, Density Budget, Anti-Generic Failure Examples, Source-Link Status Summary, and Label-Off Recognition Criteria stay aligned to capacity geometry so Time does not read like a calendar mimic.

- anchor:non-calendar capacity geometry
- anchor:day/week/month grammar
- anchor:vacation/away override
- anchor:no calendar clone
