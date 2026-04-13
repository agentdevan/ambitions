import { View } from "react-native";

import {
  AccountIdentity,
  AuthStateSnapshot,
  AuthStatus,
  LocalAttachmentState,
  LocalAttachmentStatus,
  SyncConflictRecord,
  SyncMode,
  SyncStateSnapshot,
} from "../../domain/models";
import { summarizeSyncState } from "../../services/profile/controlSummaries";
import { Button } from "../ui/Button";
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";

interface AccountStatusCardProps {
  account: AccountIdentity | null;
  authState: AuthStateSnapshot | null;
  attachmentState: LocalAttachmentState | null;
  syncState: SyncStateSnapshot | null;
  conflicts: SyncConflictRecord[];
  busyAction?: "attach" | "sync" | "defer" | "sign_out" | null;
  onAttach: () => void;
  onDefer: () => void;
  onSync: () => void;
  onSignOut: () => void;
}

export function AccountStatusCard({
  account,
  authState,
  attachmentState,
  syncState,
  conflicts,
  busyAction,
  onAttach,
  onDefer,
  onSync,
  onSignOut,
}: AccountStatusCardProps) {
  const hasAccount = !!account;
  const accountUnavailable = !hasAccount && (authState?.availableProviders.length ?? 0) === 0;
  const requiresAttachment =
    attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired;
  const syncSummary = summarizeSyncState({
    syncState,
    attachmentState,
    conflicts,
  });
  const statusPills = buildStatusPills({
    hasAccount,
    accountUnavailable,
    syncState,
    conflictsCount: conflicts.length,
  });

  return (
    <Surface tone="sunken">
      <View className="gap-5">
        <View className="gap-2">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Account
          </AppText>
          <AppText variant="section">{buildHeadline(hasAccount, syncState, authState)}</AppText>
          <AppText tone="secondary">{buildSummary(hasAccount, accountUnavailable, attachmentState, syncState)}</AppText>
          <View className="flex-row flex-wrap gap-x-5 gap-y-2">
            {statusPills.map((pill) => (
              <AppText key={pill} tone="secondary" variant="caption">
                {pill}
              </AppText>
            ))}
          </View>
        </View>

        {account ? (
          <View className="gap-3 rounded-[18px] px-4 py-4" style={{ backgroundColor: "rgba(255,255,255,0.04)" }}>
            <View className="gap-1">
              <AppText>{account.displayName ?? account.email ?? "Account"}</AppText>
              <AppText tone="tertiary" variant="caption">
                {account.email ?? "Email account"}
              </AppText>
            </View>
            <View className="gap-1">
              <AppText variant="caption">{syncSummary.headline}</AppText>
              <AppText tone="secondary" variant="caption">
                {syncSummary.detail}
              </AppText>
            </View>
            <View className="flex-row flex-wrap gap-x-5 gap-y-2">
              {syncSummary.meta.slice(1).map((item) => (
                <AppText key={item} tone="tertiary" variant="caption">
                  {item}
                </AppText>
              ))}
            </View>
          </View>
        ) : null}

        {hasAccount && authState?.lastError ? (
          <AppText tone="tertiary" variant="caption">
            {authState.lastError}
          </AppText>
        ) : null}

        {requiresAttachment ? (
          <View className="gap-4">
            <View className="gap-2">
              <AppText>Bring this device&apos;s data into the signed-in account?</AppText>
              <AppText tone="secondary" variant="caption">
                Goals, plans, history, and settings will upload as the first sync.
              </AppText>
            </View>
            <View className="flex-row gap-3">
              <Button style={{ flex: 1 }} busy={busyAction === "attach"} onPress={onAttach}>
                Attach data
              </Button>
              <Button
                tone="tertiary"
                style={{ flex: 1 }}
                busy={busyAction === "defer"}
                onPress={onDefer}
              >
                Stay local
              </Button>
            </View>
          </View>
        ) : hasAccount ? (
          <View className="gap-3">
            <View className="flex-row gap-3">
              <Button
                style={{ flex: 1 }}
                busy={busyAction === "sync"}
                onPress={onSync}
                disabled={attachmentState?.status !== LocalAttachmentStatus.Attached}
              >
                Retry sync
              </Button>
              <Button
                tone="tertiary"
                style={{ flex: 1 }}
                busy={busyAction === "sign_out"}
                onPress={onSignOut}
              >
                Sign out
              </Button>
            </View>
            {(syncState?.pendingPushCount ?? 0) > 0 || syncState?.mode === SyncMode.Offline || syncState?.mode === SyncMode.Issue ? (
              <AppText tone="tertiary" variant="caption">
                Signing out keeps current changes on this device. They will not reach your account until you sign in and sync again.
              </AppText>
            ) : (
              <AppText tone="tertiary" variant="caption">
                Signing out leaves local data on this device and pauses connected syncing.
              </AppText>
            )}
          </View>
        ) : null}
      </View>
    </Surface>
  );
}

