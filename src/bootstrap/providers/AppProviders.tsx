import { PropsWithChildren, useEffect } from "react";
import { NavigationContainer, DefaultTheme } from "@react-navigation/native";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import * as SystemUI from "expo-system-ui";
import { useColorScheme, View } from "react-native";

import { resolveTheme } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";
import { Button } from "../../components/ui/Button";
import { AppText } from "../../components/ui/Text";
import {
  getUnsupportedRuntimeMessage,
  isWebRuntime,
} from "../runtime/runtimeSupport";

export function AppProviders({ children }: PropsWithChildren) {
  const bootStatus = useAppStore((state) => state.bootStatus);
  const lastError = useAppStore((state) => state.lastError);
  const appearanceMode = useAppStore((state) => state.productPreferences?.appearanceMode);
  const accentTheme = useAppStore((state) => state.productPreferences?.accentTheme);
  const systemScheme = useColorScheme();
  const theme = resolveTheme({ appearanceMode, accentTheme, systemScheme });
  const unsupportedWebRuntime = isWebRuntime();
  const navigationTheme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      background: theme.colors.background.canvas,
      card: theme.colors.background.elevated,
      text: theme.colors.text.primary,
      border: theme.colors.border.subtle,
      primary: theme.colors.accent.primary,
    },
  };

  useEffect(() => {
    if (unsupportedWebRuntime) {
      return;
    }

    useAppStore.getState().bootstrap().catch(() => null);
  }, [unsupportedWebRuntime]);

  useEffect(() => {
    SystemUI.setBackgroundColorAsync(theme.colors.background.canvas).catch(() => null);
  }, [theme.colors.background.canvas]);

  const bootstrap = useAppStore((state) => state.bootstrap);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <NavigationContainer theme={navigationTheme}>
          <StatusBar style={theme.mode === "dark" ? "light" : "dark"} />
          {unsupportedWebRuntime ? (
            <View
              style={{
                flex: 1,
                justifyContent: "center",
                alignItems: "center",
                padding: 28,
                backgroundColor: theme.colors.background.canvas,
              }}
            >
              <View style={{ gap: 12, maxWidth: 360 }}>
                <AppText variant="caption" tone="tertiary" style={{ textAlign: "center" }}>
                  Ambitions
                </AppText>
                <AppText variant="title" style={{ textAlign: "center" }}>
                  Native release validation only
                </AppText>
                <AppText tone="secondary" style={{ textAlign: "center" }}>
                  {getUnsupportedRuntimeMessage()}
                </AppText>
                <AppText tone="tertiary" variant="caption" style={{ textAlign: "center" }}>
                  Use an iPhone simulator, iPhone device, or Android device for runtime and launch-readiness testing.
                </AppText>
              </View>
            </View>
          ) : bootStatus === "idle" || bootStatus === "loading" ? (
            <View
              style={{
                flex: 1,
                justifyContent: "center",
                alignItems: "center",
                padding: 28,
                backgroundColor: theme.colors.background.canvas,
              }}
            >
              <View style={{ gap: 12, maxWidth: 320 }}>
                <AppText variant="caption" tone="tertiary" style={{ textAlign: "center" }}>
                  Ambitions
                </AppText>
                <AppText variant="title" style={{ textAlign: "center" }}>
                  Loading the personal planning layer
                </AppText>
                <AppText tone="secondary" style={{ textAlign: "center" }}>
                  Rebuilding your local context, preferences, and today&apos;s baseline.
                </AppText>
              </View>
            </View>
          ) : bootStatus === "error" ? (
            <View
              style={{
                flex: 1,
                justifyContent: "center",
                alignItems: "center",
                padding: 24,
                backgroundColor: theme.colors.background.canvas,
              }}
            >
              <View style={{ gap: 12, maxWidth: 320 }}>
                <AppText variant="section" style={{ textAlign: "center" }}>
                  Ambitions could not load the local data layer.
                </AppText>
                <AppText style={{ textAlign: "center" }} tone="secondary">
                  {lastError ?? "Unknown startup failure."}
                </AppText>
                <Button tone="secondary" onPress={() => void bootstrap()}>
                  Retry loading
                </Button>
              </View>
            </View>
          ) : (
            children
          )}
        </NavigationContainer>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
