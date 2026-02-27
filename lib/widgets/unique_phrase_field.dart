import 'package:flutter/material.dart';

class UniquePhraseField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const UniquePhraseField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Unique Phrase',
        prefixIcon: Icon(Icons.language),
        hintText: 'e.g. github.com',
      ),
    );
  }
}
