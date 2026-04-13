import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useEffect, useMemo, useState } from "react";
import { View } from "react-native";

import { PageHeader } from "../../components/navigation/PageHeader";
import { Button } from "../../components/ui/Button";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { SelectionCard } from "../../components/ui/SelectionCard";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { TextField } from "../../components/ui/TextField";
import { GoalsStackParamList } from "../../navigation/types";
import { inferGoalDraft } from "../../product/goalIntake";
import { createGoalArtifacts } from "../../product/planOrchestrator";
import { GoalPaceMode } from "../../product/types";
import { useAppStore } from "../../state/useAppStore";
import { formatShortDate } from "../../utils/date";
import { GoalEditScreen as LegacyGoalEditScreen } from "./GoalDetailScreens";

type Props = NativeStackScreenProps<GoalsStackParamList, "GoalEdit">;

function addDays(date: string, amount: number) {
  return new Date(Date.parse(`${date}T12:00:00.000Z`) + amount * 86400000)
    .toISOString()
    .slice(0, 10);
}

const createSteps = [
  "Frame it",
  "Set target",
  "Pick pace",
  "See the shape",
  "Review",
] as const;

export function GoalComposerScreen(props: Props) {
  if (props.route.params?.goalId) {
    return <LegacyGoalEditScreen {...props} />;
  }

  return <NewGoalFlow {...props} />;
}

