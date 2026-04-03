import 'package:flutter/material.dart';

/// A styled, reusable text field for the GOAT design system.
///
/// Wraps [TextFormField] with consistent styling, label, hint,
/// prefix/suffix support, and validation.
class CustomTextField extends StatelessWidget {
  /// Field label displayed above the input.
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String? hint;

  /// Controller for reading / writing the field value.
  final TextEditingController? controller;

  /// Keyboard type (email, number, etc.).
  final TextInputType keyboardType;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// Validation function — return an error string or `null`.
  final String? Function(String?)? validator;

  /// Called when the field value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. presses done).
  final ValueChanged<String>? onFieldSubmitted;

  /// Icon or widget shown before the input text.
  final Widget? prefixIcon;

  /// Icon or widget shown after the input text.
  final Widget? suffixIcon;

  /// Whether the field is enabled.
  final bool enabled;

  /// Maximum number of lines.
  final int maxLines;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Text input action (next, done, search, etc.).
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          maxLines: maxLines,
          focusNode: focusNode,
          textInputAction: textInputAction,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
