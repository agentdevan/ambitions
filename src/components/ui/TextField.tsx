import { TextInput, TextInputProps, View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface TextFieldProps extends TextInputProps {
  label?: string;
  multiline?: boolean;
}

export function TextField({ label, multiline = false, style, ...props }: TextFieldProps) {
  const theme = useResolvedTheme();

  return (
    <View className="gap-2">
      {label ? (
        <AppText variant="caption" tone="secondary">
          {label}
        </AppText>
      ) : null}
      <TextInput
        {...props}
        multiline={multiline}
        placeholderTextColor={theme.colors.text.tertiary}
        style={[
          {
            minHeight: multiline ? 108 : 52,
            borderRadius: 22,
            borderWidth: 1,
            borderColor: theme.colors.border.subtle,
            backgroundColor: theme.colors.background.elevated,
            paddingHorizontal: 16,
            paddingVertical: multiline ? 16 : 14,
            color: theme.colors.text.primary,
            fontSize: 15,
            lineHeight: 21,
            textAlignVertical: multiline ? "top" : "center",
          },
          style,
        ]}
      />
    </View>
  );
}
