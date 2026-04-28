# Ambitions Design Tokens

Status: Active design canon consolidation layer.

Purpose: Translate the Ambitions visual doctrine into implementation-readable token categories. This document does not replace the Visual System, Design Constitution, or component matrix. It gives future SwiftUI and design-system work stable names for color, spacing, typography, radius, elevation, motion, density, and state.

## Token Doctrine

Ambitions should feel like:

```text
Calm shell, rich panels, meaningful visual state.
```

Tokens must preserve:

- dark-first premium identity
- intentional light mode
- warm neutral base
- restrained accent use
- accessibility
- no color-only meaning
- centralized theme control
- Appearance Studio compatibility
- consistent top-level shell and panel behavior

Do not hard-code one-off screen colors, spacing, radii, shadows, or tab treatments.

## Token Naming Convention

Recommended naming shape:

```text
category.role.variant.state
```

Examples:

```text
color.canvas.primary
color.surface.panel.elevated
color.text.primary
space.16
radius.panel.comfortable
motion.receipt.enter
```

SwiftUI naming can map to equivalent camelCase constants.

## Color Tokens

### Canvas

| Token | Purpose |
| --- | --- |
| `color.canvas.primary` | Main app background. Never pure black. |
| `color.canvas.secondary` | Subtle alternate background for detail/sheets. |
| `color.canvas.grouped` | Background behind grouped navigation sections. |
| `color.canvas.modal` | Sheet/modal base. |

Dark mode direction:

- warm charcoal
- blue-black
- near-black navy
- soft atmospheric depth

Light mode direction:

- warm off-white
- soft warm neutral
- never stark white

### Surface

| Token | Purpose |
| --- | --- |
| `color.surface.panel` | Default rich panel surface. |
| `color.surface.panel.elevated` | Elevated hero or active panel. |
| `color.surface.panel.subtle` | Lower-emphasis supporting panel. |
| `color.surface.row` | Grouped/list row background. |
| `color.surface.control` | Button/chip/control background. |
| `color.surface.receipt` | Action Closure / receipt tray. |
| `color.surface.warning` | Calm caution surface. |
| `color.surface.destructive` | Destructive confirmation surface. |

Rules:

- Surfaces should feel tactile and blended.
- Use faint borders and tonal lift before heavy shadows.
- Avoid flat wireframe cards.

### Text

| Token | Purpose |
| --- | --- |
| `color.text.primary` | Main readable text. |
| `color.text.secondary` | Supporting copy. |
| `color.text.tertiary` | Metadata. |
| `color.text.inverse` | Text on strong accent or high-contrast fill. |
| `color.text.disabled` | Disabled content. |
| `color.text.destructive` | Destructive labels. |
| `color.text.link` | Inline navigational or explanatory action. |

Rules:

- Text contrast must pass in dark and light modes.
- Do not use low-contrast decorative text for important states.

### Accent

| Token | Purpose |
| --- | --- |
| `color.accent.primary` | Primary action and active focus. Default amber family. |
| `color.accent.primary.subtle` | Low-opacity accent wash. |
| `color.accent.secondary` | Secondary accent for muted blue-gray states. |
| `color.accent.focus` | Focus / protected work emphasis. |
| `color.accent.selection` | Selected tab, row, chip, or control. |

Rules:

- One dominant accent per view.
- Amber is default active accent family.
- Amber must be used sparingly.
- Accent cannot be the only meaning carrier.

### Semantic State

| Token | Purpose |
| --- | --- |
| `color.state.success` | Calm earned success. |
| `color.state.caution` | Warm specific caution. |
| `color.state.risk` | Serious risk without panic. |
| `color.state.blocked` | Blocked/waiting state. |
| `color.state.protected` | Protected goal or action. |
| `color.state.recovered` | Recovery completed. |
| `color.state.calendar` | Calendar-derived context. |
| `color.state.ambitionsCreated` | Ambitions-created plan data. |
| `color.state.trust` | Trust/sync/privacy status. |

