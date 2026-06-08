class ReadingProgress {
  final String bookId;
  final int currentPage;
  final int totalPages;
  final double progressPercentage;
  final DateTime? lastReadAt;

  const ReadingProgress({
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    this.lastReadAt,
  });
}
