export interface SupabaseConfig {
  url: string;
  anonKey: string;
}

const placeholderValues = new Set([
  "https://your-project.supabase.co",
  "your-public-anon-key",
]);

function readEnvValue(name: "EXPO_PUBLIC_SUPABASE_URL" | "EXPO_PUBLIC_SUPABASE_ANON_KEY") {
  const value = process.env[name]?.trim();
  if (!value || placeholderValues.has(value)) {
    return null;
  }

  return value;
}

function isValidSupabaseUrl(value: string) {
  try {
    const url = new URL(value);
    return url.protocol === "https:" && url.hostname.length > 0;
  } catch {
    return false;
  }
}

export function getSupabaseConfig(): SupabaseConfig | null {
  const url = readEnvValue("EXPO_PUBLIC_SUPABASE_URL");
  const anonKey = readEnvValue("EXPO_PUBLIC_SUPABASE_ANON_KEY");

  if (!url || !anonKey) {
    return null;
  }

  if (!isValidSupabaseUrl(url)) {
    return null;
  }

  return { url, anonKey };
}

export function isSupabaseConfigured() {
  return getSupabaseConfig() !== null;
}
