# Feature Layer Guidance

- Preserve the existing screen -> view model -> service pattern already used across native features.
- Keep service boundaries clear. Do not move persistence or domain orchestration directly into SwiftUI views.
- Avoid UI drift: reuse shared primitives, theme tokens, and nearby feature conventions before inventing new surface patterns.
- When a feature change affects routing, captures, or goal detail launch behavior, re-check the corresponding app and service layers.
- If a feature change crosses into routing, persistence, or multiple feature files, plan first before editing.
- Implement feature work in bounded slices and verify each slice against the adjacent service, routing, or persistence seam before widening the diff.
- If the requested feature would require cross-layer rewrites beyond scope, stop at the narrow truthful slice and report what remains.
