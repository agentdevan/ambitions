import { View } from "react-native";

import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { getGoalReviewDraft } from "../../services/goals/metadata";
import { useAppStore } from "../../state/useAppStore";

function MetaLine({ items }: { items: string[] }) {
  return (
    <View className="flex-row flex-wrap gap-x-4 gap-y-2">
      {items.map((item) => (
        <AppText key={item} tone="secondary" variant="caption">
          {item}
        </AppText>
      ))}
    </View>
  );
}

export function InsightContinuityScreen() {
  const today = useAppStore((state) => state.today);
  const goals = useAppStore((state) => state.goals);
  const pendingReviews = goals.filter((goal) => getGoalReviewDraft(goal) !== null);

  if (!today) {
    return (
      <Screen>
        <EmptyStateCard title="No insight data" body="Today's continuity snapshot is not available." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Continuity</AppText>
          <AppText tone="secondary">
            See what is carrying forward well and what still needs a decision.
          </AppText>
        </Surface>
        <Surface className="gap-3">
          <MetaLine
            items={[
              `${today.progress.completed} completed`,
              `${today.progress.scheduled} still scheduled`,
              `${today.progress.recovery} recovery items`,
            ]}
          />
          {pendingReviews.map((goal) => (
            <View key={goal.id} className="gap-1">
              <AppText>{goal.title}</AppText>
              <AppText tone="secondary" variant="caption">
                {getGoalReviewDraft(goal)?.summary}
              </AppText>
            </View>
          ))}
        </Surface>
      </View>
    </Screen>
  );
}

export function InsightSignalsScreen() {
  const today = useAppStore((state) => state.today);
  const replanSuggestions = useAppStore((state) => state.replanSuggestions);

  if (!today) {
    return (
      <Screen>
        <EmptyStateCard title="No signals yet" body="Signal detail is not available right now." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Planning signals</AppText>
          <AppText tone="secondary">
            These signals explain why the plan is staying steady or asking for change.
          </AppText>
        </Surface>
        <Surface className="gap-3">
          {today.adaptiveGuidance.map((item) => (
            <View key={item} className="gap-1">
              <AppText>{item}</AppText>
            </View>
          ))}
        </Surface>
        <Surface className="gap-3">
          {replanSuggestions.length === 0 ? (
            <AppText tone="secondary">No active replan suggestions right now.</AppText>
          ) : (
            replanSuggestions.map((suggestion) => (
              <View key={suggestion.id} className="gap-1">
                <View className="flex-row flex-wrap items-center gap-2">
                  <AppText>{suggestion.title}</AppText>
                  <Pill label={suggestion.type.replaceAll("_", " ")} tone="quiet" />
                </View>
                <AppText tone="secondary" variant="caption">
                  {suggestion.rationale}
                </AppText>
              </View>
            ))
          )}
        </Surface>
      </View>
    </Screen>
  );
}

export function InsightCapacityScreen() {
  const today = useAppStore((state) => state.today);

  if (!today) {
    return (
      <Screen>
        <EmptyStateCard title="No capacity read yet" body="Capacity insight is not available right now." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-4">
        <Surface tone="accent" className="gap-3">
          <AppText variant="title">Capacity and balance</AppText>
          <AppText tone="secondary">
            A compact read on how heavy the day is and how much room is left.
          </AppText>
        </Surface>
        <Surface className="gap-3">
          <MetaLine
            items={[
              `${today.capacity.focusBudgetMinutes} focus minutes`,
              `${today.capacity.meetingLoadMinutes} meeting minutes`,
              `${today.capacity.unusedCapacityMinutes} unused`,
            ]}
          />
          <AppText tone="secondary">
            Pressure is {today.capacity.planPressure}. Confidence is{" "}
            {Math.round(today.capacity.confidence * 100)}%.
          </AppText>
          {today.capacity.overloadWarning ? (
            <AppText tone="secondary">
              The planner is already holding work back to avoid overload.
            </AppText>
          ) : null}
        </Surface>
      </View>
    </Screen>
  );
}
