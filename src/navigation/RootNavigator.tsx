import { Ionicons } from "@expo/vector-icons";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { createNativeStackNavigator } from "@react-navigation/native-stack";

import { useResolvedTheme } from "../design/theme/useResolvedTheme";
import { GoalsScreen } from "../screens/goals/GoalsScreen";
import {
  GoalDetailScreen,
  GoalEditScreen,
  GoalHistoryScreen,
  GoalMilestonesScreen,
  GoalProgressScreen,
} from "../screens/goals/GoalDetailScreens";
import { InsightsScreen } from "../screens/insights/InsightsScreen";
import {
  InsightActivityScreen,
  InsightCapacityScreen,
  InsightContinuityScreen,
  InsightPlanChangesScreen,
} from "../screens/insights/InsightDetailScreens";
import { OnboardingScreen } from "../screens/onboarding/OnboardingScreen";
import { PlanScreen } from "../screens/plan/PlanScreen";
import {
  PlanDetailScreen,
  PlanReviewScreen,
  PlanStructureScreen,
} from "../screens/plan/PlanDetailScreens";
import { ProfileScreen } from "../screens/profile/ProfileScreen";
import {
  ProfileAccountScreen,
  ProfileAppearanceScreen,
  ProfileHistoryScreen,
  ProfileIntegrationsScreen,
  ProfileNotificationsScreen,
  ProfilePlanningPreferencesScreen,
  ProfileScheduleDefaultsScreen,
} from "../screens/profile/ProfileDetailScreens";
import { TodayScreen } from "../screens/today/TodayScreen";
import {
  TodayCapacityScreen,
  TodayContextScreen,
  TodaySessionDetailScreen,
  TodayTimelineScreen,
} from "../screens/today/TodayDetailScreens";
import { useAppStore } from "../state/useAppStore";
import {
  GoalsStackParamList,
  InsightsStackParamList,
  PlanStackParamList,
  ProfileStackParamList,
  RootTabParamList,
  TodayStackParamList,
} from "./types";

const Tab = createBottomTabNavigator<RootTabParamList>();
const TodayStack = createNativeStackNavigator<TodayStackParamList>();
const GoalsStack = createNativeStackNavigator<GoalsStackParamList>();
const PlanStack = createNativeStackNavigator<PlanStackParamList>();
const InsightsStack = createNativeStackNavigator<InsightsStackParamList>();
const ProfileStack = createNativeStackNavigator<ProfileStackParamList>();

const iconMap: Record<keyof RootTabParamList, keyof typeof Ionicons.glyphMap> = {
  Today: "today-outline",
  Goals: "flag-outline",
  Plan: "layers-outline",
  Insights: "analytics-outline",
  Profile: "person-circle-outline",
};

function useStackOptions() {
  const theme = useResolvedTheme();

  return {
    gestureEnabled: true,
    headerShadowVisible: false,
    headerBackTitleVisible: false,
    headerTintColor: theme.colors.text.primary,
    headerStyle: {
      backgroundColor: theme.colors.background.canvas,
    },
    headerTitleStyle: {
      fontSize: 17,
      fontWeight: "600" as const,
      letterSpacing: -0.2,
    },
    contentStyle: {
      backgroundColor: theme.colors.background.canvas,
    },
  };
}

function TodayNavigator() {
  const stackOptions = useStackOptions();

  return (
    <TodayStack.Navigator screenOptions={stackOptions}>
      <TodayStack.Screen
        name="TodayHome"
        component={TodayScreen}
        options={{ headerShown: false }}
      />
      <TodayStack.Screen
        name="TodayTimeline"
        component={TodayTimelineScreen}
        options={{ title: "Timeline" }}
      />
      <TodayStack.Screen
        name="TodaySessionDetail"
        component={TodaySessionDetailScreen}
        options={{ title: "Session" }}
      />
      <TodayStack.Screen
        name="TodayCapacity"
        component={TodayCapacityScreen}
        options={{ title: "Capacity" }}
      />
      <TodayStack.Screen
        name="TodayContext"
        component={TodayContextScreen}
        options={{ title: "Context" }}
      />
    </TodayStack.Navigator>
  );
}

function GoalsNavigator() {
  const stackOptions = useStackOptions();

  return (
    <GoalsStack.Navigator screenOptions={stackOptions}>
      <GoalsStack.Screen
        name="GoalsHome"
        component={GoalsScreen}
        options={{ headerShown: false }}
      />
      <GoalsStack.Screen
        name="GoalDetail"
        component={GoalDetailScreen}
        options={{ title: "Goal" }}
      />
      <GoalsStack.Screen
        name="GoalMilestones"
        component={GoalMilestonesScreen}
        options={{ title: "Milestones" }}
      />
      <GoalsStack.Screen
        name="GoalProgress"
        component={GoalProgressScreen}
        options={{ title: "Progress" }}
      />
      <GoalsStack.Screen
        name="GoalHistory"
        component={GoalHistoryScreen}
        options={{ title: "History" }}
      />
      <GoalsStack.Screen
        name="GoalEdit"
        component={GoalEditScreen}
        options={({ route }) => ({ title: route.params?.goalId ? "Edit Goal" : "New Goal" })}
      />
    </GoalsStack.Navigator>
  );
}