function buildHeadline(
  hasAccount: boolean,
  syncState: SyncStateSnapshot | null,
  authState: AuthStateSnapshot | null,
) {
  if (!hasAccount) {
    return authState?.status === AuthStatus.Unavailable ? "Local only" : "Connect an account";
  }

  switch (syncState?.mode) {
    case SyncMode.Syncing:
      return "Syncing changes";
    case SyncMode.Synced:
      return "Up to date";
    case SyncMode.PendingChanges:
      return "Pending changes";
    case SyncMode.Offline:
      return "Offline for now";
    case SyncMode.Issue:
      return "Couldn’t sync";
    case SyncMode.ReviewRequired:
      return "Needs review";
    default:
      return "Signed in";
  }
}

function buildSummary(
  hasAccount: boolean,
  accountUnavailable: boolean,
  attachmentState: LocalAttachmentState | null,
  syncState: SyncStateSnapshot | null,
) {
  if (!hasAccount) {
    if (accountUnavailable) {
      return "Your data stays on this device. Account connection is unavailable right now.";
    }
    return "Your data stays on this device until you connect an account.";
  }

  if (attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired) {
    return "This device has local data ready to carry forward.";
  }

  switch (syncState?.mode) {
    case SyncMode.Syncing:
      return "Keeping goals, plans, history, and settings in sync.";
    case SyncMode.Synced:
      return "This account is ready across devices.";
    case SyncMode.PendingChanges:
      return "Recent changes are queued to sync.";
    case SyncMode.Offline:
      return "You can keep using Ambitions. Sync will resume when the connection returns.";
    case SyncMode.Issue:
      return "Changes are still safe on this device. Try syncing again.";
    default:
      return "Signed in and ready.";
  }
}

function buildModeLabel(syncState: SyncStateSnapshot | null) {
  switch (syncState?.mode) {
    case SyncMode.Syncing:
      return "Syncing";
    case SyncMode.Synced:
      return "Up to date";
    case SyncMode.PendingChanges:
      return "Pending changes";
    case SyncMode.Offline:
      return "Offline";
    case SyncMode.Issue:
      return "Retry needed";
    case SyncMode.ReviewRequired:
      return "Review needed";
    default:
      return "Local only";
  }
}

function buildStatusPills({
  hasAccount,
  accountUnavailable,
  syncState,
  conflictsCount,
}: {
  hasAccount: boolean;
  accountUnavailable: boolean;
  syncState: SyncStateSnapshot | null;
  conflictsCount: number;
}) {
  const pills: string[] = [];

  if (hasAccount) {
    pills.push("Signed in");
    pills.push(buildModeLabel(syncState));
  } else {
    pills.push("Local only");
    if (accountUnavailable) {
      pills.push("Connection unavailable");
    }
  }

  if (conflictsCount > 0) {
    pills.push(`${conflictsCount} item${conflictsCount === 1 ? "" : "s"} need review`);
  }

  return pills;
}
