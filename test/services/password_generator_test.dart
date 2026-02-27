import 'package:flutter_test/flutter_test.dart';
import 'package:passgrinder_mobile/services/password_generator.dart';

void main() {
  group('PasswordGenerator - Desktop Parity', () {
    // These expected values were generated from the desktop app's algorithm.
    // The mobile app MUST produce identical output for the same inputs.

    test('test123 + github.com + variation 0', () {
      final generator = PasswordGenerator(
        masterPassword: 'test123',
        uniquePhrase: 'github.com',
        variation: 0,
      );
      expect(generator.generate(), equals(r'C%tOb0z>t$myrt[+yMw('));
    });

    test('test123 + github.com + variation 1', () {
      final generator = PasswordGenerator(
        masterPassword: 'test123',
        uniquePhrase: 'github.com',
        variation: 1,
      );
      expect(generator.generate(), equals(r'&$YmSaDvGIObgI)32S3a'));
    });

    test('test123 + github.com + variation 2', () {
      final generator = PasswordGenerator(
        masterPassword: 'test123',
        uniquePhrase: 'github.com',
        variation: 2,
      );
      expect(generator.generate(), equals(r')5c*Tug^b*<3m%8v7e9D'));
    });

    test('test123 + github.com + variation 3', () {
      final generator = PasswordGenerator(
        masterPassword: 'test123',
        uniquePhrase: 'github.com',
        variation: 3,
      );
      expect(generator.generate(), equals(r'<uHuuuSmhgb9aDe5=5wv'));
    });

    test('test123 + empty phrase + variation 0', () {
      final generator = PasswordGenerator(
        masterPassword: 'test123',
        uniquePhrase: '',
        variation: 0,
      );
      expect(generator.generate(), equals(r'PtQr58dXzSfH]UaT6Xu7'));
    });

    test('empty master + github.com + variation 0', () {
      final generator = PasswordGenerator(
        masterPassword: '',
        uniquePhrase: 'github.com',
        variation: 0,
      );
      expect(generator.generate(), equals(r'J!2?21lFwqM:3+D81USN'));
    });

    test('special characters in inputs', () {
      final generator = PasswordGenerator(
        masterPassword: r'p@ss!w0rd#$%',
        uniquePhrase: 'test.com/path?q=1&b=2',
        variation: 0,
      );
      expect(generator.generate(), equals(r'}1LSrT&.@Su[Ee-o0ygG'));
    });

    test('mypassword + google.com + variation 0', () {
      final generator = PasswordGenerator(
        masterPassword: 'mypassword',
        uniquePhrase: 'google.com',
        variation: 0,
      );
      expect(generator.generate(), equals(r'-DkeeUq?qBdvYSCl%#:l'));
    });
  });

  group('PasswordGenerator - Properties', () {
    test('always generates 20-character passwords', () {
      final generator = PasswordGenerator(
        masterPassword: 'anypassword',
        uniquePhrase: 'anyphrase',
        variation: 0,
      );
      expect(generator.generate().length, equals(20));
    });

    test('different variations produce different passwords', () {
      final passwords = <String>{};
      for (int v = 0; v < 4; v++) {
        final generator = PasswordGenerator(
          masterPassword: 'test123',
          uniquePhrase: 'github.com',
          variation: v,
        );
        passwords.add(generator.generate());
      }
      expect(passwords.length, equals(4));
    });

    test('same inputs always produce the same output (deterministic)', () {
      final g1 = PasswordGenerator(
        masterPassword: 'test',
        uniquePhrase: 'example.com',
        variation: 0,
      );
      final g2 = PasswordGenerator(
        masterPassword: 'test',
        uniquePhrase: 'example.com',
        variation: 0,
      );
      expect(g1.generate(), equals(g2.generate()));
    });

    test('different master passwords produce different outputs', () {
      final g1 = PasswordGenerator(
        masterPassword: 'password1',
        uniquePhrase: 'example.com',
        variation: 0,
      );
      final g2 = PasswordGenerator(
        masterPassword: 'password2',
        uniquePhrase: 'example.com',
        variation: 0,
      );
      expect(g1.generate(), isNot(equals(g2.generate())));
    });

    test('different unique phrases produce different outputs', () {
      final g1 = PasswordGenerator(
        masterPassword: 'test',
        uniquePhrase: 'site1.com',
        variation: 0,
      );
      final g2 = PasswordGenerator(
        masterPassword: 'test',
        uniquePhrase: 'site2.com',
        variation: 0,
      );
      expect(g1.generate(), isNot(equals(g2.generate())));
    });
  });
}