function PlanNavigator() {
  const stackOptions = useStackOptions();

  return (
    <PlanStack.Navigator screenOptions={stackOptions}>
      <PlanStack.Screen
        name="PlanHome"
        component={PlanScreen}
        options={{ headerShown: false }}
      />
      <PlanStack.Screen
        name="PlanReview"
        component={PlanReviewScreen}
        options={{ title: "Review Changes" }}
      />
      <PlanStack.Screen
        name="PlanDetail"
        component={PlanDetailScreen}
        options={{ title: "Plan Detail" }}
      />
      <PlanStack.Screen
        name="PlanStructure"
        component={PlanStructureScreen}
        options={{ title: "Structure" }}
      />
    </PlanStack.Navigator>
  );
}

function InsightsNavigator() {
  const stackOptions = useStackOptions();

  return (
    <InsightsStack.Navigator screenOptions={stackOptions}>
      <InsightsStack.Screen
        name="InsightsHome"
        component={InsightsScreen}
        options={{ headerShown: false }}
      />
      <InsightsStack.Screen
        name="InsightContinuity"
        component={InsightContinuityScreen}
        options={{ title: "Continuity" }}
      />
      <InsightsStack.Screen
        name="InsightActivity"
        component={InsightActivityScreen}
        options={{ title: "Activity Timeline" }}
      />
      <InsightsStack.Screen
        name="InsightPlanChanges"
        component={InsightPlanChangesScreen}
        options={{ title: "Plan Changes" }}
      />
      <InsightsStack.Screen
        name="InsightCapacity"
        component={InsightCapacityScreen}
        options={{ title: "Capacity & Balance" }}
      />
    </InsightsStack.Navigator>
  );
}

function ProfileNavigator() {
  const stackOptions = useStackOptions();

  return (
    <ProfileStack.Navigator screenOptions={stackOptions}>
      <ProfileStack.Screen
        name="ProfileHome"
        component={ProfileScreen}
        options={{ headerShown: false }}
      />
      <ProfileStack.Screen
        name="ProfileHistory"
        component={ProfileHistoryScreen}
        options={{ title: "Recent Movement" }}
      />
      <ProfileStack.Screen
        name="ProfileAppearance"
        component={ProfileAppearanceScreen}
        options={{ title: "Appearance" }}
      />
      <ProfileStack.Screen
        name="ProfileScheduleDefaults"
        component={ProfileScheduleDefaultsScreen}
        options={{ title: "Schedule Defaults" }}
      />
      <ProfileStack.Screen
        name="ProfileIntegrations"
        component={ProfileIntegrationsScreen}
        options={{ title: "Integrations" }}
      />
      <ProfileStack.Screen
        name="ProfileNotifications"
        component={ProfileNotificationsScreen}
        options={{ title: "Notifications" }}
      />
      <ProfileStack.Screen
        name="ProfilePlanningPreferences"
        component={ProfilePlanningPreferencesScreen}
        options={{ title: "Planning Preferences" }}
      />
      <ProfileStack.Screen
        name="ProfileAccount"
        component={ProfileAccountScreen}
        options={{ title: "Account" }}
      />
    </ProfileStack.Navigator>
  );
}

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
        tabBarHideOnKeyboard: true,
        tabBarStyle: {
          backgroundColor: theme.colors.background.elevated,
          borderTopColor: theme.colors.border.subtle,
          borderTopWidth: 1,
          height: 86,
          paddingTop: 10,
          paddingBottom: 16,
        },
        tabBarItemStyle: {
          marginHorizontal: 6,
          marginVertical: 6,
          borderRadius: 20,
        },
        tabBarLabelStyle: {
          fontSize: 11,
          fontWeight: "700",
          letterSpacing: 0.15,
          marginTop: 2,
        },
        tabBarIcon: ({ color, size, focused }) => (
          <Ionicons
            color={color}
            name={focused ? iconMap[route.name] : iconMap[route.name]}
            size={size}
          />
        ),
        sceneStyle: {
          backgroundColor: theme.colors.background.canvas,
        },
      })}
    >
      <Tab.Screen name="Today" component={TodayNavigator} />
      <Tab.Screen name="Goals" component={GoalsNavigator} />
      <Tab.Screen name="Plan" component={PlanNavigator} />
      <Tab.Screen name="Insights" component={InsightsNavigator} />
      <Tab.Screen name="Profile" component={ProfileNavigator} />
    </Tab.Navigator>
  );
}
