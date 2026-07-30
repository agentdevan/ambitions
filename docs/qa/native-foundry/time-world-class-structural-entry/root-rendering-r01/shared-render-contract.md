<!-- markdownlint-disable MD013 -->

# Shared Render Contract

All three renders use the same truth, device posture, shell, appearance, density, type size, and evidence ceiling. Only the selected direction’s root structure changes.

## Viewport and shell

- Standalone iPhone portrait app screenshot, approximately 9:19.5, with no hardware bezel or presentation frame
- Dark appearance
- Dynamic Type: Large
- Content density: typical, using only the named fixture facts
- Status bar time: `9:41`
- Safe-area-respecting native shell
- Crown row: crown glyph plus `Ambitions`
- Root title: `Time`
- Supporting identity: `Life Calendar`
- Exact range: `This week · Jul 27–Aug 2`
- Current day: Wednesday
- Subordinate `Today` return
- Provisional Crowned Edge Dock in ordinary Peek posture at the lower right, labelled `Time`
- Opaque deep-graphite content plane, system typography, restrained violet-indigo only for action/focus
- No glass content cards, glow, gradients, dashboard cards, heat maps, waveforms, AI briefing, or device mockup

## Corrected fixture truth

- `Send the launch brief` — Wednesday, 2:00–2:30 PM — `Accepted · Fixed`
- `Family time` — Wednesday, 5:30–6:30 PM — `Accepted · Protected` — `No work`
- `After 6:30 PM` — `Open calendar space` — personal usability is not inferred
- `Prenatal appointment` — Thursday, 9:00–10:00 AM — `Apple Calendar observation` — external, not accepted Ambitions truth
- `Paint the nursery wall` — Thursday, 10:30–11:30 AM — `Proposed · Not scheduled`
- `Launch review` — proposed Wednesday, 5:45–6:15 PM — conflicts with protected Family time — no accepted current launch-review interval is invented
- Rendering-only Now constant: Wednesday, 3:12 PM, used identically in all three images

## Required root-only behavior

- Communicate Week before every label is read.
- Keep accepted, proposed, external, protected, fixed, and open states distinct without color alone.
- Preserve the corrected 6:30 PM protection/open boundary.
- Show proposals as visibly uncommitted.
- Do not show controls or copy that imply working mutation, settlement, Receipt, Undo, or runtime integration.
- Do not render focused day, object detail, current/proposed review, settlement, or return screens.

## Evidence settings

- Reduce Motion: not applicable to static image; no motion-dependent meaning
- Reduce Transparency: standard setting, while all content remains opaque enough to preserve hierarchy
- Increased Contrast: standard setting; all state distinctions still use text plus shape/edge/placement
- Locale: English (US)
- Calendar: Monday-start Week
