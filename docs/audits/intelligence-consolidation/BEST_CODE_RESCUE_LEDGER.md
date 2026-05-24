# Best Code Rescue Ledger

Status: Active runner input. Stronger older/package/preview code must be recorded before replacement or retirement.

| Candidate path/type | Current status | Why it may be better | Active code it competes with | Rescue recommendation | Migration target | Tests/proof required | Risk | Owner review needed |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `Sources/**` design primitives | PACKAGE_ONLY_CANDIDATE | Shared primitives may be more reusable than app-local one-offs. | `Native/Ambitions/UI/**`, feature-local SwiftUI helpers | RESCUE_VISUAL_PRIMITIVE | design_system | preview/accessibility checks and target membership proof | Medium | yes |
| `Sources/Previews/**` Reality Meridian / Start Here references | PREVIEW_ONLY_REFERENCE | May contain stronger visual states and accessibility fixture coverage. | `Native/Ambitions/Features/Today/**` | RESCUE_STATE_MODEL | today_root | Today UI tests, accessibility fixtures, proof packet | Medium | yes |
