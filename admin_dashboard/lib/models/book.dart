class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String audience;
  final String description;
  final int pageCount;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.audience,
    required this.description,
    required this.pageCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final pages = json['pages'];
    return Book(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? 'Sin titulo'}',
      author: '${json['author'] ?? 'Mini Read'}',
      category: '${json['category'] ?? 'General'}',
      audience: '${json['audience'] ?? json['category'] ?? 'General'}',
      description: '${json['description'] ?? ''}',
      pageCount: pages is List ? pages.length : 0,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      if (id.trim().isNotEmpty) 'id': id.trim(),
      'title': title.trim(),
      'author': author.trim().isEmpty ? 'Mini Read' : author.trim(),
      'category': category.trim().isEmpty ? 'General' : category.trim(),
      'audience': audience.trim().isEmpty ? category.trim() : audience.trim(),
      'description': description.trim(),
      'pages': List.generate(
        pageCount <= 0 ? 1 : pageCount,
        (index) => {
          'pageNumber': index + 1,
          'title': 'Pagina ${index + 1}',
          'text': '',
          'imageUrl': null,
        },
      ),
    };
  }
}
