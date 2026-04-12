import { View } from "react-native";

import { TodaySuggestion } from "../../state/viewModels/today";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface ReplanSuggestionsPanelProps {
  suggestions: TodaySuggestion[];
}

export function ReplanSuggestionsPanel({ suggestions }: ReplanSuggestionsPanelProps) {
  if (suggestions.length === 0) {
    return null;
  }

  return (
    <Surface tone="sunken" className="gap-4">
      <View className="gap-2">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          Replan Suggestions
        </AppText>
        <AppText variant="section">Calm recovery options, not silent reshuffling</AppText>
      </View>

      <View className="gap-4">
        {suggestions.map((suggestion) => (
          <Surface key={suggestion.id} className="gap-2" tone="default">
            <Pill label="Recovery option" tone="quiet" />
            <AppText variant="section">{suggestion.title}</AppText>
            {suggestion.taskTitle ? (
              <AppText tone="tertiary" variant="caption">
                {suggestion.taskTitle}
              </AppText>
            ) : null}
            <AppText tone="secondary">{suggestion.rationale}</AppText>
          </Surface>
        ))}
      </View>
    </Surface>
  );
}
