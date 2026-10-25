import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/profile/presentation/avatar_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the profile picture asks before the photos open', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.reset);
    final controller = AppController();
    addTearDown(controller.dispose);
    var opened = 0;
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: AvatarEditor(
              controller: controller,
              pickPhoto: () async {
                opened++;
                return null;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('avatar-select')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-access-dialog')), findsOneWidget);
    expect(find.text('Fotos öffnen?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('photo-access-cancel')));
    await tester.pumpAndSettle();
    expect(opened, 0);
    expect(find.byKey(const Key('photo-access-dialog')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('avatar-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('photo-access-open')));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.byKey(const ValueKey('avatar-select')), findsOneWidget);
  });
}
