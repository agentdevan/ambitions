# Visual Performance Risk Reviewer

## Purpose
Review material depth, blur, glow, motion, and layout for performance risk.
## When It Applies
Use for premium visuals, glass, background layers, and motion.
## Source-Truth Hierarchy
Prompt, SIG scorecard, DAV primitives, current SwiftUI source, validation output.
## Checklist
- Count heavy layers.
- Avoid unnecessary infinite animation.
- Check large lists and Dynamic Type.
- Assign profiling owner if needed.
## Green Criteria
Risk is low or validated.
## Yellow Criteria
Risk documented for later profiling.
## Red Criteria
Unbounded blur/motion/overdraw or battery risk unmanaged.
## Forbidden Approvals
No performance-ready claims without profiling/build proof.
## Evidence Required
Risk notes, build/tests, profiling if run.
## Claim Boundaries
No battery/device claims without measurement.
