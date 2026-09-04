import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/feature_badge.dart';
import '../../coach/presentation/coach_page.dart';
import '../../diary/presentation/diary_page.dart';
import '../../discover/presentation/discover_page.dart';
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
    DiscoverPage(),
    CoachPage(),
    ProgressPage(),
  ];

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Heute',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_menu_rounded),
      selectedIcon: Icon(Icons.restaurant_rounded),
      label: 'Tagebuch',
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: 'Entdecken',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'Coach',
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
        final isWide = constraints.maxWidth >= 920;
        final content = AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutQuart,
          switchOutCurve: Curves.easeInQuart,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.035, 0),
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
            floatingActionButton: FloatingActionButton(
              onPressed: _showQuickAdd,
              backgroundColor: AppColors.lime,
              foregroundColor: AppColors.darkForest,
              elevation: 5,
              tooltip: 'Schnell hinzufügen',
              child: const Icon(Icons.add_rounded, size: 30),
            ),
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
                extended: constraints.maxWidth >= 1160,
                minExtendedWidth: 220,
                leading: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 24, 14, 30),
                  child: _Brand(showName: constraints.maxWidth >= 1160),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FloatingActionButton.small(
                        onPressed: _showQuickAdd,
                        backgroundColor: AppColors.lime,
                        foregroundColor: AppColors.darkForest,
                        child: const Icon(Icons.add_rounded),
                      ),
                    ),
                  ),
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

  void _showQuickAdd() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (context) => const _QuickAddSheet(),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.showName});

  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.forest, AppColors.darkForest],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.bubble_chart_rounded, color: AppColors.lime),
        ),
        if (showName) ...[
          const SizedBox(width: 10),
          const Text(
            'LIVO',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Was möchtest du hinzufügen?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Die manuelle Erfassung wird zuerst umgesetzt. KI und Kamera folgen danach.',
              ),
              const SizedBox(height: 22),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickAddTile(
                    icon: Icons.edit_note_rounded,
                    color: AppColors.lime,
                    title: 'Mahlzeit',
                    subtitle: 'Manuell eintragen',
                  ),
                  _QuickAddTile(
                    icon: Icons.search_rounded,
                    color: AppColors.sky,
                    title: 'Lebensmittel',
                    subtitle: 'Datenbank suchen',
                  ),
                  _QuickAddTile(
                    icon: Icons.qr_code_scanner_rounded,
                    color: AppColors.peach,
                    title: 'Barcode',
                    subtitle: 'Scanner · später',
                    isPreview: true,
                  ),
                  _QuickAddTile(
                    icon: Icons.photo_camera_outlined,
                    color: AppColors.lilac,
                    title: 'Foto',
                    subtitle: 'KI-Schätzung · später',
                    isPreview: true,
                  ),
                  _QuickAddTile(
                    icon: Icons.monitor_weight_outlined,
                    color: Color(0xFFFFE5A8),
                    title: 'Gewicht',
                    subtitle: 'Fortschritt notieren',
                  ),
                  _QuickAddTile(
                    icon: Icons.water_drop_outlined,
                    color: AppColors.mint,
                    title: 'Wasser',
                    subtitle: 'Glas hinzufügen',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.isPreview = false,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 52).clamp(145.0, 210.0);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$title ist als nächster Funktionsschritt vorbereitet.',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.ink, size: 21),
                ),
                if (isPreview) ...[
                  const Spacer(),
                  const FeatureBadge(label: 'BALD'),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
