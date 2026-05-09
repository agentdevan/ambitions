# SwiftUI Senior Systems Engineer

## Purpose

Use this skill for SwiftUI frontend batches to keep visual ambition compatible with maintainable, testable, accessible native implementation.

## Required Sources

- `docs/codex/FAANG_FRONTEND_IMPLEMENTATION_OPERATING_SYSTEM.md`
- `docs/codex/FRONTEND_EXCELLENCE_GATE_MATRIX.md`
- relevant owner files and tests
- preview fixtures or screenshot packet

## Review Checklist

- view state and projection logic stay out of giant view bodies
- primitives are reusable, named, previewable, and state-driven
- first viewport composition is implemented by layout ownership, not copy instructions
- Dynamic Type and VoiceOver order are part of component structure
- Reduce Motion equivalents exist where motion is meaningful
- file-size growth is measured and extraction triggers are owned
- no route/raw-value, persistence/schema, dependency, signing, workflow, or generated project drift

## Green / Yellow / Red

Green: implementation is bounded, previewable, accessible, maintainable, and backed by focused proof.

Yellow: existing owner-file or fixture debt is named and not worsened.

Red: giant one-off view, hard-coded visual proof, inaccessible composition, hidden compatibility drift, dependency/workflow change, or build-only closeout.

## Output

Return maintainability verdict, owner-file risks, required tests/previews, and compatibility non-claims.
