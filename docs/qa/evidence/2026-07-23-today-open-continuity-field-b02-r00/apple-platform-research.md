# Current Apple-platform research

Research date: 2026-07-23. Sources are official Apple documentation.

## Applied findings

- Liquid Glass is a functional controls/navigation layer, not a content-layer
  material. B02 keeps content matte and opaque and limits glass to dock and
  transient native chrome. [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
  and [Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass).
- `NavigationStack` remains the one-column native hierarchy. Lightweight typed
  route identity preserves Back and restoration behavior. [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack).
- Full-screen review remains appropriate as an immersive consequential task;
  recovery remains a scoped native sheet. Both retain explicit native
  dismissal. [Modality](https://developer.apple.com/design/human-interface-guidelines/modality)
  and [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets).
- Semantic system text styles and SF Symbols preserve Dynamic Type and script
  behavior. Essential controls keep at least 44 by 44 points and only one
  prominent action owns a surface. [Typography](https://developer.apple.com/design/human-interface-guidelines/typography),
  [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons),
  [SF Symbols](https://developer.apple.com/design/human-interface-guidelines/sf-symbols).
- State never relies on hue alone. Reduce Transparency gets opaque chrome;
  Differentiate Without Color adds shape/text; Increased Contrast strengthens
  boundaries. [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility).
- Reduce Motion removes zoom, blur, spring travel, and large spatial morphs in
  favor of focus, static seams, and short opacity changes. [Motion](https://developer.apple.com/design/human-interface-guidelines/motion).
- Leading/trailing layout, native Back controls, safe areas, and flexible
  containers support RTL and resizable environments. [Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
  and [Right to left](https://developer.apple.com/design/human-interface-guidelines/right-to-left).
- Current Apple Design Award criteria reward platform-native interaction,
  inclusive transformation, cohesive visuals, and simplicity. B02 uses those
  as an internal quality lens, never as an acceptance claim. [Apple Design Awards](https://developer.apple.com/design/awards/).

## Verification implications

Render and interact in Light, Dark, Increased Contrast, Differentiate Without
Color, Reduce Transparency, Reduce Motion, Accessibility Dynamic Type, genuine
RTL, compact width, Pro Max, and resizable widths. Simulator proof cannot close
physical VoiceOver, reach, edge-gesture, haptic, low-brightness, or performance
obligations.
