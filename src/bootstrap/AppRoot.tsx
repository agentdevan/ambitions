import { AppProviders } from "./providers/AppProviders";
import { RootNavigator } from "../navigation/RootNavigator";

export function AppRoot() {
  return (
    <AppProviders>
      <RootNavigator />
    </AppProviders>
  );
}
