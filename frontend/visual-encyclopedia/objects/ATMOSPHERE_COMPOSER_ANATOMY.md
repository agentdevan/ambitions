# Atmosphere Composer Anatomy

Status: Active primary-object canon
Destination: Capture

## User-Facing Role

Atmosphere Composer captures input first, then reveals route options without becoming a chat surface.

## Capture Flow

```text
Atmosphere Composer
  ├─ idle composer
  ├─ input field
  ├─ post-input route reveal
  ├─ hold / needs a place path
  └─ receipt / proof seam
```

## What It Must Hold

- one quiet input-first composer
- route reveal only after the user has typed or attached something
- a safe hold path for items that need a place
- proof-aware placement and receipt behavior

## Read When Labels Are Off

- The composer should still read as input, not as a transcript.
- The route reveal should feel like a local product choice, not a hidden assistant.
- The proof seam should read as a compact consequence, not a badge.
- Hold should read as dignity, not failure.

## Interaction Grammar

- capture
- choose a route
- save
- hold
- re-place if the first route was wrong

## Failure Modes

- route reveal appears before input
- assistant framing leaks in
- too many route choices
- hold is framed as failure
- feed-at-rest behavior sneaks in

## Trust Rule

The route choices are a local product decision, not a chatbot decision.

## Accessibility Notes

- For VoiceOver, read composer, input, route, proof/receipt, then hold or re-place.
- Dynamic Type must keep the composer thumb-reachable.
- Reduce Motion should make the route reveal understandable without animation.
- Reduce Transparency should not hide the route seam.

## Native Believability

- Reads like an input-first composer and stays thumb-first.
- Avoids chat bubbles.
- Avoids prompt walls.

## Why It Exists

Atmosphere Composer exists so capture can stay capture-first while still revealing a safe next route after input.

## Label-Off Visual Signature

Bottom-native composer note: ASCII Anatomy, Required Zones, Zone Order, Density Budget, Anti-Generic Failure Examples, Source-Link Status Summary, and Label-Off Recognition Criteria stay tied to the route-first composer so capture stays route-first and not chat-shaped.

- anchor:bottom-native composer
- anchor:no feed at rest
- anchor:no chat bubbles
- anchor:three-route cap
- anchor:Held With Dignity
- anchor:re-place wrong-route recovery
