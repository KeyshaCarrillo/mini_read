import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../controllers/library_controller.dart';
import '../widgets/navigation/library_sidebar.dart';
import '../widgets/navigation/library_topbar.dart';

class EnterpriseLibraryShell extends StatefulWidget {
  final LibraryController controller;
  final Widget child;

  const EnterpriseLibraryShell({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<EnterpriseLibraryShell> createState() => _EnterpriseLibraryShellState();
}

class _EnterpriseLibraryShellState extends State<EnterpriseLibraryShell> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = !AppBreakpoints.isTablet(constraints.maxWidth);
        return Scaffold(
          drawer: compact
              ? Drawer(
                  child: LibrarySidebar(
                    collapsed: false,
                    compact: false,
                    onToggle: () => Navigator.pop(context),
                    onProfiles: () => Navigator.pushReplacementNamed(context, '/profiles'),
                    bookCount: widget.controller.books.length,
                    profileCount: widget.controller.profiles.length,
                  ),
                )
              : null,
          body: Row(
            children: [
              LibrarySidebar(
                collapsed: _collapsed,
                compact: compact,
                onToggle: () => setState(() => _collapsed = !_collapsed),
                onProfiles: () => Navigator.pushReplacementNamed(context, '/profiles'),
                bookCount: widget.controller.books.length,
                profileCount: widget.controller.profiles.length,
              ),
              Expanded(
                child: Column(
                  children: [
                    Builder(
                      builder: (context) => Row(
                        children: [
                          if (compact)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: IconButton(
                                tooltip: 'Abrir navegación',
                                onPressed: () => Scaffold.of(context).openDrawer(),
                                icon: const Icon(Icons.menu_rounded),
                              ),
                            ),
                          Expanded(
                            child: LibraryTopbar(
                              profile: widget.controller.activeProfile,
                              isPremium: widget.controller.isPremium,
                              actionLoading: widget.controller.actionLoading,
                              onProfiles: () => Navigator.pushReplacementNamed(context, '/profiles'),
                              onReward: widget.controller.rewardAdWatched,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
