import { PropsWithChildren, useEffect } from "react";
import { NavigationContainer, DefaultTheme } from "@react-navigation/native";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import * as SystemUI from "expo-system-ui";
import { View } from "react-native";

import { resolveThemePreset } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";
import { AppText } from "../../components/ui/Text";

export function AppProviders({ children }: PropsWithChildren) {
  const bootStatus = useAppStore((state) => state.bootStatus);
  const lastError = useAppStore((state) => state.lastError);
  const themePreset = useAppStore((state) => state.productPreferences?.themePreset);
  const theme = resolveThemePreset(themePreset);
  const navigationTheme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      background: theme.colors.background.canvas,
      card: theme.colors.background.canvas,
      text: theme.colors.text.primary,
      border: theme.colors.border.subtle,
      primary: theme.colors.accent.primary,
    },
  };

  useEffect(() => {
    useAppStore.getState().bootstrap().catch(() => null);
  }, []);

  useEffect(() => {
    SystemUI.setBackgroundColorAsync(theme.colors.background.canvas).catch(() => null);
  }, [theme.colors.background.canvas]);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <NavigationContainer theme={navigationTheme}>
          <StatusBar style="dark" />
          {bootStatus === "error" ? (
            <View
              style={{
                flex: 1,
                justifyContent: "center",
                alignItems: "center",
                padding: 24,
                backgroundColor: theme.colors.background.canvas,
              }}
            >
              <AppText variant="section">Ambitions could not load the local data layer.</AppText>
              <AppText style={{ marginTop: 12, textAlign: "center" }} tone="secondary">
                {lastError ?? "Unknown startup failure."}
              </AppText>
            </View>
          ) : (
            children
          )}
        </NavigationContainer>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
