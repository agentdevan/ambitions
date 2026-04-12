function normalizeMessage(error: unknown) {
  if (error instanceof Error) {
    return error.message.toLowerCase();
  }

  return String(error ?? "").toLowerCase();
}

export function mapAuthErrorMessage(error: unknown, mode: "sign_in" | "sign_up") {
  const message = normalizeMessage(error);

  if (
    message.includes("failed to fetch") ||
    message.includes("network request failed") ||
    message.includes("network error") ||
    message.includes("fetch")
  ) {
    return "Connection unavailable right now. Try again.";
  }

  if (message.includes("invalid login credentials")) {
    return "Couldn’t sign in. Check your email and password and try again.";
  }

  if (message.includes("email not confirmed")) {
    return "Check your email to finish setting up your account.";
  }

  if (message.includes("user already registered")) {
    return "That email already has an account. Sign in instead.";
  }

  if (message.includes("password should be at least")) {
    return "Use at least 8 characters for your password.";
  }

  if (message.includes("invalid email") || message.includes("email_address_invalid")) {
    return "Enter a valid email address.";
  }

  if (message.includes("signup is disabled")) {
    return "Account creation isn’t available right now.";
  }

  if (message.includes("check your email to finish creating your account")) {
    return "Check your email to finish setting up your account.";
  }

  if (message.includes("session expired")) {
    return "Your session ended. Sign in again to keep syncing.";
  }

  return mode === "sign_in"
    ? "Couldn’t sign in. Try again."
    : "Couldn’t create your account. Try again.";
}

export function getAuthUnavailableMessage() {
  return "Account connection is unavailable until EXPO_PUBLIC_SUPABASE_URL and EXPO_PUBLIC_SUPABASE_ANON_KEY are set with real values.";
}
