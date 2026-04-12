import { Ionicons } from "@expo/vector-icons";
import type { ComponentProps } from "react";
import { ForwardedRef, forwardRef, useState } from "react";
import { TextInput, TextInputProps, View } from "react-native";

import { useResolvedTheme } from "../../design/theme/useResolvedTheme";
import { AppText } from "./Text";

interface TextFieldProps extends TextInputProps {
  label?: string;
  multiline?: boolean;
  supportingText?: string;
  validationState?: "default" | "success" | "error";
}

type IoniconName = ComponentProps<typeof Ionicons>["name"];

function TextFieldComponent(
  {
    label,
    multiline = false,
    style,
    supportingText,
    validationState = "default",
    ...props
  }: TextFieldProps,
  ref: ForwardedRef<TextInput>,
) {
  const theme = useResolvedTheme();
  const [focused, setFocused] = useState(false);
  const showValidationIcon = !multiline && validationState !== "default";
  const palette =
    validationState === "success"
      ? {
          borderColor: theme.colors.semantic.success,
          backgroundColor:
            theme.mode === "dark" ? "rgba(142,168,131,0.12)" : "rgba(111,133,102,0.08)",
          labelTone: "accent" as const,
          helperTone: "accent" as const,
          iconName: "checkmark-circle" as IoniconName,
          iconColor: theme.colors.semantic.success,
        }
      : validationState === "error"
        ? {
            borderColor: theme.colors.semantic.warning,
            backgroundColor:
              theme.mode === "dark" ? "rgba(193,154,116,0.12)" : "rgba(165,128,89,0.08)",
          labelTone: "tertiary" as const,
          helperTone: "tertiary" as const,
          iconName: "alert-circle" as IoniconName,
          iconColor: theme.colors.semantic.warning,
        }
        : {
            borderColor: focused ? theme.colors.border.accent : theme.colors.border.subtle,
            backgroundColor: theme.colors.background.elevatedSecondary,
            labelTone: focused ? "accent" as const : "tertiary" as const,
            helperTone: "tertiary" as const,
            iconName: null,
            iconColor: "transparent",
          };

  return (
    <View className="gap-2">
      {label ? (
        <AppText
          variant="micro"
          tone={palette.labelTone}
          style={{ marginLeft: 2, textTransform: "uppercase" }}
        >
          {label}
        </AppText>
      ) : null}
      <View
        style={[
          {
            minHeight: multiline ? 108 : 54,
            borderRadius: 22,
            borderWidth: 1,
            borderColor: palette.borderColor,
            backgroundColor: palette.backgroundColor,
            paddingHorizontal: 16,
            paddingVertical: multiline ? 14 : 0,
            flexDirection: multiline ? "column" : "row",
            alignItems: multiline ? "stretch" : "center",
            shadowColor: theme.colors.shadow.color,
            shadowOpacity:
              validationState === "success"
                ? theme.mode === "dark"
                  ? 0.18
                  : 0.08
                : focused
                  ? theme.mode === "dark"
                    ? 0.18
                    : 0.06
                  : 0.02,
            shadowRadius: validationState === "success" || focused ? 12 : 6,
            shadowOffset: { width: 0, height: validationState === "success" || focused ? 5 : 2 },
          },
        ]}
      >
        <TextInput
          {...props}
          ref={ref}
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
              minHeight: multiline ? 80 : 52,
              color: theme.colors.text.primary,
              fontSize: 15,
              lineHeight: 21,
              textAlignVertical: multiline ? "top" : "center",
              paddingRight: showValidationIcon ? 12 : 0,
              flex: 1,
            },
            style,
          ]}
        />
        {showValidationIcon && palette.iconName ? (
          <Ionicons color={palette.iconColor} name={palette.iconName} size={20} />
        ) : null}
      </View>
      {supportingText ? (
        <AppText tone={palette.helperTone} variant="caption" style={{ marginLeft: 2 }}>
          {supportingText}
        </AppText>
      ) : null}
    </View>
  );
}

export const TextField = forwardRef(TextFieldComponent);
