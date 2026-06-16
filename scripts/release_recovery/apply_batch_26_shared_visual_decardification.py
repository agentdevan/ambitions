#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from report_reconstruction_support import require_markers, write, write_proof

SURFACES = "Sources/Components/ObjectStageSurfaces.swift"
STALE_ALIASES = "Sources/Components/ObjectStageSurfaceAliases.swift"

SWIFT = r'''
#if canImport(SwiftUI)
import SwiftUI

/// Root-level object surface without default card chrome.
///
/// Use for Today / Goals / Time / Motion first viewports when the product object
/// should own the screen rather than sit inside a generic rounded card stack.
public struct ObjectStageSurface<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            AmbitionsIOS26SemanticTokens.Graphite.base
            content
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: reduceMotion)
    }
}

/// Instrument field surface for stateful product meaning.
public struct InstrumentField<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(AmbitionsIOS26SemanticTokens.Fill.quaternaryDark)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(AmbitionsIOS26SemanticTokens.Separator.darkNonOpaque)
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }
    }
}

/// Progressive disclosure seam for Source / Proof / Receipt detail.
public struct TrustSeamDisclosure<Content: View>: View {
    private let title: String
    private let content: Content

    public init(_ title: String = "Why this?", @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        DisclosureGroup(title) {
            content
                .padding(.top, 8)
        }
        .font(AmbitionsIOS26SemanticTokens.Typography.footnote)
    }
}

/// Native grouped control surface for You and detail settings flows.
public struct NativeGroupedControlSurface<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .background(AmbitionsIOS26SemanticTokens.Graphite.base)
    }
}
#endif
'''


def main() -> int:
    stale_alias_path = Path(STALE_ALIASES)
    if stale_alias_path.exists():
        stale_alias_path.unlink()

    write(SURFACES, SWIFT)
    require_markers(SURFACES, ["ObjectStageSurface", "InstrumentField", "TrustSeamDisclosure", "NativeGroupedControlSurface", "AmbitionsIOS26SemanticTokens"])
    if Path(STALE_ALIASES).exists():
        raise RuntimeError("Stale ObjectStageSurfaceAliases.swift must not coexist with ObjectStageSurfaces.swift.")
    write_proof(
        "REPORT_BATCH_26_SHARED_VISUAL_DECARDIFICATION.md",
        """
# Batch 26 — Shared visual de-cardification

Status: applied.

Scope:
- Added root object-stage primitives that do not default to AppCard/WidgetCard/HeroCard chrome.
- Added InstrumentField for stateful product objects.
- Added TrustSeamDisclosure for progressive Source / Proof / Receipt inspection.
- Added NativeGroupedControlSurface for You/settings-style control flows.
- Removed the stale ObjectStageSurfaceAliases file so the real ObjectStageSurface primitive has a single definition.

Atlas gates:
- Root surfaces should not be generic card stacks.
- Source / Proof / Receipt become progressive trust disclosure, not loud metadata rows.
- Visual primitives lean on iOS 26 graphite/fill/separator tokens while remaining Ambitions-owned.
""",
    )
    print("Applied Batch 26 Shared visual de-cardification.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
