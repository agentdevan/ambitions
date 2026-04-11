import { PropsWithChildren, useEffect } from "react";
import { NavigationContainer, DefaultTheme } from "@react-navigation/native";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import * as SystemUI from "expo-system-ui";
import { View } from "react-native";

import { appTheme } from "../../design/theme";
import { useAppStore } from "../../state/useAppStore";
import { AppText } from "../../components/ui/Text";

const navigationTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    background: appTheme.colors.background.canvas,
    card: appTheme.colors.background.canvas,
    text: appTheme.colors.text.primary,
    border: appTheme.colors.border.subtle,
    primary: appTheme.colors.accent.sage,
  },
};

export function AppProviders({ children }: PropsWithChildren) {
  const bootStatus = useAppStore((state) => state.bootStatus);
  const lastError = useAppStore((state) => state.lastError);

  useEffect(() => {
    SystemUI.setBackgroundColorAsync(appTheme.colors.background.canvas).catch(() => null);
    useAppStore.getState().bootstrap().catch(() => null);
  }, []);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <NavigationContainer theme={navigationTheme}>
          <StatusBar style="dark" />
          {bootStatus === "error" ? (
            <View style={{ flex: 1, justifyContent: "center", alignItems: "center", padding: 24 }}>
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
