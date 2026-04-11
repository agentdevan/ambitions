import { colors } from "../tokens/colors";
import { radius } from "../tokens/radius";
import { spacing } from "../tokens/spacing";
import { typeScale } from "../tokens/type";

export const appTheme = {
  colors,
  spacing,
  radius,
  typeScale,
  shadow: {
    soft: {
      shadowColor: "#1A1B1E",
      shadowOpacity: 0.08,
      shadowRadius: 18,
      shadowOffset: { width: 0, height: 10 },
      elevation: 4,
    },
  },
};

export type AppTheme = typeof appTheme;
