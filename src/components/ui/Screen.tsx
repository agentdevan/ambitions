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
          paddingTop: insets.top + 10,
          paddingBottom: insets.bottom + 24,
        }}
        showsVerticalScrollIndicator={false}
      >
        <View className="px-5">{children}</View>
      </ScrollView>
    );
  }

  return (
    <View
      className="flex-1 bg-[#F3F1EC] px-5"
      style={{ paddingTop: insets.top + 10, paddingBottom: insets.bottom + 24 }}
    >
      {children}
    </View>
  );
}
