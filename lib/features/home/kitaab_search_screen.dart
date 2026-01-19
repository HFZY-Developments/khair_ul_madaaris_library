import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../providers/app_state_provider.dart';

class KitaabSearchScreen extends ConsumerStatefulWidget {
  const KitaabSearchScreen({super.key});

  @override
  ConsumerState<KitaabSearchScreen> createState() => _KitaabSearchScreenState();
}

class _KitaabSearchScreenState extends ConsumerState<KitaabSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  List<_SearchEntry> _searchIndex = const [];
  List<_SearchEntry> _lastSearchPool = const [];
  List<Book> _searchResults = const [];
  List<Book>? _lastBooksRef;
  String _lastSearchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final books = booksAsync.asData?.value;
    if (books != null) {
      _prepareSearchIndex(books);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trimmedQuery = _searchQuery.trim();
    final hasQuery = trimmedQuery.isNotEmpty;
    final results = _searchResults;
    final showSummary = hasQuery && booksAsync.asData != null;

    Widget content;
    if (booksAsync.isLoading) {
      content = _buildHint('Loading library...', isDark);
    } else if (booksAsync.hasError) {
      content = _buildHint('Unable to load books right now.', isDark);
    } else if (!hasQuery) {
      content = _buildHint('Type to search title, ID, shelf, category.', isDark);
    } else if (results.isEmpty) {
      content = _buildHint('No matching books found. Try a shorter search.', isDark);
    } else {
      content = ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: results.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _buildSearchResultItem(results[index], isDark),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitaab Search'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchBar(),
              SizedBox(height: 16.h),
              if (showSummary) ...[
                _buildSearchSummary(trimmedQuery, results.length, isDark),
                SizedBox(height: 12.h),
              ],
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark
        ? AppColors.primaryTeal.withValues(alpha: 0.35)
        : AppColors.primaryTeal.withValues(alpha: 0.2);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryTeal.withValues(alpha: 0.25),
            AppColors.primaryLime.withValues(alpha: 0.25),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(1.4.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _handleSearchChanged,
          onSubmitted: _applySearch,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search title, ID, shelf, category, borrower',
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primaryTeal,
              size: 22.sp,
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.clear_rounded, color: Colors.grey[500]),
                    onPressed: () {
                      _searchController.clear();
                      _applySearch('');
                      FocusScope.of(context).unfocus();
                    },
                  ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSummary(String query, int resultCount, bool isDark) {
    return Row(
      children: [
        Icon(Icons.search_rounded, color: AppColors.primaryTeal, size: 18.sp),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Search Results',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.primaryDarkBlue,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primaryTeal.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            '$resultCount',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryTeal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(Book book, bool isDark) {
    final statusColor = book.statusColor;
    final subtitleText = '${book.bookId} - ${book.shelf} / ${book.category}';
    final borrowerName = book.borrowerName?.trim();
    final hasBorrower = borrowerName != null && borrowerName.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(book.statusIcon, color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primaryDarkBlue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasBorrower) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Borrower: $borrowerName',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              book.statusText,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHint(String message, bool isDark) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _prepareSearchIndex(List<Book> books) {
    if (identical(_lastBooksRef, books)) {
      return;
    }

    _lastBooksRef = books;
    _searchIndex = books
        .where((book) => book.title.trim().isNotEmpty)
        .map((book) => _SearchEntry(book, _buildSearchText(book)))
        .toList();
    _lastSearchPool = _searchIndex;
    _lastSearchQuery = '';

    if (_searchQuery.trim().isNotEmpty) {
      _searchResults = _filterSearchIndex(_searchQuery.trim());
    } else {
      _searchResults = const [];
    }
  }

  String _buildSearchText(Book book) {
    return [
      book.bookId,
      book.title,
      book.author,
      book.category,
      book.shelf,
      book.borrowerName ?? '',
      book.statusText,
      book.status.name,
    ].join(' ').toLowerCase();
  }

  List<Book> _filterSearchIndex(String query) {
    if (query.isEmpty) {
      _lastSearchQuery = '';
      _lastSearchPool = _searchIndex;
      return const [];
    }

    final normalized = query.toLowerCase();
    final terms = normalized.split(RegExp(r'\s+')).where((term) => term.isNotEmpty).toList();
    final source = _lastSearchQuery.isNotEmpty && normalized.startsWith(_lastSearchQuery)
        ? _lastSearchPool
        : _searchIndex;

    final matches = <_SearchEntry>[];
    for (final entry in source) {
      var matchesAll = true;
      for (final term in terms) {
        if (!entry.searchText.contains(term)) {
          matchesAll = false;
          break;
        }
      }
      if (matchesAll) {
        matches.add(entry);
      }
    }

    _lastSearchQuery = normalized;
    _lastSearchPool = matches;
    return matches.map((entry) => entry.book).toList();
  }

  void _handleSearchChanged(String value) {
    final trimmed = value.trim();
    final results = trimmed.isEmpty ? const <Book>[] : _filterSearchIndex(trimmed);

    setState(() {
      _searchQuery = value;
      _searchResults = results;
    });
  }

  void _applySearch(String value) {
    _handleSearchChanged(value);
  }
}

class _SearchEntry {
  final Book book;
  final String searchText;

  _SearchEntry(this.book, this.searchText);
}
