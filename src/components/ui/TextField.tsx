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
            minHeight: multiline ? 108 : 50,
            borderRadius: 16,
            borderWidth: 1,
            borderColor: focused ? theme.colors.accent.primary : theme.colors.border.strong,
            backgroundColor: "#FBF7F1",
            paddingHorizontal: 16,
            paddingVertical: multiline ? 14 : 12,
            color: theme.colors.text.primary,
            fontSize: 15,
            lineHeight: 21,
            textAlignVertical: multiline ? "top" : "center",
            shadowColor: theme.colors.text.primary,
            shadowOpacity: focused ? 0.05 : 0.02,
            shadowRadius: focused ? 10 : 6,
            shadowOffset: { width: 0, height: focused ? 6 : 3 },
          },
          style,
        ]}
      />
    </View>
  );
}
