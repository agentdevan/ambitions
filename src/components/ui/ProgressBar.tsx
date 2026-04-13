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
  const fillColor = muted ? theme.colors.progress.mutedFill : theme.colors.progress.fill;

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
        pointerEvents="none"
        style={{
          position: "absolute",
          top: 1,
          left: 1,
          right: 1,
          height: Math.max(2, Math.round(height * 0.46)),
          borderRadius: 999,
          backgroundColor: theme.mode === "dark" ? "rgba(255,255,255,0.06)" : "rgba(255,255,255,0.36)",
        }}
      />
      <View
        style={{
          height: "100%",
          width: clamped > 0 ? `${Math.max(clamped * 100, height + 4)}%` : "0%",
          borderRadius: 999,
          backgroundColor: fillColor,
          shadowColor: fillColor,
          shadowOpacity: clamped > 0 ? (theme.mode === "dark" ? 0.22 : 0.12) : 0,
          shadowRadius: 10,
          shadowOffset: { width: 0, height: 4 },
        }}
      />
    </View>
  );
}
