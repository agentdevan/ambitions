import { useMemo, useState } from "react";
import { Pressable, View } from "react-native";

import { Button } from "../../components/ui/Button";
import { EmptyStateCard } from "../../components/ui/EmptyStateCard";
import { OptionChip } from "../../components/ui/OptionChip";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { TextField } from "../../components/ui/TextField";
import { AppText } from "../../components/ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { DomainKey } from "../../domain/models";
import { inferGoalDraft } from "../../product/goalIntake";
import { accentThemeOptions, appearanceModeOptions } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";
import { formatTimeLabel, formatTimeRangeLabel, normalizeTimeString } from "../../utils/date";

const taskSizingOptions = [
  { key: "smaller", label: "Smaller tasks" },
  { key: "mixed", label: "Mixed" },
  { key: "bigger", label: "Fewer bigger tasks" },
] as const;

const intensityOptions = [
  { key: "light", label: "Light" },
  { key: "balanced", label: "Balanced" },
  { key: "ambitious", label: "Ambitious" },
] as const;

function ChoiceRow<T extends string>(props: {
  label: string;
  options: ReadonlyArray<{ key: T; label: string }>;
  value: T;
  onChange: (value: T) => void;
}) {
  return (
    <View className="gap-3">
      <AppText variant="caption" tone="secondary">
        {props.label}
      </AppText>
      <View className="flex-row flex-wrap gap-2">
        {props.options.map((option) => (
          <OptionChip
            key={option.key}
            selected={option.key === props.value}
            onPress={() => props.onChange(option.key)}
          >
            {option.label}
          </OptionChip>
        ))}
      </View>
    </View>
  );
}

