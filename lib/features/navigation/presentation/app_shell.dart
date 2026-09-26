import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/state/app_controller.dart';
import '../../../shared/widgets/ui_components.dart';
import '../../coach/presentation/coach_page.dart';
import '../../discover/presentation/discover_page.dart';
import '../../home/presentation/home_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../diary/presentation/quick_add_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final PageController _pageController;
  late DateTime _observedDiaryDay;
  Timer? _midnightTimer;

  static const _items = [
    _NavItem(Icons.menu_book_outlined, Icons.menu_book_rounded, 'Tagebuch'),
    _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome_rounded, 'KI'),
    _NavItem(
      Icons.restaurant_menu_outlined,
      Icons.restaurant_menu_rounded,
      'Rezepte',
    ),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  static const _addNavIndex = 2;

  static int _pageToNav(int page) => page >= _addNavIndex ? page + 1 : page;
  static int _navToPage(int nav) => nav > _addNavIndex ? nav - 1 : nav;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _observedDiaryDay = _dateOnly(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = AppScope.of(context);
      unawaited(controller.loadRemoteProfile());
      unawaited(controller.loadRemoteCatalog());
      unawaited(controller.loadRemoteDiary());
      unawaited(controller.loadRemoteFavorites());
      unawaited(controller.loadFoodPreferences());
      unawaited(controller.loadTrackingStreak());
      unawaited(controller.loadReminderPreferences());
      _scheduleNextDayRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshForNewDay());
    }
  }

  void _scheduleNextDayRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextDay.difference(now) + const Duration(seconds: 1),
      () {
        unawaited(_refreshForNewDay());
        _scheduleNextDayRefresh();
      },
    );
  }

  Future<void> _refreshForNewDay() async {
    final today = _dateOnly(DateTime.now());
    if (_sameDay(today, _observedDiaryDay) || !mounted) return;
    _observedDiaryDay = today;
    final controller = AppScope.of(context);
    await Future.wait([
      controller.loadRemoteDiary(today),
      controller.loadTrackingStreak(),
    ]);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpenPage: _selectPage),
      const CoachPage(),
      const DiscoverPage(),
      const ProfilePage(),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 960;
              final pageView = PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) =>
                    setState(() => _selectedIndex = index),
                children: pages,
              );

              if (desktop) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: AppBackdrop(
                    child: Row(
                      children: [
                        _DesktopNavigation(
                          selectedIndex: _selectedIndex,
                          onSelected: _selectPage,
                        ),
                        Container(
                          width: 1,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.borderBright,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: SafeArea(child: pageView)),
                      ],
                    ),
                  ),
                );
              }

              return Scaffold(
                backgroundColor: Colors.transparent,
                extendBody: true,
                body: AppBackdrop(
                  child: SafeArea(bottom: false, child: pageView),
                ),
                bottomNavigationBar: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(10, 0, 10, 9),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.borderBright),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.42),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.035),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: NavigationBar(
                      selectedIndex: _pageToNav(_selectedIndex),
                      onDestinationSelected: (index) {
                        if (index == _addNavIndex) {
                          showQuickAddSheet(context);
                        } else {
                          _selectPage(_navToPage(index));
                        }
                      },
                      destinations: [
                        for (var i = 0; i < _items.length; i++) ...[
                          if (i == _addNavIndex)
                            const NavigationDestination(
                              key: Key('nav-quick-add'),
                              icon: _AddNavIcon(),
                              label: 'Hinzufügen',
                              tooltip: 'Mahlzeit hinzufügen',
                            ),
                          NavigationDestination(
                            icon: Icon(_items[i].icon),
                            selectedIcon: TweenAnimationBuilder<double>(
                              key: ValueKey('${_items[i].label}-selected'),
                              tween: Tween(begin: 0.88, end: 1),
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) =>
                                  Transform.scale(scale: value, child: child),
                              child: Icon(_items[i].selectedIcon),
                            ),
                            label: _items[i].label,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _selectPage(int index) {
    if (index == _selectedIndex) return;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || (index - _selectedIndex).abs() > 1) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 310),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceHigh, AppColors.backgroundRaised],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Brand(),
          const SizedBox(height: 12),
          const Text(
            'Dein Alltag. Dein Rhythmus.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            key: const Key('desktop-quick-add'),
            onPressed: () => showQuickAddSheet(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Hinzufügen'),
          ),
          const SizedBox(height: 18),
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
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.mint],
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary,
                blurRadius: 18,
                spreadRadius: -8,
              ),
            ],
          ),
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(Icons.eco_rounded, color: AppColors.black),
          ),
        ),
        const SizedBox(width: 11),
        const Text(
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
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.22)
                  : Colors.transparent,
            ),
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

class _AddNavIcon extends StatelessWidget {
  const _AddNavIcon();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.mint],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: .35),
          blurRadius: 14,
          spreadRadius: -4,
        ),
      ],
    ),
    child: const SizedBox.square(
      dimension: 40,
      child: Icon(Icons.add_rounded, color: AppColors.black, size: 28),
    ),
  );
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
