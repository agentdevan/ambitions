import { View } from "react-native";

import { Screen } from "./Screen";
import { Surface } from "./Surface";
import { AppText } from "./Text";

interface PlaceholderScreenProps {
  eyebrow: string;
  title: string;
  body: string;
}

export function PlaceholderScreen({ eyebrow, title, body }: PlaceholderScreenProps) {
  return (
    <Screen>
      <View className="gap-6">
        <View className="gap-2 pt-4">
          <AppText tone="tertiary" variant="caption">
            {eyebrow}
          </AppText>
          <AppText variant="hero">{title}</AppText>
          <AppText tone="secondary">{body}</AppText>
        </View>

        <Surface tone="sunken" className="gap-3">
          <AppText variant="section">Foundation Placeholder</AppText>
          <AppText tone="secondary">
            This section is intentionally held at the shell level in phase one so the navigation,
            design language, and architectural boundaries settle before feature depth expands.
          </AppText>
        </Surface>
      </View>
    </Screen>
  );
}
