# Launch Operator Runbook

## Purpose

This runbook is the short execution layer for launch operators.

Use it with:

- [../canon/Ambitions_Launch_Master_Checklist.md](../canon/Ambitions_Launch_Master_Checklist.md)
- [../canon/Ambitions_App_Store_Release_Compliance.md](../canon/Ambitions_App_Store_Release_Compliance.md)
- [../canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md](../canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md)
- [../native-build-and-release.md](../native-build-and-release.md)

It is not a product-scope or launch-strategy document.

## App Store Connect Setup Tasks

- confirm the app record exists for the launch bundle identifier
- confirm app name, primary language, SKU, and platform settings are correct
- confirm launch region is configured for U.S. only
- confirm pricing is free
- confirm no subscription or IAP setup exists for launch
- confirm app category and age-rating inputs are accurate
- confirm team roles for submission, TestFlight, and support operations

## Website / Support / Privacy URL Tasks

- publish the home or marketing page
- publish the support page
- publish the privacy policy page
- publish the privacy choices page
- publish the accessibility page
- verify each URL resolves publicly without login
- verify each URL matches actual launch behavior and doctrine

## Metadata Entry Checklist

- app name
- subtitle
- keywords
- promotional text if used
- description
- support URL
- marketing URL if used
- privacy policy URL
- screenshots for the supported iPhone launch band
- app review contact details
- copyright and version metadata

Metadata truth rules:

- keep iPhone-only, portrait-only, and U.S.-only launch truth aligned
- do not imply account creation or in-app login
- do not imply paid features, subscriptions, or shared-cloud life-data storage
- do not imply unsupported iPad, Mac, Watch, or health-like launch scope

## TestFlight Rollout Checklist

### Internal Beta

- upload internal beta candidate
- verify install path and first-launch behavior
- verify core tabs and key task flows
- verify permission timing remains contextual
- verify widget and Live Activity behavior if still in launch scope
- capture blocking regressions before external beta

### Small Closed External Beta

- select a narrow tester group
- provide feedback instructions
- monitor crash reports, support feedback, and permission confusion
- review any launch-claim contradictions before submission

## Reviewer Notes / Reviewer Access Checklist

- explain that no Ambitions account or in-app login is required
- explain local-first data posture briefly and plainly
- explain any shipped permission use for notifications, calendar, and reminders
- explain any ambient surfaces shipped at launch such as widgets or Live Activities
- explain any navigation-only App Intents or external routes if relevant to review
- provide any required reproduction instructions for non-obvious surfaces

## External Surface Platform Review Checklist

- verify Share Sheet presentation
- verify Share Extension intake UX on real device or simulator where available
- verify App Shortcuts discoverability
- verify Quick Capture shortcut
- verify Quick Focus shortcut
- verify Quick Plan shortcut
- verify Quick Recovery shortcut
- verify Spotlight/Search landing where supported
- verify external-create-to-app-shell handoff
- verify origin/provenance behavior from `share_extension` and `app_intent`

## Export Compliance Checklist

- answer Apple export-compliance questions truthfully for the actual build
- confirm no unsupported cryptography claims are implied
- store the exact operator answers used for the submitted build

## Final Upload / Submission Checklist

- generate the final project and release candidate archive on the release machine
- validate archive and upload path in Xcode or Transporter as appropriate
- confirm release build matches final metadata and screenshots
- confirm App Privacy answers match shipped behavior
- confirm URLs remain live
- confirm reviewer notes are attached
- confirm final signoff against the release-compliance canon

## Launch-Day Monitoring Checklist

- monitor Apple crash reporting
- monitor App Store review themes
- monitor support requests
- monitor permission-friction reports
- monitor widget and Live Activity failures if those surfaces ship
- monitor sync/recovery confusion and export/import support questions

## Post-Launch Hotfix Checklist

- classify issue severity quickly
- prefer narrow hotfixes over scope expansion
- update support/privacy/accessibility pages if shipped behavior or user guidance changed
- verify hotfix metadata and reviewer notes if resubmission is required
- record what launch doctrine or checklist item failed so it is not repeated
