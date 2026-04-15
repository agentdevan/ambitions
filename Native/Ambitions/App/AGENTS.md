# App Layer Guidance

- Keep `AppContainer`, `AppContainerFactory`, `AppNavigationModel`, tab wiring, and external routing synchronized.
- Route new app-entry behavior through the existing container and navigation seams instead of screen-local globals.
- Deep links, widget taps, notification payloads, and captures/goal routing should converge through `AppExternalRouting` or the existing app action router.
- When changing app wiring, re-check service injection, selected-tab behavior, and goal-detail navigation together.
- Any edit to routing or container wiring must begin with a plan, even if it is lightweight.
- Execute app-wiring changes in bounded slices, then self-check the affected route, tab, and container exposure before moving on.
- If the requested behavior needs an app-entry seam that does not exist, stop and report the missing seam instead of creating parallel routing paths opportunistically.
