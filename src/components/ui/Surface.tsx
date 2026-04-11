import { PropsWithChildren } from "react";
import { View, ViewProps } from "react-native";

interface SurfaceProps extends PropsWithChildren, ViewProps {
  tone?: "default" | "accent" | "sunken";
}

const toneMap = {
  default: "bg-[#F7F4EE] border-[#E6E0D6]",
  accent: "bg-[#E5EBE3] border-[#D9E0D6]",
  sunken: "bg-[#EFEAE2] border-[#E2DBD0]",
};

export function Surface({ children, className = "", tone = "default", style, ...props }: SurfaceProps) {
  return (
    <View
      {...props}
      className={`rounded-[30px] border px-5 py-5 ${toneMap[tone]} ${className}`.trim()}
      style={[
        {
          shadowColor: "#1A1B1E",
          shadowOpacity: 0.045,
          shadowRadius: 22,
          shadowOffset: { width: 0, height: 12 },
          elevation: 3,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}
