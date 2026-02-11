import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:khair_ul_madaaris_library/services/app_update_service.dart';

void main() {
  group('AppUpdateService update metadata validation', () {
    test('accepts valid payload with required sha256', () {
      final payload = <String, dynamic>{
        'version': '1.1.0',
        'versionCode': 8,
        'downloadUrl': 'https://example.com/app-release.apk',
        'sha256':
            '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      };

      final parsed = AppUpdateService.parseUpdateInfoForTesting(payload);

      expect(parsed, isNotNull);
      expect(parsed!['versionCode'], 8);
    });

    test('rejects payload when sha256 is missing/invalid', () {
      final missingHash = <String, dynamic>{
        'version': '1.1.0',
        'versionCode': 8,
        'downloadUrl': 'https://example.com/app-release.apk',
      };
      final invalidHash = <String, dynamic>{
        'version': '1.1.0',
        'versionCode': 8,
        'downloadUrl': 'https://example.com/app-release.apk',
        'sha256': 'not-a-real-hash',
      };

      expect(AppUpdateService.parseUpdateInfoForTesting(missingHash), isNull);
      expect(AppUpdateService.parseUpdateInfoForTesting(invalidHash), isNull);
    });
  });

  group('AppUpdateService SHA-256 verification', () {
    test('passes when file bytes match expected hash', () {
      final bytes = Uint8List.fromList(utf8.encode('trusted-apk-bytes'));
      final expected = AppUpdateService.sha256FromBytes(bytes);
      final updateInfo = <String, dynamic>{'sha256': expected};

      final isValid = AppUpdateService.verifySha256ForTesting(
        bytes: bytes,
        updateInfo: updateInfo,
      );

      expect(isValid, isTrue);
    });

    test('fails when file bytes do not match expected hash', () {
      final bytes = Uint8List.fromList(utf8.encode('trusted-apk-bytes'));
      final differentBytes = Uint8List.fromList(utf8.encode('tampered-bytes'));
      final expected = AppUpdateService.sha256FromBytes(bytes);
      final updateInfo = <String, dynamic>{'sha256': expected};

      final isValid = AppUpdateService.verifySha256ForTesting(
        bytes: differentBytes,
        updateInfo: updateInfo,
      );

      expect(isValid, isFalse);
    });
  });
}
