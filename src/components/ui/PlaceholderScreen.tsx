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
      <View className="gap-8">
        <View className="gap-3 pt-5">
          <AppText tone="tertiary" variant="caption">
            {eyebrow}
          </AppText>
          <AppText variant="hero">{title}</AppText>
          <AppText tone="secondary" style={{ maxWidth: 310 }}>
            {body}
          </AppText>
        </View>

        <Surface tone="sunken" className="gap-2">
          <AppText variant="section">Reserved for a later phase</AppText>
          <AppText tone="secondary">
            The shell is in place. Detail stays intentionally quiet here until the core workflows are
            ready to take shape.
          </AppText>
        </Surface>
      </View>
    </Screen>
  );
}
