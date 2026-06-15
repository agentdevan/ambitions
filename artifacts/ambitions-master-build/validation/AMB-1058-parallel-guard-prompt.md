# AMB-1058 parallel implementation guard prompt

Issue: AMB-1058 — M04.T01 — Root navigation architecture: five-surface shell proof.

Source-changing scope:
- Prove root navigation architecture for exactly Today / Goals / Time / Motion / You.
- Keep Capture as a global action / activated composer seam only; it must not be modeled or presented as a top-level root tab.
- Keep Motion as the fifth active root surface; legacy Pulse may only map to Motion as compatibility input.
- Keep Plan as Time compatibility only; no user-facing Plan root tab.
- Root shell edits are limited to App shell/navigation ownership and focused regression tests/proof artifacts.

Allowed source owners:
- Native/Ambitions/App/AppTab.swift
- Native/Ambitions/App/AppNavigation.swift
- Native/Ambitions/App/AppExternalRouting.swift
- Native/Ambitions/App/ShellCommandModels.swift
- Native/Ambitions/App/ShellCommandRouter.swift
- Native/Ambitions/App/AmbitionsRootView.swift
- Narrow icon metadata replacements where existing source used AppTab.capture.systemImage for the global Capture action.

Required evidence:
- SourceRecord: root IA source model proves canonical five roots.
- Receipt: external compatibility records route into canonical top-level tabs or the global composer.
- ReplayTrace: focused XCTest lanes cover root tabs, legacy Pulse/Plan/Capture compatibility, and global Capture overlay behavior.
- You / What Ambitions knows stays a runtime inspection requirement in surface contracts.

Forbidden:
- No sixth tab.
- No AppTab.capture root model.
- No top-level Plan, Pulse, Profile, Review, Calendar, Inbox, or chatbot wrapper route.
- No broad feature completion inside individual surfaces.
- No release, App Store, device, or accessibility completion claims from this issue.
