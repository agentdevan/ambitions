import * as AppleAuthentication from "expo-apple-authentication";

import { AuthProvider } from "../../domain/models";

export interface AppleAuthResult {
  provider: AuthProvider.Apple;
  providerSubject: string;
  email: string | null;
  displayName: string | null;
}

export class AppleAuthenticationService {
  static async isAvailable() {
    try {
      return await AppleAuthentication.isAvailableAsync();
    } catch {
      return false;
    }
  }

  static async signIn(): Promise<AppleAuthResult> {
    const credential = await AppleAuthentication.signInAsync({
      requestedScopes: [
        AppleAuthentication.AppleAuthenticationScope.EMAIL,
        AppleAuthentication.AppleAuthenticationScope.FULL_NAME,
      ],
    });

    if (!credential.user) {
      throw new Error("Apple sign-in did not return a usable account identifier.");
    }

    const displayName =
      [credential.fullName?.givenName, credential.fullName?.familyName]
        .filter(Boolean)
        .join(" ")
        .trim() || null;

    return {
      provider: AuthProvider.Apple,
      providerSubject: credential.user,
      email: credential.email ?? null,
      displayName,
    };
  }
}
