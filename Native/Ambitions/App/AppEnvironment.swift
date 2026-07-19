import SwiftUI

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer? = nil
}

private struct AppShellCapabilityKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: AppShellCapability? = nil
}

private struct AppRuntimeCapabilityKey: EnvironmentKey {
    static let defaultValue: AppRuntimeCapability? = nil
}

private struct AppPersistenceCapabilityKey: EnvironmentKey {
    static let defaultValue: AppPersistenceCapability? = nil
}

private struct AppPlatformCapabilityKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: AppPlatformCapability? = nil
}

private struct AppUserSystemCapabilityKey: EnvironmentKey {
    static let defaultValue: AppUserSystemCapability? = nil
}

private struct AppFeatureFactoryCapabilityKey: EnvironmentKey {
    static let defaultValue: AppFeatureFactoryCapability? = nil
}

extension EnvironmentValues {
    var appContainer: AppContainer? {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }

    var appShellCapability: AppShellCapability? {
        get { self[AppShellCapabilityKey.self] }
        set { self[AppShellCapabilityKey.self] = newValue }
    }

    var appRuntimeCapability: AppRuntimeCapability? {
        get { self[AppRuntimeCapabilityKey.self] }
        set { self[AppRuntimeCapabilityKey.self] = newValue }
    }

    var appPersistenceCapability: AppPersistenceCapability? {
        get { self[AppPersistenceCapabilityKey.self] }
        set { self[AppPersistenceCapabilityKey.self] = newValue }
    }

    var appPlatformCapability: AppPlatformCapability? {
        get { self[AppPlatformCapabilityKey.self] }
        set { self[AppPlatformCapabilityKey.self] = newValue }
    }

    var appUserSystemCapability: AppUserSystemCapability? {
        get { self[AppUserSystemCapabilityKey.self] }
        set { self[AppUserSystemCapabilityKey.self] = newValue }
    }

    var appFeatureFactoryCapability: AppFeatureFactoryCapability? {
        get { self[AppFeatureFactoryCapabilityKey.self] }
        set { self[AppFeatureFactoryCapabilityKey.self] = newValue }
    }
}

extension View {
    func appContainer(_ container: AppContainer) -> some View {
        self
            .environment(\.appContainer, container)
            .environment(\.appShellCapability, container.shell)
            .environment(\.appRuntimeCapability, container.runtimeCapability)
            .environment(\.appPersistenceCapability, container.persistence)
            .environment(\.appPlatformCapability, container.platform)
            .environment(\.appUserSystemCapability, container.userSystem)
            .environment(\.appFeatureFactoryCapability, container.featureFactory)
    }
}
