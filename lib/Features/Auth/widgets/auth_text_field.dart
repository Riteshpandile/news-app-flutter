import 'package:flutter/material.dart';
import 'package:newsapp/Core/const/app_colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.textInputAction,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    OutlineInputBorder inputBorder({Color? color, double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color ?? AppColors.border, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
          cursorColor: colors.primary,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.65),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: colors.onSurfaceVariant),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: colors.surface,
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: inputBorder(),
            enabledBorder: inputBorder(),
            focusedBorder: inputBorder(color: colors.primary, width: 1.6),
            errorBorder: inputBorder(color: colors.error),
            focusedErrorBorder: inputBorder(color: colors.error, width: 1.5),
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
