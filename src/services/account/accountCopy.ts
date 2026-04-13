export type AuthFeedbackKind = "error" | "info";
export type AuthFeedbackSuggestedMode = "create" | "sign_in";
export type AuthFeedbackCode =
  | "confirmation_required"
  | "email_exists"
  | "invalid_email"
  | "weak_password"
  | "invalid_credentials"
  | "network"
  | "rate_limited"
  | "signup_disabled"
  | "session_expired"
  | "unknown";

export interface AuthFeedback {
  kind: AuthFeedbackKind;
  code: AuthFeedbackCode;
  message: string;
  suggestedMode?: AuthFeedbackSuggestedMode;
}

interface AuthErrorLike {
  message: string;
  code: string | null;
}

function readErrorMessage(error: unknown) {
  if (error instanceof Error) {
    return error.message;
  }

  return String(error ?? "");
}

function readErrorCode(error: unknown) {
  if (error && typeof error === "object" && "code" in error) {
    const code = (error as { code?: unknown }).code;
    return typeof code === "string" ? code : null;
  }

  return null;
}

function normalizeAuthError(error: unknown): AuthErrorLike {
  return {
    message: readErrorMessage(error).toLowerCase(),
    code: readErrorCode(error)?.toLowerCase() ?? null,
  };
}

export function buildConfirmationRequiredFeedback(): AuthFeedback {
  return {
    kind: "info",
    code: "confirmation_required",
    message: "Check your email to finish setting up your account.",
    suggestedMode: "sign_in",
  };
}

export function buildExistingAccountFeedback(): AuthFeedback {
  return {
    kind: "error",
    code: "email_exists",
    message: "That email already has an account. Sign in instead.",
    suggestedMode: "sign_in",
  };
}

export function mapAuthErrorFeedback(error: unknown, mode: "sign_in" | "sign_up"): AuthFeedback {
  const { message, code } = normalizeAuthError(error);

  if (
    code === "over_email_send_rate_limit" ||
    message.includes("rate limit") ||
    message.includes("too many requests")
  ) {
    return {
      kind: "error",
      code: "rate_limited",
      message: "Too many attempts right now. Give it a minute and try again.",
    };
  }

  if (
    message.includes("failed to fetch") ||
    message.includes("network request failed") ||
    message.includes("network error") ||
    message.includes("fetch")
  ) {
    return {
      kind: "error",
      code: "network",
      message: "Connection unavailable right now. Try again.",
    };
  }

  if (message.includes("invalid login credentials")) {
    return {
      kind: "error",
      code: "invalid_credentials",
      message: "Couldn’t sign in. Check your email and password and try again.",
    };
  }

  if (message.includes("email not confirmed")) {
    return buildConfirmationRequiredFeedback();
  }

  if (message.includes("user already registered")) {
    return buildExistingAccountFeedback();
  }

  if (message.includes("password should be at least")) {
    return {
      kind: "error",
      code: "weak_password",
      message: "Use at least 8 characters for your password.",
    };
  }

  if (
    message.includes("invalid email") ||
    code === "email_address_invalid" ||
    message.includes("email_address_invalid")
  ) {
    return {
      kind: "error",
      code: "invalid_email",
      message: "Enter a valid email address.",
    };
  }

  if (message.includes("signup is disabled")) {
    return {
      kind: "error",
      code: "signup_disabled",
      message: "Account creation isn’t available right now.",
    };
  }

  if (message.includes("check your email to finish creating your account")) {
    return buildConfirmationRequiredFeedback();
  }

  if (message.includes("session expired")) {
    return {
      kind: "error",
      code: "session_expired",
      message: "Your session ended. Sign in again to keep syncing.",
      suggestedMode: "sign_in",
    };
  }

  return {
    kind: "error",
    code: "unknown",
    message:
      mode === "sign_in"
        ? "Couldn’t sign in. Try again."
        : "Couldn’t create your account. Try again.",
  };
}

export function getAuthUnavailableMessage() {
  return "Account connection is unavailable until EXPO_PUBLIC_SUPABASE_URL and EXPO_PUBLIC_SUPABASE_ANON_KEY are set with real values.";
}
