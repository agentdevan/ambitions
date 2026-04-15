# External Surface Snapshot Contract (v1)

## Purpose
- Provide a stable, read-only export for future external surfaces (widgets, Live Activities).
- Keep payload minimal and privacy-safe.
- Persist in JSON so storage can move to an App Group container later without schema changes.

## File
- Preferred path: App Group container `group.com.ambitions.shared/ExternalSnapshots/external-snapshot.v1.json`
- Fallback path: app support directory under `ExternalSnapshots/external-snapshot.v1.json`
- Writer: `ExternalSurfaceSnapshotWriter` (best effort, non-blocking)

## Schema

```json
{
  "schemaVersion": "external_surface_snapshot.v1",
  "generatedAt": "2026-04-15T12:00:00Z",
  "nextAction": {
    "goalID": "goal-...",
    "stepID": "step-...",
    "display": {
      "templateKey": "next_tiny_step",
      "goalMode": "project",
      "stepState": "planned",
      "urgency": "soon",
      "timing": "deadline"
    }
  }
}
```

## Privacy Rules
- No user-entered text is exported (`goal.title`, `step.title`, notes, summaries are excluded).
- `display` values are enum/template based only.
- Consumers should treat IDs as opaque and read-only.

## Refresh Triggers
- Snapshot refresh runs after:
  - Today action mutations (`TodayServicing.performAction`)
  - Goal mutations (`createGoal`, `performAction`, `submitClarificationAnswer`)
- Startup performs one initial refresh so external readers can immediately resolve a snapshot file.

## Compatibility
- `schemaVersion` is the version gate for future readers.
- Additive changes are preferred; breaking changes should increment the version suffix.
