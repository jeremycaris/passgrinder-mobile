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
