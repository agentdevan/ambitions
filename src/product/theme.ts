import { radius } from "../design/tokens/radius";
import { spacing } from "../design/tokens/spacing";
import { typeScale } from "../design/tokens/type";
import { AccentThemeKey, AppearanceMode } from "./types";

export interface AccentThemeOption {
  id: AccentThemeKey;
  label: string;
  description: string;
  preview: [string, string];
}

export interface ResolvedTheme {
  mode: "light" | "dark";
  appearanceMode: AppearanceMode;
  accentTheme: AccentThemeKey;
  accentLabel: string;
  spacing: typeof spacing;
  radius: typeof radius & {
    card: number;
    row: number;
    control: number;
    compactControl: number;
    field: number;
  };
  typeScale: typeof typeScale;
  colors: {
    background: {
      canvas: string;
      canvasAlt: string;
      elevated: string;
      elevatedSecondary: string;
      sunken: string;
      accentWash: string;
      accentWashStrong: string;
      hero: string;
      cardTint: string;
    };
    text: {
      primary: string;
      secondary: string;
      tertiary: string;
      inverse: string;
      accent: string;
    };
    border: {
      subtle: string;
      strong: string;
      accent: string;
    };
    accent: {
      primary: string;
      secondary: string;
      muted: string;
      contrast: string;
      wash: string;
      glow: string;
    };
    semantic: {
      success: string;
      warning: string;
      muted: string;
    };
    progress: {
      track: string;
      fill: string;
      mutedFill: string;
    };
    tabBar: {
      background: string;
      border: string;
      pill: string;
      active: string;
      inactive: string;
    };
    shadow: {
      color: string;
      ambient: string;
    };
  };
}

const accentThemes: Record<AccentThemeKey, AccentThemeOption & { light: string; dark: string; secondary: string; muted: string }> = {
  gold: {
    id: "gold",
    label: "Warm Gold",
    description: "Cream, oat, and quiet gold.",
    preview: ["#B89257", "#F3E9D8"],
    light: "#B89257",
    dark: "#C6A06B",
    secondary: "#C9B08B",
    muted: "#8D775A",
  },
  sage: {
    id: "sage",
    label: "Sage",
    description: "Soft green with warm restraint.",
    preview: ["#73876C", "#E7EFE4"],
    light: "#73876C",
    dark: "#88A080",
    secondary: "#A3B19A",
    muted: "#6D7B69",
  },
  slateBlue: {
    id: "slateBlue",
    label: "Slate Blue",
    description: "Muted blue-grey with polished contrast.",
    preview: ["#72829A", "#E8EDF3"],
    light: "#72829A",
    dark: "#8A99B5",
    secondary: "#A2AEC4",
    muted: "#6B7485",
  },
  bronze: {
    id: "bronze",
    label: "Sand Bronze",
    description: "Stone, bronze, and sun-warmed neutrals.",
    preview: ["#A47A57", "#EFE3D5"],
    light: "#A47A57",
    dark: "#BC8D64",
    secondary: "#D1B190",
    muted: "#886B50",
  },
  olive: {
    id: "olive",
    label: "Soft Olive",
    description: "Muted olive with earthy calm.",
    preview: ["#7E8760", "#ECEBDC"],
    light: "#7E8760",
    dark: "#99A173",
    secondary: "#B4B890",
    muted: "#727553",
  },
  terracotta: {
    id: "terracotta",
    label: "Terracotta",
    description: "Restrained clay, never loud.",
    preview: ["#A76B5B", "#F2E2DB"],
    light: "#A76B5B",
    dark: "#BF7E6C",
    secondary: "#D2A08E",
    muted: "#875E53",
  },
};

export const accentThemeOptions = Object.values(accentThemes).map(
  ({ id, label, description, preview }) => ({ id, label, description, preview }),
);

const lightBase = {
  canvas: "#F4EFE7",
  canvasAlt: "#EFE7DC",
  elevated: "#FBF7F1",
  elevatedSecondary: "#F8F2E9",
  sunken: "#ECE4D8",
  hero: "#F0E6D6",
  cardTint: "rgba(255,255,255,0.58)",
  textPrimary: "#1B1712",
  textSecondary: "#5B5248",
  textTertiary: "#8B7F71",
  textInverse: "#FFFCF8",
  borderSubtle: "#E3D8CA",
  borderStrong: "#D2C2AF",
  success: "#6F8566",
  warning: "#A58059",
  muted: "#9C9386",
  shadow: "#201A14",
  ambient: "rgba(32,26,20,0.08)",
};

