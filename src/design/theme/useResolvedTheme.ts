import { useMemo } from "react";
import { useColorScheme } from "react-native";

import { useAppStore } from "../../state/useAppStore";
import { resolveTheme } from "../../product/theme";

export function useResolvedTheme() {
  const appearanceMode = useAppStore((state) => state.productPreferences?.appearanceMode);
  const accentTheme = useAppStore((state) => state.productPreferences?.accentTheme);
  const systemScheme = useColorScheme();

  return useMemo(
    () =>
      resolveTheme({
        appearanceMode,
        accentTheme,
        systemScheme,
      }),
    [accentTheme, appearanceMode, systemScheme],
  );
}
