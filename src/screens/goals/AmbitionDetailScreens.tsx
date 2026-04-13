import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useMemo, useState } from "react";
import { View } from "react-native";

import {
  DetailHero,
  DetailSection,
  DetailSummaryStrip,
  QuietMetaLine,
} from "../../components/detail/DetailPrimitives";
import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { AmbitionStatus, GoalStatus } from "../../domain/models";
import { GoalsStackParamList } from "../../navigation/types";
import {
  buildDirectionPortfolioSnapshot,
  buildGoalProgressTruth,
} from "../../services/goals/progress";
import { canonicalizeAmbitions, canonicalizeGoals } from "../../services/goals/portfolioIntegrity";
import { buildActivityFeed } from "../../services/history/selectors";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";

function statusLabel(status: AmbitionStatus) {
  switch (status) {
    case AmbitionStatus.Paused:
      return "Paused";
    case AmbitionStatus.Archived:
      return "Archived";
    default:
      return "Active";
  }
}

function representationTone(
  state: "well_represented" | "lightly_represented" | "underrepresented" | undefined,
) {
  if (state === "well_represented") {
    return "accent" as const;
  }

  if (state === "lightly_represented") {
    return "neutral" as const;
  }

  return "quiet" as const;
}

function useAmbitionData(ambitionId: string) {
  const ambitions = useAppStore((state) => state.ambitions);
  const goals = useAppStore((state) => state.goals);
  const milestones = useAppStore((state) => state.milestones);
  const tasks = useAppStore((state) => state.allTasks);
  const timeBlocks = useAppStore((state) => state.allTimeBlocks);
  const activityEvents = useAppStore((state) => state.activityEvents);
  const currentWeekReview = useAppStore((state) => state.currentWeekReview);
  const currentMonthReview = useAppStore((state) => state.currentMonthReview);

  return useMemo(() => {
    const uniqueAmbitions = canonicalizeAmbitions(ambitions);
    const uniqueGoals = canonicalizeGoals(goals);
    const ambition = uniqueAmbitions.find((entry) => entry.id === ambitionId) ?? null;
    const linkedGoals = uniqueGoals
      .filter((goal) => goal.ambitionId === ambitionId)
      .sort((left, right) => {
        if (left.status !== right.status) {
          return left.status === GoalStatus.Active ? -1 : 1;
        }

        return left.sortOrder - right.sortOrder;
      });
    const feed = buildActivityFeed(activityEvents, tasks, milestones);
    const goalTruths = linkedGoals.map((goal) =>
      buildGoalProgressTruth({
        goal,
        ambition,
        milestones: milestones.filter((entry) => entry.goalId === goal.id),
        tasks: tasks.filter((entry) => entry.goalId === goal.id),
        timeBlocks,
        activityFeed: feed,
        currentWeekReview,
        currentMonthReview,
      }),
    );
    const portfolio = buildDirectionPortfolioSnapshot({
      ambitions: ambition ? [ambition] : [],
      goals: linkedGoals,
      goalTruths,
    });

    return {
      ambition,
      linkedGoals,
      goalTruths,
      goalTruthById: new Map(goalTruths.map((truth) => [truth.goalId, truth])),
      ambitionTruth: portfolio.ambitions[0] ?? null,
    };
  }, [
    ambitionId,
    ambitions,
    goals,
    milestones,
    tasks,
    timeBlocks,
    activityEvents,
    currentWeekReview,
    currentMonthReview,
  ]);
}

