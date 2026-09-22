import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/animations.dart';
import '../widgets/animated_fab.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/brutal_drawer.dart';
import '../widgets/brutal_bottom_sheet.dart';
import 'add_expense_screen.dart';
import 'home_screen.dart';
import 'stats_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  // Stats is built on first visit so its entrance plays where it can be
  // seen, instead of offstage at launch inside the IndexedStack.
  bool _statsVisited = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    HapticFeedback.mediumImpact();
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openBottomSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) =>
            BrutalBottomSheet(scrollController: scrollController),
      ),
    );
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) _statsVisited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // BrutalDrawer pops itself before invoking these — don't pop again,
      // that would pop MainShell off the root navigator (black screen).
      drawer: BrutalDrawer(
        onNavigateToHome: () => _navigateToTab(0),
        onNavigateToStats: () => _navigateToTab(1),
        onNavigateToBudget: _openBottomSheet,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onMenuTap: _openDrawer),
          _statsVisited
              ? StatsScreen(
                  key: const ValueKey('stats'),
                  onMenuTap: _openDrawer,
                )
              : const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: AnimatedFAB(
        onTap: () {
          Navigator.push(
            context,
            SlidePageTransition(page: const AddExpenseScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onMenuTap: _openDrawer,
        onOptionsTap: _openBottomSheet,
        onTap: _navigateToTab,
      ),
    );
  }
}
