import { Platform } from "react-native";

export const unsupportedNotificationPermissionStatus = "unsupported";

export function isWebRuntime() {
  return Platform.OS === "web";
}

export function supportsNativeDatabase() {
  return !isWebRuntime();
}

export function supportsCalendarIntegration() {
  return Platform.OS === "ios" || Platform.OS === "android";
}

export function supportsNotifications() {
  return Platform.OS === "ios" || Platform.OS === "android";
}

export function getUnsupportedRuntimeMessage() {
  return "Ambitions is currently validated for native iPhone and Android testing only. This web build is intentionally gated because the shipped app depends on native SQLite and native device integrations that are not part of the launch path.";
}

export function getUnsupportedDatabaseMessage() {
  return "The local SQLite layer is not available in this runtime. Use a native iPhone or Android build for release validation.";
}

export function getUnsupportedCalendarMessage() {
  return "Calendar access is only available in native iPhone and Android builds.";
}

export function getUnsupportedNotificationsMessage() {
  return "Reminders are only available in native iPhone and Android builds.";
}
