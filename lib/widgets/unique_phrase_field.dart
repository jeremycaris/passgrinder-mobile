import 'package:flutter/material.dart';

class UniquePhraseField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const UniquePhraseField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<UniquePhraseField> createState() => _UniquePhraseFieldState();
}

class _UniquePhraseFieldState extends State<UniquePhraseField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.done,
      style: const TextStyle(
        fontFamily: 'SourceCodePro',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: 'Unique Phrase (optional)',
        hintText: 'e.g., gmail.com, MyBankApp, etc.',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.link, size: 18),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility : Icons.visibility_off,
            size: 20,
          ),
          tooltip: _obscure ? 'Show' : 'Hide',
        ),
      ),
    );
  }
}
