import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardHelper {
  /// Copies [text] to clipboard and shows a SnackBar confirmation.
  /// Also triggers haptic feedback on mobile.
  static Future<void> copyAndNotify(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    // Haptic feedback for tactile confirmation
    await HapticFeedback.mediumImpact();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password copied to clipboard'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
