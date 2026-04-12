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
import { Surface } from "../ui/Surface";
import { AppText } from "../ui/Text";
import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { formatShortDateTime } from "../../utils/date";

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
  const theme = useResolvedTheme();
  const hasAccount = !!account;
  const requiresAttachment =
    attachmentState?.status === LocalAttachmentStatus.ConfirmationRequired;

  return (
    <Surface tone="sunken">
      <View className="gap-5">
        <View className="gap-3">
          <AppText tone="tertiary" variant="micro" style={{ textTransform: "uppercase" }}>
            Account
          </AppText>
          <AppText variant="section">Account and sync</AppText>
          <AppText tone="secondary">
            {hasAccount
              ? "Keep the planning foundation available across devices."
              : "Stay local, or add an account when backup becomes useful."}
          </AppText>
          <View className="flex-row flex-wrap gap-x-5 gap-y-2">
            <AppText tone="secondary" variant="caption">
              {hasAccount ? "Signed in" : "Local only"}
            </AppText>
            {syncState ? (
              <AppText tone="secondary" variant="caption">
                {syncState.mode.replace("_", " ")}
              </AppText>
            ) : null}
            {conflicts.length > 0 ? (
              <AppText tone="secondary" variant="caption">
                {conflicts.length} item{conflicts.length === 1 ? "" : "s"} to review
              </AppText>
            ) : null}
          </View>
        </View>

        {account ? (
          <View
            className="gap-1 rounded-[18px] px-4 py-4"
            style={{
              backgroundColor: theme.colors.background.elevated,
              borderWidth: 1,
              borderColor: theme.colors.border.strong,
            }}
          >
            <AppText>{account.displayName ?? account.email ?? "Apple account"}</AppText>
            <AppText tone="tertiary" variant="caption">
              {syncState?.lastSyncAt
                ? `Last sync ${formatShortDateTime(syncState.lastSyncAt)}`
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
              <AppText>Attach this device's data to the signed-in account?</AppText>
              <AppText tone="secondary" variant="caption">
                Existing goals, plans, and preferences become the sync baseline. Nothing is overwritten silently.
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
                Keep local only
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
              Sync now
            </Button>
          </View>
        ) : (
          <Button tone="secondary" busy={busyAction === "sign_in"} onPress={onSignIn}>
            Add account
          </Button>
        )}
      </View>
    </Surface>
  );
}
