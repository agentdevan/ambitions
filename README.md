# Ambitions

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017.0%2B-black?style=for-the-badge&logo=apple" alt="Platform: iOS 17.0+" />
  <img src="https://img.shields.io/badge/Language-Swift%206.0-orange?style=for-the-badge&logo=swift" alt="Language: Swift 6.0" />
  <img src="https://img.shields.io/badge/Build-XcodeGen-blue?style=for-the-badge&logo=xcode" alt="Build: XcodeGen" />
  <img src="https://img.shields.io/badge/Security-Local%20Only-green?style=for-the-badge" alt="Security: Local Only" />
</p>

***

> [!IMPORTANT]
> **Active Authority Index Notice**: Repository authority starts in [docs/truth/README.md](file:///c:/Users/Devan/Documents/GitHub/ambitions/docs/truth/README.md). If this README conflicts with `docs/truth/*`, the active truth files win. This file serves as architectural orientation and engineering guidelines.

Ambitions is a premium, native iOS **personal life operating system and external brain**. Designed to organize intent, ground long-term goals in daily constraints, and adapt elegantly to changing life realities, Ambitions rejects standard task lists, calendar clones, and cloud-first telemetry in favor of an elegant, local-first product experience.

---

## 🗺️ Architectural Topology

Ambitions utilizes a strict unidirectional dependency graph and modular packages to enforce complete decoupling of feature views, business rules, and database engines.

```mermaid
graph TD
    classDef main fill:#1a1a1a,stroke:#333,stroke-width:2px,color:#fff;
    classDef feature fill:#1b2a4a,stroke:#3b5998,stroke-width:2px,color:#fff;
    classDef service fill:#003311,stroke:#008833,stroke-width:2px,color:#fff;
    classDef domain fill:#2b1b00,stroke:#885500,stroke-width:2px,color:#fff;
    
    App[Native/Ambitions/App<br/>Entry & Routing]:::main
    
    TodayFeature[Native/Ambitions/Features/Today<br/>Reality Meridian]:::feature
    GoalsFeature[Native/Ambitions/Features/Goals<br/>Constellation Atlas]:::feature
    CaptureFeature[Native/Ambitions/Features/Capture<br/>Atmosphere Composer]:::feature
    TimeFeature[Native/Ambitions/Features/Time<br/>LifeShape Field]:::feature
    YouFeature[Native/Ambitions/Features/You<br/>Your System]:::feature
    
    AppServices[Native/Ambitions/Services<br/>Service Protocols]:::service
    AppRepositories[Native/Ambitions/Persistence<br/>SwiftData Repositories]:::service
    
    DomainPlanning[Native/Ambitions/Domain/Planning<br/>Capacity & Freshness]:::domain
    DomainCore[Native/Ambitions/Domain/Core<br/>Nouns & Invariants]:::domain
    
    App --> TodayFeature
    App --> GoalsFeature
    App --> CaptureFeature
    App --> TimeFeature
    App --> YouFeature
    
    TodayFeature --> AppServices
    GoalsFeature --> AppServices
    CaptureFeature --> AppServices
    TimeFeature --> AppServices
    YouFeature --> AppServices
    
    AppServices --> AppRepositories
    AppRepositories --> DomainPlanning
    DomainPlanning --> DomainCore
```

---

## 📂 Repository Directory Structure

For any FAANG engineer starting in this repository, here is the clean map of the core zones:

*   **[`Native/Ambitions/App/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/App)**: App entry, application container dependencies, unified shell composition, and deep-link/Widget intake routing.
*   **[`Native/Ambitions/Domain/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Domain)**: Pure business models, capacity limits, freshness brokers, non-shaming closure invariants, and planning horizon calculations.
*   **[`Native/Ambitions/Services/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Services)**: Core coordination service boundaries, protocol contracts, and mock/stub registries.
*   **[`Native/Ambitions/Persistence/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Persistence)**: On-device SQLite/SwiftData repository configurations.
*   **[`Native/Ambitions/Features/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Features)**: Rich feature layouts organized into five domain portals:
    *   **[`Today/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Features/Today)**: Focus & execution (`Start Here` & `Reality Meridian`).
    *   **[`Goals/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Features/Goals)**: Directed outcomes (`Constellation Atlas`).
    *   **[`Capture/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Features/Capture)**: Quiet incoming intake (`Atmosphere Composer`).
    *   **[`Time/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Features/Time)**: Capacity orientation (`LifeShape Field`).
    *   **[`You/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Native/Ambitions/Features/You)**: Permission & Trust center (`Your System`).
*   **[`Sources/AmbitionsDesignSystem/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/Sources/AmbitionsDesignSystem)**: Local Swift Package providing premium Dark Mode visual tokens (Graphite Recess, Luminous Trace, Quiet Glass) and high-polish interface widgets.
*   **[`AppUI/Sources/AmbitionsWidgetUI/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/AppUI/Sources/AmbitionsWidgetUI)**: Encapsulated widget view primitives sharing design metrics.
*   **[`scripts/`](file:///c:/Users/Devan/Documents/GitHub/ambitions/scripts)**: Rich automation suite for accessibility compliance, memory safety scans, dynamic type verification, and visual regression gating.

---

## 🛠️ Local Build & Dev Setup

Ambitions uses **XcodeGen** to avoid messy, merge-conflicted Xcode project files. The project is dynamically synthesized from `project.yml`.

### 1. Prerequisite Checklist
*   macOS 14.0+ (for local Xcode builds)
*   Xcode 15.4+ or Xcode 16.0+ (configured for Swift 6 compiler toolchain)
*   Homebrew installed `xcodegen`

### 2. Synthesize Xcode Project
Generate the `.xcodeproj` shell container locally prior to opening Xcode:
```bash
xcodegen generate
```

### 3. Build & Run Tests via CLI
To perform localized verification and validate compiler boundaries:

*   **Build Project**:
    ```bash
    ./scripts/build-local.sh
    ```
*   **Run Unit and Integration Suite**:
    ```bash
    ./scripts/test-local.sh
    ```

---

## 🛡️ Core Moat & Design Guidelines

Ambitions enforces a series of strict structural invariants designed to ensure world-class iOS quality and reject features that commoditize the experience:

1.  **Tab Restraint**: Exactly five canonical tabs: `Today / Goals / Capture / Time / You`. Banned: *Plan*, *Inbox*, *Profile*, or any sixth navigation tab.
2.  **No Silent Automation**: No silent reads/writes to calendar, no secret cloud-sync channels, and no background profiling. Any action that changes scheduling requires an explicit receipt.
3.  **Local-First Privacy**: Storing user context, goal threads, and capture logs strictly on-device. The system must operate completely free of server-side data profiling or cloud AI API dependencies.
4.  **Calm & Non-Shaming**: Overdue elements are closed or pivoted gracefully. Gamified anxiety triggers (such as daily streak clocks or productivity comparison leaderboards) are explicitly forbidden.

---

## 🔍 Codebase Health Scans

Engineers must execute the localized quality checks under `scripts/` before proposing changes to the codebase. The gate checks inspect critical metrics:
*   `accessibility-cognitive-load-scan.sh`: Validates touch-target constraints and Dynamic Type scalability.
*   `cqs-architecture-boundary-scan.sh`: Audits target boundaries to prevent circular dependencies between Services and Features.
*   `codex-forbidden-claim-scan.sh`: Prevents making false validation claims in the absence of verified local simulator/hardware proof.
