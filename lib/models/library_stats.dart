/// Library Statistics Model for Admin Dashboard
class LibraryStats {
  final int totalBooks;
  final int availableBooks;
  final int checkedOutBooks;
  final int overdueBooks;
  final int reservedBooks;
  final int damagedBooks;
  final int lostBooks;
  final Map<String, int> booksByCategory;
  final Map<String, int> booksByShelf;
  final List<TopBorrower> topBorrowers;
  final List<RecentActivity> recentActivities;
  final DateTime lastUpdated;

  const LibraryStats({
    required this.totalBooks,
    required this.availableBooks,
    required this.checkedOutBooks,
    required this.overdueBooks,
    required this.reservedBooks,
    required this.damagedBooks,
    required this.lostBooks,
    required this.booksByCategory,
    required this.booksByShelf,
    required this.topBorrowers,
    required this.recentActivities,
    required this.lastUpdated,
  });

  /// Calculate availability percentage
  double get availabilityPercentage {
    if (totalBooks == 0) return 0;
    return (availableBooks / totalBooks) * 100;
  }

  /// Calculate utilization percentage
  double get utilizationPercentage {
    if (totalBooks == 0) return 0;
    return (checkedOutBooks / totalBooks) * 100;
  }

  /// Get overdue percentage
  double get overduePercentage {
    if (checkedOutBooks == 0) return 0;
    return (overdueBooks / checkedOutBooks) * 100;
  }

  /// Empty stats
  factory LibraryStats.empty() {
    return LibraryStats(
      totalBooks: 0,
      availableBooks: 0,
      checkedOutBooks: 0,
      overdueBooks: 0,
      reservedBooks: 0,
      damagedBooks: 0,
      lostBooks: 0,
      booksByCategory: {},
      booksByShelf: {},
      topBorrowers: [],
      recentActivities: [],
      lastUpdated: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalBooks': totalBooks,
      'availableBooks': availableBooks,
      'checkedOutBooks': checkedOutBooks,
      'overdueBooks': overdueBooks,
      'reservedBooks': reservedBooks,
      'damagedBooks': damagedBooks,
      'lostBooks': lostBooks,
      'booksByCategory': booksByCategory,
      'booksByShelf': booksByShelf,
      'topBorrowers': topBorrowers.map((b) => b.toJson()).toList(),
      'recentActivities': recentActivities.map((a) => a.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LibraryStats.fromJson(Map<String, dynamic> json) {
    return LibraryStats(
      totalBooks: json['totalBooks'] as int? ?? 0,
      availableBooks: json['availableBooks'] as int? ?? 0,
      checkedOutBooks: json['checkedOutBooks'] as int? ?? 0,
      overdueBooks: json['overdueBooks'] as int? ?? 0,
      reservedBooks: json['reservedBooks'] as int? ?? 0,
      damagedBooks: json['damagedBooks'] as int? ?? 0,
      lostBooks: json['lostBooks'] as int? ?? 0,
      booksByCategory: Map<String, int>.from(json['booksByCategory'] as Map? ?? {}),
      booksByShelf: Map<String, int>.from(json['booksByShelf'] as Map? ?? {}),
      topBorrowers: (json['topBorrowers'] as List<dynamic>? ?? [])
          .map((b) => TopBorrower.fromJson(b as Map<String, dynamic>))
          .toList(),
      recentActivities: (json['recentActivities'] as List<dynamic>? ?? [])
          .map((a) => RecentActivity.fromJson(a as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  LibraryStats copyWith({
    int? totalBooks,
    int? availableBooks,
    int? checkedOutBooks,
    int? overdueBooks,
    int? reservedBooks,
    int? damagedBooks,
    int? lostBooks,
    Map<String, int>? booksByCategory,
    Map<String, int>? booksByShelf,
    List<TopBorrower>? topBorrowers,
    List<RecentActivity>? recentActivities,
    DateTime? lastUpdated,
  }) {
    return LibraryStats(
      totalBooks: totalBooks ?? this.totalBooks,
      availableBooks: availableBooks ?? this.availableBooks,
      checkedOutBooks: checkedOutBooks ?? this.checkedOutBooks,
      overdueBooks: overdueBooks ?? this.overdueBooks,
      reservedBooks: reservedBooks ?? this.reservedBooks,
      damagedBooks: damagedBooks ?? this.damagedBooks,
      lostBooks: lostBooks ?? this.lostBooks,
      booksByCategory: booksByCategory ?? this.booksByCategory,
      booksByShelf: booksByShelf ?? this.booksByShelf,
      topBorrowers: topBorrowers ?? this.topBorrowers,
      recentActivities: recentActivities ?? this.recentActivities,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Top Borrower Model
class TopBorrower {
  final String name;
  final int booksCheckedOut;
  final DateTime? lastCheckout;

  const TopBorrower({
    required this.name,
    required this.booksCheckedOut,
    this.lastCheckout,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'booksCheckedOut': booksCheckedOut,
      'lastCheckout': lastCheckout?.toIso8601String(),
    };
  }

  factory TopBorrower.fromJson(Map<String, dynamic> json) {
    return TopBorrower(
      name: json['name'] as String,
      booksCheckedOut: json['booksCheckedOut'] as int,
      lastCheckout: json['lastCheckout'] != null
          ? DateTime.parse(json['lastCheckout'] as String)
          : null,
    );
  }
}

/// Recent Activity Model
class RecentActivity {
  final String bookId;
  final String bookTitle;
  final String action; // 'checkout', 'return', 'added'
  final String? borrowerName;
  final DateTime timestamp;

  const RecentActivity({
    required this.bookId,
    required this.bookTitle,
    required this.action,
    this.borrowerName,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'action': action,
      'borrowerName': borrowerName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      bookId: json['bookId'] as String,
      bookTitle: json['bookTitle'] as String,
      action: json['action'] as String,
      borrowerName: json['borrowerName'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
