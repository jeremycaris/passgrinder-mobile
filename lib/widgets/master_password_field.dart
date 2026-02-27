import 'package:flutter/material.dart';

class MasterPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const MasterPasswordField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<MasterPasswordField> createState() => _MasterPasswordFieldState();
}

class _MasterPasswordFieldState extends State<MasterPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Master Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
          tooltip: _obscure ? 'Show password' : 'Hide password',
        ),
      ),
    );
  }
}
