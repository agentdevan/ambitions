# AMB-959 / UIQL-004 Repair Reframe Report

Status: Active repair reframe before closeout.
Program: UIQL
Linear issue: AMB-959
Sequence label: UIQL-004

## Reason For Reframe

AMB-959 exceeded three repair cycles while repairing shell safe-area and dock legibility:

1. The first repair made the five-destination dock visible and moved activated Capture / receipt overlays above it.
2. The second repair added root scaffold bottom clearance and moved the shell crown below the Dynamic Island/status area.
3. The third repair added Today bottom clearance, which fixed the original Today receipt overlap but did not prove other surfaces.
4. The fourth repair expanded screen-level scroll insets for Goals, Time, Motion, and You, but screenshots still showed long content visible underneath the floating dock.
5. Later screenshot passes exposed two live text-fit Reds in the proof matrix: the Today context crown clipped under the Dynamic Island, Motion clipped `Receipt-aware`, and Goals clipped `Relationships` in the equal-weight area row.

## Failed Assumption

The failed assumption was that feature-level bottom insets alone would prevent dock occlusion. The screenshots showed the custom visible dock still behaved as a floating overlay, so scroll content could remain visible under it even after larger screen insets.

## Reframed Repair

The smallest safe repair is to make the root shell reserve bottom layout clearance for the visible dock and add an explicit root dock backdrop so content cannot remain materially readable through bottom chrome. The Today Day Rail owns its own top clearance because its first-viewport object is inside the feature surface rather than the shell header. The root `TabView` remains the selection owner. The existing `AppMeridianDestinationRail` remains the visible dock primitive. No new root shell, navigation model, material system, or top-level destination is introduced.

## Required Proof Before Closeout

- Fresh screenshots for Today, Goals, Time, Motion, You, activated Capture, and Increase Contrast.
- Visual evaluation that the dock is legible, selected tab identity is clear, and no first-viewport content is materially hidden by dock chrome.
- Focused shell UI tests or explicitly scoped replacement tests for the visible dock contract.
- `git diff --check`.
- UIQL preflight and mini-regression.

## Final Repair Result

The final repair hides the native tab bar, keeps the custom Meridian dock visible as the only bottom navigation chrome, reserves root and surface-level bottom clearance, moves activated Capture and the continuity receipt above the dock clearance, strengthens the dock material, and adds a bottom backdrop behind the floating dock. It also removes the duplicate lower Today continuity strip, gives the Today Day Rail internal top clearance, and shortens only the visible Goals/Motion labels that clipped in the AMB-959 proof matrix. Fresh final-labels screenshots show the dock labels and selected destination state remain legible on Today, Goals, Time, Motion, You, activated Capture, and Increase Contrast.

## No-Claim Boundary

This reframe does not claim owner approval, full accessibility certification, release readiness, TestFlight readiness, App Store readiness, physical-device proof, or completion of later UIQL reconstruction issues.
