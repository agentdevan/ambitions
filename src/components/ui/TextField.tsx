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
        <AppText variant="caption" tone="secondary" style={{ marginLeft: 2 }}>
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
            borderRadius: 22,
            borderWidth: 1,
            borderColor: focused ? theme.colors.border.strong : theme.colors.border.subtle,
            backgroundColor: theme.colors.background.elevated,
            paddingHorizontal: 16,
            paddingVertical: multiline ? 16 : 14,
            color: theme.colors.text.primary,
            fontSize: 15,
            lineHeight: 21,
            textAlignVertical: multiline ? "top" : "center",
            shadowColor: theme.colors.text.primary,
            shadowOpacity: focused ? 0.05 : 0,
            shadowRadius: 10,
            shadowOffset: { width: 0, height: 4 },
          },
          style,
        ]}
      />
    </View>
  );
}
