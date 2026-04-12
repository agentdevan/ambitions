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
        <AppText variant="micro" tone="tertiary" style={{ marginLeft: 4, textTransform: "uppercase" }}>
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
            minHeight: multiline ? 108 : 52,
            borderRadius: 24,
            borderWidth: 1.5,
            borderColor: focused ? theme.colors.border.strong : theme.colors.border.subtle,
            backgroundColor: theme.colors.background.canvas,
            paddingHorizontal: 18,
            paddingVertical: multiline ? 16 : 14,
            color: theme.colors.text.primary,
            fontSize: 15,
            lineHeight: 21,
            textAlignVertical: multiline ? "top" : "center",
            shadowColor: theme.colors.text.primary,
            shadowOpacity: focused ? 0.06 : 0.02,
            shadowRadius: focused ? 14 : 8,
            shadowOffset: { width: 0, height: focused ? 8 : 4 },
          },
          style,
        ]}
      />
    </View>
  );
}
