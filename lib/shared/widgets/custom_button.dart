import 'package:flutter/material.dart';

/// A styled, reusable button following the GOAT design system.
///
/// Supports primary/outlined variants, loading state, and custom sizing.
class CustomButton extends StatelessWidget {
  /// The button label text.
  final String text;

  /// Called when the button is tapped. If `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// When `true`, shows a spinner instead of the text.
  final bool isLoading;

  /// When `true`, renders an outlined style instead of filled.
  final bool isOutlined;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// Button width. Defaults to full-width (`double.infinity`).
  final double? width;

  /// Button height.
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width = double.infinity,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── Child content (loading spinner or label) ─────────────────────
    final Widget child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isOutlined
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    // ── Button shell ────────────────────────────────────────────────
    final effectiveOnPressed = isLoading ? null : onPressed;

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    );
  }
}
