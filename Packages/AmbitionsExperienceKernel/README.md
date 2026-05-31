# AmbitionsExperienceKernel

Canonical Swift package for Ambitions object-first visual experience, semantic state compilation, proof/replay inspection, Action Closure, motion, haptics, accessibility grammar, and release gates.

This package supersedes earlier generated visual bundles. The production app should depend on this kernel, not on generated release strata.

## Install

```bash
python Scripts/install_into_ambitions_repo.py /path/to/agentdevan/ambitions
python Scripts/ambitions_kernel_lint.py
```

## Swift usage

```swift
import AmbitionsExperienceKernel

let input = AmbitionsPreviewFixtures.normalTodayInput
let field = AmbitionsExperienceCompiler.compile(input)

AmbitionsSurfaceRoot(surface: .today, field: field) {
    RealityMeridianObject(nodes: AmbitionsPreviewFixtures.sampleNodes, field: field)
    StartHereDecisionLayerView(
        title: "Recommended step",
        whyNow: "Fits the current free time and goal thread.",
        fit: field.fit,
        receipts: AmbitionsPreviewFixtures.sampleReceipts,
        startAction: {},
        adjustAction: {}
    )
}
```
