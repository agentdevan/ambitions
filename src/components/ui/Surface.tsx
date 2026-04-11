import { PropsWithChildren } from "react";
import { View, ViewProps } from "react-native";

interface SurfaceProps extends PropsWithChildren, ViewProps {
  tone?: "default" | "accent" | "sunken";
}

const toneMap = {
  default: "bg-[#F8F6F1] border-[#DDD8D0]",
  accent: "bg-[#E5EBE3] border-[#D3DBD1]",
  sunken: "bg-[#ECE8E1] border-[#DDD8D0]",
};

export function Surface({ children, className = "", tone = "default", style, ...props }: SurfaceProps) {
  return (
    <View
      {...props}
      className={`rounded-[28px] border px-4 py-4 ${toneMap[tone]} ${className}`.trim()}
      style={[
        {
          shadowColor: "#1A1B1E",
          shadowOpacity: 0.06,
          shadowRadius: 18,
          shadowOffset: { width: 0, height: 10 },
          elevation: 4,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}