Rules:

- Pair state color with text, icon, shape, or pattern.
- Avoid loud green and alert-spam red.

### Goal Weather

| Token | Meaning |
| --- | --- |
| `color.weather.clear` | Healthy direction/proof/next step. |
| `color.weather.cloudy` | Some progress, weaker clarity. |
| `color.weather.stormy` | Risk, blocker, or deadline pressure. |
| `color.weather.foggy` | Missing signal/proof/clarity. |
| `color.weather.protected` | Needs defense from distraction. |

Rules:

- Weather must include label/explanation.
- No childish weather graphics.

## Typography Tokens

| Token | Purpose |
| --- | --- |
| `type.display` | Rare flagship/marketing-style screen title. |
| `type.hero.title` | Hero Decision Panel title. |
| `type.hero.value` | Important number/time/state in hero. |
| `type.title.large` | Screen title / major section. |
| `type.title.medium` | Panel title. |
| `type.title.small` | Row group title. |
| `type.body` | Main readable copy. |
| `type.body.compact` | Dense but readable copy. |
| `type.caption` | Metadata and supporting labels. |
| `type.label` | Buttons, chips, compact state labels. |
| `type.mono.time` | Optional stable time/number treatment. |

Rules:

- Hero type is reserved for hero panels.
- Body copy should stay concise.
- Dynamic Type must preserve hierarchy.
- Avoid uppercase as default style.

## Spacing Tokens

Base rhythm:

```text
4, 8, 12, 16, 20, 24, 32
```

| Token | Purpose |
| --- | --- |
| `space.4` | Hairline separation / tight internal detail. |
| `space.8` | Compact stack gap. |
| `space.12` | Row internal gap. |
| `space.16` | Default panel padding / section gap. |
| `space.20` | Comfortable panel padding. |
| `space.24` | Major section separation. |
| `space.32` | Hero/screen-level breathing room. |

Screen margins:

| Token | Purpose |
| --- | --- |
| `space.screen.horizontal` | Standard screen side inset. |
| `space.screen.top` | Header-to-content spacing. |
| `space.screen.bottom` | Bottom-tab safe spacing. |
| `space.panel.gap` | Gap between stacked panels. |
| `space.section.gap` | Gap between content regions. |

Rules:

- Top-level screens need confident whitespace.
- Compact density cannot become cramped.
- Large panel size cannot feel stretched.

## Radius Tokens

| Token | Purpose |
| --- | --- |
| `radius.none` | Hard edges where platform requires. |
| `radius.xs` | Small chips/badges. |
| `radius.sm` | Row containers. |
| `radius.md` | Default controls. |
| `radius.panel` | Default panel/card radius. |
| `radius.panel.large` | Hero/large panel radius. |
| `radius.sheet` | Modal/sheet corner. |
| `radius.pill` | Pills, chips, Mode Lens. |

Guidance:

- Panels generally live around 8-16pt depending on context.
- Avoid bubble-like UI.
- Radius should be consistent per component role.

## Border And Elevation Tokens

| Token | Purpose |
| --- | --- |
| `border.subtle` | Faint tonal separation. |
| `border.panel` | Default panel edge. |
| `border.focus` | Focused/selected state. |
| `border.warning` | Calm caution state. |
| `shadow.none` | Flat when appropriate. |
| `shadow.subtle` | Slight lift. |
| `shadow.panel` | Standard elevated panel. |
| `shadow.hero` | Hero Decision Panel lift. |
| `material.innerLight` | Subtle inner highlight. |
| `material.blur.light` | Restrained blur treatment. |
| `material.blur.heavy` | Rare; avoid stacking. |

Rules:

- Prefer tonal lift and faint borders over heavy shadows.
- Avoid repeated expensive blur on scroll-heavy surfaces.

## Component Tokens

### Shell

- `shell.canvas`
- `shell.header.background`
- `shell.header.title`
- `shell.header.button`
- `shell.tab.active`
- `shell.tab.inactive`
- `shell.tab.background`
- `shell.ribbon.background`
- `shell.ribbon.text`

