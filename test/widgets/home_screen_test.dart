import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passgrinder_mobile/screens/home_screen.dart';
import 'package:passgrinder_mobile/theme/app_theme.dart';

void main() {
  Widget buildApp() {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }

  group('HomeScreen', () {
    testWidgets('renders all input fields and controls', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.text('Master Password'), findsOneWidget);
      expect(find.text('Unique Phrase'), findsOneWidget);
      expect(find.text('Variation'), findsOneWidget);
      expect(find.text('Copy Password'), findsOneWidget);
    });

    testWidgets('copy button is disabled when no password generated',
        (tester) async {
      await tester.pumpWidget(buildApp());

      // Find the button containing 'Copy Password' text
      final buttonFinder = find.ancestor(
        of: find.text('Copy Password'),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('generates password when master password has text',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Master Password'),
        'test123',
      );
      await tester.pump();

      // The password output should no longer show placeholder
      // (desktop generates password even with empty unique phrase)
      expect(
        find.text('Enter master password and phrase'),
        findsNothing,
      );
    });

    testWidgets('generates different password with both fields',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Master Password'),
        'test123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Unique Phrase'),
        'github.com',
      );
      await tester.pump();

      expect(
        find.text('Enter master password and phrase'),
        findsNothing,
      );
    });

    testWidgets('variation chips are tappable', (tester) async {
      await tester.pumpWidget(buildApp());

      // Tap variation 1
      await tester.tap(find.text('Variation 1'));
      await tester.pump();

      // Verify chip is selected
      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Variation 1'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('default variation is initially selected', (tester) async {
      await tester.pumpWidget(buildApp());

      final chip = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Default'),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('visibility toggle works on master password', (tester) async {
      await tester.pumpWidget(buildApp());

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

    testWidgets('shows 4 variation chips', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.byType(ChoiceChip), findsNWidgets(4));
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Variation 1'), findsOneWidget);
      expect(find.text('Variation 2'), findsOneWidget);
      expect(find.text('Variation 3'), findsOneWidget);
    });

    testWidgets('copy button enables when password is generated',
        (tester) async {
      await tester.pumpWidget(buildApp());

      // Enter text to generate password
      await tester.enterText(
        find.widgetWithText(TextField, 'Master Password'),
        'test123',
      );
      await tester.pump();

      final buttonFinder = find.ancestor(
        of: find.text('Copy Password'),
        matching: find.bySubtype<ButtonStyleButton>(),
      );
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<ButtonStyleButton>(buttonFinder);
      expect(button.onPressed, isNotNull);
    });
  });
}