function NewGoalFlow({ navigation }: Props) {
  const planDate = useAppStore((state) => state.planDate);
  const ambitions = useAppStore((state) => state.ambitions);
  const goals = useAppStore((state) => state.goals);
  const productPreferences = useAppStore((state) => state.productPreferences);
  const userPreferences = useAppStore((state) => state.userPreferences);
  const adaptationProfile = useAppStore((state) => state.adaptationProfile);
  const createGoal = useAppStore((state) => state.createGoal);
  const [stepIndex, setStepIndex] = useState(0);
  const [goalPrompt, setGoalPrompt] = useState("");
  const [titleOverride, setTitleOverride] = useState("");
  const [targetDate, setTargetDate] = useState("");
  const [selectedPaceMode, setSelectedPaceMode] = useState<GoalPaceMode>("balanced");
  const [selectedAmbitionId, setSelectedAmbitionId] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);
  const [composerBusy, setComposerBusy] = useState(false);
  const [composer, setComposer] = useState<Awaited<ReturnType<typeof createGoalArtifacts>>["composer"] | null>(null);

  const baseInput = goalPrompt.trim() || titleOverride.trim();
  const inferredDraft = useMemo(
    () => (baseInput ? inferGoalDraft(baseInput, planDate) : null),
    [baseInput, planDate],
  );

  const composedInference = useMemo(() => {
    if (!inferredDraft) {
      return null;
    }

    return {
      ...inferredDraft,
      ambitionId: selectedAmbitionId,
      title: titleOverride.trim() || inferredDraft.title,
      naturalLanguage: goalPrompt.trim() || inferredDraft.naturalLanguage,
      summary: goalPrompt.trim() || inferredDraft.summary,
      targetDate: targetDate.trim() || null,
      paceMode: selectedPaceMode,
    };
  }, [goalPrompt, inferredDraft, selectedAmbitionId, selectedPaceMode, targetDate, titleOverride]);

  useEffect(() => {
    if (!inferredDraft || targetDate) {
      return;
    }

    setTargetDate(inferredDraft.targetDate ?? "");
  }, [inferredDraft, targetDate]);

  useEffect(() => {
    let cancelled = false;

    if (!composedInference || !productPreferences || !userPreferences) {
      setComposer(null);
      setComposerBusy(false);
      return () => {
        cancelled = true;
      };
    }

    setComposerBusy(true);
    createGoalArtifacts({
      inference: composedInference,
      productPreferences,
      currentPreferences: userPreferences,
      today: planDate,
      adaptationProfile,
    })
      .then((result) => {
        if (!cancelled) {
          setComposer(result.composer);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setComposer(null);
        }
      })
      .finally(() => {
        if (!cancelled) {
          setComposerBusy(false);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [adaptationProfile, composedInference, planDate, productPreferences, userPreferences]);

  useEffect(() => {
    if (composer) {
      setSelectedPaceMode((current) =>
        current === "balanced" ? composer.recommendedPaceMode : current,
      );
    }
  }, [composer]);

  function canAdvance() {
    if (stepIndex === 0) {
      return baseInput.length > 0;
    }

    if (stepIndex === 1) {
      return true;
    }

    if (stepIndex === 2) {
      return composer !== null;
    }

    if (stepIndex === 3) {
      return composer !== null;
    }

    return composedInference !== null && composer !== null;
  }

  async function handleCreate() {
    if (!composedInference) {
      return;
    }

    setBusy(true);
    setRuntimeMessage(null);

    try {
      await createGoal(composedInference);
      const latestGoal = [...useAppStore.getState().goals].sort((left, right) =>
        right.createdAt.localeCompare(left.createdAt),
      )[0];
      if (latestGoal) {
        navigation.replace("GoalDetail", { goalId: latestGoal.id });
      } else {
        navigation.goBack();
      }
    } catch (error) {
      setRuntimeMessage(error instanceof Error ? error.message : "The goal could not be created.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <Screen>
      <View className="gap-5">
        <PageHeader
          eyebrow="New goal"
          title={createSteps[stepIndex]}
          description={`Step ${stepIndex + 1} of ${createSteps.length}`}
          action={<Pill label={`${stepIndex + 1}/${createSteps.length}`} tone="accent" />}
        />

        <Surface className="gap-4">
          <View className="gap-2">
            <ProgressDots currentIndex={stepIndex} />
            {stepIndex === 0 ? (
              <View className="gap-4">
                <TextField
                  label="What do you want to make happen?"
                  multiline
                  onChangeText={setGoalPrompt}
                  placeholder="Release 3 songs by August 1"
                  supportingText="One plain sentence is enough."
                  value={goalPrompt}
                />
                <TextField
                  label="Goal title"
                  onChangeText={setTitleOverride}
                  placeholder={inferredDraft?.title ?? "Goal title"}
                  supportingText="Optional. Leave blank to use the generated title."
                  value={titleOverride}
                />
              </View>
            ) : null}

            {stepIndex === 1 ? (
              <View className="gap-4">
                <TextField
                  label="Target date"
                  onChangeText={setTargetDate}
                  placeholder="YYYY-MM-DD or leave blank"
                  supportingText="Leave it open if you want to shape the goal first."
                  value={targetDate}
                />
                <View className="flex-row flex-wrap gap-2">
                  <Button size="compact" tone="tertiary" onPress={() => setTargetDate(addDays(planDate, 30))}>
                    +30 days
                  </Button>
                  <Button size="compact" tone="tertiary" onPress={() => setTargetDate(addDays(planDate, 90))}>
                    +90 days
                  </Button>
                  <Button size="compact" tone="tertiary" onPress={() => setTargetDate("")}>
                    No date yet
                  </Button>
                </View>
              </View>
            ) : null}

            {stepIndex === 2 ? (
              <View className="gap-3">
                {composerBusy ? (
                  <AppText tone="secondary" variant="caption">
                    Building pace options...
                  </AppText>
                ) : null}
                {composer?.paceOptions.map((option) => (
                  <SelectionCard
                    key={option.mode}
                    selected={selectedPaceMode === option.mode}
                    eyebrow={option.recommended ? "Recommended" : "Pace"}
                    onPress={() => setSelectedPaceMode(option.mode)}
                    trailing={<Pill label={option.deadlineConfidence} tone={option.recommended ? "accent" : "quiet"} />}
                  >
                    <View className="gap-2">
                      <AppText variant="section">{option.label}</AppText>
                      <AppText tone="secondary" variant="caption">
                        {option.summary}
                      </AppText>
                      <View className="flex-row flex-wrap gap-2">
                        <Pill label={`${option.weeklyHours} hr/week`} tone="quiet" />
                        <Pill label={`${option.sessionCount} sessions`} tone="quiet" />
                        <Pill label={option.riskLevel} tone="quiet" />
                      </View>
                    </View>
                  </SelectionCard>
                ))}
              </View>
            ) : null}

            {stepIndex === 3 ? (
              <View className="gap-4">
                <Surface tone="sunken" className="gap-2 mb-0">
                  <AppText variant="section">Work shape</AppText>
                  <AppText tone="secondary" variant="caption">
                    {composer?.workloadEstimateLabel ?? "Building preview..."}
                  </AppText>
                  <AppText tone="secondary" variant="caption">
                    {composer?.availableCapacitySummary}
                  </AppText>
                </Surface>
                <Surface tone="sunken" className="gap-3 mb-0">
                  <AppText variant="section">Early milestones</AppText>
                  {composer?.firstMilestonePath.slice(0, 3).map((milestone) => (
                    <View key={milestone.title} className="gap-1">
                      <AppText variant="caption">{milestone.title}</AppText>
                      <AppText tone="secondary" variant="caption">
                        {milestone.targetDate ? formatShortDate(milestone.targetDate) : "No date yet"}
                      </AppText>
                    </View>
                  ))}
                </Surface>
                <Surface tone="sunken" className="gap-3 mb-0">
                  <AppText variant="section">First moves</AppText>
                  {composer?.firstWeekActionPreview.slice(0, 3).map((task) => (
                    <View key={task.title} className="gap-1">
                      <AppText variant="caption">{task.title}</AppText>
                      <AppText tone="secondary" variant="caption">
                        {task.estimatedMinutes} min
                      </AppText>
                    </View>
                  ))}
                </Surface>
              </View>
            ) : null}

            {stepIndex === 4 ? (
              <View className="gap-4">
                <Surface tone="sunken" className="gap-3 mb-0">
                  <AppText variant="section">{composedInference?.title ?? "New goal"}</AppText>
                  <View className="flex-row flex-wrap gap-2">
                    {targetDate ? <Pill label={formatShortDate(targetDate)} tone="quiet" /> : <Pill label="Flexible date" tone="quiet" />}
                    <Pill label={composer?.paceOptions.find((item) => item.mode === selectedPaceMode)?.label ?? "Balanced"} tone="accent" />
                    {selectedAmbitionId
                      ? <Pill label={ambitions.find((item) => item.id === selectedAmbitionId)?.title ?? "Direction linked"} tone="quiet" />
                      : null}
                  </View>
                  <AppText tone="secondary" variant="caption">
                    {composer?.feasibility.summary ?? "Ready to create."}
                  </AppText>
                </Surface>
                {ambitions.length > 0 ? (
                  <Surface tone="sunken" className="gap-3 mb-0">
                    <AppText variant="section">Direction</AppText>
                    <View className="flex-row flex-wrap gap-2">
                      <Button
                        size="compact"
                        tone={selectedAmbitionId === null ? "secondary" : "tertiary"}
                        onPress={() => setSelectedAmbitionId(null)}
                      >
                        Skip for now
                      </Button>
                      {ambitions.slice(0, 4).map((ambition) => (
                        <Button
                          key={ambition.id}
                          size="compact"
                          tone={selectedAmbitionId === ambition.id ? "secondary" : "tertiary"}
                          onPress={() => setSelectedAmbitionId(ambition.id)}
                        >
                          {ambition.title}
                        </Button>
                      ))}
                    </View>
                  </Surface>
                ) : null}
              </View>
            ) : null}
          </View>
        </Surface>

        <View className="flex-row gap-3">
          <Button
            tone="tertiary"
            style={{ flex: 1 }}
            onPress={() => (stepIndex === 0 ? navigation.goBack() : setStepIndex((current) => current - 1))}
          >
            {stepIndex === 0 ? "Cancel" : "Back"}
          </Button>
          {stepIndex < createSteps.length - 1 ? (
            <Button
              style={{ flex: 1 }}
              disabled={!canAdvance()}
              onPress={() => setStepIndex((current) => current + 1)}
            >
              Next
            </Button>
          ) : (
            <Button style={{ flex: 1 }} busy={busy} disabled={!canAdvance()} onPress={() => void handleCreate()}>
              Create goal
            </Button>
          )}
        </View>

        {runtimeMessage ? (
          <AppText tone="secondary" variant="caption">
            {runtimeMessage}
          </AppText>
        ) : null}
      </View>
    </Screen>
  );
}

function ProgressDots({ currentIndex }: { currentIndex: number }) {
  return (
    <View className="flex-row gap-2">
      {createSteps.map((step, index) => (
        <View
          key={step}
          style={{
            flex: 1,
            height: 6,
            borderRadius: 999,
            backgroundColor: index <= currentIndex ? "#C6A06B" : "rgba(198,160,107,0.16)",
          }}
        />
      ))}
    </View>
  );
}
