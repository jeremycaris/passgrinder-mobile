# Passgrinder Mobile — Comprehensive Refactoring Plan

> **Goal**: Refactor the [passgrinder-desktop](https://github.com/jeremycaris/passgrinder-desktop) Flutter app into a mobile-optimized version for iOS and Android.

---

## Table of Contents

1. [Desktop App Architecture Overview](#1-desktop-app-architecture-overview)
2. [Project Initialization](#2-project-initialization)
3. [Dependencies & pubspec.yaml](#3-dependencies--pubspecyaml)
4. [Directory Structure](#4-directory-structure)
5. [Core Logic — Password Generation](#5-core-logic--password-generation)
6. [UI Refactoring — Screen by Screen](#6-ui-refactoring--screen-by-screen)
7. [Platform-Specific Differences](#7-platform-specific-differences)
8. [Theming & Styling](#8-theming--styling)
9. [Keyboard & Input Handling](#9-keyboard--input-handling)
10. [Auto-Reset Timer](#10-auto-reset-timer)
11. [Clipboard Integration](#11-clipboard-integration)
12. [Assets & Icons](#12-assets--icons)
13. [Testing](#13-testing)
14. [CI/CD with GitHub Actions](#14-cicd-with-github-actions)
15. [Build & Release](#15-build--release)
16. [Checklist](#16-checklist)

---

## 1. Desktop App Architecture Overview

The desktop app is a single-screen password generator built with Flutter/Dart. Key characteristics:

- **Language**: Dart (48.1% of repo), with platform glue in C++, CMake, Swift, Shell, Ruby, C
- **UI Pattern**: Chrome extension-style — compact, single-screen layout in a small fixed window (~500×450 px)
- **Features**:
  - Master Password input field
  - Unique Phrase input field
  - Password variation selector (radio group with chip-style UI)
  - Generated password output with copy button
  - Visibility toggle on password field
  - Auto-reset timer (clears sensitive data after 1 minute of inactivity)
  - Dark/light mode (follows system theme)
  - Full keyboard navigation (Tab, Arrow keys)
  - Menu bar integration on macOS
- **Platforms**: macOS (Universal), Windows (x64), Linux (x64)
- **Directory layout** (desktop):
  ```
  lib/              # Dart source (main app logic, UI, password generation)
  assets/           # App assets (icons, images)
  test/             # Widget and unit tests
  macos/            # macOS runner & config
  windows/          # Windows runner & config
  linux/            # Linux runner & config
  scripts/          # Build/version sync scripts
  .github/          # GitHub Actions workflows
  ```

### Key Source Files to Port (expected structure in `lib/`):

Based on the desktop app's features, the `lib/` directory likely contains:

| File (estimated) | Purpose |
|---|---|
| `lib/main.dart` | App entry point, MaterialApp setup, theme configuration |
| `lib/screens/home_screen.dart` | Single-screen UI with all input fields, radio group, output |
| `lib/widgets/password_field.dart` | Custom password input with visibility toggle |
| `lib/services/password_generator.dart` | Core password generation algorithm (hash-based) |
| `lib/theme/` or inline theme | Dark/light theme definitions |
| `lib/utils/` | Clipboard helpers, timer logic, etc. |

---

## 2. Project Initialization

### Step 2.1 — Create the Flutter project

Run from the `passgrinder-mobile` directory:

```bash
flutter create . --org com.jeremycaris --project-name passgrinder_mobile --platforms ios,android
```

> **Why `--platforms ios,android` only?** We're building a mobile app. Desktop platform folders are not needed.

### Step 2.2 — Verify the scaffold runs

```bash
flutter run
```

Confirm the default counter app runs on a simulator/emulator before proceeding.

### Step 2.3 — Clean the scaffold

- Delete the default `lib/main.dart` counter app content (keep the file).
- Delete `test/widget_test.dart` content (keep the file).

---

## 3. Dependencies & pubspec.yaml

Create the `pubspec.yaml` with these specifics:

```yaml
name: passgrinder_mobile
description: Passgrinder mobile password generator
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  crypto: ^3.0.3          # For SHA-256 / HMAC password generation
  # NOTE: Do NOT include these desktop-only packages:
  #   - tray_manager (menu bar integration — macOS only)
  #   - window_manager (window sizing — desktop only)
  #   - window_size (desktop only)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/
    - assets/icons/
```

### Key Dependency Differences from Desktop

| Desktop Dependency | Mobile Equivalent | Action |
|---|---|---|
| `window_manager` / `window_size` | Not needed | **Remove** — mobile apps don't control window size |
| `tray_manager` | Not needed | **Remove** — no system tray on mobile |
| `crypto` | Same | **Keep** — password generation logic is identical |
| `flutter/services.dart` (Clipboard) | Same | **Keep** — `Clipboard.setData` works on mobile |

---

## 4. Directory Structure

Create this structure inside `lib/`:

```
lib/
├── main.dart                          # App entry, MaterialApp, theme setup
├── screens/
│   └── home_screen.dart               # Main (only) screen
├── widgets/
│   ├── master_password_field.dart     # Master password input
│   ├── unique_phrase_field.dart       # Unique phrase input
│   ├── password_output.dart           # Generated password display + copy
│   └── variation_selector.dart        # Password variation chips/radio
├── services/
│   └── password_generator.dart        # Core algorithm (ported directly)
├── utils/
│   ├── clipboard_helper.dart          # Copy-to-clipboard utility
│   └── auto_reset_timer.dart          # Inactivity timer logic
└── theme/
    └── app_theme.dart                 # Light and dark theme definitions
```

Also create:

```
assets/
├── icons/
│   ├── app_icon.png                   # 1024x1024 source icon
│   └── (adaptive icon layers — see Section 12)
test/
├── services/
│   └── password_generator_test.dart   # Unit tests for core algorithm
├── widgets/
│   └── home_screen_test.dart          # Widget tests
└── utils/
    └── auto_reset_timer_test.dart     # Timer tests
```

---

## 5. Core Logic — Password Generation

### What to Port (COPY DIRECTLY)

The password generation algorithm is **platform-independent pure Dart**. Copy it verbatim from the desktop repo's `lib/services/password_generator.dart` (or wherever the generation logic lives).

The algorithm likely works as follows (based on the app's UX):

```dart
// filepath: lib/services/password_generator.dart

import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordGenerator {
  /// Generates a password from a master password and unique phrase.
  ///
  /// [masterPassword] - The user's master password (never stored)
  /// [uniquePhrase] - A site/service-specific phrase
  /// [variation] - Which variation index (0, 1, 2, etc.)
  /// [length] - Desired password length (default: 16)
  ///
  /// Returns a generated password string.
  static String generate({
    required String masterPassword,
    required String uniquePhrase,
    int variation = 0,
    int length = 16,
  }) {
    // Combine inputs with variation index
    final input = '$masterPassword:$uniquePhrase:$variation';
    
    // Hash with SHA-256
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    
    // Convert to password characters
    // (Port the EXACT logic from the desktop app — character set,
    //  encoding scheme, length truncation, etc.)
    
    // IMPORTANT: Copy the exact implementation from the desktop repo.
    // The algorithm MUST produce identical output for the same inputs
    // so users get the same passwords on mobile and desktop.
    return _hashToPassword(digest.toString(), length);
  }

  static String _hashToPassword(String hash, int length) {
    // TODO: Copy exact implementation from desktop repo
    // This must match character-for-character with desktop output
    throw UnimplementedError('Copy from desktop repo');
  }
}
```

> **⚠️ CRITICAL**: The mobile app MUST produce **identical passwords** to the desktop app for the same inputs. Copy the generation algorithm exactly. Do not refactor, optimize, or "improve" the algorithm. Test with known input/output pairs from the desktop app.

### How to Verify Parity

1. Run the desktop app
2. Enter master password: `test123`, unique phrase: `github.com`, variation: 0
3. Record the generated password
4. Run the same inputs through the mobile app's generator
5. Outputs **must match exactly**
6. Repeat for variations 1, 2, 3, etc.
7. Repeat for edge cases: empty master password, empty phrase, special characters, unicode

---

## 6. UI Refactoring — Screen by Screen

### 6.1 — `main.dart` (App Entry Point)

```dart
// filepath: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait orientation on mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const PassgrinderApp());
}

class PassgrinderApp extends StatelessWidget {
  const PassgrinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passgrinder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Follow system setting
      home: const HomeScreen(),
    );
  }
}
```

**Differences from desktop**:
- **Remove** `window_manager` initialization (fixed window size, title bar config)
- **Remove** `tray_manager` setup (macOS menu bar)
- **Add** portrait orientation lock (`SystemChrome.setPreferredOrientations`)
- **Remove** any `windowSize` or `setWindowTitle` calls

### 6.2 — `home_screen.dart` (Main Screen)

The desktop uses a fixed 500×450 window. On mobile, we need a **scrollable, responsive layout**.

```dart
// filepath: lib/screens/home_screen.dart

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

  // Number of variations to offer (match desktop exactly)
  static const int variationCount = 4; // Adjust to match desktop

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

  // MOBILE-SPECIFIC: Clear fields when app goes to background
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
    final phrase = _uniquePhraseController.text;

    if (master.isEmpty || phrase.isEmpty) {
      setState(() => _generatedPassword = '');
      return;
    }

    setState(() {
      _generatedPassword = PasswordGenerator.generate(
        masterPassword: master,
        uniquePhrase: phrase,
        variation: _selectedVariation,
      );
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
        // MOBILE: Use resizeToAvoidBottomInset to handle keyboard
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Passgrinder'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            // MOBILE: Scrollable to handle small screens + keyboard
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
```

**Key differences from desktop**:

| Aspect | Desktop | Mobile |
|---|---|---|
| Layout container | Fixed window (500×450) | `SingleChildScrollView` + `SafeArea` |
| Keyboard dismiss | Not needed (physical keyboard) | `GestureDetector` → `unfocus()` on tap outside |
| Keyboard avoidance | N/A | `resizeToAvoidBottomInset: true` |
| App lifecycle | Window focus/blur events | `WidgetsBindingObserver` → `didChangeAppLifecycleState` |
| Security on background | No action needed | **Clear all fields when app goes to background** |
| Navigation | Tab/Arrow key focus | Touch-based, `TextInputAction.next` for field advance |
| Safe area | N/A | `SafeArea` widget to avoid notch/home indicator |

### 6.3 — `master_password_field.dart`

```dart
// filepath: lib/widgets/master_password_field.dart

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
      // MOBILE: advance to next field on "Next" key
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Master Password',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
          tooltip: _obscure ? 'Show password' : 'Hide password',
        ),
      ),
    );
  }
}
```

**Differences from desktop**:
- **Add** `textInputAction: TextInputAction.next` so the mobile keyboard shows a "Next" button to advance to the Unique Phrase field
- **Add** `autocorrect: false` and `enableSuggestions: false` to prevent the mobile keyboard from suggesting/autocorrecting passwords
- The visibility toggle logic is **identical** to desktop

### 6.4 — `unique_phrase_field.dart`

```dart
// filepath: lib/widgets/unique_phrase_field.dart

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
      // MOBILE: "Done" dismisses the keyboard after last text field
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Unique Phrase',
        border: OutlineInputBorder(),
        hintText: 'e.g. github.com',
      ),
    );
  }
}
```

### 6.5 — `variation_selector.dart`

```dart
// filepath: lib/widgets/variation_selector.dart

import 'package:flutter/material.dart';

class VariationSelector extends StatelessWidget {
  final int count;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const VariationSelector({
    super.key,
    required this.count,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variation',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        // MOBILE: Wrap chips so they flow to next line on narrow screens
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(count, (index) {
            final isSelected = index == selectedIndex;
            return ChoiceChip(
              label: Text('${index + 1}'),
              selected: isSelected,
              onSelected: (_) => onChanged(index),
              // MOBILE: Ensure minimum touch target of 48x48
              materialTapTargetSize: MaterialTapTargetSize.padded,
            );
          }),
        ),
      ],
    );
  }
}
```

**Differences from desktop**:
- Desktop uses arrow key navigation through a radio group. **Remove** keyboard focus/arrow-key logic entirely.
- Use `ChoiceChip` with `Wrap` layout for touch-friendly interaction.
- Ensure each chip meets the **48×48 dp minimum touch target** (Material Design guideline). `MaterialTapTargetSize.padded` ensures this.
- Desktop may use a compact row — mobile should use `Wrap` to handle narrow widths gracefully.

### 6.6 — `password_output.dart`

```dart
// filepath: lib/widgets/password_output.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: SelectableText(
            hasPassword ? password : 'Enter master password and phrase',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              color: hasPassword
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Copy button — MOBILE: full-width, tall touch target
        SizedBox(
          height: 48, // Minimum 48dp touch target
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
```

**Differences from desktop**:
- Desktop has a compact copy button. Mobile should be **full-width** for easy thumb reach.
- Button height must be **at least 48dp** (Material touch target).
- Use `SelectableText` so users can long-press to select on mobile.
- Consider adding **haptic feedback** on copy (see clipboard helper below).

---

## 7. Platform-Specific Differences

### 7.1 — Remove Desktop-Only Code

When copying from the desktop repo, **remove or do not port** the following:

| Desktop Feature | File(s) | Reason |
|---|---|---|
| Window size configuration | `main.dart`, possibly `macos/`, `linux/`, `windows/` | Mobile apps are always full-screen |
| Menu bar / system tray | `main.dart` or separate tray service | No system tray on mobile |
| Title bar customization | `main.dart` | Mobile uses standard app bar |
| Keyboard focus management (Tab order) | `home_screen.dart` | Mobile uses touch; replace with `textInputAction` |
| Arrow key variation cycling | `home_screen.dart` or variation widget | Replace with touch-based `ChoiceChip` |
| `FocusNode` / `FocusTraversalGroup` | Various widgets | Not needed for mobile |
| Platform-specific window setup | `scripts/`, platform runner folders | Replace with mobile platform config |

### 7.2 — Add Mobile-Only Features

| Feature | Implementation | Why |
|---|---|---|
| **Background security** | `didChangeAppLifecycleState` → clear fields | Prevent password exposure in app switcher |
| **Secure screen** | `FlutterWindowManager` or `FLAG_SECURE` | Prevent screenshots (optional, see below) |
| **Haptic feedback** | `HapticFeedback.mediumImpact()` on copy | Tactile confirmation |
| **Portrait lock** | `SystemChrome.setPreferredOrientations` | App is designed for portrait use |
| **Keyboard management** | `GestureDetector` to dismiss, `TextInputAction` | Standard mobile UX pattern |
| **Safe area** | `SafeArea` widget | Avoid notch, status bar, home indicator |

### 7.3 — Optional: Prevent Screenshots (Enhanced Security)

For sensitive apps, prevent screenshots in the app switcher:

**Android** — in `android/app/src/main/kotlin/.../MainActivity.kt`:
```kotlin
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }
}
```

**iOS** — this is more complex and optional. Can be deferred to a later version.

---

## 8. Theming & Styling

### 8.1 — `app_theme.dart`

Port the desktop theme but adjust for mobile:

```dart
// filepath: lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Copy exact colors from desktop app's theme
  // Look in the desktop repo's theme file or main.dart for color values

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.blue, // REPLACE with desktop app's primary color
    // MOBILE: Larger text for readability
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        // MOBILE: Taller input fields for touch targets
        vertical: 16,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.blue, // REPLACE with desktop app's primary color
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
```

**Key adjustments for mobile**:
- `contentPadding` in `InputDecorationTheme` is **larger** (16 vertical vs desktop's likely 8-12) for finger-sized touch targets
- Button `minimumSize` is `48dp` height
- Font sizes may need a bump if desktop used small text for its compact window

---

## 9. Keyboard & Input Handling

### 9.1 — Remove Desktop Keyboard Navigation

The desktop app has extensive keyboard navigation:
- Tab through: Master Password → Unique Phrase → Radio Group → Copy button
- Arrow keys cycle through password variations

**For mobile, remove all of this.** Instead:

1. **`textInputAction: TextInputAction.next`** on Master Password field — virtual keyboard shows "Next" button
2. **`textInputAction: TextInputAction.done`** on Unique Phrase field — virtual keyboard shows "Done" button, dismisses keyboard
3. **Touch-based variation selection** — tap `ChoiceChip` widgets
4. **No `FocusNode` management** needed (remove from desktop code)
5. **No `FocusTraversalGroup`** needed (remove from desktop code)
6. **No `RawKeyboardListener`** or `KeyboardListener` needed (remove from desktop code)

### 9.2 — Keyboard Dismissal

```dart
// In home_screen.dart build method, wrap Scaffold in:
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  child: Scaffold(/* ... */),
)
```

This dismisses the on-screen keyboard when the user taps outside text fields.

---

## 10. Auto-Reset Timer

Port the auto-reset timer but add **mobile lifecycle awareness**:

```dart
// filepath: lib/utils/auto_reset_timer.dart

import 'dart:async';
import 'package:flutter/foundation.dart';

class AutoResetTimer {
  final Duration duration;
  final VoidCallback onReset;
  Timer? _timer;

  AutoResetTimer({
    required this.duration,
    required this.onReset,
  });

  /// Call this on every user interaction to restart the countdown.
  void reset() {
    _timer?.cancel();
    _timer = Timer(duration, () {
      onReset();
    });
  }

  /// Cancel the timer entirely (e.g. when widget is disposed).
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
```

**Mobile-specific addition**: In `HomeScreen`, also clear fields when the app goes to background (already shown in Section 6.2 via `didChangeAppLifecycleState`). This is **more aggressive** than the desktop behavior because:
- On desktop, the window stays visible — clearing on blur would be annoying
- On mobile, backgrounding means switching apps — sensitive data should be cleared

---

## 11. Clipboard Integration

```dart
// filepath: lib/utils/clipboard_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClipboardHelper {
  /// Copies [text] to clipboard and shows a SnackBar confirmation.
  /// Also triggers haptic feedback on mobile.
  static Future<void> copyAndNotify(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));

    // MOBILE: Haptic feedback for tactile confirmation
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
```

**Differences from desktop**:
- **Add haptic feedback** (`HapticFeedback.mediumImpact()`) — not available on desktop
- **Use `SnackBar`** instead of any desktop-style tooltip or notification
- Use `SnackBarBehavior.floating` for modern Material 3 look
- Check `context.mounted` before showing SnackBar (async gap safety)

---

## 12. Assets & Icons

### 12.1 — App Icon

1. Copy the app icon source file from `assets/` in the desktop repo
2. Place it as `assets/icons/app_icon.png` (1024×1024 minimum)

### 12.2 — Generate Platform Icons

Use the `flutter_launcher_icons` package:

Add to `dev_dependencies` in `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1
```

Create `flutter_launcher_icons.yaml` in project root:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"    # Match desktop app's background
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"

  # iOS specific
  remove_alpha_ios: true
```

Run:
```bash
dart run flutter_launcher_icons
```

### 12.3 — Splash Screen (Optional)

Use `flutter_native_splash` for a branded launch experience:

```yaml
# flutter_native_splash.yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: "assets/icons/app_icon.png"
  android: true
  ios: true
  android_12:
    color: "#FFFFFF"
    icon_background_color: "#FFFFFF"
    image: "assets/icons/app_icon.png"
```

Run:
```bash
dart run flutter_native_splash:create
```

---

## 13. Testing

### 13.1 — Unit Tests (Password Generator Parity)

This is the **most critical test** — the mobile app must generate identical passwords to the desktop app.

```dart
// filepath: test/services/password_generator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:passgrinder_mobile/services/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    // IMPORTANT: Record these expected values from the DESKTOP app
    // Run the desktop app, input these values, and copy the output
    
    test('generates consistent output for known inputs', () {
      final result = PasswordGenerator.generate(
        masterPassword: 'test123',
        uniquePhrase: 'github.com',
        variation: 0,
      );
      // REPLACE with actual output from desktop app:
      expect(result, equals('PASTE_DESKTOP_OUTPUT_HERE'));
    });

    test('different variations produce different passwords', () {
      final v0 = PasswordGenerator.generate(
        masterPassword: 'test123',
        uniquePhrase: 'github.com',
        variation: 0,
      );
      final v1 = PasswordGenerator.generate(
        masterPassword: 'test123',
        uniquePhrase: 'github.com',
        variation: 1,
      );
      expect(v0, isNot(equals(v1)));
    });

    test('empty master password returns empty string', () {
      final result = PasswordGenerator.generate(
        masterPassword: '',
        uniquePhrase: 'github.com',
        variation: 0,
      );
      expect(result, isEmpty);
    });

    test('empty unique phrase returns empty string', () {
      final result = PasswordGenerator.generate(
        masterPassword: 'test123',
        uniquePhrase: '',
        variation: 0,
      );
      expect(result, isEmpty);
    });

    test('handles special characters', () {
      final result = PasswordGenerator.generate(
        masterPassword: 'p@ss!w0rd#\$%',
        uniquePhrase: 'tëst.çom/pàth?q=1&b=2',
        variation: 0,
      );
      expect(result, isNotEmpty);
      // REPLACE with actual output from desktop app:
      expect(result, equals('PASTE_DESKTOP_OUTPUT_HERE'));
    });

    test('handles unicode input', () {
      final result = PasswordGenerator.generate(
        masterPassword: '密码测试',
        uniquePhrase: '网站.com',
        variation: 0,
      );
      expect(result, isNotEmpty);
    });
  });
}
```

### 13.2 — Widget Tests

```dart
// filepath: test/widgets/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passgrinder_mobile/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders all input fields and controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      expect(find.text('Master Password'), findsOneWidget);
      expect(find.text('Unique Phrase'), findsOneWidget);
      expect(find.text('Variation'), findsOneWidget);
      expect(find.text('Copy Password'), findsOneWidget);
    });

    testWidgets('copy button is disabled when no password generated',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Copy Password'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('generates password when both fields have text',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Master Password'),
        'test123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Unique Phrase'),
        'github.com',
      );
      await tester.pump();

      // The password output should no longer show placeholder
      expect(
        find.text('Enter master password and phrase'),
        findsNothing,
      );
    });

    testWidgets('variation chips are tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      // Tap variation 2
      await tester.tap(find.text('2'));
      await tester.pump();

      // Verify chip 2 is selected (check ChoiceChip selected state)
      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, '2'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('visibility toggle works on master password', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeScreen()),
      );

      // Initially obscured
      final textField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Master Password'),
      );
      expect(textField.obscureText, isTrue);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now visible
      final updatedTextField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Master Password'),
      );
      expect(updatedTextField.obscureText, isFalse);
    });
  });
}
```

### 13.3 — Auto-Reset Timer Test

```dart
// filepath: test/utils/auto_reset_timer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:passgrinder_mobile/utils/auto_reset_timer.dart';

void main() {
  group('AutoResetTimer', () {
    test('calls onReset after duration', () async {
      bool wasReset = false;
      final timer = AutoResetTimer(
        duration: const Duration(milliseconds: 100),
        onReset: () => wasReset = true,
      );

      timer.reset(); // Start the timer
      await Future.delayed(const Duration(milliseconds: 150));
      expect(wasReset, isTrue);

      timer.dispose();
    });

    test('restarting timer delays the reset', () async {
      bool wasReset = false;
      final timer = AutoResetTimer(
        duration: const Duration(milliseconds: 100),
        onReset: () => wasReset = true,
      );

      timer.reset();
      await Future.delayed(const Duration(milliseconds: 60));
      timer.reset(); // Restart — should delay another 100ms
      await Future.delayed(const Duration(milliseconds: 60));
      expect(wasReset, isFalse); // Should NOT have fired yet
      await Future.delayed(const Duration(milliseconds: 60));
      expect(wasReset, isTrue); // Now it should have fired

      timer.dispose();
    });

    test('dispose cancels pending timer', () async {
      bool wasReset = false;
      final timer = AutoResetTimer(
        duration: const Duration(milliseconds: 100),
        onReset: () => wasReset = true,
      );

      timer.reset();
      timer.dispose();
      await Future.delayed(const Duration(milliseconds: 150));
      expect(wasReset, isFalse);
    });
  });
}
```

---

## 14. CI/CD with GitHub Actions

Create a workflow for mobile builds:

```yaml
# filepath: .github/workflows/build.yml

name: Build Mobile

on:
  push:
    branches: [main]
    tags: ['*']
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/')
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build apk --release
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: startsWith(github.ref, 'refs/tags/')
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      - run: flutter pub get
      # Build unsigned IPA (signing requires certificates)
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: build/ios/iphoneos/Runner.app

  release:
    needs: [build-android, build-ios]
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/')
    permissions:
      contents: write
    steps:
      - uses: actions/download-artifact@v4
      - uses: softprops/action-gh-release@v2
        with:
          files: |
            android-release/flutter-apk/app-release.apk
          draft: true
```

---

## 15. Build & Release

### 15.1 — Android

```bash
# Debug build
flutter run

# Release APK
flutter build apk --release

# Release App Bundle (for Play Store)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### 15.2 — iOS

```bash
# Debug build (simulator)
flutter run

# Release build (requires Apple Developer account + signing)
flutter build ios --release

# Archive for App Store
# Open in Xcode: ios/Runner.xcworkspace
# Product → Archive → Distribute
```

### 15.3 — Signing Setup

**Android** — Create `android/key.properties` (do NOT commit):
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=passgrinder
storeFile=/path/to/your/keystore.jks
```

Add to `android/app/build.gradle`:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('android/key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**iOS** — Configure in Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target → Signing & Capabilities
3. Select your Team (requires Apple Developer account)
4. Set Bundle Identifier to `com.jeremycaris.passgrinder`

---

## 16. Checklist

### Phase 1: Project Setup
- [ ] Run `flutter create` with correct org and platforms
- [ ] Configure `pubspec.yaml` with correct dependencies
- [ ] Create directory structure (`lib/`, `assets/`, `test/`)
- [ ] Verify blank app runs on iOS simulator and Android emulator

### Phase 2: Core Logic (MUST BE FIRST)
- [ ] Copy `password_generator.dart` from desktop repo **exactly**
- [ ] Write parity tests with known desktop input/output pairs
- [ ] Run tests and confirm **100% output parity** with desktop
- [ ] Test edge cases: empty inputs, special chars, unicode, long strings

### Phase 3: UI Implementation
- [ ] Implement `app_theme.dart` (light + dark, matching desktop colors)
- [ ] Implement `master_password_field.dart` with visibility toggle
- [ ] Implement `unique_phrase_field.dart`
- [ ] Implement `variation_selector.dart` with touch-friendly chips
- [ ] Implement `password_output.dart` with copy button
- [ ] Implement `home_screen.dart` assembling all widgets
- [ ] Implement `main.dart` with theme, orientation lock

### Phase 4: Utilities
- [ ] Implement `auto_reset_timer.dart`
- [ ] Implement `clipboard_helper.dart` with haptic feedback
- [ ] Add `didChangeAppLifecycleState` for background security

### Phase 5: Polish
- [ ] Generate app icons with `flutter_launcher_icons`
- [ ] (Optional) Add splash screen with `flutter_native_splash`
- [ ] (Optional) Add screenshot prevention (`FLAG_SECURE`)
- [ ] Test on multiple screen sizes (small phone, large phone, tablet)
- [ ] Test dark mode and light mode
- [ ] Test with system font scaling (accessibility)

### Phase 6: Testing
- [ ] All unit tests pass (`flutter test`)
- [ ] All widget tests pass
- [ ] Manual test: password parity with desktop app (3+ input combinations)
- [ ] Manual test: auto-reset after 1 minute
- [ ] Manual test: fields clear when app backgrounded
- [ ] Manual test: keyboard dismissal on tap outside
- [ ] Run `flutter analyze` with zero issues

### Phase 7: Build & Release
- [ ] Set up Android signing
- [ ] Set up iOS signing (Apple Developer account)
- [ ] Create GitHub Actions workflow
- [ ] Tag first release
- [ ] Build APK and test on physical Android device
- [ ] Build IPA and test on physical iOS device

---

## Appendix: Quick Reference — Desktop vs Mobile

| Feature | Desktop | Mobile |
|---|---|---|
| Window size | Fixed 500×450 | Full screen, responsive |
| System tray | macOS menu bar | Not applicable |
| Keyboard navigation | Tab, Arrow keys | Virtual keyboard "Next"/"Done" |
| Variation selection | Arrow keys on radio group | Touch `ChoiceChip` |
| Copy feedback | May use tooltip | `SnackBar` + haptic feedback |
| Security on hide | None needed | Clear fields on background |
| Orientation | Landscape/Portrait both | Portrait locked |
| Touch targets | N/A | Minimum 48×48 dp |
| Safe area | N/A | `SafeArea` for notch/home bar |
| Scrolling | Not needed (fixed size) | `SingleChildScrollView` |
| Password algorithm | SHA-256 based | **IDENTICAL** — same code |
| Theme | System follow | System follow (same) |
| Platforms | macOS, Windows, Linux | iOS, Android |
