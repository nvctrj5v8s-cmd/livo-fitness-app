import 'package:fitness_ai_app/features/discover/data/planning_store.dart';
import 'package:fitness_ai_app/features/discover/domain/kitchen_planning.dart';

/// Planning store without device storage, with optional failures.
class MemoryPlanningStore implements PlanningStore {
  MemoryPlanningStore({this.failLoad = false, this.failSave = false});

  final bool failLoad;
  final bool failSave;
  final Map<String, KitchenState> saved = {};
  int saveCount = 0;

  @override
  Future<KitchenState?> load(String userId) async {
    if (failLoad) throw const FormatException('kaputt');
    return saved[userId];
  }

  @override
  Future<void> save(String userId, KitchenState state) async {
    if (failSave) throw StateError('voll');
    saveCount++;
    saved[userId] = state;
  }

  @override
  Future<void> clear(String userId) async => saved.remove(userId);
}
