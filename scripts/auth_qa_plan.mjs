#!/usr/bin/env node

const now = new Date();
const hourKey = `${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, "0")}${String(
  now.getUTCDate(),
).padStart(2, "0")}${String(now.getUTCHours()).padStart(2, "0")}`;
const minuteKey = `${String(now.getUTCMinutes()).padStart(2, "0")}`;
const localStamp = now.toLocaleString("en-US", {
  dateStyle: "medium",
  timeStyle: "short",
});
const cooldownSeconds = 60;

function formatChecklist(title, items) {
  return [title, ...items.map((item) => `- ${item}`)].join("\n");
}

const suggestedAliases = [
  `devanwarner+auth-${hourKey}-a@gmail.com`,
  `devanwarner+auth-${hourKey}-b@gmail.com`,
];

const sections = [
  `Auth QA plan generated ${localStamp}`,
  "",
  "Current Supabase constraints to assume:",
  "- Default SMTP send budget is 2 emails per hour for the whole project.",
  `- Signup confirmation has a per-user resend cooldown of about ${cooldownSeconds} seconds.`,
  "- A rate-limited first tap can still happen if the project budget was already consumed earlier.",
  "",
  formatChecklist("Use this sequence:", [
    "Reserve one fresh alias for the single brand-new signup test that actually needs an email.",
    "Reserve a second alias only if you have confirmed the project still has another email send available this hour.",
    "Run existing-account, invalid-credentials, weak-password, invalid-email, and stale-state tests without triggering additional confirmation emails.",
    "Do not hammer Create account on the same alias; one attempt is enough to classify the backend state.",
  ]),
  "",
  formatChecklist("Suggested aliases for this hour:", suggestedAliases),
  "",
  formatChecklist("Recommended verification split:", [
    `Email-send path: brand-new signup with alias A, then stop and use the inbox link.`,
    "No-email paths: existing-account signup, sign-in with existing account, invalid credentials, stale-error clearing, mode-switch clearing.",
    "If signup returns rate-limited immediately, stop retrying and wait for the next hour window or switch to custom SMTP before continuing auth-email QA.",
  ]),
  "",
  formatChecklist("If you need stable high-volume auth QA:", [
    "Configure custom SMTP in Supabase Auth.",
    "Then raise the email rate limit from the dashboard's Authentication > Rate Limits settings.",
    "Keep using plus-address aliases so each confirmation test stays attributable in the inbox.",
  ]),
];

console.log(sections.join("\n"));
