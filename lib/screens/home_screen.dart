import 'package:flutter/material.dart';
import '../widgets/master_password_field.dart';
import '../widgets/unique_phrase_field.dart';
import '../widgets/variation_selector.dart';
import '../widgets/password_output.dart';
import '../services/password_generator.dart';
import '../utils/auto_reset_timer.dart';
import '../utils/clipboard_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _masterPasswordController = TextEditingController();
  final _uniquePhraseController = TextEditingController();
  int _selectedVariation = 0;
  String _generatedPassword = '';
  bool _showPassword = false;
  late AutoResetTimer _autoResetTimer;

  static const int variationCount = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoResetTimer = AutoResetTimer(
      duration: const Duration(minutes: 1),
      onReset: _clearAllFields,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoResetTimer.dispose();
    _masterPasswordController.dispose();
    _uniquePhraseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _clearAllFields();
    }
  }

  void _onInputChanged() {
    _autoResetTimer.reset();
    _generatePassword();
  }

  void _generatePassword() {
    final master = _masterPasswordController.text;

    if (master.isEmpty) {
      setState(() {
        _generatedPassword = '';
        _showPassword = false;
      });
      return;
    }

    setState(() {
      final generator = PasswordGenerator(
        masterPassword: master,
        uniquePhrase: _uniquePhraseController.text,
        variation: _selectedVariation,
      );
      _generatedPassword = generator.generate();
    });
  }

  void _clearAllFields() {
    setState(() {
      _masterPasswordController.clear();
      _uniquePhraseController.clear();
      _selectedVariation = 0;
      _generatedPassword = '';
      _showPassword = false;
    });
  }

  void _onVariationChanged(int index) {
    _autoResetTimer.reset();
    setState(() {
      _selectedVariation = index;
    });
    _generatePassword();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _copyPassword() {
    if (_generatedPassword.isNotEmpty) {
      ClipboardHelper.copyAndNotify(context, _generatedPassword);
    }
  }

  bool get _isResetEnabled {
    return _masterPasswordController.text.isNotEmpty ||
        _uniquePhraseController.text.isNotEmpty ||
        _selectedVariation != 0;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final helperColor = isLight ? const Color(0xFF1e2629) : Colors.white70;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/passgrinder-1200.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Master Password
                  MasterPasswordField(
                    controller: _masterPasswordController,
                    onChanged: (_) => _onInputChanged(),
                  ),
                  const SizedBox(height: 14),

                  // Unique Phrase
                  UniquePhraseField(
                    controller: _uniquePhraseController,
                    onChanged: (_) => _onInputChanged(),
                  ),
                  const SizedBox(height: 10),

                  // Helper text (matches desktop)
                  Text(
                    'Use the website URL, domain name, or app name where this password will be used to grind your master password into something more unique.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: helperColor),
                  ),
                  const SizedBox(height: 18),

                  // Variation Selector
                  VariationSelector(
                    count: variationCount,
                    selectedIndex: _selectedVariation,
                    onChanged: _onVariationChanged,
                  ),
                  const SizedBox(height: 10),

                  // Variation helper text (matches desktop)
                  Text(
                    'Use a variation if you are required to change your password without needing to change your master password or unique phrase.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: helperColor),
                  ),
                  const SizedBox(height: 22),

                  // Password Output with inline copy/reset/visibility
                  PasswordOutput(
                    password: _generatedPassword,
                    showPassword: _showPassword,
                    onToggleVisibility: _togglePasswordVisibility,
                    onCopy: _copyPassword,
                    onReset: _isResetEnabled ? _clearAllFields : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
