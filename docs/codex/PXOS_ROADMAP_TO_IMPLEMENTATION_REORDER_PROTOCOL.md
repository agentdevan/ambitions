# PXOS Roadmap To Implementation Reorder Protocol

Status: Future Codex OS protocol; PXOS implementation not started
Date: 2026-05-02

## Classification Options

- Keep order
- Move earlier
- Move later
- Split
- Merge
- Convert to recurring gate
- Block until dependency resolved
- Leave future/inactive

## Dependency Principles

1. Release evidence truth prevents false product claims.
2. PXOS canon should exist before major user-facing implementation.
3. ME extraction should occur before large UI/feature expansion in affected areas.
4. CS retirement should occur before renaming/removing legacy internal seams.
5. AOS runtime/intelligence should not expose user-facing intelligence until PXOS defines expression.
6. Product Depth follows PXOS canon and relevant ME/CS safety gates.
7. UI implementation needs PXOS source truth, accessibility, copy, visual, and validation gates.
8. Intelligence implementation needs AmbitionsOS truth, PXOS expression rules, privacy/trust/fallback gates.
9. Messaging must pass REC/PXOS release-claim boundaries.
10. Route/raw/external changes pass CS gates.
11. Large UI expansion passes ME gates.
12. Top-level surface changes pass PXOS hierarchy gates.

## Global Reorder Findings

| Train or batch group | Classification | Rationale |
| --- | --- | --- |
| REC01-REC06 | Keep order | REC is active at REC01 and should continue through evidence closure before public messaging claims. |
| PX01-PX20 | Leave future/inactive | PXOS train is created here but requires explicit phrase before starting. |
| PX01 canon/surface hierarchy | Move earlier after REC proof plan | PXOS canon should precede major user-facing implementation. |
| PX18 reorder gate | Convert to recurring gate | Reorder should run before any major post-PX implementation lane. |
| ME01-ME12 | Move earlier before large UI work | Extraction gates protect affected large files before PXOS implementation. |
| CS01-CS10 | Move earlier before renames/removals | Compatibility seams must be mapped/proved before user-facing terminology causes internal deletion. |
| AOS01-AOS30 | Move later for user-facing exposure | Internal intelligence can proceed only after AmbitionsOS contracts and PXOS expression rules exist. |
| Product Depth | Block until dependency resolved | Requires PXOS canon plus affected ME/CS gates. |
| Release readiness/TestFlight/App Store evidence | Move later | Only after proof exists and REC gates close. |
