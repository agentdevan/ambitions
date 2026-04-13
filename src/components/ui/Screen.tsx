import { ForwardedRef, PropsWithChildren, forwardRef } from "react";
import { ScrollView, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";

interface ScreenProps extends PropsWithChildren {
  scrollable?: boolean;
}

export const Screen = forwardRef(function Screen(
  { children, scrollable = true }: ScreenProps,
  ref: ForwardedRef<ScrollView>,
) {
  const insets = useSafeAreaInsets();
  const theme = useResolvedTheme();

  if (scrollable) {
    return (
      <ScrollView
        ref={ref}
        className="flex-1"
        contentContainerStyle={{
          flexGrow: 1,
          paddingTop: insets.top + 14,
          paddingBottom: insets.bottom + 34,
          paddingHorizontal: 20,
          backgroundColor: theme.colors.background.canvas,
        }}
        contentInsetAdjustmentBehavior="automatic"
        keyboardShouldPersistTaps="handled"
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
});
