import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";

interface ProgressBarProps {
  progress: number;
  muted?: boolean;
  height?: number;
}

export function ProgressBar({ progress, muted = false, height = 6 }: ProgressBarProps) {
  const theme = useResolvedTheme();
  const clamped = Math.max(0, Math.min(1, progress));

  return (
    <View
      style={{
        height,
        borderRadius: 999,
        overflow: "hidden",
        backgroundColor: theme.colors.progress.track,
        borderWidth: 1,
        borderColor: theme.colors.border.subtle,
      }}
    >
      <View
        style={{
          height: "100%",
          width: `${clamped * 100}%`,
          borderRadius: 999,
          backgroundColor: muted
            ? theme.colors.progress.mutedFill
            : theme.colors.progress.fill,
          shadowColor: muted ? theme.colors.progress.mutedFill : theme.colors.progress.fill,
          shadowOpacity: clamped > 0 ? (theme.mode === "dark" ? 0.22 : 0.12) : 0,
          shadowRadius: 10,
          shadowOffset: { width: 0, height: 4 },
        }}
      />
    </View>
  );
}