export function AmbitionDetailScreen({
  route,
  navigation,
}: NativeStackScreenProps<GoalsStackParamList, "AmbitionDetail">) {
  const { ambition, linkedGoals, goalTruthById, ambitionTruth } = useAmbitionData(route.params.ambitionId);

  if (!ambition) {
    return (
      <Screen>
        <EmptyStateCard title="Ambition not found" body="That direction is not available." />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Ambition"
          title={ambition.title}
          description={ambition.thesis ?? "A direction above the current goals."}
          badges={
            <>
              <Pill label={statusLabel(ambition.status)} tone="quiet" />
              {ambitionTruth ? (
                <Pill
                  label={ambitionTruth.representationLabel}
                  tone={representationTone(ambitionTruth.representationState)}
                />
              ) : null}
            </>
          }
          meta={
            <QuietMetaLine
              items={[
                `${linkedGoals.length} linked goals`,
                ambitionTruth?.portfolioSummary ?? "No representation read yet",
              ]}
            />
          }
        />

        {ambitionTruth ? (
          <DetailSection
            title="Direction truth"
            description={ambitionTruth.portfolioSummary}
          >
            <View className="gap-4">
              <DetailSummaryStrip
                items={[
                  {
                    label: "Representation",
                    value: ambitionTruth.representationLabel,
                    detail: ambitionTruth.representationSummary,
                  },
                  {
                    label: "This week",
                    value: `${Math.round(ambitionTruth.currentWeekScheduledMinutes / 60)} hr`,
                    detail: "Direction represented through planned time.",
                  },
                  {
                    label: "Moving goals",
                    value: String(ambitionTruth.movingGoalCount),
                    detail: `${ambitionTruth.representedGoalCount} currently visible in the week`,
                  },
                  {
                    label: "Active goals",
                    value: String(ambitionTruth.activeGoalCount),
                    detail: "Linked goals carrying this direction.",
                  },
                ]}
              />
              <Surface
                tone={ambitionTruth.representationState === "underrepresented" ? "accent" : "sunken"}
                className="gap-2 mb-0"
              >
                <AppText variant="caption">{ambitionTruth.portfolioSummary}</AppText>
                <AppText tone="secondary" variant="caption">
                  {ambitionTruth.representationSummary}
                </AppText>
              </Surface>
            </View>
          </DetailSection>
        ) : null}

        <DetailSection
          title="Goals under this direction"
          description="Meaning should stay linked to live work."
          action={
            <Button tone="inline" onPress={() => navigation.navigate("AmbitionEdit", { ambitionId: ambition.id })}>
              Edit
            </Button>
          }
        >
          {linkedGoals.length === 0 ? (
            <Surface className="mb-0 gap-2">
              <AppText>No goals are linked here yet.</AppText>
              <AppText tone="secondary">
                Link a goal to this ambition from the goal editor.
              </AppText>
            </Surface>
          ) : (
            <View className="gap-3">
              {linkedGoals.map((goal) => {
                const truth = goalTruthById.get(goal.id);
                return (
                  <Surface key={goal.id} tone="sunken" className="gap-3 mb-0">
                    <View className="flex-row flex-wrap items-center justify-between gap-2">
                      <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                        {goal.status === GoalStatus.Active ? "Active goal" : "Inactive goal"}
                      </AppText>
                      <View className="flex-row flex-wrap gap-2">
                        {truth ? (
                          <Pill
                            label={truth.paceLabel}
                            tone={representationTone(
                              truth.paceState === "on_pace" || truth.paceState === "recovered"
                                ? "well_represented"
                                : truth.paceState === "slightly_off_pace"
                                  ? "lightly_represented"
                                  : "underrepresented",
                            )}
                          />
                        ) : null}
                        {truth?.crowded ? <Pill label="Crowded" tone="quiet" /> : null}
                        {truth?.stale ? <Pill label="Quiet" tone="quiet" /> : null}
                      </View>
                    </View>
                    <View className="gap-1">
                      <AppText variant="section">{goal.title}</AppText>
                      <AppText tone="secondary" variant="caption">
                        {truth?.paceSummary ?? goal.summary ?? "Open the current read."}
                      </AppText>
                    </View>
                    <View className="flex-row flex-wrap gap-3">
                      <Surface tone="sunken" className="min-w-[31%] flex-1 gap-1.5 mb-0 px-4 py-4">
                        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                          This week
                        </AppText>
                        <AppText variant="section">
                          {truth ? `${Math.round(truth.currentWeekScheduledMinutes / 60)} hr` : "0 hr"}
                        </AppText>
                        <AppText tone="secondary" variant="caption">
                          {truth?.representationSummary ?? "No current week read."}
                        </AppText>
                      </Surface>
                      <Surface tone="sunken" className="min-w-[31%] flex-1 gap-1.5 mb-0 px-4 py-4">
                        <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
                          Timeline
                        </AppText>
                        <AppText variant="section">
                          {goal.targetDate ? formatShortDate(goal.targetDate) : "No date"}
                        </AppText>
                        <AppText tone="secondary" variant="caption">
                          {truth?.deadlineSummary ?? "Goal detail carries the full timeline read."}
                        </AppText>
                      </Surface>
                    </View>
                    <View className="flex-row items-center justify-between gap-3">
                      <AppText tone="secondary" variant="caption" style={{ flex: 1 }}>
                        {goal.summary ?? "Direction stays meaningful through linked live work."}
                      </AppText>
                      <Button
                        tone="tertiary"
                        size="compact"
                        onPress={() => navigation.navigate("GoalDetail", { goalId: goal.id })}
                      >
                        Open goal
                      </Button>
                    </View>
                  </Surface>
                );
              })}
            </View>
          )}
        </DetailSection>
      </View>
    </Screen>
  );
}

export function AmbitionEditScreen({
  route,
  navigation,
}: NativeStackScreenProps<GoalsStackParamList, "AmbitionEdit">) {
  const ambitions = useAppStore((state) => state.ambitions);
  const createAmbition = useAppStore((state) => state.createAmbition);
  const updateAmbition = useAppStore((state) => state.updateAmbition);
  const ambition = ambitions.find((entry) => entry.id === route.params?.ambitionId) ?? null;
  const [title, setTitle] = useState(ambition?.title ?? "");
  const [thesis, setThesis] = useState(ambition?.thesis ?? "");
  const [status, setStatus] = useState<AmbitionStatus>(ambition?.status ?? AmbitionStatus.Active);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  async function handleSave() {
    setBusy(true);
    setMessage(null);

    try {
      const result = ambition
        ? await updateAmbition(ambition.id, { title, thesis, status })
        : await createAmbition({ title, thesis, status });
      navigation.replace("AmbitionDetail", { ambitionId: result.id });
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "The ambition could not be saved.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <Screen>
      <View className="gap-6">
        <DetailHero
          eyebrow="Ambition"
          title={ambition ? "Refine the direction" : "Add an ambition"}
          description="Keep it meaningful, calm, and structurally above goals."
        />

        <Surface className="mb-0 gap-4">
          <TextField label="Title" value={title} onChangeText={setTitle} placeholder="Build a steadier creative practice" />
          <TextField
            label="Direction note"
            value={thesis}
            onChangeText={setThesis}
            multiline
            placeholder="What this direction means and what the current season is trying to protect."
          />
          <View className="gap-2">
            <AppText variant="section">Status</AppText>
            <View className="flex-row flex-wrap gap-2">
              {[AmbitionStatus.Active, AmbitionStatus.Paused, AmbitionStatus.Archived].map((option) => (
                <OptionChip
                  key={option}
                  selected={status === option}
                  onPress={() => setStatus(option)}
                >
                  {statusLabel(option)}
                </OptionChip>
              ))}
            </View>
          </View>
        </Surface>

        <View className="flex-row gap-3">
          <Button tone="tertiary" style={{ flex: 1 }} onPress={() => navigation.goBack()}>
            Cancel
          </Button>
          <Button style={{ flex: 1 }} onPress={() => void handleSave()} busy={busy}>
            Save ambition
          </Button>
        </View>

        {message ? (
          <AppText tone="tertiary" variant="caption">
            {message}
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}
