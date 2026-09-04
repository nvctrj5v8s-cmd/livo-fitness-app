import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../coach/presentation/coach_page.dart';
import '../../diary/presentation/diary_page.dart';
import '../../home/presentation/home_page.dart';
import '../../progress/presentation/progress_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    HomePage(),
    DiaryPage(),
    CoachPage(),
    ProgressPage(),
  ];

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.grid_view_rounded),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'Heute',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_menu_rounded),
      selectedIcon: Icon(Icons.restaurant_rounded),
      label: 'Ernährung',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'KI-Coach',
    ),
    NavigationDestination(
      icon: Icon(Icons.show_chart_rounded),
      selectedIcon: Icon(Icons.insights_rounded),
      label: 'Fortschritt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        final content = AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.025, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _pages[_selectedIndex],
          ),
        );

        if (!isWide) {
          return Scaffold(
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectPage,
              destinations: _destinations,
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                backgroundColor: AppColors.white,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _selectPage,
                extended: constraints.maxWidth >= 1080,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: _BrandMark(),
                ),
                destinations: _destinations
                    .map(
                      (item) => NavigationRailDestination(
                        icon: item.icon,
                        selectedIcon: item.selectedIcon,
                        label: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
              Expanded(child: content),
            ],
          ),
        );
      },
    );
  }

  void _selectPage(int index) => setState(() => _selectedIndex = index);
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.eco_rounded, color: AppColors.lime),
    );
  }
}
