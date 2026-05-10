import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/book.dart';
import '../controllers/library_controller.dart';

class ReadingPage extends StatefulWidget {
  final LibraryController controller;
  final Book book;

  const ReadingPage({super.key, required this.controller, required this.book});

  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _aiMenuOpen = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openChat(AiQuestionType type) {
    setState(() => _aiMenuOpen = false);
    final page = widget.book.pages[_currentIndex];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AiChatSheet(
        controller: widget.controller,
        book: widget.book,
        page: page,
        type: type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5EFE3),
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.book.pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final page = widget.book.pages[index];
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double delta = 0;
                        if (_pageController.position.haveDimensions) {
                          delta =
                              (_pageController.page ?? index.toDouble()) -
                              index;
                        }
                        final angle =
                            delta.clamp(-1.0, 1.0).toDouble() * math.pi / 18;

                        return Transform(
                          alignment: delta > 0
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: child,
                        );
                      },
                      child: _ReaderPage(book: widget.book, page: page),
                    );
                  },
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'ai-menu',
                        tooltip: 'Preguntar a la IA',
                        onPressed: () =>
                            setState(() => _aiMenuOpen = !_aiMenuOpen),
                        child: const Icon(Icons.auto_awesome_rounded),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _aiMenuOpen
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _AiMenuButton(
                                      icon: Icons.sticky_note_2_rounded,
                                      label: 'Pregunta sobre esta pagina',
                                      cost: widget.controller.costFor(
                                        AiQuestionType.page,
                                      ),
                                      onTap: () =>
                                          _openChat(AiQuestionType.page),
                                    ),
                                    const SizedBox(height: 8),
                                    _AiMenuButton(
                                      icon: Icons.question_answer_rounded,
                                      label: 'Pregunta general',
                                      cost: widget.controller.costFor(
                                        AiQuestionType.general,
                                      ),
                                      onTap: () =>
                                          _openChat(AiQuestionType.general),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _ReaderStatus(controller: widget.controller),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: _PageProgress(
                    current: _currentIndex + 1,
                    total: widget.book.pages.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReaderPage extends StatelessWidget {
  final Book book;
  final BookPage page;

  const _ReaderPage({required this.book, required this.page});

  @override
  Widget build(BuildContext context) {
    final isVisual = book.hasImmersiveImages && page.illustration != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 82, 18, 64),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.paper,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            Text(
              book.title,
              style: TextStyle(
                color: AppTheme.ink.withValues(alpha: 0.56),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              page.title,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            if (isVisual) ...[
              const SizedBox(height: 20),
              _IllustrationPanel(
                color: Color(book.accentColor),
                label: page.illustration!,
              ),
            ],
            const SizedBox(height: 22),
            Text(
              page.body,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 20,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  final Color color;
  final String label;

  const _IllustrationPanel({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.landscape_rounded,
              color: color.withValues(alpha: 0.78),
              size: 86,
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int cost;
  final VoidCallback onTap;

  const _AiMenuButton({
    required this.icon,
    required this.label,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text('$label · $cost'),
    );
  }
}

class _ReaderStatus extends StatelessWidget {
  final LibraryController controller;

  const _ReaderStatus({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.isPremium
                ? Icons.workspace_premium_rounded
                : Icons.paid_rounded,
            size: 18,
            color: AppTheme.coral,
          ),
          const SizedBox(width: 6),
          Text(
            controller.isPremium ? 'Premium' : '${controller.coins}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PageProgress extends StatelessWidget {
  final int current;
  final int total;

  const _PageProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 6,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$current/$total',
          style: const TextStyle(
            color: AppTheme.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AiChatSheet extends StatefulWidget {
  final LibraryController controller;
  final Book book;
  final BookPage page;
  final AiQuestionType type;

  const _AiChatSheet({
    required this.controller,
    required this.book,
    required this.page,
    required this.type,
  });

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final TextEditingController _inputController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      _ChatMessage(
        fromUser: false,
        text: widget.type == AiQuestionType.page
            ? 'Preguntame sobre "${widget.page.title}". Usare esta pagina como contexto.'
            : 'Preguntame algo general sobre "${widget.book.title}".',
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _send() {
    final question = _inputController.text.trim();
    if (question.isEmpty) return;

    if (!widget.controller.spendForQuestion(widget.type)) {
      setState(() {
        _messages.add(_ChatMessage(fromUser: true, text: question));
        _messages.add(
          const _ChatMessage(
            fromUser: false,
            text:
                'No tienes monedas suficientes. Puedes ver un anuncio demo para sumar 30 monedas o activar premium.',
          ),
        );
      });
      _inputController.clear();
      return;
    }

    final answer = widget.controller.mockAiAnswer(
      book: widget.book,
      type: widget.type,
      question: question,
      page: widget.page,
    );

    setState(() {
      _messages.add(_ChatMessage(fromUser: true, text: question));
      _messages.add(_ChatMessage(fromUser: false, text: answer));
    });
    _inputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.42,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.type == AiQuestionType.page
                              ? 'IA de esta pagina'
                              : 'IA del libro',
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        widget.controller.isPremium
                            ? 'Premium'
                            : '${widget.controller.coins} monedas',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: _messages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _MessageBubble(message: _messages[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu pregunta',
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Enviar',
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.fromUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.fromUser ? AppTheme.moss : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.fromUser ? Colors.white : AppTheme.ink,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool fromUser;
  final String text;

  const _ChatMessage({required this.fromUser, required this.text});
}
