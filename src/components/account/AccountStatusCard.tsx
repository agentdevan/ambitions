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
import { formatShortDateTime } from "../../utils/date";
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
  const requiresAttachment =
    attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired;

  return (
    <Surface tone="sunken">
      <View className="gap-5">
        <View className="gap-2">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Account
          </AppText>
          <AppText variant="section">{buildHeadline(hasAccount, syncState, authState)}</AppText>
          <AppText tone="secondary">{buildSummary(hasAccount, attachmentState, syncState)}</AppText>
          <View className="flex-row flex-wrap gap-x-5 gap-y-2">
            <AppText tone="secondary" variant="caption">
              {hasAccount ? "Signed in" : "Local only"}
            </AppText>
            <AppText tone="secondary" variant="caption">
              {buildModeLabel(syncState)}
            </AppText>
            {conflicts.length > 0 ? (
              <AppText tone="secondary" variant="caption">
                {conflicts.length} item{conflicts.length === 1 ? "" : "s"} need review
              </AppText>
            ) : null}
          </View>
        </View>

        {account ? (
          <View className="gap-1 rounded-[18px] px-4 py-4" style={{ backgroundColor: "rgba(255,255,255,0.04)" }}>
            <AppText>{account.displayName ?? account.email ?? "Account"}</AppText>
            <AppText tone="tertiary" variant="caption">
              {account.email ?? "Email account"}
            </AppText>
            <AppText tone="tertiary" variant="caption">
              {syncState?.lastSyncAt
                ? `Last sync ${formatShortDateTime(syncState.lastSyncAt)}`
                : "Not synced yet."}
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
    return authState?.status === AuthStatus.Unavailable ? "Local only" : "Add an account";
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
  attachmentState: LocalAttachmentState | null,
  syncState: SyncStateSnapshot | null,
) {
  if (!hasAccount) {
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
