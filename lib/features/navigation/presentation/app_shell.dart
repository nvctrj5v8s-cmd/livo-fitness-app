import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/state/app_controller.dart';
import '../../diary/presentation/add_meal_sheet.dart';
import '../../diary/presentation/diary_page.dart';
import '../../discover/presentation/discover_page.dart';
import '../../home/presentation/home_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../progress/presentation/progress_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Heute'),
    _NavItem(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Tagebuch'),
    _NavItem(
      Icons.restaurant_menu_outlined,
      Icons.restaurant_menu_rounded,
      'Rezepte',
    ),
    _NavItem(Icons.insights_outlined, Icons.insights_rounded, 'Fortschritt'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AppScope.of(context).loadRemoteCatalog());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpenPage: _selectPage),
      DiaryPage(onAddMeal: () => showAddMealSheet(context)),
      const DiscoverPage(),
      const ProgressPage(),
      const ProfilePage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 960;
        final pageView = PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          children: pages,
        );

        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopNavigation(
                  selectedIndex: _selectedIndex,
                  onSelected: _selectPage,
                  onAdd: () => showAddMealSheet(context),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pageView),
              ],
            ),
          );
        }

        return Scaffold(
          body: pageView,
          floatingActionButton: FloatingActionButton(
            onPressed: () => showAddMealSheet(context),
            tooltip: 'Mahlzeit hinzufügen',
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.black,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.add_rounded, size: 29),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectPage,
              destinations: _items
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void _selectPage(int index) {
    if (index == _selectedIndex) return;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Brand(),
          const SizedBox(height: 34),
          for (var index = 0; index < _AppShellState._items.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: _DesktopNavButton(
                item: _AppShellState._items[index],
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Mahlzeit hinzufügen'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(Icons.eco_rounded, color: AppColors.black),
          ),
        ),
        SizedBox(width: 11),
        Text(
          'LIVO',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.3,
          ),
        ),
      ],
    );
  }
}

class _DesktopNavButton extends StatelessWidget {
  const _DesktopNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.11)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.text : AppColors.textMuted,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
