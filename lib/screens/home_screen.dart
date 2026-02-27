import 'package:flutter/material.dart';
import '../widgets/master_password_field.dart';
import '../widgets/unique_phrase_field.dart';
import '../widgets/variation_selector.dart';
import '../widgets/password_output.dart';
import '../services/password_generator.dart';
import '../utils/auto_reset_timer.dart';

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
  late AutoResetTimer _autoResetTimer;

  // 4 variations to match desktop: Default, Variation 1, Variation 2, Variation 3
  static const int variationCount = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoResetTimer = AutoResetTimer(
      duration: const Duration(minutes: 1),
      onReset: _clearAllFields,
    );
    _masterPasswordController.addListener(_onInputChanged);
    _uniquePhraseController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoResetTimer.dispose();
    _masterPasswordController.dispose();
    _uniquePhraseController.dispose();
    super.dispose();
  }

  // Clear fields when app goes to background for security
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
      setState(() => _generatedPassword = '');
      return;
    }

    // Match desktop behavior: generates password even with empty unique phrase
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
    });
  }

  void _onVariationChanged(int index) {
    _autoResetTimer.reset();
    setState(() {
      _selectedVariation = index;
    });
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside input fields
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Passgrinder'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Master Password
                MasterPasswordField(
                  controller: _masterPasswordController,
                  onChanged: (_) => _onInputChanged(),
                ),
                const SizedBox(height: 16),

                // Unique Phrase
                UniquePhraseField(
                  controller: _uniquePhraseController,
                  onChanged: (_) => _onInputChanged(),
                ),
                const SizedBox(height: 20),

                // Variation Selector
                VariationSelector(
                  count: variationCount,
                  selectedIndex: _selectedVariation,
                  onChanged: _onVariationChanged,
                ),
                const SizedBox(height: 24),

                // Password Output + Copy
                PasswordOutput(
                  password: _generatedPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
