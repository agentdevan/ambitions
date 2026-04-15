# App Layer Guidance

- Keep `AppContainer`, `AppContainerFactory`, `AppNavigationModel`, tab wiring, and external routing synchronized.
- Route new app-entry behavior through the existing container and navigation seams instead of screen-local globals.
- Deep links, widget taps, notification payloads, and captures/goal routing should converge through `AppExternalRouting` or the existing app action router.
- When changing app wiring, re-check service injection, selected-tab behavior, and goal-detail navigation together.
