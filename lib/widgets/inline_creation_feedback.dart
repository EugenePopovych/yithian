import 'package:flutter/material.dart';

/// A tiny pill-shaped feedback bubble used inline near a field.
/// Choose severity with [isError] or [isWarning]. Defaults to neutral.
/// Keep this dumb: pass already-short messages.
class InlineCreationFeedback extends StatelessWidget {
  const InlineCreationFeedback({
    super.key,
    required this.message,
    this.isError = false,
    this.isWarning = false,
  });

  final String message;
  final bool isError;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Color bg = isError
        ? scheme.errorContainer
        : (isWarning ? scheme.surfaceContainerHigh : scheme.surfaceContainer);
    final Color fg = isError
        ? scheme.onErrorContainer
        : (isWarning ? scheme.onSurface : scheme.onSurface);
    final IconData icon =
        isError ? Icons.error_outline : (isWarning ? Icons.info_outline : Icons.check_circle_outline);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 2)),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 240),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: fg),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
