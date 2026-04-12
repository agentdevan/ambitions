import { View } from "react-native";

import {
  AccountIdentity,
  AuthStateSnapshot,
  LocalAttachmentState,
  LocalAttachmentStatus,
  SyncConflictRecord,
  SyncStateSnapshot,
} from "../../domain/models";
import { Button } from "../ui/Button";
import { Pill } from "../ui/Pill";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface AccountStatusCardProps {
  account: AccountIdentity | null;
  authState: AuthStateSnapshot | null;
  attachmentState: LocalAttachmentState | null;
  syncState: SyncStateSnapshot | null;
  conflicts: SyncConflictRecord[];
  busyAction?: "sign_in" | "attach" | "sync" | "defer" | null;
  onSignIn: () => void;
  onAttach: () => void;
  onDefer: () => void;
  onSync: () => void;
}

export function AccountStatusCard({
  account,
  authState,
  attachmentState,
  syncState,
  conflicts,
  busyAction,
  onSignIn,
  onAttach,
  onDefer,
  onSync,
}: AccountStatusCardProps) {
  const hasAccount = !!account;
  const requiresAttachment =
    attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired;

  return (
    <Surface tone={requiresAttachment ? "accent" : "default"}>
      <View className="gap-5">
        <View className="gap-3">
          <View className="flex-row flex-wrap gap-2">
            <Pill
              label={hasAccount ? "Signed in" : "Local only"}
              tone={hasAccount ? "accent" : "neutral"}
            />
            {syncState ? <Pill label={syncState.mode.replace("_", " ")} tone="quiet" /> : null}
            {conflicts.length > 0 ? <Pill label={`${conflicts.length} items to review`} /> : null}
          </View>
          <AppText variant="section">Account and sync</AppText>
          <AppText tone="secondary">
            {hasAccount
              ? "Keep your core Ambitions data available across devices without turning the app into an account product."
              : "Stay local if you want. Add an account when backup and cross-device continuity become useful."}
          </AppText>
        </View>

        {account ? (
          <View
            className="gap-1 rounded-[24px] px-4 py-4"
            style={{ backgroundColor: "#FFFFFF66" }}
          >
            <AppText>{account.displayName ?? account.email ?? "Apple account"}</AppText>
            <AppText tone="tertiary" variant="caption">
              {syncState?.lastSyncAt
                ? `Last sync ${syncState.lastSyncAt}`
                : "Sync has not run yet."}
            </AppText>
          </View>
        ) : null}

        {authState?.lastError ? (
          <AppText tone="tertiary" variant="caption">
            {authState.lastError}
          </AppText>
        ) : null}

        {requiresAttachment ? (
          <View className="gap-4">
            <View className="gap-2">
              <AppText>
                Attach this device&apos;s Ambitions data to the signed-in account?
              </AppText>
              <AppText tone="secondary" variant="caption">
                Existing goals, milestones, tasks, daily plans, preferences, and adaptation profile
                will stay on this device and become the baseline for sync. Nothing is overwritten
                silently.
              </AppText>
            </View>
            <View className="flex-row gap-3">
              <Button style={{ flex: 1 }} busy={busyAction === "attach"} onPress={onAttach}>
                Attach data
              </Button>
              <Button
                tone="ghost"
                style={{ flex: 1 }}
                busy={busyAction === "defer"}
                onPress={onDefer}
              >
                Not now
              </Button>
            </View>
          </View>
        ) : hasAccount ? (
          <View className="flex-row gap-3">
            <Button
              tone="secondary"
              style={{ flex: 1 }}
              busy={busyAction === "sync"}
              onPress={onSync}
              disabled={attachmentState?.status !== LocalAttachmentStatus.Attached}
            >
              Sync now
            </Button>
          </View>
        ) : (
          <Button busy={busyAction === "sign_in"} onPress={onSignIn}>
            Add Apple account
          </Button>
        )}
      </View>
    </Surface>
  );
}
