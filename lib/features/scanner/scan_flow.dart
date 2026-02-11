import '../../models/book.dart';

/// Next action for scanner flow after loading a book.
enum ScannerAction { checkout, returnBook, unavailable }

/// Maps book status to scanner action.
///
/// - Available -> checkout
/// - Checked out/Overdue -> return
/// - Any unavailable status -> unavailable action
ScannerAction resolveScannerAction(BookStatus status) {
  switch (status) {
    case BookStatus.available:
      return ScannerAction.checkout;
    case BookStatus.checkedOut:
    case BookStatus.overdue:
      return ScannerAction.returnBook;
    case BookStatus.reserved:
    case BookStatus.damaged:
    case BookStatus.lost:
      return ScannerAction.unavailable;
  }
}
