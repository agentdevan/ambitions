import { ReactNode } from "react";
import { View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface PageHeaderProps {
  eyebrow: string;
  title: string;
  description?: string | null;
  action?: ReactNode;
}

export function PageHeader({
  eyebrow,
  title,
  description = null,
  action = null,
}: PageHeaderProps) {
  const theme = useResolvedTheme();

  return (
    <Surface tone="hero" className="gap-4 mb-0">
      <View className="flex-row items-center gap-2">
        <View
          style={{
            width: 26,
            height: 3,
            borderRadius: 999,
            backgroundColor: theme.colors.accent.primary,
            opacity: theme.mode === "dark" ? 0.92 : 0.8,
          }}
        />
        <AppText tone="accent" variant="micro" style={{ textTransform: "uppercase" }}>
          {eyebrow}
        </AppText>
      </View>
      <View className="flex-row items-start justify-between gap-3">
        <View className="flex-1 gap-2">
          <AppText variant="hero" style={{ maxWidth: "96%" }}>
            {title}
          </AppText>
          {description ? (
            <AppText tone="secondary" variant="caption" style={{ maxWidth: "96%" }}>
              {description}
            </AppText>
          ) : null}
        </View>
        {action ? <View style={{ marginTop: 6 }}>{action}</View> : null}
      </View>
    </Surface>
  );
}
