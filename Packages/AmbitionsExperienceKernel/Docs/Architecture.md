# Architecture

The package has five layers.

1. Tokens: color, type, spacing, radius, motion, and tier policy.
2. Contracts: top-level surfaces, primary objects, decision layers, and proof requirements.
3. Compiler: local runtime input to semantic visual field state.
4. Objects: SwiftUI rendering primitives driven by compiled state.
5. Gates: diagnostics, lint, preview matrix, Codex batches, and repo installation.

Runtime flow:

```text
Private Life Runtime snapshot
  -> AmbitionsRuntimeSnapshotInput
  -> AmbitionsExperienceCompiler
  -> AmbitionsVisualFieldState
  -> object-first SwiftUI rendering
  -> proof and replay inspection
```
