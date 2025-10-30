import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/premium_dialogs.dart';
import '../../services/google_sheets_service.dart';
import '../../models/book.dart';
import '../../core/widgets/gradient_button.dart';

class QRScannerScreen extends StatefulWidget {
  final bool isAdmin;

  const QRScannerScreen({super.key, required this.isAdmin});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _showCheckmark = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner view
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              // STRICT CHECK: Prevent multiple detections
              if (_isProcessing) {
                print('DEBUG: Already processing, ignoring detection');
                return;
              }

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

              final code = barcodes.first.rawValue!;
              final now = DateTime.now();

              // DEBOUNCE: Ignore same code within 3 seconds
              if (_lastScannedCode == code &&
                  _lastScanTime != null &&
                  now.difference(_lastScanTime!).inSeconds < 3) {
                print('DEBUG: Same code scanned within 3s, ignoring');
                return;
              }

              // LOCK: Set processing immediately
              setState(() {
                _isProcessing = true;
                _lastScannedCode = code;
                _lastScanTime = now;
              });

              print('DEBUG: QR detected: $code, processing now...');
              _handleQRCode(code);
            },
          ),

          // Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(
              color: widget.isAdmin ? AppColors.primaryLime : AppColors.primaryTeal,
            ),
            child: Container(),
          ),

          // Elegant checkmark animation overlay (EXACT MATCH to original - gradient circle with white check)
          if (_showCheckmark)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryTeal, AppColors.primaryLime],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.6),
                        blurRadius: 80,
                        spreadRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                      BoxShadow(
                        color: AppColors.primaryLime.withValues(alpha: 0.4),
                        blurRadius: 120,
                        spreadRadius: 30,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: EdgeInsets.all(50.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.primaryTeal,
                      size: 70.sp,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 200.ms).scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1.0, 1.0),
              duration: 300.ms,
              curve: Curves.easeOutBack,
            ),

          // Instructions
          Positioned(
            bottom: 32.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Align QR code within frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Future<void> _handleQRCode(String qrCode) async {
    try {
      print('DEBUG: Starting _handleQRCode for: $qrCode');

      // INSTANT FEEDBACK: Universal vibration (works on all Android devices including Xiaomi)
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100); // Short, satisfying vibration
      }

      // Show beautiful checkmark animation (quick but visible - 400ms total)
      if (mounted) {
        setState(() => _showCheckmark = true);
      }

      // Let checkmark show for 400ms then auto-dismiss
      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted) {
        setState(() => _showCheckmark = false);
      }

      if (!mounted) return;

      // Show loading dialog while fetching book data
      showPremiumLoadingDialog(context, message: 'Looking up book...');

      print('DEBUG: Fetching book from Google Sheets with FORCE REFRESH...');
      // CRITICAL: Force refresh to get latest data from sheets (including checkout dates!)
      final book = await GoogleSheetsService.instance.getBookById(qrCode, forceRefresh: true);
      print('DEBUG: Book fetched: ${book?.title ?? "NOT FOUND"}');
      if (book != null) {
        print('DEBUG: Book details - ID: ${book.bookId}, Title: "${book.title}", Shelf: "${book.shelf}", Category: "${book.category}"');
        print('DEBUG: Book checkout date: ${book.checkoutDate}');
      }

      // Dismiss loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      if (book == null) {
        print('DEBUG: Book not found');
        // Book not found
        if (widget.isAdmin) {
          await _showAddBookDialog(qrCode);
        } else {
          await showPremiumErrorDialog(
            context,
            title: 'Book Not Found',
            message: 'Book with ID "$qrCode" is not registered in the system.\n\nPlease contact the administrator.',
            icon: Icons.search_off_rounded,
          );
        }
      } else {
        // CRITICAL: Check if book is incomplete (missing title, shelf, or category)
        final isIncomplete = book.title.trim().isEmpty ||
                             book.shelf.trim().isEmpty ||
                             book.category.trim().isEmpty;

        if (isIncomplete) {
          print('DEBUG: Book is incomplete - title: "${book.title}", shelf: "${book.shelf}", category: "${book.category}"');
          if (widget.isAdmin) {
            // Admin can edit incomplete book
            await _showEditIncompleteBookDialog(book);
          } else {
            // Normal user gets "not found" error
            await showPremiumErrorDialog(
              context,
              title: 'Book Not Found',
              message: 'Book with ID "$qrCode" is not properly registered.\n\nPlease contact the administrator to complete the book registration.',
              icon: Icons.search_off_rounded,
            );
          }
          return;
        }

        // Book found and complete - show action based on status (both admin and normal user)
        print('DEBUG: Book status: ${book.status}');
        if (book.status == BookStatus.available) {
          // Show checkout dialog with book details integrated
          await _showCheckoutDialog(book);
        } else if (book.status == BookStatus.checkedOut) {
          // Show return dialog with book details integrated
          await _showReturnDialog(book);
        } else {
          // Book unavailable (damaged, lost, etc.)
          await showPremiumErrorDialog(
            context,
            title: 'Book Unavailable',
            message: 'This book is currently ${book.statusText.toLowerCase()} and cannot be borrowed.',
            icon: Icons.block_rounded,
          );
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error in _handleQRCode: $e');
      print('DEBUG: Stack trace: $stackTrace');

      // Dismiss any showing dialogs
      while (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      await showPremiumErrorDialog(
        context,
        title: 'Error',
        message: 'Failed to process QR code:\n${e.toString()}',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      // Reset processing flag - scanner keeps running with debounce protection
      print('DEBUG: Resetting _isProcessing flag');
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showAddBookDialog(String bookId) async {
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final shelfController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(28.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.limeGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.primaryDarkBlue,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Book',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'ID: $bookId',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),

              // Form fields
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Book Title *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.book_rounded),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: shelfController,
                decoration: InputDecoration(
                  labelText: 'Shelf Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category/Genre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
              ),
              SizedBox(height: 28.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        await showPremiumErrorDialog(
                          context,
                          title: 'Validation Error',
                          message: 'Book title is required.',
                          icon: Icons.warning_rounded,
                        );
                        return;
                      }

                      // Close dialog first
                      Navigator.pop(context);

                      // Show loading
                      showPremiumLoadingDialog(context, message: 'Adding book...');

                      try {
                        final book = Book(
                          bookId: bookId,
                          title: titleController.text.trim(),
                          author: '',
                          category: categoryController.text.trim(),
                          shelf: shelfController.text.trim(),
                          status: BookStatus.available,
                          addedDate: DateTime.now(),
                        );

                        final success = await GoogleSheetsService.instance.addBook(book);

                        // Dismiss loading
                        if (mounted) Navigator.pop(context);

                        if (!mounted) return;

                        if (success) {
                          await showPremiumSuccessDialog(
                            context,
                            title: 'Book Added!',
                            message: '${book.title} has been successfully added to the library.',
                            icon: Icons.check_circle_rounded,
                            onPrimaryPressed: () {
                              Navigator.pop(context); // Close success
                              Navigator.pop(context); // Close scanner
                            },
                          );
                        } else {
                          await showPremiumErrorDialog(
                            context,
                            title: 'Failed',
                            message: 'Could not add the book. Please try again.',
                            icon: Icons.error_rounded,
                          );
                        }
                      } catch (e) {
                        if (mounted && Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        if (!mounted) return;

                        await showPremiumErrorDialog(
                          context,
                          title: 'Error',
                          message: 'An error occurred:\n${e.toString()}',
                          icon: Icons.error_outline_rounded,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLime,
                      foregroundColor: AppColors.primaryDarkBlue,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Add Book',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ), // Column
        ), // Container
          ), // SingleChildScrollView
          ), // ConstrainedBox
      ), // Dialog
    ); // showDialog
  }

  /// Show dialog to edit incomplete book details (admin only)
  Future<void> _showEditIncompleteBookDialog(Book incompleteBook) async {
    final titleController = TextEditingController(text: incompleteBook.title);
    final categoryController = TextEditingController(text: incompleteBook.category);
    final shelfController = TextEditingController(text: incompleteBook.shelf);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(28.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.limeGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppColors.primaryDarkBlue,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Book Details',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'ID: ${incompleteBook.bookId}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),

              // Form fields
              TextField(
                controller: titleController,
                autofocus: incompleteBook.title.trim().isEmpty,
                decoration: InputDecoration(
                  labelText: 'Book Title *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.book_rounded),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: shelfController,
                autofocus: incompleteBook.title.trim().isNotEmpty && incompleteBook.shelf.trim().isEmpty,
                decoration: InputDecoration(
                  labelText: 'Shelf Location *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: categoryController,
                autofocus: incompleteBook.title.trim().isNotEmpty &&
                          incompleteBook.shelf.trim().isNotEmpty &&
                          incompleteBook.category.trim().isEmpty,
                decoration: InputDecoration(
                  labelText: 'Category/Genre *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
              ),
              SizedBox(height: 28.h),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () async {
                      final dialogContext = context; // Capture dialog context

                      // Validate all required fields
                      if (titleController.text.trim().isEmpty) {
                        await showPremiumErrorDialog(
                          dialogContext,
                          title: 'Validation Error',
                          message: 'Book title is required.',
                          icon: Icons.warning_rounded,
                        );
                        return;
                      }

                      if (shelfController.text.trim().isEmpty) {
                        await showPremiumErrorDialog(
                          dialogContext,
                          title: 'Validation Error',
                          message: 'Shelf location is required.',
                          icon: Icons.warning_rounded,
                        );
                        return;
                      }

                      if (categoryController.text.trim().isEmpty) {
                        await showPremiumErrorDialog(
                          dialogContext,
                          title: 'Validation Error',
                          message: 'Category/Genre is required.',
                          icon: Icons.warning_rounded,
                        );
                        return;
                      }

                      // Close edit dialog first
                      Navigator.of(dialogContext).pop();

                      // Show loading (using scanner screen context via mounted state)
                      if (!mounted) return;
                      showPremiumLoadingDialog(this.context, message: 'Updating book...');

                      try {
                        print('DEBUG EDIT: Updating incomplete book - ID: ${incompleteBook.bookId}');
                        print('DEBUG EDIT: New values - Title: "${titleController.text.trim()}", Shelf: "${shelfController.text.trim()}", Category: "${categoryController.text.trim()}"');

                        // Create updated book with complete details
                        final updatedBook = Book(
                          bookId: incompleteBook.bookId,
                          title: titleController.text.trim(),
                          author: incompleteBook.author,
                          category: categoryController.text.trim(),
                          shelf: shelfController.text.trim(),
                          status: incompleteBook.status,
                          borrowerName: incompleteBook.borrowerName,
                          checkoutDate: incompleteBook.checkoutDate,
                          addedDate: incompleteBook.addedDate,
                        );

                        print('DEBUG EDIT: Calling updateBook...');
                        final success = await GoogleSheetsService.instance.updateBook(updatedBook).timeout(
                          const Duration(seconds: 30),
                          onTimeout: () {
                            print('DEBUG EDIT: updateBook TIMED OUT after 30 seconds');
                            throw Exception('Update operation timed out. Please check your internet connection and try again.');
                          },
                        );
                        print('DEBUG EDIT: updateBook returned: $success');

                        // Dismiss loading dialog
                        print('DEBUG EDIT: About to dismiss loading, mounted=$mounted');
                        if (!mounted) return;
                        Navigator.of(this.context).pop();
                        print('DEBUG EDIT: Loading dismissed');

                        print('DEBUG EDIT: Checking mounted again, mounted=$mounted');
                        if (!mounted) return;

                        print('DEBUG EDIT: About to show success dialog, success=$success');
                        if (success) {
                          // Success! Double vibration pattern like checkout/return
                          print('DEBUG EDIT: Triggering success vibration');
                          if (await Vibration.hasVibrator() ?? false) {
                            Vibration.vibrate(pattern: [0, 100, 100, 100]);
                          }

                          print('DEBUG EDIT: Showing success dialog with scanner context');
                          await showPremiumSuccessDialog(
                            this.context,
                            title: 'Book Details Updated!',
                            message: '${updatedBook.title} has been successfully registered in the library.\n\nBook ID: ${updatedBook.bookId}\nShelf: ${updatedBook.shelf}\nCategory: ${updatedBook.category}',
                            icon: Icons.check_circle_rounded,
                            onPrimaryPressed: () {
                              print('DEBUG EDIT: Success dialog - Done button pressed');
                              Navigator.of(this.context).pop(); // Close success dialog ONLY (stay in scanner!)
                            },
                          );
                          print('DEBUG EDIT: Success dialog closed');
                        } else {
                          print('DEBUG EDIT: Showing error dialog');
                          await showPremiumErrorDialog(
                            this.context,
                            title: 'Failed',
                            message: 'Could not update the book. Please try again.',
                            icon: Icons.error_rounded,
                          );
                        }
                      } catch (e) {
                        print('DEBUG EDIT: Error caught: $e');
                        // Dismiss loading if still showing
                        if (mounted) {
                          Navigator.of(this.context).pop();
                        }

                        if (!mounted) return;

                        await showPremiumErrorDialog(
                          this.context,
                          title: 'Error',
                          message: 'An error occurred:\n${e.toString()}',
                          icon: Icons.error_outline_rounded,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLime,
                      foregroundColor: AppColors.primaryDarkBlue,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ), // Column
        ), // Container
          ), // SingleChildScrollView
          ), // ConstrainedBox
      ), // Dialog
    ); // showDialog
  }

  /// Premium info row with icon, label, and value
  Widget _buildPremiumInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    bool isTitle = false,
    bool isWarning = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isWarning
                ? Colors.red.withValues(alpha: 0.2)
                : (isDark
                    ? AppColors.primaryTeal.withValues(alpha: 0.2)
                    : AppColors.primaryTeal.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: isWarning
                ? Colors.red.shade400
                : (isDark ? AppColors.primaryTeal : AppColors.primaryTeal),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTitle ? 17.sp : 15.sp,
                  fontWeight: isTitle ? FontWeight.w800 : FontWeight.w600,
                  color: isWarning
                      ? Colors.red.shade400
                      : (isDark ? Colors.white : AppColors.primaryDarkBlue),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get status color
  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.available:
        return Colors.green.shade600;
      case BookStatus.checkedOut:
        return Colors.orange.shade600;
      case BookStatus.reserved:
        return Colors.blue.shade600;
      case BookStatus.damaged:
        return Colors.red.shade600;
      case BookStatus.lost:
        return Colors.red.shade900;
      default:
        return Colors.grey.shade600;
    }
  }

  /// Premium Checkout Dialog - Book Details + Name Input + Checkout Action (ALL IN ONE!)
  Future<void> _showCheckoutDialog(Book book) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(  // SCROLLABLE - NO OVERFLOW!
          child: Container(
            padding: EdgeInsets.all(20.w),  // Reduced padding for smaller screens
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Theme.of(context).dialogBackgroundColor,
                      Colors.green.shade900.withValues(alpha: 0.3),
                    ]
                  : [
                      Colors.white,
                      Colors.green.shade50,
                    ],
            ),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: isDark
                  ? AppColors.primaryLime.withValues(alpha: 0.5)
                  : AppColors.primaryLime.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLime.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Icon and Status
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, AppColors.primaryLime],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLime.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.output_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checkout Book',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.primaryLime : Colors.green.shade700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.green.shade600,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),  // Reduced

              // Book Details with Premium Styling
              _buildPremiumInfoRow(
                Icons.fingerprint_rounded,
                'ID',
                book.bookId,
                isDark,
              ),
              SizedBox(height: 10.h),  // Reduced
              _buildPremiumInfoRow(
                Icons.title_rounded,
                'Title',
                book.title,
                isDark,
                isTitle: true,
              ),
              SizedBox(height: 10.h),  // Reduced
              _buildPremiumInfoRow(
                Icons.menu_book_rounded,
                'Shelf',
                book.shelf.isNotEmpty ? book.shelf : 'Not specified',
                isDark,
              ),
              SizedBox(height: 10.h),  // Reduced
              _buildPremiumInfoRow(
                Icons.category_rounded,
                'Category',
                book.category.isNotEmpty ? book.category : 'Not specified',
                isDark,
              ),

              SizedBox(height: 16.h),  // Reduced

              // Borrower Name Input (INTEGRATED - NO SECOND DIALOG!)
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Borrower Name *',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryTeal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.primaryTeal : AppColors.primaryTeal.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: AppColors.primaryTeal,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.grey.shade50,
                ),
              ),

              SizedBox(height: 18.h),  // Reduced from 28

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Get name from the TextField in THIS dialog (no second dialog!)
                        final borrowerName = nameController.text.trim();

                        print('DEBUG: Checkout button pressed, name: "$borrowerName"');

                        // Validate name
                        if (borrowerName.isEmpty) {
                          print('DEBUG: Name is empty, showing error');
                          showPremiumErrorDialog(
                            context,
                            title: 'Name Required',
                            message: 'Please enter your name before checking out the book.',
                            icon: Icons.person_off_rounded,
                          );
                          return;
                        }

                        // Close the checkout dialog
                        Navigator.pop(context);

                        if (!mounted) return;

                        // CRITICAL: Get context from the widget state (THIS context works!)
                        final widgetContext = this.context;

                        // Show loading
                        showPremiumLoadingDialog(widgetContext, message: 'Checking out book...');

                        try {
                          print('DEBUG: Starting checkout for book ${book.bookId} to $borrowerName');

                          final success = await GoogleSheetsService.instance.checkoutBook(
                            book.bookId,
                            borrowerName,
                          );

                          print('DEBUG: Checkout result: $success');

                          // Dismiss loading
                          if (mounted) {
                            Navigator.of(widgetContext).pop();
                          }

                          if (!mounted) return;

                          if (success) {
                            // Success! Fulfilling vibration pattern
                            print('DEBUG: Showing success dialog');
                            if (await Vibration.hasVibrator() ?? false) {
                              // Double vibration for success (fulfilling feeling)
                              Vibration.vibrate(pattern: [0, 100, 100, 100]);
                            }

                            await showPremiumSuccessDialog(
                              widgetContext,
                              title: 'Book Checked Out!',
                              message: '${book.title} has been checked out to $borrowerName.\n\nDue back in 14 days.',
                              icon: Icons.check_circle_rounded,
                              onPrimaryPressed: () {
                                Navigator.of(widgetContext).pop(); // Close success dialog ONLY (stay in scanner!)
                              },
                            );
                          } else {
                            // Failure vibration (error pattern)
                            print('DEBUG: Checkout returned false');
                            if (await Vibration.hasVibrator() ?? false) {
                              // Triple short vibration for error
                              Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50]);
                            }

                            await showPremiumErrorDialog(
                              context,
                              title: 'Checkout Failed',
                              message: 'Failed to checkout the book. Please try again.',
                              icon: Icons.error_rounded,
                            );
                          }
                        } catch (e, stackTrace) {
                          print('DEBUG: Checkout error: $e');
                          print('DEBUG: Stack trace: $stackTrace');

                          // Dismiss loading if showing
                          if (mounted && Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          if (!mounted) return;

                          await showPremiumErrorDialog(
                            context,
                            title: 'Error',
                            message: 'An error occurred:\n${e.toString()}',
                            icon: Icons.error_outline_rounded,
                          );
                        } finally {
                          // CRITICAL: Reset processing flag so scanner can work again
                          print('DEBUG: Resetting _isProcessing flag after checkout');
                          if (mounted) {
                            setState(() => _isProcessing = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        backgroundColor: Colors.green.shade600,
                        elevation: 3,
                      ),
                      child: Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),  // Close Container
        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
      ),  // Close SingleChildScrollView
    );
  }

  /// Premium Borrower Name Input Dialog
  Future<String?> _showBorrowerInputDialog() async {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Small delay to let previous dialog fully close and keyboard settle
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Theme.of(context).dialogBackgroundColor,
                      AppColors.primaryTeal.withValues(alpha: 0.2),
                    ]
                  : [
                      Colors.white,
                      AppColors.primaryTeal.withValues(alpha: 0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isDark
                  ? AppColors.primaryTeal.withValues(alpha: 0.5)
                  : AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryTeal, AppColors.primaryLime],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'Enter Your Name',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                ),
              ),

              SizedBox(height: 24.h),

              TextField(
                controller: controller,
                autofocus: false, // Disable autofocus to prevent keyboard glitch
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Borrower Name *',
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.primaryTeal : AppColors.primaryTeal.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: AppColors.primaryTeal,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryTeal,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.grey.shade50,
                ),
                onSubmitted: (value) {
                  print('DEBUG: TextField submitted with value: "$value"');
                  if (value.trim().isNotEmpty) {
                    print('DEBUG: Calling Navigator.pop from onSubmitted');
                    Navigator.of(context, rootNavigator: true).pop(value.trim());
                  }
                },
              ),

              SizedBox(height: 28.h),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        print('DEBUG: Cancel button pressed in borrower dialog');
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        print('DEBUG: Continue button pressed!');
                        final name = controller.text.trim();
                        print('DEBUG: Name entered: "$name"');
                        if (name.isNotEmpty) {
                          print('DEBUG: Calling Navigator.pop with name');
                          Navigator.of(context, rootNavigator: true).pop(name);  // Use rootNavigator!
                        } else {
                          print('DEBUG: Name is empty, not closing dialog');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),
      ),
    );

    return result;
  }

  /// Premium Return Dialog - Book Details + Return Action Combined
  Future<void> _showReturnDialog(Book book) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysBorrowed = book.daysSinceCheckout ?? 0;
    final isOverdue = book.isOverdue;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Theme.of(context).dialogBackgroundColor,
                      isOverdue
                          ? Colors.red.shade900.withValues(alpha: 0.3)
                          : Colors.blue.shade900.withValues(alpha: 0.3),
                    ]
                  : [
                      Colors.white,
                      isOverdue ? Colors.red.shade50 : Colors.blue.shade50,
                    ],
            ),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: isOverdue
                  ? (isDark ? Colors.red.shade600 : Colors.red.shade400).withValues(alpha: 0.5)
                  : (isDark ? Colors.blue.shade600 : Colors.blue.shade400).withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isOverdue ? Colors.red : Colors.blue).withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Icon and Status
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isOverdue
                            ? [Colors.red.shade600, Colors.red.shade800]
                            : [Colors.blue.shade600, Colors.blue.shade800],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: (isOverdue ? Colors.red : Colors.blue).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      isOverdue ? Icons.warning_rounded : Icons.keyboard_return_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Return Book',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: isOverdue
                                ? (isDark ? Colors.red.shade400 : Colors.red.shade700)
                                : (isDark ? Colors.blue.shade400 : Colors.blue.shade700),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: (isOverdue ? Colors.red.shade600 : Colors.orange.shade600).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: isOverdue ? Colors.red.shade600 : Colors.orange.shade600,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            isOverdue ? 'Overdue' : 'Checked Out',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isOverdue ? Colors.red.shade600 : Colors.orange.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Book Details with Premium Styling
              _buildPremiumInfoRow(
                Icons.fingerprint_rounded,
                'ID',
                book.bookId,
                isDark,
              ),
              SizedBox(height: 14.h),
              _buildPremiumInfoRow(
                Icons.title_rounded,
                'Title',
                book.title,
                isDark,
                isTitle: true,
              ),
              SizedBox(height: 14.h),
              _buildPremiumInfoRow(
                Icons.menu_book_rounded,
                'Shelf',
                book.shelf.isNotEmpty ? book.shelf : 'Not specified',
                isDark,
              ),
              SizedBox(height: 14.h),
              _buildPremiumInfoRow(
                Icons.category_rounded,
                'Category',
                book.category.isNotEmpty ? book.category : 'Not specified',
                isDark,
              ),
              SizedBox(height: 14.h),
              _buildPremiumInfoRow(
                Icons.person_rounded,
                'Borrower',
                book.borrowerName ?? 'Unknown',
                isDark,
              ),
              SizedBox(height: 14.h),
              _buildPremiumInfoRow(
                Icons.calendar_today_rounded,
                'Checkout Date',
                book.checkoutDate != null ? _formatDate(book.checkoutDate!) : 'N/A',
                isDark,
              ),
              SizedBox(height: 14.h),
              _buildPremiumInfoRow(
                isOverdue ? Icons.warning_rounded : Icons.access_time_rounded,
                'Days Borrowed',
                '$daysBorrowed days${isOverdue ? ' (OVERDUE)' : ''}',
                isDark,
                isWarning: isOverdue,
              ),

              SizedBox(height: 28.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Close the return dialog
                        Navigator.pop(context);

                        if (!mounted) return;

                        // CRITICAL: Get context from the widget state (THIS context works!)
                        final widgetContext = this.context;

                        // Show loading
                        showPremiumLoadingDialog(widgetContext, message: 'Returning book...');

                        try {
                          final success = await GoogleSheetsService.instance.returnBook(book.bookId);

                          // Dismiss loading
                          if (mounted) {
                            Navigator.of(widgetContext).pop();
                          }

                          if (!mounted) return;

                          if (success) {
                            // Success! Fulfilling vibration pattern
                            if (await Vibration.hasVibrator() ?? false) {
                              // Double vibration for success
                              Vibration.vibrate(pattern: [0, 100, 100, 100]);
                            }

                            await showPremiumSuccessDialog(
                              widgetContext,
                              title: 'Book Returned!',
                              message: '${book.title} has been successfully returned.\n\nThank you for using the library!',
                              icon: Icons.check_circle_rounded,
                              onPrimaryPressed: () {
                                Navigator.of(widgetContext).pop(); // Close success dialog ONLY (stay in scanner!)
                              },
                            );
                          } else {
                            // Failure vibration
                            if (await Vibration.hasVibrator() ?? false) {
                              // Triple short vibration for error
                              Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50]);
                            }

                            await showPremiumErrorDialog(
                              context,
                              title: 'Return Failed',
                              message: 'Failed to return the book. Please try again or contact the administrator.',
                              icon: Icons.error_rounded,
                            );
                          }
                        } catch (e) {
                          // Dismiss loading if showing
                          if (mounted && Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          if (!mounted) return;

                          await showPremiumErrorDialog(
                            context,
                            title: 'Error',
                            message: 'An error occurred:\n${e.toString()}',
                            icon: Icons.error_outline_rounded,
                          );
                        } finally {
                          // CRITICAL: Reset processing flag so scanner can work again
                          print('DEBUG: Resetting _isProcessing flag after return');
                          if (mounted) {
                            setState(() => _isProcessing = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        backgroundColor: isOverdue ? Colors.red.shade600 : Colors.blue.shade600,
                        elevation: 3,
                      ),
                      child: Text(
                        'Return Book',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
      ),
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color color;

  ScannerOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final framePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final frameSize = 280.0;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2;

    // Draw overlay
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(left, top, frameSize, frameSize))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, paint);

    // Draw frame corners
    final cornerLength = 32.0;
    final cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Top-left
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left, top + cornerLength), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(left + frameSize - cornerLength, top), Offset(left + frameSize, top), cornerPaint);
    canvas.drawLine(Offset(left + frameSize, top), Offset(left + frameSize, top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + frameSize - cornerLength), Offset(left, top + frameSize), cornerPaint);
    canvas.drawLine(Offset(left, top + frameSize), Offset(left + cornerLength, top + frameSize), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(left + frameSize, top + frameSize - cornerLength), Offset(left + frameSize, top + frameSize), cornerPaint);
    canvas.drawLine(Offset(left + frameSize - cornerLength, top + frameSize), Offset(left + frameSize, top + frameSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
