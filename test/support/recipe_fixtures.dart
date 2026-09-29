import 'package:fitness_ai_app/core/models/app_models.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:fitness_ai_app/features/subscription/domain/entitlement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Account with an active Plus subscription, without network access.
class PlusSubscriptionRepository implements SubscriptionRepository {
  const PlusSubscriptionRepository();

  @override
  Future<Entitlement> loadEntitlement() async =>
      const Entitlement.subscription();

  @override
  Future<TrialStartResult> startTrial() async =>
      const TrialStartResult(TrialStartStatus.alreadyPremium);
}

Future<AppController> recipeTestController({required bool plus}) async {
  final controller = AppController(
    subscriptionRepository: plus
        ? const PlusSubscriptionRepository()
        : const PreviewSubscriptionRepository(),
  );
  await controller.subscription.load();
  return controller;
}

void setTestScreen(WidgetTester tester, Size size, {double textScale = 1}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

Widget recipeTestApp(AppController controller, Widget home) => AppScope(
  controller: controller,
  child: MaterialApp(theme: AppTheme.dark, home: home),
);

const curryTips = [
  'Die Zwiebel wirklich glasig werden lassen, nicht bräunen.',
  'Gewürze nur kurz rösten, sonst werden sie bitter.',
  'Kichererbsen vorher gut abspülen, dann schäumt nichts.',
  'Nur leicht köcheln lassen, damit die Kokosmilch nicht ausflockt.',
  'Den Spinat erst ganz am Ende unterheben.',
  '',
];

const curryRecipe = Recipe(
  id: 'test-chickpea-curry',
  slug: 'kichererbsen-curry',
  title: 'Kichererbsen-Curry mit Spinat',
  subtitle: 'Cremiges Curry mit Kokosmilch, Spinat und Reis.',
  minutes: 35,
  prepMinutes: 10,
  cookMinutes: 25,
  difficulty: 'Mittel',
  servings: 2,
  calories: 540,
  protein: 21,
  nutritionPerServing: RecipeNutrition(
    calories: 540,
    protein: 21,
    carbohydrates: 68,
    fat: 19,
    fiber: 12,
    sugar: 9,
    salt: 1.4,
  ),
  imageAsset: 'assets/images/recipes/kichererbsen-curry.webp',
  tags: ['Für dich', 'Abendessen', 'Vegetarisch', 'Vegan'],
  equipment: ['Großer Topf mit Deckel', 'Schneidebrett'],
  ingredients: [
    RecipeIngredient(
      foodId: 'f1',
      name: 'Kichererbsen, abgetropft',
      amountGrams: 240,
      measure: '1 Dose',
      nutrition: RecipeNutrition(
        calories: 290,
        protein: 17,
        carbohydrates: 40,
        fat: 5,
      ),
    ),
    RecipeIngredient(
      foodId: 'f2',
      name: 'Olivenöl',
      amountGrams: 10,
      measure: '1 EL',
      nutrition: RecipeNutrition(calories: 88, protein: 0, fat: 10),
    ),
    RecipeIngredient(
      foodId: 'f3',
      name: 'Zwiebel',
      amountGrams: 80,
      measure: '1 Zwiebel',
      note: 'fein gewürfelt',
    ),
    RecipeIngredient(foodId: 'f4', name: 'Babyspinat', amountGrams: 100),
  ],
  steps: [
    RecipeStep(
      title: 'Zwiebel anschwitzen',
      text:
          'Das Öl im Topf bei mittlerer Hitze erwärmen. Die Zwiebel darin '
          'unter Rühren etwa 4 Minuten glasig dünsten.',
      minutes: 4,
    ),
    RecipeStep(
      title: 'Gewürze rösten',
      text:
          'Currypulver und Kreuzkümmel zugeben und 1 Minute mitrösten, bis '
          'es duftet. Dabei ständig rühren.',
      minutes: 1,
    ),
    RecipeStep(
      title: 'Kichererbsen zugeben',
      text:
          'Die abgespülten Kichererbsen unterrühren. Mit Kokosmilch ablöschen '
          'und alles einmal aufkochen lassen.',
    ),
    RecipeStep(
      title: 'Köcheln lassen',
      text:
          'Die Hitze reduzieren und das Curry mit Deckel 15 Minuten leise '
          'köcheln lassen. Gelegentlich umrühren.',
      minutes: 15,
    ),
    RecipeStep(
      title: 'Spinat unterheben',
      text:
          'Den Spinat unterheben und 1 bis 2 Minuten zusammenfallen lassen. '
          'Mit Salz und Zitronensaft abschmecken.',
      minutes: 2,
    ),
    RecipeStep(
      title: 'Anrichten',
      text: 'Das Curry mit Reis in Schalen anrichten und sofort servieren.',
    ),
  ],
  premiumDetails: RecipePremiumDetails(
    stepTips: curryTips,
    commonMistakes: ['Die Kokosmilch sprudelnd kochen lassen.'],
    substitutions: ['Spinat durch Grünkohl ersetzen.'],
    mealPrep: 'Hält sich im Kühlschrank drei Tage.',
    variations: ['Mit Süßkartoffelwürfeln.'],
    servingTip: 'Mit frischem Koriander servieren.',
  ),
);