const darkBase = {
  canvas: "#111215",
  canvasAlt: "#16181C",
  elevated: "#1A1C20",
  elevatedSecondary: "#202228",
  sunken: "#0E1013",
  hero: "#23252C",
  cardTint: "rgba(255,255,255,0.03)",
  textPrimary: "#F4EFE7",
  textSecondary: "#C2BAAF",
  textTertiary: "#8D857B",
  textInverse: "#121317",
  borderSubtle: "#2A2D33",
  borderStrong: "#3A3E46",
  success: "#8EA883",
  warning: "#C19A74",
  muted: "#777168",
  shadow: "#000000",
  ambient: "rgba(0,0,0,0.32)",
};

function withAlpha(hex: string, alphaHex: string) {
  return `${hex}${alphaHex}`;
}

export const appearanceModeOptions: Array<{ id: AppearanceMode; label: string; description: string }> = [
  { id: "light", label: "Light", description: "Warm editorial surfaces." },
  { id: "dark", label: "Dark", description: "Low-glare cinematic depth." },
  { id: "system", label: "System", description: "Follow iPhone appearance." },
];

export function resolveTheme(options: {
  appearanceMode?: AppearanceMode | null;
  accentTheme?: AccentThemeKey | null;
  systemScheme?: "light" | "dark" | null;
}): ResolvedTheme {
  const appearanceMode = options.appearanceMode ?? "system";
  const mode =
    appearanceMode === "system" ? (options.systemScheme === "dark" ? "dark" : "light") : appearanceMode;
  const accentTheme = options.accentTheme ?? "gold";
  const accent = accentThemes[accentTheme] ?? accentThemes.gold;
  const base = mode === "dark" ? darkBase : lightBase;
  const accentPrimary = mode === "dark" ? accent.dark : accent.light;

  return {
    mode,
    appearanceMode,
    accentTheme,
    accentLabel: accent.label,
    spacing,
    radius: {
      ...radius,
      card: 28,
      row: 24,
      control: 20,
      compactControl: 16,
      field: 24,
    },
    typeScale,
    colors: {
      background: {
        canvas: base.canvas,
        canvasAlt: base.canvasAlt,
        elevated: base.elevated,
        elevatedSecondary: base.elevatedSecondary,
        sunken: base.sunken,
        accentWash: withAlpha(accentPrimary, mode === "dark" ? "1C" : "18"),
        accentWashStrong: withAlpha(accentPrimary, mode === "dark" ? "2F" : "28"),
        hero: base.hero,
        cardTint: base.cardTint,
      },
      text: {
        primary: base.textPrimary,
        secondary: base.textSecondary,
        tertiary: base.textTertiary,
        inverse: base.textInverse,
        accent: accentPrimary,
      },
      border: {
        subtle: base.borderSubtle,
        strong: base.borderStrong,
        accent: withAlpha(accentPrimary, mode === "dark" ? "66" : "44"),
      },
      accent: {
        primary: accentPrimary,
        secondary: accent.secondary,
        muted: accent.muted,
        contrast: mode === "dark" ? "#141518" : "#FFFCF8",
        wash: withAlpha(accentPrimary, mode === "dark" ? "20" : "18"),
        glow: withAlpha(accentPrimary, mode === "dark" ? "44" : "24"),
      },
      semantic: {
        success: base.success,
        warning: base.warning,
        muted: base.muted,
      },
      progress: {
        track: mode === "dark" ? "#2A2E35" : "#E4DBCF",
        fill: accentPrimary,
        mutedFill: accent.secondary,
      },
      tabBar: {
        background: mode === "dark" ? "#17191D" : "#F7F1E8",
        border: mode === "dark" ? "#272A30" : "#DFD4C5",
        pill: mode === "dark" ? withAlpha(accentPrimary, "28") : withAlpha(accentPrimary, "16"),
        active: base.textPrimary,
        inactive: base.textTertiary,
      },
      shadow: {
        color: base.shadow,
        ambient: base.ambient,
      },
    },
  };
}
