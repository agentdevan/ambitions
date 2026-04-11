import { View } from "react-native";

import { PlanBlock } from "../../data/models";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface TimelinePlanProps {
  blocks: PlanBlock[];
}

const stateAccentMap = {
  complete: "#6A8368",
  scheduled: "#6C7483",
  active: "#4F6D7A",
  rolled: "#A17A56",
  deferred: "#9A978E",
  cancelled: "#A19B92",
};

export function TimelinePlan({ blocks }: TimelinePlanProps) {
  return (
    <Surface className="gap-6">
      <View className="gap-2">
        <AppText tone="secondary" variant="caption">
          Time-blocked plan
        </AppText>
        <AppText variant="section">A believable shape for the day</AppText>
      </View>

      <View className="gap-1">
        {blocks.map((block, index) => (
          <View
            key={block.id}
            className={`flex-row gap-4 py-4 ${index < blocks.length - 1 ? "border-b border-[#E7E1D8]" : ""}`}
          >
            <View className="items-center pt-0.5">
              <AppText variant="micro" tone="tertiary">
                {block.startsAt}
              </AppText>
              <View
                className="mt-2 w-[2px] flex-1 rounded-full"
                style={{ backgroundColor: `${stateAccentMap[block.state]}24`, minHeight: 46 }}
              />
            </View>

            <View className="flex-1 gap-2">
              <View className="flex-row items-start justify-between gap-3">
                <View className="flex-1 gap-1.5">
                  <AppText variant="section">{block.title}</AppText>
                  <AppText tone="tertiary" variant="caption">
                    Until {block.endsAt}
                  </AppText>
                </View>
                <View
                  className="rounded-full px-2.5 py-1"
                  style={{ backgroundColor: `${stateAccentMap[block.state]}14` }}
                >
                  <AppText
                    variant="micro"
                    style={{
                      color: stateAccentMap[block.state],
                      textTransform: "capitalize",
                    }}
                  >
                    {block.state}
                  </AppText>
                </View>
              </View>

              <AppText tone="secondary" style={{ maxWidth: 280 }}>
                {block.note}
              </AppText>
            </View>
          </View>
        ))}
      </View>
    </Surface>
  );
}
