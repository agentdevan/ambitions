import { ThemePresetKey } from "./types";

export interface ResolvedTheme {
  id: ThemePresetKey;
  label: string;
  description: string;
  colors: {
    background: {
      canvas: string;
      elevated: string;
      sunken: string;
      accentWash: string;
    };
    text: {
      primary: string;
      secondary: string;
      tertiary: string;
      inverse: string;
    };
    border: {
      subtle: string;
      strong: string;
    };
    accent: {
      primary: string;
      secondary: string;
      muted: string;
    };
    semantic: {
      success: string;
      warning: string;
      muted: string;
    };
  };
}

const presets: Record<ThemePresetKey, ResolvedTheme> = {
  neutral: {
    id: "neutral",
    label: "Neutral",
    description: "Quiet and balanced.",
    colors: {
      background: {
        canvas: "#F3F1EC",
        elevated: "#F8F6F1",
        sunken: "#ECE8E1",
        accentWash: "#E5EBE3",
      },
      text: {
        primary: "#18181A",
        secondary: "#4B4B53",
        tertiary: "#7A7A84",
        inverse: "#F8F8FA",
      },
      border: {
        subtle: "#DDD8D0",
        strong: "#CAC3B9",
      },
      accent: {
        primary: "#6D7C6D",
        secondary: "#9F7552",
        muted: "#6C7483",
      },
      semantic: {
        success: "#6A8368",
        warning: "#A17A56",
        muted: "#9A978E",
      },
    },
  },
  sage: {
    id: "sage",
    label: "Sage",
    description: "Soft green depth.",
    colors: {
      background: {
        canvas: "#EEF2ED",
        elevated: "#F5F8F4",
        sunken: "#E6ECE5",
        accentWash: "#DEE9E0",
      },
      text: {
        primary: "#172018",
        secondary: "#425046",
        tertiary: "#6A776C",
        inverse: "#F6F8F5",
      },
      border: {
        subtle: "#D1DACE",
        strong: "#BAC6B8",
      },
      accent: {
        primary: "#5F7865",
        secondary: "#8D6B58",
        muted: "#63727A",
      },
      semantic: {
        success: "#5E7B63",
        warning: "#9A7455",
        muted: "#8E948E",
      },
    },
  },
  slate: {
    id: "slate",
    label: "Slate",
    description: "Cool and restrained.",
    colors: {
      background: {
        canvas: "#EEF1F3",
        elevated: "#F5F7F9",
        sunken: "#E5E9ED",
        accentWash: "#E1E7EB",
      },
      text: {
        primary: "#17202A",
        secondary: "#485767",
        tertiary: "#6D7A88",
        inverse: "#F7F8FA",
      },
      border: {
        subtle: "#D4DCE3",
        strong: "#BFCAD5",
      },
      accent: {
        primary: "#627384",
        secondary: "#92715E",
        muted: "#6C7A77",
      },
      semantic: {
        success: "#607A6D",
        warning: "#A17A56",
        muted: "#9199A2",
      },
    },
  },
  dusk: {
    id: "dusk",
    label: "Dusk",
    description: "Warm slate with a little hush.",
    colors: {
      background: {
        canvas: "#F1EEEF",
        elevated: "#F8F5F6",
        sunken: "#EAE4E7",
        accentWash: "#E8E1E6",
      },
      text: {
        primary: "#221A22",
        secondary: "#564B57",
        tertiary: "#7A6F7A",
        inverse: "#FAF7F8",
      },
      border: {
        subtle: "#DDD3D9",
        strong: "#CABEC7",
      },
      accent: {
        primary: "#73667A",
        secondary: "#9A745C",
        muted: "#687483",
      },
      semantic: {
        success: "#6D7D73",
        warning: "#A37A5A",
        muted: "#9B9299",
      },
    },
  },
};

export const themePresets = Object.values(presets);

export function resolveThemePreset(preset: ThemePresetKey | null | undefined) {
  return presets[preset ?? "neutral"] ?? presets.neutral;
}
