import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171511).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF2A2418),
                child: book.coverUrl.trim().isEmpty
                    ? const Icon(
                        Icons.auto_stories_rounded,
                        color: AppTheme.gold,
                        size: 46,
                      )
                    : Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.auto_stories_rounded,
                          color: AppTheme.gold,
                          size: 46,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (book.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      book.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.48),
                        fontSize: 11,
                        height: 1.18,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
