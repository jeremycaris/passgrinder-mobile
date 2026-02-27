import 'dart:convert';

import 'package:crypto/crypto.dart';

class PasswordGenerator {
  final String masterPassword;
  final String uniquePhrase;
  final int variation;

  PasswordGenerator({
    required this.masterPassword,
    required this.uniquePhrase,
    required this.variation,
  });

  /// Mirrors the Chrome extension logic to produce a 20-character password.
  String generate() {
    final masterRaw = md5.convert(utf8.encode(masterPassword)).bytes;
    final saltRaw = md5.convert(utf8.encode(uniquePhrase)).bytes;
    final variationRaw = md5.convert(utf8.encode(variation.toString())).bytes;

    final combinedRawString = StringBuffer()
      ..write(latin1.decode(masterRaw, allowInvalid: true))
      ..write(latin1.decode(saltRaw, allowInvalid: true))
      ..write(latin1.decode(variationRaw, allowInvalid: true));

    final combinedUtf8 = utf8.encode(combinedRawString.toString());
    final finalMd5 = md5.convert(combinedUtf8).bytes;
    return _encodeZ85(finalMd5);
  }

  String _encodeZ85(List<int> bytes) {
    const alphabet =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%\$#';
    final buffer = StringBuffer();

    for (int i = 0; i < bytes.length; i += 4) {
      final value = ((bytes[i] & 0xFF) << 24) |
          ((bytes[i + 1] & 0xFF) << 16) |
          ((bytes[i + 2] & 0xFF) << 8) |
          (bytes[i + 3] & 0xFF);

      final enc1 = value ~/ 52200625; // 85^4
      final enc2 = (value ~/ 614125) % 85; // 85^3
      final enc3 = (value ~/ 7225) % 85; // 85^2
      final enc4 = (value ~/ 85) % 85;
      final enc5 = value % 85;

      buffer
        ..write(alphabet[enc1])
        ..write(alphabet[enc2])
        ..write(alphabet[enc3])
        ..write(alphabet[enc4])
        ..write(alphabet[enc5]);
    }

    return buffer.toString();
  }
}