### Panel

- `panel.background.default`
- `panel.background.hero`
- `panel.background.subtle`
- `panel.border.default`
- `panel.padding.compact`
- `panel.padding.comfortable`
- `panel.padding.large`
- `panel.radius.default`
- `panel.shadow.default`

### Buttons

- `button.primary.background`
- `button.primary.text`
- `button.secondary.background`
- `button.secondary.text`
- `button.tertiary.text`
- `button.destructive.background`
- `button.destructive.text`
- `button.disabled.background`
- `button.disabled.text`

### GroupedNavigationList

- `groupedList.section.background`
- `groupedList.section.spacing`
- `groupedList.row.background`
- `groupedList.row.text`
- `groupedList.row.value`
- `groupedList.row.chevron`
- `groupedList.row.destructive`

### Receipt / Action Closure

- `receipt.background`
- `receipt.border`
- `receipt.title`
- `receipt.summary`
- `receipt.action.undo`
- `receipt.action.correct`
- `receipt.privacy.hidden`

## Motion Tokens

| Token | Purpose |
| --- | --- |
| `motion.duration.fast` | Small button/control response. |
| `motion.duration.standard` | Normal panel/sheet transition. |
| `motion.duration.slow` | Rare explanatory transition. |
| `motion.curve.standard` | Default ease. |
| `motion.curve.snappy` | Press/release and small state changes. |
| `motion.curve.gentle` | Calm receipt/reflow movement. |
| `motion.button.press` | Press compression. |
| `motion.receipt.enter` | Action Closure tray entry. |
| `motion.plan.reflow` | Plan change explanation. |
| `motion.capture.route` | Smart Attachment route movement. |
| `motion.goal.weatherChange` | Goal Weather state change. |
| `motion.reduceMotion.replacement` | Static equivalent state change. |

Rules:

- Motion explains state change first.
- Reduced Motion must preserve equivalent clarity.
- No motion should be required to understand state.
- Avoid magic/thinking animations.

## Haptic Tokens

| Token | Purpose |
| --- | --- |
| `haptic.selection` | Small selection changes. |
| `haptic.confirmation` | Completion/confirmed meaningful action. |
| `haptic.warning` | Serious but non-punitive warning. |
| `haptic.receipt` | Action Closure appears. |

Rules:

- Use haptics sparingly.
- Haptics support meaning, not decoration.

## Density And Size Tokens

Display Density:

- `density.minimal`
- `density.balanced`
- `density.detailed`

Panel Size:

- `panelSize.compact`
- `panelSize.comfortable`
- `panelSize.large`

Default:

```text
density.balanced + panelSize.comfortable
```

Rules:

- Density controls information amount.
- Size controls physical scale.
- Large panels show fewer things.
- Compact panels remain readable and tappable.

## Accessibility Token Requirements

All tokens must support:

- dark and light mode
- Dynamic Type
- VoiceOver-readable component states
- Reduce Motion variants
- sufficient contrast
- no color-only meaning
- stable tap targets
- visible alternatives for gestures

## Implementation Acceptance Criteria

A token implementation is acceptable when:

- Shell, panels, buttons, grouped lists, receipts, and key states consume centralized tokens.
- Appearance Studio can change allowed appearance/accent behavior without breaking hierarchy.
- No major screen hard-codes visual identity values outside token boundaries.
- Dark mode does not use pure black as main app canvas.
- Light mode is intentionally designed, not default-white fallback.
- Semantic state uses text/icon/shape in addition to color.
- Reduced Motion has non-motion equivalents.
- Dynamic Type does not destroy primary action visibility.

## Open Questions For Future Waves

- What exact default accent palette should ship?
- Should theme names be user-facing or hidden behind accent/appearance controls?
- Should Ambitions use one default font or platform-native typography only?
- Should Goal Weather tokens have shape/pattern equivalents from day one?
- How customizable should panel density be at launch?
