import { useState } from "react";
import { TextInput, TextInputProps, View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface TextFieldProps extends TextInputProps {
  label?: string;
  multiline?: boolean;
}

export function TextField({ label, multiline = false, style, ...props }: TextFieldProps) {
  const theme = useResolvedTheme();
  const [focused, setFocused] = useState(false);

  return (
    <View className="gap-2">
      {label ? (
        <AppText variant="micro" tone="tertiary" style={{ marginLeft: 2, textTransform: "uppercase" }}>
          {label}
        </AppText>
      ) : null}
      <TextInput
        {...props}
        multiline={multiline}
        onBlur={(event) => {
          setFocused(false);
          props.onBlur?.(event);
        }}
        onFocus={(event) => {
          setFocused(true);
          props.onFocus?.(event);
        }}
        placeholderTextColor={theme.colors.text.tertiary}
        style={[
          {
            minHeight: multiline ? 108 : 50,
            borderRadius: 20,
            borderWidth: 1,
            borderColor: focused ? theme.colors.border.accent : theme.colors.border.subtle,
            backgroundColor: theme.colors.background.elevatedSecondary,
            paddingHorizontal: 16,
            paddingVertical: multiline ? 14 : 12,
            color: theme.colors.text.primary,
            fontSize: 15,
            lineHeight: 21,
            textAlignVertical: multiline ? "top" : "center",
            shadowColor: theme.colors.shadow.color,
            shadowOpacity: focused ? (theme.mode === "dark" ? 0.18 : 0.06) : 0.02,
            shadowRadius: focused ? 12 : 6,
            shadowOffset: { width: 0, height: focused ? 5 : 2 },
          },
          style,
        ]}
      />
    </View>
  );
}
