# AMB-1059 parallel implementation guard prompt

Issue: AMB-1059 — M04.T02 — Global search entry and presentation: trusted retrieval handoff.

Source-changing scope:
- Provide a real global Memory Lens search entry and result presentation from the existing shell overlay.
- Route selected search results through existing shell/navigation owners with visible local handoff context.
- Preserve active root destinations: Today / Goals / Time / Motion / You.
- Keep Capture as a global action or compatibility handoff only; it must not become a top-level tab.
- Keep search local-first, source-grounded, and non-mutating until the user explicitly opens a result.
- Use the existing Memory Lens retrieval contract as-is; this train owns app-shell presentation and routing only.

Allowed source owners:
- Native/Ambitions/App/ShellCommandModels.swift
- Native/Ambitions/App/ShellCommandRouter.swift
- Native/Ambitions/App/AppShellView.swift
- Native/AmbitionsTests/App/MemoryLensServiceTests.swift
- Native/AmbitionsTests/App/ShellCommandRouterTests.swift

Required evidence:
- Runtime wiring boundary: SourceRecord, Receipt, and ReplayTrace remain in existing runtime/proof owners; this train only displays and routes existing Memory Lens result metadata.
- Search metadata: Memory Lens result metadata declares source evidence, trust decay, retrieval scope, and canonical handoff owner.
- Handoff evidence: selected search results create visible local handoff context before/while routing to the owning surface or global Capture handoff.
- Focused tests: XCTest lanes cover search result filtering, trusted route owners, Capture handoff, and stale IA rejection.
- You / What Ambitions knows remains local inspection and does not claim durable memory creation.

Forbidden:
- No sixth tab.
- No AppTab.capture root model.
- No top-level Plan, Pulse, Profile, Review, Calendar, Inbox, or chatbot wrapper route.
- No cloud search, hosted AI, telemetry, analytics, or external service dependency.
- No silent mutation from search result presentation.
- No broad surface completion, release, App Store, device, privacy/legal, or accessibility certification claims from this issue.
