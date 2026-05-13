# Planned Train Frontend Direction Inventory

Status: Active all-train source-family inventory for intended frontend direction

This inventory extracts planned frontend-relevant train/source families from prompts, batch-trains, queue files, trace docs, and canonical overlays. MRI and HBI remain entries inside the broader system rather than the only source-family overlays.

- `pk` - PK - active_planned - surface_behavior - Today, Goals, Capture, Time, You, Cross-surface
- `mri` - MRI - supporting - privacy_trust - Today, Capture, You, Cross-surface
- `hbi` - HBI - supporting - surface_behavior - Goals, Time, You, Cross-surface
- `lid` - LID - active_planned - runtime_source - Today, Capture, You, Cross-surface
- `aos` - AOS - active_planned - runtime_source - Today, Goals, Capture, Time, You, Cross-surface
- `rec` - REC - active_planned - surface_behavior - Today, Goals, Capture, Time, You, Cross-surface
- `si` - SI - active_planned - direct_visual - Today, Goals, Capture, Time, You, Cross-surface
- `pd` - PD - active_planned - copy_labeling - Goals, Time, You, Cross-surface
- `moat_runtime` - Moat Runtime - active_planned - runtime_source - Today, Goals, Capture, Time, You, Cross-surface
- `runtime` - Runtime - supporting - runtime_source - Today, Goals, Capture, Time, You, Cross-surface
- `visual_canon` - Visual Canon - active_planned - direct_visual - Today, Goals, Capture, Time, You, Cross-surface
- `planning` - Planning - active_planned - copy_labeling - Time, You, Goals
- `capture` - Capture - active_planned - surface_behavior - Capture, Today, Goals, Cross-surface
- `time` - Time - active_planned - surface_behavior - Time, Goals, Today, You, Cross-surface
- `today` - Today - active_planned - direct_visual - Today, Goals, Capture, Time, You, Cross-surface
- `goals` - Goals - active_planned - direct_visual - Goals, Today, Time, You, Cross-surface
- `you` - You - active_planned - privacy_trust - You, Cross-surface
- `accessibility` - Accessibility - supporting - accessibility - Today, Goals, Capture, Time, You, Cross-surface
- `privacy` - Privacy - supporting - privacy_trust - Capture, You, Today, Goals, Cross-surface
- `qa_validation` - QA / validation - supporting - validation_only - Today, Goals, Capture, Time, You, Cross-surface
- `onboarding_first_run` - Onboarding / First Run - supporting - copy_labeling - Today, Goals, Capture, Time, You
- `supporting_programs` - Supporting Programs - active_completed - validation_only - Today, Goals, Capture, Time, You, Cross-surface
- `historical_programs` - Historical Programs - historical - non_frontend - Today, Goals, Capture, Time, You
