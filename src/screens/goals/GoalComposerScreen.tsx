import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { useEffect, useMemo, useState } from "react";
import { View } from "react-native";

import { DetailSummaryStrip } from "../../components/detail/DetailPrimitives";
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

const createStepDescriptions = [
  "Write the outcome in plain language so Ambitions can shape the right kind of plan.",
  "Set the deadline pressure before the weekly pace gets locked in.",
  "Choose the weekly tempo that feels believable in actual life.",
  "Preview the path, workload, and first moves before you commit.",
  "Confirm the goal, pace, and direction in one final pass.",
] as const;

const createStepPrimaryActions = [
  "Continue to target",
  "Continue to pace",
  "Continue to preview",
  "Continue to review",
  "Create goal",
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

  const stepDescription = createStepDescriptions[stepIndex];
  const primaryActionLabel = createStepPrimaryActions[stepIndex];
  const nextStepName = createSteps[Math.min(stepIndex + 1, createSteps.length - 1)];
  const selectedPaceLabel =
    composer?.paceOptions.find((item) => item.mode === selectedPaceMode)?.label ?? "Balanced";

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
          description={stepDescription}
          action={
            <View className="flex-row flex-wrap items-center gap-2">
              <Pill label={`Step ${stepIndex + 1} of ${createSteps.length}`} tone="accent" />
              {stepIndex < createSteps.length - 1 ? (
                <Pill label={`Next: ${nextStepName}`} tone="quiet" />
              ) : (
                <Pill label="Final step" tone="quiet" />
              )}
            </View>
          }
        />

        <Surface tone="hero" className="gap-4">
          <ProgressDots currentIndex={stepIndex} />
          <DetailSummaryStrip
            items={[
              {
                label: "Goal",
                value: composedInference?.title ?? "Not framed yet",
                detail: baseInput.length > 0 ? "The setup is following your draft." : "Start with one clear outcome.",
              },
              {
                label: "Target",
                value: targetDate ? formatShortDate(targetDate) : "Flexible",
                detail: stepIndex < 1 ? "You can leave this open until the next step." : "This date shapes workload and confidence.",
              },
              {
                label: "Pace",
                value: selectedPaceLabel,
                detail: composer ? "You can still adjust the pace before creation." : "Pace options appear after the goal is framed.",
              },
              {
                label: "Direction",
                value:
                  selectedAmbitionId
                    ? ambitions.find((item) => item.id === selectedAmbitionId)?.title ?? "Linked"
                    : "Optional",
                detail: "Direction stays optional until the review step.",
              },
            ]}
          />
        </Surface>

        <Surface className="gap-5">
          <View className="gap-2">
            <AppText variant="section">{createSteps[stepIndex]}</AppText>
            <AppText tone="secondary">{stepDescription}</AppText>
          </View>

          {stepIndex === 0 ? (
            <View className="gap-4">
              <Surface tone="sunken" className="gap-3 mb-0">
                <AppText variant="section">Start with one sentence</AppText>
                <AppText tone="secondary" variant="caption">
                  Make the outcome concrete. The title can stay automatic if you want the fastest path through setup.
                </AppText>
              </Surface>
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
              {inferredDraft ? (
                <DetailSummaryStrip
                  items={[
                    {
                      label: "Read",
                      value: inferredDraft.title,
                      detail: inferredDraft.naturalLanguage,
                    },
                    {
                      label: "Type",
                      value: inferredDraft.type.replaceAll("_", " "),
                      detail: inferredDraft.domainKey.replaceAll("_", " "),
                    },
                  ]}
                />
              ) : null}
            </View>
          ) : null}

          {stepIndex === 1 ? (
            <View className="gap-4">
              <Surface tone="sunken" className="gap-3 mb-0">
                <AppText variant="section">Set the pressure, not perfection</AppText>
                <AppText tone="secondary" variant="caption">
                  Leave the date open if you want to see the work shape before you commit to a deadline.
                </AppText>
              </Surface>
              <TextField
                label="Target date"
                onChangeText={setTargetDate}
                placeholder="YYYY-MM-DD or leave blank"
                supportingText="Leave it open if you want to shape the goal first."
                value={targetDate}
              />
              <View className="flex-row flex-wrap gap-2">
                <Button size="compact" tone="secondary" onPress={() => setTargetDate(addDays(planDate, 30))}>
                  +30 days
                </Button>
                <Button size="compact" tone="secondary" onPress={() => setTargetDate(addDays(planDate, 90))}>
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
              <Surface tone="sunken" className="gap-3 mb-0">
                <AppText variant="section">Choose the tempo</AppText>
                <AppText tone="secondary" variant="caption">
                  The recommended pace stays highlighted, but you can choose the one that feels most believable.
                </AppText>
              </Surface>
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
              <DetailSummaryStrip
                items={[
                  {
                    label: "Workload",
                    value: composer?.workloadEstimateLabel ?? "Building preview",
                    detail: composer?.interpretation.workPattern ?? "The goal is being translated into real work.",
                  },
                  {
                    label: "Capacity",
                    value: composer?.availableCapacitySummary ?? "Checking room",
                    detail: composer?.commitmentsSummary ?? "Available room is being checked against commitments.",
                  },
                ]}
              />
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
                  <Pill label={selectedPaceLabel} tone="accent" />
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
                  <View className="gap-1">
                    <AppText variant="section">Direction</AppText>
                    <AppText tone="secondary" variant="caption">
                      Link the goal to a larger direction if you want it to roll up in the portfolio.
                    </AppText>
                  </View>
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
        </Surface>

        <Surface tone="accent" className="gap-4">
          <View className="gap-1">
            <AppText variant="section">
              {stepIndex < createSteps.length - 1
                ? `Ready to ${nextStepName.toLowerCase()}?`
                : "Ready to create this goal?"}
            </AppText>
            <AppText tone="secondary" variant="caption">
              {stepIndex < createSteps.length - 1
                ? "The forward action stays dominant on every non-terminal step so the flow never dead-ends."
                : "Creating the goal generates the first plan path and drops you into the detail view."}
            </AppText>
          </View>
          <View className="flex-row gap-3">
            <Button
              tone="tertiary"
              style={{ width: 124 }}
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
                {primaryActionLabel}
              </Button>
            ) : (
              <Button style={{ flex: 1 }} busy={busy} disabled={!canAdvance()} onPress={() => void handleCreate()}>
                {primaryActionLabel}
              </Button>
            )}
          </View>
          {runtimeMessage ? (
            <AppText tone="secondary" variant="caption">
              {runtimeMessage}
            </AppText>
          ) : null}
        </Surface>
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
            height: 8,
            borderRadius: 999,
            backgroundColor: index <= currentIndex ? "#C6A06B" : "rgba(198,160,107,0.18)",
          }}
        />
      ))}
    </View>
  );
}
