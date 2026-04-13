import { useSyncExternalStore } from "react";
import { AccessibilityInfo } from "react-native";

interface AccessibilityPreferences {
  reduceMotionEnabled: boolean;
}

let reduceMotionEnabled = false;
let nativeSubscription: { remove: () => void } | null = null;
const listeners = new Set<() => void>();

function emit() {
  listeners.forEach((listener) => listener());
}

function updateReduceMotion(nextValue: boolean) {
  if (reduceMotionEnabled === nextValue) {
    return;
  }

  reduceMotionEnabled = nextValue;
  emit();
}

function ensureSubscription() {
  if (nativeSubscription) {
    return;
  }

  AccessibilityInfo.isReduceMotionEnabled()
    .then(updateReduceMotion)
    .catch(() => null);

  nativeSubscription = AccessibilityInfo.addEventListener(
    "reduceMotionChanged",
    updateReduceMotion,
  );
}

function subscribe(listener: () => void) {
  ensureSubscription();
  listeners.add(listener);

  return () => {
    listeners.delete(listener);

    if (listeners.size === 0 && nativeSubscription) {
      nativeSubscription.remove();
      nativeSubscription = null;
    }
  };
}

function getSnapshot() {
  return reduceMotionEnabled;
}

export function useAccessibilityPreferences(): AccessibilityPreferences {
  const motionPreference = useSyncExternalStore(subscribe, getSnapshot, () => false);

  return {
    reduceMotionEnabled: motionPreference,
  };
}
