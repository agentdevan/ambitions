import { useMemo } from "react";

import { useAppStore } from "../../state/useAppStore";
import { resolveThemePreset } from "../../product/theme";

export function useResolvedTheme() {
  const preset = useAppStore((state) => state.productPreferences?.themePreset);

  return useMemo(() => resolveThemePreset(preset), [preset]);
}
