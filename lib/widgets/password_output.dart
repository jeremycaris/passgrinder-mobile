import 'package:flutter/material.dart';
import '../utils/clipboard_helper.dart';

class PasswordOutput extends StatelessWidget {
  final String password;

  const PasswordOutput({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final hasPassword = password.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Password display container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: SelectableText(
            hasPassword ? password : 'Enter master password and phrase',
            style: TextStyle(
              fontFamily: 'SourceCodePro',
              fontSize: 16,
              color: hasPassword
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Copy button — full-width, tall touch target
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: hasPassword
                ? () => ClipboardHelper.copyAndNotify(context, password)
                : null,
            icon: const Icon(Icons.copy),
            label: const Text('Copy Password'),
          ),
        ),
      ],
    );
  }
}
