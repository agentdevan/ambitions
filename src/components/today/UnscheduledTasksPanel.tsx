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
        <AppText tone="secondary" variant="caption">
          Left Unscheduled
        </AppText>
        <AppText variant="section">Held out to keep the day executable</AppText>
      </View>

      <View className="gap-4">
        {tasks.map((task) => (
          <View key={task.taskId} className="gap-2">
            <AppText variant="section">{task.title}</AppText>
            <View className="flex-row flex-wrap gap-2">
              <Pill label={task.status.replaceAll("_", " ")} />
              <Pill label={`${task.estimatedMinutes} min`} />
            </View>
            <AppText tone="secondary">{task.reason}</AppText>
          </View>
        ))}
      </View>
    </Surface>
  );
}
