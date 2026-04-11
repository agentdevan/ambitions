import { PropsWithChildren } from "react";
import { ScrollView, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

interface ScreenProps extends PropsWithChildren {
  scrollable?: boolean;
}

export function Screen({ children, scrollable = true }: ScreenProps) {
  const insets = useSafeAreaInsets();

  if (scrollable) {
    return (
      <ScrollView
        className="flex-1 bg-[#F3F1EC]"
        contentContainerStyle={{
          paddingTop: insets.top + 14,
          paddingBottom: insets.bottom + 34,
        }}
        showsVerticalScrollIndicator={false}
      >
        <View className="px-6">{children}</View>
      </ScrollView>
    );
  }

  return (
    <View
      className="flex-1 bg-[#F3F1EC] px-6"
      style={{ paddingTop: insets.top + 14, paddingBottom: insets.bottom + 34 }}
    >
      {children}
    </View>
  );
}
