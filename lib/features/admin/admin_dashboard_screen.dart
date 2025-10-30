import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../models/library_stats.dart';
import '../../models/book.dart';
import '../../services/google_sheets_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(libraryStatsProvider);
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              // CRITICAL: Clear Google Sheets cache to get fresh data
              await GoogleSheetsService.instance.getAllBooks(forceRefresh: true);
              // Then invalidate providers to trigger rebuild
              ref.invalidate(libraryStatsProvider);
              ref.invalidate(booksProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          // CRITICAL: Clear Google Sheets cache to get fresh data
          await GoogleSheetsService.instance.getAllBooks(forceRefresh: true);
          // Then invalidate providers to trigger rebuild
          ref.invalidate(libraryStatsProvider);
          ref.invalidate(booksProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: statsAsync.when(
          data: (stats) => _buildDashboard(context, stats, booksAsync.value ?? []),
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryTeal),
                SizedBox(height: 16.h),
                Text(
                  'Loading dashboard...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 64.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text('Error loading dashboard', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 8.h),
                Text(error.toString(), style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, LibraryStats stats, List<Book> books) {
    // Filter books with titles only
    final booksWithTitles = books.where((book) => book.title.trim().isNotEmpty).toList();

    // Calculate overdue books manually (14-day detection)
    final overdueBooks = booksWithTitles.where((book) => book.isOverdue).toList();
    final checkedOutBooks = booksWithTitles.where((book) => book.status == BookStatus.checkedOut).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Stats Bar - Clickable
          _buildPremiumStatsBar(stats, booksWithTitles, checkedOutBooks, overdueBooks),

          SizedBox(height: 28.h),

          // Overdue Alert (if any)
          if (overdueBooks.isNotEmpty) ...[
            _buildOverdueAlert(overdueBooks),
            SizedBox(height: 28.h),
          ],

          // Interactive Shelves Section
          _buildShelvesSection(stats, booksWithTitles),

          SizedBox(height: 28.h),

          // Categories Section
          _buildCategoriesSection(stats, booksWithTitles),
        ],
      ),
    );
  }

  /// Premium Stats Bar - Beautiful gradient cards that are tappable
  Widget _buildPremiumStatsBar(LibraryStats stats, List<Book> booksWithTitles, List<Book> checkedOutBooks, List<Book> overdueBooks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Library Overview',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildClickableStatCard(
                title: 'Total',
                value: booksWithTitles.length,
                icon: Icons.library_books_rounded,
                gradient: LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.primaryTeal.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showAllBooksSheet(booksWithTitles),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildClickableStatCard(
                title: 'Available',
                value: booksWithTitles.where((b) => b.status == BookStatus.available).length,
                icon: Icons.check_circle_rounded,
                gradient: LinearGradient(
                  colors: [AppColors.primaryLime, AppColors.primaryLime.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showFilteredBooksSheet(
                  booksWithTitles.where((b) => b.status == BookStatus.available).toList(),
                  'Available Books',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildClickableStatCard(
                title: 'Checked Out',
                value: checkedOutBooks.length,
                icon: Icons.schedule_rounded,
                gradient: LinearGradient(
                  colors: [AppColors.primaryDarkBlue, AppColors.primaryDarkBlue.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showCheckedOutBooksSheet(checkedOutBooks),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildClickableStatCard(
                title: 'Overdue',
                value: overdueBooks.length,
                icon: Icons.error_rounded,
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: overdueBooks.isEmpty ? null : () => _showOverdueBooksSheet(overdueBooks),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildClickableStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.mediumImpact();
              onTap();
            }
          : null,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36.sp, color: Colors.white),
            SizedBox(height: 12.h),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            if (onTap != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward_rounded, size: 14.sp, color: Colors.white),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().scale(delay: 100.ms, duration: 300.ms);
  }

  /// Overdue Alert Banner
  Widget _buildOverdueAlert(List<Book> overdueBooks) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${overdueBooks.length} Overdue Book${overdueBooks.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Books borrowed for more than 14 days',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: Colors.red.shade900),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showOverdueBooksSheet(overdueBooks);
            },
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms)
        .slideX(begin: -0.2, end: 0)
        .then()
        .shimmer(delay: 800.ms, duration: 2000.ms, color: Colors.red.withValues(alpha: 0.3));
  }

  /// Interactive Shelves Section - Horizontal scrolling cards
  Widget _buildShelvesSection(LibraryStats stats, List<Book> books) {
    final shelves = stats.booksByShelf.entries.toList();
    if (shelves.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Library Shelves',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkBlue,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${shelves.length} Shelves',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 160.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shelves.length,
            itemBuilder: (context, index) {
              final shelf = shelves[index];
              final shelfBooks = books.where((b) => b.shelf == shelf.key).toList();
              final totalCount = shelfBooks.length;
              final availableCount = shelfBooks.where((b) => b.status == BookStatus.available).length;

              return _buildShelfCard(
                shelfName: shelf.key,
                availableCount: availableCount,
                totalCount: totalCount,
                books: shelfBooks,
              ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShelfCard({
    required String shelfName,
    required int availableCount,
    required int totalCount,
    required List<Book> books,
  }) {
    // Calculate how full the shelf is (lower available = more full)
    final availabilityRate = totalCount > 0 ? (availableCount / totalCount) : 1.0;
    final displayColor = availabilityRate < 0.3
        ? Colors.red.shade600  // Less than 30% available = red (shelf almost empty)
        : availabilityRate < 0.6
            ? Colors.orange.shade600  // Less than 60% available = orange
            : AppColors.primaryLime;  // 60%+ available = green

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showShelfDetailSheet(shelfName, books);
      },
      child: Container(
        width: 180.w,
        margin: EdgeInsets.only(right: 16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDarkBlue,
              AppColors.primaryDarkBlue.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDarkBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.library_books_rounded, color: Colors.white, size: 24.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    shelfName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$availableCount/$totalCount',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: displayColor,
                  ),
                ),
                Text(
                  'books on shelf',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Books',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_rounded, size: 14.sp, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Categories Section
  Widget _buildCategoriesSection(LibraryStats stats, List<Book> books) {
    final categories = stats.booksByCategory.entries.toList();
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        SizedBox(height: 16.h),
        ...categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final categoryBooks = books.where((b) => b.category == category.key).toList();

          return _buildCategoryTile(
            categoryName: category.key,
            bookCount: category.value,
            books: categoryBooks,
          ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildCategoryTile({
    required String categoryName,
    required int bookCount,
    required List<Book> books,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showCategoryDetailSheet(categoryName, books);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryTeal.withValues(alpha: 0.05),
              AppColors.primaryLime.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primaryTeal.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.primaryLime],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.category_rounded, color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$bookCount book${bookCount != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.primaryTeal, size: 28.sp),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM SHEETS ====================

  /// Show all books
  void _showAllBooksSheet(List<Book> books) {
    _showBooksBottomSheet(
      title: 'All Books',
      books: books,
      icon: Icons.library_books_rounded,
      color: AppColors.primaryTeal,
    );
  }

  /// Show filtered books
  void _showFilteredBooksSheet(List<Book> books, String title) {
    _showBooksBottomSheet(
      title: title,
      books: books,
      icon: Icons.filter_list_rounded,
      color: AppColors.primaryLime,
    );
  }

  /// Show checked-out books with borrower data
  void _showCheckedOutBooksSheet(List<Book> books) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryDarkBlue, AppColors.primaryTeal],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.schedule_rounded, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checked Out Books',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                          Text(
                            '${books.length} book${books.length != 1 ? 's' : ''} currently borrowed',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final daysBorrowed = book.daysSinceCheckout ?? 0;
                    final isOverdue = book.isOverdue;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: isOverdue
                            ? (isDark
                                ? LinearGradient(
                                    colors: [
                                      Colors.red.shade900.withValues(alpha: 0.4),
                                      Colors.red.shade800.withValues(alpha: 0.3),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [Colors.red.shade50, Colors.red.shade100.withValues(alpha: 0.5)],
                                  ))
                            : null,
                        color: !isOverdue
                            ? (isDark ? Theme.of(context).cardColor.withValues(alpha: 0.8) : Colors.white)
                            : null,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isOverdue
                              ? (isDark ? Colors.red.shade600 : Colors.red.shade400)
                              : (isDark ? AppColors.primaryTeal.withValues(alpha: 0.5) : AppColors.primaryTeal.withValues(alpha: 0.3)),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isOverdue ? Colors.red : AppColors.primaryTeal).withValues(alpha: isDark ? 0.2 : 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row with Icon & Status Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: isOverdue ? Colors.red.shade600 : AppColors.primaryTeal,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              // Title & Status
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    if (isOverdue)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade600,
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Text(
                                          'OVERDUE',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          // Details with better spacing
                          _buildPremiumDetailRow(
                            Icons.person_rounded,
                            'Borrower',
                            book.borrowerName ?? 'Unknown',
                            isDark,
                          ),
                          SizedBox(height: 12.h),
                          _buildPremiumDetailRow(
                            Icons.calendar_today_rounded,
                            'Checkout Date',
                            book.checkoutDate != null ? DateFormat('MMM dd, yyyy').format(book.checkoutDate!) : 'N/A',
                            isDark,
                          ),
                          SizedBox(height: 12.h),
                          _buildPremiumDetailRow(
                            Icons.schedule_rounded,
                            'Days Borrowed',
                            '$daysBorrowed days${isOverdue ? ' (${daysBorrowed - 14} days overdue)' : ''}',
                            isDark,
                          ),
                          SizedBox(height: 12.h),
                          _buildPremiumDetailRow(Icons.library_books_rounded, 'Shelf', book.shelf, isDark),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 30).ms).slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show overdue books
  void _showOverdueBooksSheet(List<Book> books) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.error_rounded, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overdue Books',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.red.shade900,
                            ),
                          ),
                          Text(
                            '${books.length} book${books.length != 1 ? 's' : ''} borrowed > 14 days',
                            style: TextStyle(fontSize: 14.sp, color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final daysBorrowed = book.daysSinceCheckout ?? 0;
                    final daysOverdue = daysBorrowed - 14;

                    return Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? LinearGradient(
                                colors: [
                                  Colors.red.shade900.withValues(alpha: 0.3),
                                  Colors.orange.shade900.withValues(alpha: 0.3),
                                ],
                              )
                            : LinearGradient(
                                colors: [Colors.red.shade50, Colors.orange.shade50],
                              ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? Colors.red.shade700 : Colors.red.shade400,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  book.title,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '+$daysOverdue DAYS',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailRow(Icons.person_rounded, 'Borrower', book.borrowerName ?? 'Unknown'),
                          SizedBox(height: 8.h),
                          _buildDetailRow(
                            Icons.schedule_rounded,
                            'Days Overdue',
                            '$daysOverdue days (borrowed for $daysBorrowed days total)',
                          ),
                          SizedBox(height: 8.h),
                          _buildDetailRow(Icons.library_books_rounded, 'Shelf', book.shelf),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 30).ms).shake(delay: (index * 30 + 200).ms, hz: 2);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show shelf detail (books on a specific shelf)
  void _showShelfDetailSheet(String shelfName, List<Book> books) {
    _showBooksBottomSheet(
      title: 'Shelf: $shelfName',
      books: books,
      icon: Icons.library_books_rounded,
      color: AppColors.primaryDarkBlue,
    );
  }

  /// Show category detail
  void _showCategoryDetailSheet(String categoryName, List<Book> books) {
    _showBooksBottomSheet(
      title: categoryName,
      books: books,
      icon: Icons.category_rounded,
      color: AppColors.primaryTeal,
    );
  }

  /// Generic books bottom sheet
  void _showBooksBottomSheet({
    required String title,
    required List<Book> books,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                          Text(
                            '${books.length} book${books.length != 1 ? 's' : ''}',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: book.statusColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: book.statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: book.statusColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(book.statusIcon, color: Colors.white, size: 20.sp),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDarkBlue,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  '${book.shelf} • ${book.category}',
                                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                                ),
                                if (book.borrowerName != null) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Borrower: ${book.borrowerName}',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: book.statusColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              book.statusText,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (index * 20).ms);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Premium detail row with better visibility in dark mode
  Widget _buildPremiumDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: isDark ? AppColors.primaryTeal.withValues(alpha: 0.8) : AppColors.primaryTeal,
        ),
        SizedBox(width: 12.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey[100] : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
