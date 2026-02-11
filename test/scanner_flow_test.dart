import 'package:flutter_test/flutter_test.dart';
import 'package:khair_ul_madaaris_library/features/scanner/scan_flow.dart';
import 'package:khair_ul_madaaris_library/models/book.dart';

void main() {
  group('resolveScannerAction', () {
    test('returns checkout for available books', () {
      expect(
        resolveScannerAction(BookStatus.available),
        ScannerAction.checkout,
      );
    });

    test('returns returnBook for checked out books', () {
      expect(
        resolveScannerAction(BookStatus.checkedOut),
        ScannerAction.returnBook,
      );
    });

    test('returns returnBook for overdue books', () {
      expect(
        resolveScannerAction(BookStatus.overdue),
        ScannerAction.returnBook,
      );
    });

    test('returns unavailable for non-circulating statuses', () {
      expect(
        resolveScannerAction(BookStatus.reserved),
        ScannerAction.unavailable,
      );
      expect(
        resolveScannerAction(BookStatus.damaged),
        ScannerAction.unavailable,
      );
      expect(resolveScannerAction(BookStatus.lost), ScannerAction.unavailable);
    });
  });
}
