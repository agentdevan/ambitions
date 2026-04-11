import { View } from "react-native";

import { UnscheduledTask } from "../../engines";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface UnscheduledTasksPanelProps {
  tasks: UnscheduledTask[];
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
          <View key={task.taskId} className="gap-1">
            <AppText variant="section">{task.title}</AppText>
            <AppText tone="tertiary" variant="caption">
              {task.estimatedMinutes} min
            </AppText>
            <AppText tone="secondary">{task.reason}</AppText>
          </View>
        ))}
      </View>
    </Surface>
  );
}
