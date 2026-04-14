import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import os from "node:os";
import path from "node:path";

const repoRoot = path.resolve(import.meta.dirname, "..");
const androidDir = path.join(repoRoot, "android");

if (!existsSync(androidDir)) {
  console.error(
    "Android project not found. Generate it first with `npx expo prebuild --platform android` or `expo run:android`.",
  );
  process.exit(1);
}

function findAndroidSdk() {
  const candidates = [
    process.env.ANDROID_HOME,
    process.env.ANDROID_SDK_ROOT,
    path.join(os.homedir(), "AppData", "Local", "Android", "Sdk"),
    path.join(os.homedir(), "Library", "Android", "sdk"),
    path.join(path.sep, "opt", "android-sdk"),
  ].filter(Boolean);

  return candidates.find((candidate) => existsSync(candidate)) ?? null;
}

const sdkPath = findAndroidSdk();

if (!sdkPath) {
  console.error(
    "Android SDK not found. Set ANDROID_HOME or ANDROID_SDK_ROOT, or install the SDK in the default user path.",
  );
  process.exit(1);
}

const child =
  process.platform === "win32"
    ? spawn("cmd.exe", ["/c", "gradlew.bat", "assembleDebug", "--console=plain", "--no-daemon"], {
        cwd: androidDir,
        stdio: "inherit",
        env: {
          ...process.env,
          ANDROID_HOME: sdkPath,
          ANDROID_SDK_ROOT: sdkPath,
          NODE_ENV: process.env.NODE_ENV ?? "production",
        },
      })
    : spawn(path.join(androidDir, "gradlew"), ["assembleDebug", "--console=plain", "--no-daemon"], {
        cwd: androidDir,
        stdio: "inherit",
        env: {
          ...process.env,
          ANDROID_HOME: sdkPath,
          ANDROID_SDK_ROOT: sdkPath,
          NODE_ENV: process.env.NODE_ENV ?? "production",
        },
      });

child.on("exit", (code, signal) => {
  if (signal) {
    console.error(`Android build terminated with signal ${signal}.`);
    process.exit(1);
  }

  process.exit(code ?? 1);
});
