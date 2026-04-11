import { useMemo, useState } from "react";
import { Pressable, TextInput, View } from "react-native";

import { Button } from "../../components/ui/Button";
import { Pill } from "../../components/ui/Pill";
import { Screen } from "../../components/ui/Screen";
import { Surface } from "../../components/ui/Surface";
import { AppText } from "../../components/ui/Text";
import { DomainKey } from "../../domain/models";
import { inferGoalDraft } from "../../product/goalIntake";
import { ThemePresetKey } from "../../product/types";
import { themePresets } from "../../product/theme";
import { useAppStore } from "../../state/useAppStore";

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
        {props.options.map((option) => {
          const selected = option.key === props.value;
          return (
            <Pressable
              key={option.key}
              className="rounded-full border px-4 py-3"
              onPress={() => props.onChange(option.key)}
              style={{
                backgroundColor: selected ? "#18181A" : "#F8F6F1",
                borderColor: selected ? "#18181A" : "#DDD8D0",
              }}
            >
              <AppText tone={selected ? "inverse" : "secondary"} variant="caption">
                {option.label}
              </AppText>
            </Pressable>
          );
        })}
      </View>
    </View>
  );
}

function Field(props: {
  label: string;
  value: string;
  onChangeText: (value: string) => void;
  placeholder?: string;
  multiline?: boolean;
}) {
  return (
    <View className="gap-2">
      <AppText variant="caption" tone="secondary">
        {props.label}
      </AppText>
      <TextInput
        multiline={props.multiline}
        onChangeText={props.onChangeText}
        placeholder={props.placeholder}
        placeholderTextColor="#8A8680"
        style={{
          minHeight: props.multiline ? 108 : 52,
          borderRadius: 22,
          borderWidth: 1,
          borderColor: "#DDD8D0",
          backgroundColor: "#F8F6F1",
          paddingHorizontal: 16,
          paddingVertical: props.multiline ? 16 : 14,
          color: "#18181A",
          fontSize: 15,
          lineHeight: 21,
        }}
        value={props.value}
      />
    </View>
  );
}

