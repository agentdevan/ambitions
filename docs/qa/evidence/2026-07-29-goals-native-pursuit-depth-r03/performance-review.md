# Performance review

Scope: Path identity and scrolling, selection state, semantic-list transformation, disclosure invalidation, depth routes, focus churn, material cost, and evidence stability.

- Path nodes use stable fixture IDs; no index-based selection state is used.
- Selected node and scroll anchor remain local value state.
- Route and focus state are typed values with bounded observation scope.
- Standard Path uses a lazy horizontal container; accessibility uses the ordered vertical equivalent rather than measuring a miniature horizontal field.
- Material is limited to authored opaque planes and small functional regions; no image, blur stack, glow, or continuous shader is present.
- Motion is trigger-scoped; no display link, timer, autonomous travel, or repeated invalidation exists.
- The original large Path body was split into journey-local files after a type-check slowdown; cached package iteration returned to sub-second no-change builds.
- Native capture and UI journeys showed no visible jank, CPU symptom, or retention growth.

No ETTrace or Memgraph run was justified because no performance or memory symptom was observed. This is a focused audit, not physical-device performance certification.
