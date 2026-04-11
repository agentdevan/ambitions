import { View } from "react-native";

import { CapacityProfile } from "../../data/models";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface CapacityInsightProps {
  capacity: CapacityProfile;
  focus: string;
}

export function CapacityInsight({ capacity, focus }: CapacityInsightProps) {
  return (
    <Surface tone="accent" className="gap-5">
      <View className="gap-2">
        <AppText tone="secondary" variant="caption">
          Capacity
        </AppText>
        <AppText variant="section">
          {capacity.focusBudgetMinutes} minutes of clear focus room today.
        </AppText>
      </View>

      <AppText tone="secondary" style={{ maxWidth: 300 }}>
        {focus}
      </AppText>

      <View className="flex-row gap-3">
        <View className="flex-1 rounded-[22px] border border-[#D7DED3] bg-[#EEF3EC] px-4 py-3">
          <AppText tone="tertiary" variant="micro">
            Mental load
          </AppText>
          <AppText variant="section" style={{ marginTop: 6, textTransform: "capitalize" }}>
            {capacity.mentalLoad}
          </AppText>
        </View>

        <View className="flex-1 rounded-[22px] border border-[#D7DED3] bg-[#EEF3EC] px-4 py-3">
          <AppText tone="tertiary" variant="micro">
            Meeting load
          </AppText>
          <AppText variant="section" style={{ marginTop: 6 }}>
            {capacity.meetingLoadMinutes} min
          </AppText>
        </View>
      </View>
    </Surface>
  );
}
