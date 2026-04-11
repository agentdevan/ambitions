import { Ionicons } from "@expo/vector-icons";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";

import { appTheme } from "../design/theme";
import { GoalsScreen } from "../screens/goals/GoalsScreen";
import { InsightsScreen } from "../screens/insights/InsightsScreen";
import { PlanScreen } from "../screens/plan/PlanScreen";
import { TodayScreen } from "../screens/today/TodayScreen";
import { RootTabParamList } from "./types";

const Tab = createBottomTabNavigator<RootTabParamList>();

const iconMap: Record<keyof RootTabParamList, keyof typeof Ionicons.glyphMap> = {
  Today: "sparkles-outline",
  Goals: "flag-outline",
  Plan: "calendar-outline",
  Insights: "pulse-outline",
};

export function RootNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: appTheme.colors.text.primary,
        tabBarInactiveTintColor: appTheme.colors.text.tertiary,
        tabBarStyle: {
          backgroundColor: appTheme.colors.background.elevated,
          borderTopColor: appTheme.colors.border.subtle,
          height: 86,
          paddingTop: 12,
          paddingBottom: 18,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: "600",
          letterSpacing: 0.2,
        },
        tabBarIcon: ({ color, size }) => (
          <Ionicons color={color} name={iconMap[route.name]} size={size} />
        ),
        sceneStyle: {
          backgroundColor: appTheme.colors.background.canvas,
        },
      })}
    >
      <Tab.Screen name="Today" component={TodayScreen} />
      <Tab.Screen name="Goals" component={GoalsScreen} />
      <Tab.Screen name="Plan" component={PlanScreen} />
      <Tab.Screen name="Insights" component={InsightsScreen} />
    </Tab.Navigator>
  );
}
