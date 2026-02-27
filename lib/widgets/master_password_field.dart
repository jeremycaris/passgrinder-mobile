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
      style: const TextStyle(
        fontFamily: 'SourceCodePro',
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: 'Master Password',
        hintText: 'Enter your master password',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.lock_outline, size: 18),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIconConstraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility : Icons.visibility_off,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
          tooltip: _obscure ? 'Show' : 'Hide',
        ),
      ),
    );
  }
}
