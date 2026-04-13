import { PropsWithChildren } from "react";
import { ScrollView, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";

interface ScreenProps extends PropsWithChildren {
  scrollable?: boolean;
}

export function Screen({ children, scrollable = true }: ScreenProps) {
  const insets = useSafeAreaInsets();
  const theme = useResolvedTheme();

  if (scrollable) {
    return (
      <ScrollView
        className="flex-1"
        contentContainerStyle={{
          paddingTop: insets.top + 14,
          paddingBottom: insets.bottom + 34,
          paddingHorizontal: 20,
          backgroundColor: theme.colors.background.canvas,
        }}
        showsVerticalScrollIndicator={false}
      >
        <View className="pb-6">{children}</View>
      </ScrollView>
    );
  }

  return (
    <View
      className="flex-1 px-5"
      style={{
        paddingTop: insets.top + 14,
        paddingBottom: insets.bottom + 34,
        backgroundColor: theme.colors.background.canvas,
      }}
    >
      {children}
    </View>
  );
}
