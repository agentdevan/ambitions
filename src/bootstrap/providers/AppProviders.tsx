import { PropsWithChildren, useEffect } from "react";
import { NavigationContainer, DefaultTheme } from "@react-navigation/native";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import * as SystemUI from "expo-system-ui";

import { appTheme } from "../../design/theme";
import { initializeDatabase } from "../../services/database/client";
import { NotificationsService } from "../../services/notifications/NotificationsService";

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
  useEffect(() => {
    SystemUI.setBackgroundColorAsync(appTheme.colors.background.canvas).catch(() => null);
    initializeDatabase().catch(() => null);
    NotificationsService.configure().catch(() => null);
  }, []);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <NavigationContainer theme={navigationTheme}>
          <StatusBar style="dark" />
          {children}
        </NavigationContainer>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
