import 'book.dart';

class ContinueReadingItem {
  final Book book;
  final String profileId;
  final int lastPageRead;
  final double progress;
  final DateTime? updatedAt;

  const ContinueReadingItem({
    required this.book,
    required this.profileId,
    required this.lastPageRead,
    required this.progress,
    this.updatedAt,
  });
}

class RecentReadingActivity {
  final Book book;
  final String profileId;
  final int lastPageRead;
  final double progress;
  final DateTime? updatedAt;

  const RecentReadingActivity({
    required this.book,
    required this.profileId,
    required this.lastPageRead,
    required this.progress,
    this.updatedAt,
  });
}

class ReaderDashboard {
  final int booksRead;
  final int booksInProgress;
  final int favorites;
  final int totalReadingMinutes;
  final ContinueReadingItem? continueReading;
  final List<RecentReadingActivity> recentActivity;

  const ReaderDashboard({
    this.booksRead = 0,
    this.booksInProgress = 0,
    this.favorites = 0,
    this.totalReadingMinutes = 0,
    this.continueReading,
    this.recentActivity = const [],
  });
}
