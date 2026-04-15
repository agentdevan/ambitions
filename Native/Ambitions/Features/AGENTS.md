# Feature Layer Guidance

- Preserve the existing screen -> view model -> service pattern already used across native features.
- Keep service boundaries clear. Do not move persistence or domain orchestration directly into SwiftUI views.
- Avoid UI drift: reuse shared primitives, theme tokens, and nearby feature conventions before inventing new surface patterns.
- When a feature change affects routing, captures, or goal detail launch behavior, re-check the corresponding app and service layers.
