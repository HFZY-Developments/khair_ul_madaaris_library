import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Book Model - Represents a library book with all its metadata
class Book {
  final String bookId;
  final String title;
  final String author;
  final String category;
  final String shelf;
  final BookStatus status;
  final String? borrowerName;
  final DateTime? checkoutDate;
  final DateTime addedDate;

  const Book({
    required this.bookId,
    required this.title,
    required this.author,
    required this.category,
    required this.shelf,
    required this.status,
    this.borrowerName,
    this.checkoutDate,
    required this.addedDate,
  });

  /// Calculate days since checkout
  int? get daysSinceCheckout {
    if (checkoutDate == null) return null;
    return DateTime.now().difference(checkoutDate!).inDays;
  }

  /// Check if book is overdue (>14 days)
  bool get isOverdue {
    final days = daysSinceCheckout;
    return days != null && days > 14;
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case BookStatus.available:
        return AppColors.statusAvailable;
      case BookStatus.checkedOut:
        return isOverdue ? AppColors.statusOverdue : AppColors.statusCheckedOut;
      case BookStatus.overdue:
        return AppColors.statusOverdue;
      case BookStatus.reserved:
        return AppColors.statusReserved;
      case BookStatus.damaged:
        return AppColors.statusDamaged;
      case BookStatus.lost:
        return AppColors.statusLost;
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case BookStatus.available:
        return AppConstants.statusAvailable;
      case BookStatus.checkedOut:
        return isOverdue ? AppConstants.statusOverdue : AppConstants.statusCheckedOut;
      case BookStatus.overdue:
        return AppConstants.statusOverdue;
      case BookStatus.reserved:
        return AppConstants.statusReserved;
      case BookStatus.damaged:
        return AppConstants.statusDamaged;
      case BookStatus.lost:
        return AppConstants.statusLost;
    }
  }

  /// Get status icon
  IconData get statusIcon {
    switch (status) {
      case BookStatus.available:
        return Icons.check_circle;
      case BookStatus.checkedOut:
        return isOverdue ? Icons.error : Icons.schedule;
      case BookStatus.overdue:
        return Icons.error;
      case BookStatus.reserved:
        return Icons.bookmark;
      case BookStatus.damaged:
        return Icons.report_problem;
      case BookStatus.lost:
        return Icons.help_outline;
    }
  }

  /// Create a copy with updated fields
  Book copyWith({
    String? bookId,
    String? title,
    String? author,
    String? category,
    String? shelf,
    BookStatus? status,
    String? borrowerName,
    DateTime? checkoutDate,
    DateTime? addedDate,
    bool clearBorrower = false,
    bool clearCheckoutDate = false,
  }) {
    return Book(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      shelf: shelf ?? this.shelf,
      status: status ?? this.status,
      borrowerName: clearBorrower ? null : (borrowerName ?? this.borrowerName),
      checkoutDate: clearCheckoutDate ? null : (checkoutDate ?? this.checkoutDate),
      addedDate: addedDate ?? this.addedDate,
    );
  }

  /// Convert to JSON for local caching
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'category': category,
      'shelf': shelf,
      'status': status.name,
      'borrowerName': borrowerName,
      'checkoutDate': checkoutDate?.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      category: json['category'] as String? ?? '',
      shelf: json['shelf'] as String? ?? '',
      status: BookStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookStatus.available,
      ),
      borrowerName: json['borrowerName'] as String?,
      checkoutDate: json['checkoutDate'] != null
          ? DateTime.parse(json['checkoutDate'] as String)
          : null,
      addedDate: json['addedDate'] != null
          ? DateTime.parse(json['addedDate'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to Google Sheets row format
  /// Row format: [Book ID, Title, Shelf, Category/Genre, Status, Borrower Name, Checkout Date]
  List<String> toSheetsRow() {
    return [
      bookId,
      title,
      shelf,
      category,
      statusText,
      borrowerName ?? '',
      checkoutDate != null
          ? '${checkoutDate!.year}-${checkoutDate!.month.toString().padLeft(2, '0')}-${checkoutDate!.day.toString().padLeft(2, '0')}'
          : '',
    ];
  }

  /// Create from Google Sheets row
  /// Row format: [Book ID, Title, Shelf, Category/Genre, Status, Borrower Name, Checkout Date]
  factory Book.fromSheetsRow(List<dynamic> row) {
    if (row.isEmpty) {
      throw Exception('Empty row data');
    }

    final bookId = row.isNotEmpty ? row[0].toString() : '';
    final title = row.length > 1 ? row[1].toString() : '';
    final shelf = row.length > 2 ? row[2].toString() : '';
    final category = row.length > 3 ? row[3].toString() : '';
    final statusStr = row.length > 4 ? row[4].toString() : AppConstants.statusAvailable;
    final borrowerName = row.length > 5 && row[5].toString().isNotEmpty
        ? row[5].toString()
        : null;
    final checkoutDateStr = row.length > 6 && row[6].toString().isNotEmpty
        ? row[6].toString()
        : null;

    // Parse status
    BookStatus status;
    if (statusStr.toLowerCase().contains('checked out')) {
      status = BookStatus.checkedOut;
    } else if (statusStr.toLowerCase().contains('overdue')) {
      status = BookStatus.overdue;
    } else if (statusStr.toLowerCase().contains('reserved')) {
      status = BookStatus.reserved;
    } else if (statusStr.toLowerCase().contains('damaged')) {
      status = BookStatus.damaged;
    } else if (statusStr.toLowerCase().contains('lost')) {
      status = BookStatus.lost;
    } else {
      status = BookStatus.available;
    }

    // Parse checkout date
    DateTime? checkoutDate;
    if (checkoutDateStr != null) {
      try {
        print('DEBUG PARSE: Raw checkout date string from sheets: "$checkoutDateStr" (length: ${checkoutDateStr.length})');

        // Try standard ISO format first (YYYY-MM-DD)
        try {
          checkoutDate = DateTime.parse(checkoutDateStr);
          print('DEBUG PARSE: Successfully parsed as ISO date: $checkoutDate');
        } catch (_) {
          // Google Sheets auto-formats dates to "DD MMM YYYY" (e.g., "26 Oct 2025")
          // We need to parse this format manually
          final parts = checkoutDateStr.trim().split(' ');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]);
            final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            final month = monthNames.indexOf(parts[1]) + 1;
            final year = int.tryParse(parts[2]);

            if (day != null && month > 0 && year != null) {
              checkoutDate = DateTime(year, month, day);
              print('DEBUG PARSE: Successfully parsed Google Sheets date format: $checkoutDate');
            } else {
              print('DEBUG PARSE: Could not parse date parts - day: $day, month: $month, year: $year');
              checkoutDate = null;
            }
          } else {
            print('DEBUG PARSE: Unexpected date format (${parts.length} parts): $checkoutDateStr');
            checkoutDate = null;
          }
        }
      } catch (e) {
        print('DEBUG PARSE: ERROR parsing checkout date "$checkoutDateStr": $e');
        checkoutDate = null;
      }
    } else {
      print('DEBUG PARSE: Checkout date string is NULL for book');
    }

    return Book(
      bookId: bookId,
      title: title,
      author: '', // Not in current sheet format, can be added later
      category: category,
      shelf: shelf,
      status: status,
      borrowerName: borrowerName,
      checkoutDate: checkoutDate,
      addedDate: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          bookId == other.bookId;

  @override
  int get hashCode => bookId.hashCode;

  @override
  String toString() {
    return 'Book{bookId: $bookId, title: $title, status: $status}';
  }
}

/// Book Status Enum
enum BookStatus {
  available,
  checkedOut,
  overdue,
  reserved,
  damaged,
  lost,
}

/// Extension methods for BookStatus
extension BookStatusExtension on BookStatus {
  String get displayName {
    switch (this) {
      case BookStatus.available:
        return 'Available';
      case BookStatus.checkedOut:
        return 'Checked Out';
      case BookStatus.overdue:
        return 'Overdue';
      case BookStatus.reserved:
        return 'Reserved';
      case BookStatus.damaged:
        return 'Damaged';
      case BookStatus.lost:
        return 'Lost';
    }
  }
}