export function OnboardingScreen() {
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
    `${current?.schedule.sleepStart ?? "23:00"}-${current?.schedule.sleepEnd ?? "07:00"}`,
  );
  const [prepMinutes, setPrepMinutes] = useState(
    String(current?.schedule.morningPrepMinutes ?? 30),
  );
  const [workStart, setWorkStart] = useState(current?.schedule.workdayStart ?? "09:00");
  const [workEnd, setWorkEnd] = useState(current?.schedule.workdayEnd ?? "17:00");
  const [commuteMinutes, setCommuteMinutes] = useState(
    String(current?.schedule.commuteMinutes ?? 20),
  );
  const [taskSizing, setTaskSizing] = useState(current?.taskSizing ?? "mixed");
  const [dayIntensity, setDayIntensity] = useState(current?.dayIntensity ?? "balanced");
  const [themePreset, setThemePreset] = useState<ThemePresetKey>(
    current?.themePreset ?? "neutral",
  );
  const [focusDomains, setFocusDomains] = useState<DomainKey[]>(
    current?.focusDomains ?? [DomainKey.Career, DomainKey.Personal],
  );

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

  const handleGenerate = async () => {
    if (!inferredGoal) {
      return;
    }

    const [sleepStart, sleepEnd] = sleepWindow.includes("-")
      ? sleepWindow.split("-")
      : ["23:00", "07:00"];

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
        themePreset,
        schedule: {
          sleepStart,
          sleepEnd,
          morningPrepMinutes: Number(prepMinutes) || 30,
          workdayStart: workStart,
          workdayEnd: workEnd,
          workdays: [1, 2, 3, 4, 5],
          commuteMinutes: Number(commuteMinutes) || 0,
        },
      },
    });
  };

  return (
    <Screen>
      <View className="gap-6">
        <View className="gap-2 pt-4">
          <Pill label="Ambitions" />
          <AppText variant="hero">Set the defaults once. Start with one real goal.</AppText>
          <AppText tone="secondary">
            This keeps the first plan believable without turning setup into a project.
          </AppText>
        </View>

        <Surface>
          <View className="gap-4">
            <AppText variant="section">A few day-shape defaults</AppText>
            <View className="flex-row gap-3">
              <View className="flex-1">
                <Field
                  label="Sleep window"
                  value={sleepWindow}
                  onChangeText={setSleepWindow}
                  placeholder="23:00-07:00"
                />
              </View>
              <View className="w-28">
                <Field
                  label="Prep minutes"
                  value={prepMinutes}
                  onChangeText={setPrepMinutes}
                  placeholder="30"
                />
              </View>
            </View>
            <View className="flex-row gap-3">
              <View className="flex-1">
                <Field
                  label="Work starts"
                  value={workStart}
                  onChangeText={setWorkStart}
                  placeholder="09:00"
                />
              </View>
              <View className="flex-1">
                <Field
                  label="Work ends"
                  value={workEnd}
                  onChangeText={setWorkEnd}
                  placeholder="17:00"
                />
              </View>
              <View className="w-28">
                <Field
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
            <View className="flex-row flex-wrap gap-2">
              {domains.map((domain) => {
                const selected = focusDomains.includes(domain.key);

                return (
                  <Pressable
                    key={domain.id}
                    className="rounded-full border px-4 py-3"
                    onPress={() => toggleDomain(domain.key)}
                    style={{
                      backgroundColor: selected ? "#18181A" : "#F8F6F1",
                      borderColor: selected ? "#18181A" : "#DDD8D0",
                    }}
                  >
                    <AppText tone={selected ? "inverse" : "secondary"} variant="caption">
                      {domain.name}
                    </AppText>
                  </Pressable>
                );
              })}
            </View>
            <Field
              label="First goal"
              value={goalText}
              onChangeText={setGoalText}
              placeholder="Raise my credit score above 720 this year by paying down the worst balances first."
              multiline
            />
            {inferredGoal ? (
              <View className="gap-3 rounded-[24px] border border-[#DED7CB] bg-[#F8F6F1] px-4 py-4">
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
              </View>
            ) : null}
            {inferredGoal ? (
              <>
                <Field
                  label="Goal title"
                  value={goalTitle}
                  onChangeText={setGoalTitle}
                  placeholder={inferredGoal.title}
                />
                <Field
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
                        <Pressable
                          key={`goal-domain-${domain.id}`}
                          className="rounded-full border px-4 py-3"
                          onPress={() => setGoalDomainKey(domain.key)}
                          style={{
                            backgroundColor: selected ? "#18181A" : "#F8F6F1",
                            borderColor: selected ? "#18181A" : "#DDD8D0",
                          }}
                        >
                          <AppText
                            tone={selected ? "inverse" : "secondary"}
                            variant="caption"
                          >
                            {domain.name}
                          </AppText>
                        </Pressable>
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
              <AppText variant="caption" tone="secondary">
                Theme
              </AppText>
              <View className="flex-row flex-wrap gap-2">
                {themePresets.map((preset) => {
                  const selected = preset.id === themePreset;
                  return (
                    <Pressable
                      key={preset.id}
                      className="rounded-[22px] border px-4 py-3"
                      onPress={() => setThemePreset(preset.id)}
                      style={{
                        minWidth: 112,
                        backgroundColor: preset.colors.background.elevated,
                        borderColor: selected
                          ? preset.colors.text.primary
                          : preset.colors.border.subtle,
                      }}
                    >
                      <AppText variant="caption">{preset.label}</AppText>
                      <AppText tone="tertiary" variant="micro">
                        {preset.description}
                      </AppText>
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
            Defaults can be edited later in Settings.
          </AppText>
        </View>
      </View>
    </Screen>
  );
}