export function OnboardingScreen() {
  const theme = useResolvedTheme();
  const domains = useAppStore((state) => state.domains);
  const current = useAppStore((state) => state.productPreferences);
  const onboardingBusy = useAppStore((state) => state.onboardingBusy);
  const createFirstPlan = useAppStore((state) => state.createFirstPlan);
  const planDate = useAppStore((state) => state.planDate);
  const [goalText, setGoalText] = useState("");
  const [goalTitle, setGoalTitle] = useState("");
  const [goalTargetDate, setGoalTargetDate] = useState("");
  const [goalDomainKey, setGoalDomainKey] = useState<DomainKey | null>(null);
  const [sleepWindow, setSleepWindow] = useState(
    formatTimeRangeLabel(
      current?.schedule.sleepStart ?? "23:00",
      current?.schedule.sleepEnd ?? "07:00",
    ),
  );
  const [prepMinutes, setPrepMinutes] = useState(
    String(current?.schedule.morningPrepMinutes ?? 30),
  );
  const [workStart, setWorkStart] = useState(
    formatTimeLabel(current?.schedule.workdayStart ?? "09:00"),
  );
  const [workEnd, setWorkEnd] = useState(
    formatTimeLabel(current?.schedule.workdayEnd ?? "17:00"),
  );
  const [commuteMinutes, setCommuteMinutes] = useState(
    String(current?.schedule.commuteMinutes ?? 20),
  );
  const [taskSizing, setTaskSizing] = useState(current?.taskSizing ?? "mixed");
  const [dayIntensity, setDayIntensity] = useState(current?.dayIntensity ?? "balanced");
  const [appearanceMode, setAppearanceMode] = useState(current?.appearanceMode ?? "system");
  const [accentTheme, setAccentTheme] = useState(current?.accentTheme ?? "gold");
  const [focusDomains, setFocusDomains] = useState<DomainKey[]>(
    current?.focusDomains ?? [DomainKey.Career, DomainKey.Personal],
  );
  const [runtimeMessage, setRuntimeMessage] = useState<string | null>(null);

  const inferredGoal = useMemo(
    () => (goalText.trim().length > 0 ? inferGoalDraft(goalText, planDate) : null),
    [goalText, planDate],
  );
  const resolvedGoalDomain = goalDomainKey ?? inferredGoal?.domainKey ?? focusDomains[0];

  const toggleDomain = (domainKey: DomainKey) => {
    setFocusDomains((existing) =>
      existing.includes(domainKey)
        ? existing.filter((entry) => entry !== domainKey)
        : [...existing.slice(-1), domainKey],
    );
  };

  async function handleGenerate() {
    if (!inferredGoal) {
      return;
    }

    setRuntimeMessage(null);
    const [rawSleepStart, rawSleepEnd] = sleepWindow.includes("-")
      ? sleepWindow.split(/\s*-\s*/)
      : ["11:00 PM", "7:00 AM"];
    const sleepStart = normalizeTimeString(rawSleepStart) ?? "23:00";
    const sleepEnd = normalizeTimeString(rawSleepEnd) ?? "07:00";

    try {
      await createFirstPlan({
        inference: {
          ...inferredGoal,
          title: goalTitle.trim() || inferredGoal.title,
          targetDate: goalTargetDate.trim() || inferredGoal.targetDate,
          domainKey: resolvedGoalDomain,
          focusDomains,
        },
        productPreferences: {
          onboardingCompleted: true,
          focusDomains,
          taskSizing,
          dayIntensity,
          adaptivePlanningEnabled: true,
          defaultUnfinishedWorkBehavior: "ask_each_time",
          weeklyReviewDay: 0,
          weeklyReviewTime: "16:30",
          autoPromptNextWeekShaping: true,
          defaultWeeklyCarryoverBehavior: "review_first",
          appearanceMode,
          accentTheme,
          schedule: {
            sleepStart,
            sleepEnd,
            morningPrepMinutes: Number(prepMinutes) || 30,
            workdayStart: normalizeTimeString(workStart) ?? "09:00",
            workdayEnd: normalizeTimeString(workEnd) ?? "17:00",
            workdays: [1, 2, 3, 4, 5],
            commuteMinutes: Number(commuteMinutes) || 0,
          },
        },
      });
    } catch (error) {
      setRuntimeMessage(
        error instanceof Error ? error.message : "The first plan could not be generated.",
      );
    }
  }

  if (domains.length === 0) {
    return (
      <Screen>
        <EmptyStateCard
          eyebrow="Ambitions"
          title="Preparing onboarding"
          body="The local setup defaults are still loading. Reopen onboarding in a moment."
        />
      </Screen>
    );
  }

  return (
    <Screen>
      <View className="gap-6">
        <View className="gap-2 pt-4">
          <Pill label="Ambitions" />
          <AppText variant="hero">Set the defaults once. Start with one real goal.</AppText>
          <AppText tone="secondary">
            A small amount of setup gives the first plan believable constraints without turning
            onboarding into work.
          </AppText>
        </View>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">A few day-shape defaults</AppText>
            <AppText tone="secondary">
              These defaults anchor the schedule so the first day feels realistic on arrival.
            </AppText>
            <View className="flex-row gap-3">
              <View style={{ flex: 1 }}>
                <TextField
                  label="Sleep window"
                  value={sleepWindow}
                  onChangeText={setSleepWindow}
                  placeholder="11:00 PM - 7:00 AM"
                />
              </View>
              <View style={{ width: 112 }}>
                <TextField
                  label="Prep"
                  value={prepMinutes}
                  onChangeText={setPrepMinutes}
                  placeholder="30"
                />
              </View>
            </View>
            <View className="flex-row gap-3">
              <View style={{ flex: 1 }}>
                <TextField
                  label="Work starts"
                  value={workStart}
                  onChangeText={setWorkStart}
                  placeholder="9:00 AM"
                />
              </View>
              <View style={{ flex: 1 }}>
                <TextField
                  label="Work ends"
                  value={workEnd}
                  onChangeText={setWorkEnd}
                  placeholder="5:00 PM"
                />
              </View>
              <View style={{ width: 112 }}>
                <TextField
                  label="Commute"
                  value={commuteMinutes}
                  onChangeText={setCommuteMinutes}
                  placeholder="20"
                />
              </View>
            </View>
          </View>
        </Surface>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">What matters first</AppText>
            <AppText tone="secondary">
              Pick the domains you want Ambitions to protect first, then describe the first real
              outcome you want to move.
            </AppText>
            <View className="flex-row flex-wrap gap-2">
              {domains.map((domain) => {
                const selected = focusDomains.includes(domain.key);

                return (
                  <OptionChip
                    key={domain.id}
                    selected={selected}
                    onPress={() => toggleDomain(domain.key)}
                  >
                    {domain.name}
                  </OptionChip>
                );
              })}
            </View>
            <TextField
              label="First goal"
              value={goalText}
              onChangeText={setGoalText}
              placeholder="Raise my credit score above 720 this year by paying down the worst balances first."
              multiline
            />
            {inferredGoal ? (
              <Surface tone="sunken" className="gap-3">
                <AppText variant="caption" tone="secondary">
                  What Ambitions is likely using
                </AppText>
                <View className="flex-row flex-wrap gap-2">
                  <Pill label={resolvedGoalDomain.replace("_", " ")} tone="accent" />
                  <Pill label={inferredGoal.type} />
                  <Pill label={inferredGoal.horizon} />
                  {goalTargetDate || inferredGoal.targetDate ? (
                    <Pill label={goalTargetDate || inferredGoal.targetDate || ""} />
                  ) : null}
                </View>
              </Surface>
            ) : null}
            {inferredGoal ? (
              <>
                <TextField
                  label="Goal title"
                  value={goalTitle}
                  onChangeText={setGoalTitle}
                  placeholder={inferredGoal.title}
                />
                <TextField
                  label="Target date"
                  value={goalTargetDate}
                  onChangeText={setGoalTargetDate}
                  placeholder={inferredGoal.targetDate ?? "Optional"}
                />
                <View className="gap-2">
                  <AppText variant="caption" tone="secondary">
                    Goal domain
                  </AppText>
                  <View className="flex-row flex-wrap gap-2">
                    {domains.map((domain) => {
                      const selected = domain.key === resolvedGoalDomain;
                      return (
                        <OptionChip
                          key={`goal-domain-${domain.id}`}
                          selected={selected}
                          onPress={() => setGoalDomainKey(domain.key)}
                        >
                          {domain.name}
                        </OptionChip>
                      );
                    })}
                  </View>
                </View>
              </>
            ) : null}
          </View>
        </Surface>

        <Surface>
          <View className="gap-5">
            <AppText variant="section">Planning feel</AppText>
            <AppText tone="secondary">
              Choose the default pacing and visual tone you want to start with. Everything here can
              be changed later.
            </AppText>
            <ChoiceRow
              label="Task size"
              options={taskSizingOptions}
              value={taskSizing}
              onChange={setTaskSizing}
            />
            <ChoiceRow
              label="Day intensity"
              options={intensityOptions}
              value={dayIntensity}
              onChange={setDayIntensity}
            />
            <View className="gap-3">
              <ChoiceRow
                label="Mode"
                options={appearanceModeOptions.map((option) => ({
                  key: option.id,
                  label: option.label,
                }))}
                value={appearanceMode}
                onChange={setAppearanceMode}
              />
              <View className="flex-row flex-wrap gap-2">
                {accentThemeOptions.map((accent) => {
                  const selected = accent.id === accentTheme;
                  return (
                    <Pressable
                      key={accent.id}
                      className="rounded-[24px]"
                      onPress={() => setAccentTheme(accent.id)}
                      style={({ pressed }) => ({
                        minWidth: 132,
                        opacity: pressed ? 0.84 : 1,
                      })}
                    >
                      <Surface
                        tone="default"
                        className="gap-2"
                        style={{
                          minWidth: 132,
                          borderColor: selected ? theme.colors.border.accent : theme.colors.border.subtle,
                        }}
                      >
                        <View className="flex-row flex-wrap gap-2">
                          {selected ? <Pill label="Selected" tone="accent" /> : null}
                          <Pill label={accent.label} />
                        </View>
                        <View className="flex-row gap-2">
                          {accent.preview.map((color) => (
                            <View
                              key={color}
                              style={{
                                width: 18,
                                height: 18,
                                borderRadius: 999,
                                backgroundColor: color,
                                borderWidth: 1,
                                borderColor: "rgba(0,0,0,0.06)",
                              }}
                            />
                          ))}
                        </View>
                        <AppText tone="secondary" variant="caption">
                          {accent.description}
                        </AppText>
                      </Surface>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          </View>
        </Surface>

        <View className="gap-3 pb-4">
          <Button busy={onboardingBusy} onPress={handleGenerate} disabled={!inferredGoal}>
            Generate the first plan
          </Button>
          <AppText tone="tertiary" variant="caption" style={{ textAlign: "center" }}>
            Defaults can be edited later in Profile.
          </AppText>
          <AppText tone="tertiary" variant="caption" style={{ textAlign: "center" }}>
            Accounts stay optional at first. Add one later when backup or cross-device continuity
            matters.
          </AppText>
          {runtimeMessage ? (
            <AppText tone="tertiary" variant="caption" style={{ textAlign: "center" }}>
              {runtimeMessage}
            </AppText>
          ) : null}
        </View>
      </View>
    </Screen>
  );
}
