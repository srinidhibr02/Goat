import 'package:flutter/material.dart';

/// A centered loading indicator with brand colors.
///
/// Optionally displays a [message] below the spinner.
class LoadingIndicator extends StatelessWidget {
  /// Optional message to show below the spinner.
  final String? message;

  /// Size of the spinner.
  final double size;

  /// Stroke width of the spinner arc.
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
