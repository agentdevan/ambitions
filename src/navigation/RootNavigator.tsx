import { Ionicons } from "@expo/vector-icons";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";

import { useResolvedTheme } from "../design/theme/useResolvedTheme";
import { GoalsScreen } from "../screens/goals/GoalsScreen";
import { InsightsScreen } from "../screens/insights/InsightsScreen";
import { OnboardingScreen } from "../screens/onboarding/OnboardingScreen";
import { PlanScreen } from "../screens/plan/PlanScreen";
import { TodayScreen } from "../screens/today/TodayScreen";
import { useAppStore } from "../state/useAppStore";
import { RootTabParamList } from "./types";

const Tab = createBottomTabNavigator<RootTabParamList>();

const iconMap: Record<keyof RootTabParamList, keyof typeof Ionicons.glyphMap> = {
  Today: "today-outline",
  Goals: "flag-outline",
  Plan: "layers-outline",
  Insights: "analytics-outline",
};

export function RootNavigator() {
  const theme = useResolvedTheme();
  const onboardingCompleted = useAppStore(
    (state) => state.productPreferences?.onboardingCompleted ?? false,
  );

  if (!onboardingCompleted) {
    return <OnboardingScreen />;
  }

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarActiveTintColor: theme.colors.text.primary,
        tabBarInactiveTintColor: theme.colors.text.tertiary,
        tabBarActiveBackgroundColor: theme.colors.background.sunken,
        tabBarStyle: {
          backgroundColor: theme.colors.background.elevated,
          borderTopColor: theme.colors.border.subtle,
          borderTopWidth: 1,
          height: 84,
          paddingTop: 10,
          paddingBottom: 16,
        },
        tabBarItemStyle: {
          marginHorizontal: 6,
          marginVertical: 6,
          borderRadius: 18,
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
          backgroundColor: theme.colors.background.canvas,
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
