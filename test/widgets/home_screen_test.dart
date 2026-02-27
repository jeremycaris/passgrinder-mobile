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
      expect(find.text('Unique Phrase (optional)'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Variation 1'), findsOneWidget);
      // Password output area (copy icon)
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('copy icon is disabled when no password generated',
        (tester) async {
      await tester.pumpWidget(buildApp());

      // Find the copy icon button
      final copyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.copy),
      );
      expect(copyButton.onPressed, isNull);
    });

    testWidgets('generates password when master password has text',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Master Password'),
        'test123',
      );
      await tester.pump();

      // Copy icon should now be enabled
      final copyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.copy),
      );
      expect(copyButton.onPressed, isNotNull);
    });

    testWidgets('generates different password with both fields',
        (tester) async {
      await tester.pumpWidget(buildApp());

      await tester.enterText(
        find.widgetWithText(TextField, 'Master Password'),
        'test123',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Unique Phrase (optional)'),
        'github.com',
      );
      await tester.pump();

      // Copy icon should be enabled
      final copyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.copy),
      );
      expect(copyButton.onPressed, isNotNull);
    });

    testWidgets('variation radio buttons are tappable', (tester) async {
      await tester.pumpWidget(buildApp());

      // Tap Variation 1 label
      await tester.tap(find.text('Variation 1'));
      await tester.pump();

      // The radio for index 1 should now be selected via RadioGroup
      final radioGroup = tester.widget<RadioGroup<int>>(
        find.byType(RadioGroup<int>),
      );
      expect(radioGroup.groupValue, equals(1));
    });

    testWidgets('default variation is initially selected', (tester) async {
      await tester.pumpWidget(buildApp());

      final radioGroup = tester.widget<RadioGroup<int>>(
        find.byType(RadioGroup<int>),
      );
      expect(radioGroup.groupValue, equals(0));
    });

    testWidgets('visibility toggle works on master password', (tester) async {
      await tester.pumpWidget(buildApp());

      // Initially obscured
      final textField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Master Password'),
      );
      expect(textField.obscureText, isTrue);

      // Find the visibility icon in the master password field area
      // Master password uses Icons.visibility (show) when obscured
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      // Now visible
      final updatedTextField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Master Password'),
      );
      expect(updatedTextField.obscureText, isFalse);
    });

    testWidgets('shows 4 variation radio buttons', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(find.byType(Radio<int>), findsNWidgets(4));
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Variation 1'), findsOneWidget);
      expect(find.text('Variation 2'), findsOneWidget);
      expect(find.text('Variation 3'), findsOneWidget);
    });

    testWidgets('reset icon clears fields and password', (tester) async {
      await tester.pumpWidget(buildApp());

      // Enter text to generate password
      await tester.enterText(
        find.widgetWithText(TextField, 'Master Password'),
        'test123',
      );
      await tester.pump();

      // Reset should be enabled
      final resetButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.restart_alt),
      );
      expect(resetButton.onPressed, isNotNull);

      // Tap reset
      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pump();

      // Copy icon should be disabled again
      final copyButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.copy),
      );
      expect(copyButton.onPressed, isNull);
    });

    testWidgets('helper text is displayed', (tester) async {
      await tester.pumpWidget(buildApp());

      expect(
        find.textContaining('Use the website URL, domain name'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Use a variation if you are required'),
        findsOneWidget,
      );
    });
  });
}
