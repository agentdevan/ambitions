# UI Studio 09 Preview Screenshot Matrix

Status: control-plane proof boundary
Authority: subordinate to `docs/truth/*` and `frontend/visual-encyclopedia/UI_STUDIO_OPERATING_SYSTEM.md`

This ledger defines the proof categories that UI Studio 09 must keep separate. It is a planning and proof boundary artifact, not implementation proof, screenshot proof, accessibility proof, device proof, or release proof.

## Required State Coverage

| State family | Required coverage when relevant | Preview fixture status | Screenshot inventory status | Rendered screenshot proof | Accessibility proof | Device proof | Release proof |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Empty | required | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Normal | required | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Dense | required | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Recovery | required | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Error | required | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Reduced motion | required where motion is affected | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Large Dynamic Type | required where layout is affected | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Small iPhone | required where compact size is relevant | required | required when screenshots are owned | not implied | not implied | not implied | not implied |
| Large iPhone | required where expanded size is relevant | required | required when screenshots are owned | not implied | not implied | not implied | not implied |

## Separation Rules

- Preview fixture coverage means the surface can render the state in a controlled preview.
- Screenshot inventory status means the batch has enumerated the screenshots that should exist.
- Rendered screenshot proof means actual images were captured, retained, and reviewed as proof artifacts.
- Accessibility proof means the accessibility claim has its own evidence.
- Device proof means the screenshot or rendering claim has been validated on the intended device or simulator target.
- Release proof means the visual work has been accepted into a release-ready state.

## Non-Claims

- "Screenshot inventory complete" does not mean screenshots were captured.
- "Screenshot inventory complete" does not mean accessibility is proven.
- "Screenshot inventory complete" does not mean device proof exists.
- "Screenshot inventory complete" does not mean release readiness exists.
