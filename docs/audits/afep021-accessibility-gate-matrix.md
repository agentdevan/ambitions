# AFEP-021 Accessibility Gate Matrix

## Gates

| Gate | Source-backed support | Follow-up proof still required | Public claim |
|---|---|---|---|
| VoiceOver | Labels, values, hints, and reading order are represented in source and tests. | Manual VoiceOver traversal on the current device band. | Blocked |
| Dynamic Type | Large-text preservation is represented in source and tests. | Dynamic Type screenshot review on device bands. | Blocked |
| Reduce Motion | Static equivalents for state changes and transitions are represented in source. | Reduce Motion walkthrough on device. | Blocked |
| Increase Contrast | State and boundary meaning are represented without depending on ambient color. | Measured contrast review. | Blocked |
| Tap targets | Tap-target and motor-access expectations are represented in source and tests. | Device motor/tap-target review. | Blocked |
| Semantic grouping | Grouped meaning and reading order are represented in source and tests. | Manual semantic-group review. | Blocked |
| Non-color meaning | State meaning is represented with text, shape, position, or iconography. | Rendered state review. | Blocked |
| Motion-independent meaning | Motion is not the only carrier of relationship or status meaning. | Reduced-motion visual review. | Blocked |
| Privacy / redaction readability | Privacy-safe and redacted states stay legible. | Device review of redaction/privacy states. | Blocked |
| Cognitive load | One-primary-object discipline is preserved on the canonical surfaces. | Manual readability review. | Blocked |

## Surface Matrix

| Surface | Primary object | Fixture state | Evidence packet | Status |
|---|---|---|---|---|
| Today | Reality Meridian | `today-reality-meridian` | source-backed support | Blocked for public claim |
| Goals | Constellation Atlas | `goals-constellation-atlas` | automated test support | Blocked for public claim |
| Capture | Atmosphere Composer | `capture-atmosphere-composer` | manual VoiceOver follow-up pending | Blocked for public claim |
| Time | LifeShape Field | `time-lifeshape-field` | rendered screenshot follow-up pending | Blocked for public claim |
| You | User System Profile | `you-user-system-profile` | public claim approval blocked | Blocked for public claim |

## Provenance

The gate matrix keeps local-only provenance explicit:

- `SourceRecord.afep021.accessibility-certification-program`
- `Receipt.afep021.accessibility-certification-program`
- `ReplayTrace.afep021.accessibility-certification-program`
- `You / What Ambitions knows`

## Rollback Baseline

- AFRI-034 accessibility proof matrix
- AFRI-005 shell screenshot proof path
