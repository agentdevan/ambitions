import { View } from "react-native";

import { TodayRecoveryTask } from "../../state/viewModels/today";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface UnscheduledTasksPanelProps {
  tasks: TodayRecoveryTask[];
}

export function UnscheduledTasksPanel({ tasks }: UnscheduledTasksPanelProps) {
  if (tasks.length === 0) {
    return null;
  }

  return (
    <Surface className="gap-5">
      <View className="gap-2">
        <AppText tone="secondary" variant="micro" style={{ textTransform: "uppercase" }}>
          Left Unscheduled
        </AppText>
        <AppText variant="section">Held out to keep the day executable</AppText>
      </View>

      <View className="gap-4">
        {tasks.map((task) => (
          <Surface key={task.taskId} className="gap-3" tone="sunken">
            <View className="flex-row flex-wrap gap-2">
              <Pill label={task.status.replaceAll("_", " ")} />
              <Pill label={`${task.estimatedMinutes} min`} tone="quiet" />
            </View>
            <AppText variant="section">{task.title}</AppText>
            <AppText tone="secondary">{task.reason}</AppText>
          </Surface>
        ))}
      </View>
    </Surface>
  );
}
