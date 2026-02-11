import 'package:flutter_test/flutter_test.dart';
import 'package:khair_ul_madaaris_library/services/google_sheets_service.dart';

void main() {
  group('GoogleSheetsService.findMatchingRowNumbersInBatch', () {
    test('finds exact ID row numbers and ignores malformed rows above', () {
      final rows = <List<dynamic>>[
        <dynamic>[],
        <dynamic>['   '],
        <dynamic>['LIB-001', 'Book A'],
        <dynamic>['LIB-002', 'Book B'],
        <dynamic>['LIB-003', 'Book C'],
      ];

      final result = GoogleSheetsService.findMatchingRowNumbersInBatch(
        rows: rows,
        startRow: 2,
        bookId: 'LIB-002',
      );

      expect(result, <int>[5]);
    });

    test('matches using trimmed values', () {
      final rows = <List<dynamic>>[
        <dynamic>[' LIB-010 ', 'Book X'],
      ];

      final result = GoogleSheetsService.findMatchingRowNumbersInBatch(
        rows: rows,
        startRow: 2,
        bookId: 'LIB-010',
      );

      expect(result, <int>[2]);
    });

    test('returns all matching rows to allow duplicate-ID detection', () {
      final rows = <List<dynamic>>[
        <dynamic>['LIB-100', 'A'],
        <dynamic>['LIB-200', 'B'],
        <dynamic>['LIB-100', 'C'],
      ];

      final result = GoogleSheetsService.findMatchingRowNumbersInBatch(
        rows: rows,
        startRow: 10,
        bookId: 'LIB-100',
      );

      expect(result, <int>[10, 12]);
    });
  });
}
